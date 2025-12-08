# deliveries/services.py

import logging
from decimal import Decimal
from typing import Optional, List
from datetime import timedelta
from django.db import transaction
from django.utils import timezone
from django.core.exceptions import ValidationError
from geopy.distance import geodesic
from django.db.models import Count, Q
from .models import Delivery
from apps.drivers.models import Driver, DriverZone
from apps.notifications.models import Notification
from apps.notifications.services import (
    notify_new_delivery_assignment,
    notify_delivery_accepted,
    notify_delivery_rejected,
    notify_delivery_status_change
)

from django.db.models import Sum
from apps.payments.models import Invoice


def compute_delivery_stats(qs, period_days=30, merchant=None):
    """Compute aggregated delivery stats for a queryset of Delivery objects.

    If `merchant` is provided, invoice-related aggregates will be computed for that merchant.
    Returns a dict with keys: deliveries, revenue, invoices
    """
    from django.utils import timezone
    from datetime import timedelta

    period_start = timezone.now() - timedelta(days=period_days)

    total_all_time = qs.count()
    # Number of deliveries created in the period
    period_created_qs = qs.filter(created_at__gte=period_start)
    period_total = period_created_qs.count()

    # Use event timestamps for delivered/cancelled counts to reflect actual completions
    delivered = qs.filter(status='delivered', delivered_at__gte=period_start).count()
    in_progress = qs.filter(status='in_progress').count()
    pending = qs.filter(status='pending').count()
    cancelled = qs.filter(status='cancelled', cancelled_at__gte=period_start).count()

    try:
        denom = delivered + cancelled
        success_rate = (delivered / denom * 100) if denom > 0 else 0
    except Exception:
        success_rate = 0

    # revenue: sum of calculated_price for period deliveries
    period_revenue = period_qs.filter(status='delivered').aggregate(total=Sum('calculated_price'))['total'] or 0
    total_billed = 0
    paid_amount = 0
    pending_amount = 0
    invoices_count = 0
    invoices_paid_count = 0
    invoices_pending_count = 0

    if merchant is not None:
        try:
            inv_qs = Invoice.objects.filter(merchant=merchant)
            period_invoices = inv_qs.filter(created_at__gte=period_start)
            total_billed = period_invoices.aggregate(total=Sum('total_amount'))['total'] or 0
            paid_amount = period_invoices.filter(status='paid').aggregate(total=Sum('total_amount'))['total'] or 0
            pending_amount = period_invoices.filter(status='sent').aggregate(total=Sum('total_amount'))['total'] or 0
            invoices_count = period_invoices.count()
            invoices_paid_count = period_invoices.filter(status='paid').count()
            invoices_pending_count = period_invoices.filter(status='sent').count()
        except Exception:
            # if Invoice model or queries fail, keep invoice-related zeros
            pass

    return {
        'period_days': period_days,
        'deliveries': {
            'total_all_time': total_all_time,
            'period_total': period_total,
            'delivered': delivered,
            'in_progress': in_progress,
            'pending': pending,
            'cancelled': cancelled,
            'success_rate': round(success_rate, 2),
        },
        'revenue': {
            'period_revenue': period_revenue,
            'total_billed': total_billed,
            'paid': paid_amount,
            'pending_payment': pending_amount,
        },
        'invoices': {
            'total': invoices_count,
            'paid': invoices_paid_count,
            'pending': invoices_pending_count,
        }
    }

logger = logging.getLogger(__name__)


class DeliveryAssignmentService:
    """
    Service gérant l'assignation des livreurs aux livraisons.
    Fournit des méthodes pour l'assignation manuelle et automatique.
    """
    
    def __init__(self):
        self.logger = logger
    
    # =========================================================================
    # ASSIGNATION MANUELLE (PAR L'ADMIN)
    # =========================================================================
    
    @transaction.atomic
    def assign_driver_manually(self, delivery_id, driver_id, assigned_by_user):
        """
        Assigne manuellement un livreur à une livraison.
        Utilisé par les administrateurs.
        
        Args:
            delivery_id: UUID de la livraison
            driver_id: UUID du livreur
            assigned_by_user: User qui fait l'assignation (admin)
            
        Returns:
            dict: Résultat de l'assignation avec détails
            
        Raises:
            ValidationError: Si l'assignation est impossible
        """
        try:
            # 1. Récupérer la livraison
            delivery = Delivery.objects.select_for_update().get(id=delivery_id)
            
            # 2. Vérifications de statut
            if delivery.status not in ['pending']:
                raise ValidationError(
                    f"Impossible d'assigner : statut actuel '{delivery.status}'"
                )
            
            # 3. Récupérer le livreur
            driver = Driver.objects.select_related('user').get(id=driver_id)
            
            # 4. Vérifications du livreur
            if driver.verification_status != 'verified':
                raise ValidationError(
                    f"Le livreur {driver.user.full_name} n'est pas vérifié"
                )
            
            if not driver.is_available:
                raise ValidationError(
                    f"Le livreur {driver.user.full_name} n'est pas disponible"
                )
            
            # 5. Vérifier la capacité du véhicule
            if delivery.package_weight_kg > driver.vehicle_capacity_kg:
                raise ValidationError(
                    f"Le colis ({delivery.package_weight_kg} kg) dépasse "
                    f"la capacité du véhicule ({driver.vehicle_capacity_kg} kg)"
                )
            
            # 6. Assigner le livreur
            old_driver = delivery.driver
            delivery.driver = driver
            delivery.status = 'in_progress'
            delivery.assigned_at = timezone.now()
            delivery.save()
            
            # 7. Créer une notification pour le livreur
            self._create_assignment_notification(delivery, driver)
            
            # 8. Logger l'action
            self.logger.info(
                f"✅ Assignation manuelle réussie | "
                f"Delivery: {delivery.tracking_number} | "
                f"Driver: {driver.user.full_name} | "
                f"Assigned by: {assigned_by_user.email}"
            )
            
            return {
                'success': True,
                'delivery_id': str(delivery.id),
                'tracking_number': delivery.tracking_number,
                'driver_name': driver.user.full_name,
                'driver_phone': driver.user.phone,
                'previous_driver': old_driver.user.full_name if old_driver else None,
                'assigned_at': delivery.assigned_at.isoformat()
            }
            
        except Delivery.DoesNotExist:
            raise ValidationError("Livraison introuvable")
        except Driver.DoesNotExist:
            raise ValidationError("Livreur introuvable")
        except Exception as e:
            self.logger.error(f"❌ Erreur assignation manuelle: {str(e)}", exc_info=True)
            raise ValidationError(f"Erreur lors de l'assignation: {str(e)}")
    
    # =========================================================================
    # ASSIGNATION AUTOMATIQUE (ALGORITHME INTELLIGENT)
    # =========================================================================
    
    @transaction.atomic
    def assign_driver_automatically(self, delivery_id):
        """
        Assigne automatiquement le meilleur livreur disponible.
        
        Critères de sélection (par priorité) :
        1. Livreur vérifié et disponible
        2. Travaille dans la zone de livraison
        3. Capacité du véhicule suffisante
        4. Meilleur rating
        5. Moins de livraisons en cours
        6. Plus proche géographiquement (si GPS disponible)
        
        Args:
            delivery_id: UUID de la livraison
            
        Returns:
            dict: Résultat de l'assignation
            
        Raises:
            ValidationError: Si aucun livreur disponible
        """
        try:
            # 1. Récupérer la livraison
            delivery = Delivery.objects.select_for_update().get(id=delivery_id)
            
            # 2. Vérifier le statut (tolérance pour anciennes valeurs)
            if delivery.status not in ['pending_assignment', 'pending']:
                raise ValidationError(
                    f"Statut invalide pour auto-assignation: {delivery.status}"
                )
            
            # 3. Trouver le meilleur livreur
            best_driver = self._find_best_driver(delivery)
            
            if not best_driver:
                raise ValidationError(
                    f"Aucun livreur disponible pour la zone '{delivery.delivery_commune}'"
                )
            
            # 4. Assigner
            delivery.driver = best_driver
            # Utiliser le statut normalisé 'in_progress' pour indiquer qu'un driver a
            # été choisi et que la livraison est en cours de traitement.
            delivery.status = 'in_progress'
            delivery.assigned_at = timezone.now()
            delivery.save()
            
            # 5. Notification
            self._create_assignment_notification(delivery, best_driver)
            
            # 6. Logger
            self.logger.info(
                f"🤖 Auto-assignation réussie | "
                f"Delivery: {delivery.tracking_number} | "
                f"Driver: {best_driver.user.full_name} | "
                f"Zone: {delivery.delivery_commune}"
            )
            
            return {
                'success': True,
                'delivery_id': str(delivery.id),
                'tracking_number': delivery.tracking_number,
                'driver_name': best_driver.user.full_name,
                'driver_phone': best_driver.user.phone,
                'driver_rating': float(best_driver.rating),
                'assigned_at': delivery.assigned_at.isoformat()
            }
            
        except Delivery.DoesNotExist:
            raise ValidationError("Livraison introuvable")
        except Exception as e:
            self.logger.error(f"❌ Erreur auto-assignation: {str(e)}", exc_info=True)
            raise
    
    # =========================================================================
    # MÉTHODES PRIVÉES - ALGORITHME DE SÉLECTION
    # =========================================================================
    
    
    # =========================================================================
    # RÉASSIGNATION (CHANGEMENT DE LIVREUR)
    # =========================================================================
    
    @transaction.atomic
    def reassign_delivery(self, delivery_id, new_driver_id, reason=""):
        """
        Réassigne une livraison à un autre livreur.
        
        Args:
            delivery_id: UUID de la livraison
            new_driver_id: UUID du nouveau livreur
            reason: Raison de la réassignation
            
        Returns:
            dict: Résultat de la réassignation
        """
        try:
            delivery = Delivery.objects.select_for_update().get(id=delivery_id)
            
            if delivery.status not in ['assigned', 'pickup_in_progress', 'in_progress']:
                raise ValidationError(
                    "Impossible de réassigner : livraison déjà en cours ou terminée"
                )
            
            old_driver = delivery.driver
            new_driver = Driver.objects.get(id=new_driver_id)
            
            # Vérifications
            if new_driver.verification_status != 'verified':
                raise ValidationError("Le nouveau livreur n'est pas vérifié")
            
            if not new_driver.is_available:
                raise ValidationError("Le nouveau livreur n'est pas disponible")
            
            # Réassigner
            delivery.driver = new_driver
            delivery.assigned_at = timezone.now()
            delivery.save()
            
            # Notifications
            self._create_reassignment_notification(delivery, old_driver, new_driver, reason)
            
            self.logger.info(
                f"🔄 Réassignation | Delivery: {delivery.tracking_number} | "
                f"De: {old_driver.user.full_name} → À: {new_driver.user.full_name} | "
                f"Raison: {reason or 'Non spécifiée'}"
            )
            
            return {
                'success': True,
                'delivery_id': str(delivery.id),
                'old_driver': old_driver.user.full_name,
                'new_driver': new_driver.user.full_name,
                'reason': reason
            }
            
        except (Delivery.DoesNotExist, Driver.DoesNotExist) as e:
            raise ValidationError(str(e))
    
    # =========================================================================
    # ACCEPTATION/REFUS PAR LE LIVREUR
    def _find_best_driver(self, delivery):
        """
        Trouve le meilleur livreur pour une livraison donnée, en privilégiant la proximité GPS.
        Returns:
            Driver: Meilleur livreur ou None
        """
        # 1. Livreurs de base (vérifiés + disponibles + capacité suffisante)
        base_query = Driver.objects.filter(
            verification_status='verified',
            is_available=True,
            vehicle_capacity_kg__gte=delivery.package_weight_kg
        ).select_related('user')
        # 1b. Filtrer par type de véhicule si requis
        if hasattr(delivery, 'required_vehicle_type') and delivery.required_vehicle_type:
            base_query = base_query.filter(vehicle_type=delivery.required_vehicle_type)

        # 2. Filtrer par zone (prioritaire)
        drivers_in_zone = base_query.filter(
            zones__commune__iexact=delivery.delivery_commune
        ).distinct()

        if not drivers_in_zone.exists():
            # Fallback : Prendre tous les livreurs disponibles
            self.logger.warning(
                f"⚠️ Aucun livreur dans la zone '{delivery.delivery_commune}', "
                f"recherche élargie"
            )
            drivers_in_zone = base_query

        # 3. Annoter avec le nombre de livraisons en cours (inclut anciennes valeurs)
        drivers_with_stats = drivers_in_zone.annotate(
            active_deliveries_count=Count(
                'deliveries',
                filter=Q(
                    deliveries__status__in=[
                        'in_progress', 'assigned', 'pickup_in_progress', 'picked_up', 'in_transit'
                    ]
                )
            )
        )

        # 4. Calculer la distance réelle pour chaque driver (si GPS dispo)
        # Utiliser la méthode utilitaire Delivery.get_coords pour normaliser l'accès
        pickup_coords = delivery.get_coords('pickup')

        driver_distance_list = []
        for driver in drivers_with_stats:
            distance_km = None
            if pickup_coords and driver.current_latitude is not None and driver.current_longitude is not None:
                try:
                    driver_coords = (float(driver.current_latitude), float(driver.current_longitude))
                    distance_km = geodesic(driver_coords, pickup_coords).km
                except Exception as e:
                    self.logger.warning(f"Erreur calcul distance GPS pour {driver.user.full_name}: {e}")
            driver_distance_list.append({
                'driver': driver,
                'distance_km': distance_km,
                'active_deliveries_count': driver.active_deliveries_count,
                'rating': driver.rating or 0,
                'successful_deliveries': getattr(driver, 'successful_deliveries', 0)
            })

        # 5. Trier par distance (si dispo), puis par critères classiques
        def sort_key(item):
            # Priorité: distance (si connue), puis charge, rating, expérience
            return (
                item['distance_km'] if item['distance_km'] is not None else float('inf'),
                item['active_deliveries_count'],
                -float(item['rating']),
                -int(item['successful_deliveries'])
            )

        driver_distance_list.sort(key=sort_key)

        best = driver_distance_list[0]['driver'] if driver_distance_list else None
        if best:
            self.logger.debug(
                f"🎯 Meilleur driver trouvé: {best.user.full_name} | "
                f"Distance: {driver_distance_list[0]['distance_km']} km | "
                f"Rating: {best.rating} | "
                f"Livraisons actives: {driver_distance_list[0]['active_deliveries_count']}"
            )
        return best
    # =========================================================================
    
    @transaction.atomic
    def driver_accept_delivery(self, delivery_id, driver):
        """
        Le livreur accepte une livraison.
        Peut accepter une livraison en 'pending_assignment' (auto-assignation) ou 'assigned'.
        
        Args:
            delivery_id: UUID de la livraison
            driver: Instance du Driver
            
        Returns:
            dict: Confirmation d'acceptation
        """
        try:
            delivery = Delivery.objects.select_for_update().get(id=delivery_id)
            
            # Vérifier que le driver est vérifié
            if driver.verification_status != 'verified':
                raise ValidationError("Votre compte n'est pas encore vérifié. Veuillez attendre la validation de votre profil.")
            
            # Vérifier que le driver est disponible
            if not driver.is_available:
                raise ValidationError("Vous devez être en ligne (disponible) pour accepter une livraison. Veuillez passer en mode 'Disponible' dans votre profil.")
            
            # Gérer selon le statut actuel
            # Acceptation depuis la liste 'available_deliveries' utilise le statut
            # 'pending' dans l'API drivers.available_deliveries. Pour être tolérant
            # nous acceptons aussi 'pending' comme cas d'auto-assignation ici.
            if delivery.status in ['pending_assignment', 'pending']:
                # Vérifier que la livraison est dans les zones du driver (si zones définies)
                try:
                    driver_zones = DriverZone.objects.filter(driver=driver).values_list('commune', flat=True)
                except Exception:
                    driver_zones = []

                if driver_zones:
                    # compare insensible à la casse
                    # Use pickup_commune here to match the logic used in drivers.available_deliveries
                    if not any((delivery.pickup_commune or '').lower() == z.lower() for z in driver_zones):
                        raise ValidationError("Cette livraison n'est pas dans votre zone de travail")

                # Vérifier la capacité du véhicule
                if delivery.package_weight_kg and delivery.package_weight_kg > driver.vehicle_capacity_kg:
                    raise ValidationError(
                        f"Le colis ({delivery.package_weight_kg} kg) dépasse la capacité de votre véhicule ({driver.vehicle_capacity_kg} kg)"
                    )

                # Vérifier dimensions si présentes
                max_dims = driver.max_package_dimensions
                if getattr(delivery, 'package_length_cm', None) is not None:
                    if delivery.package_length_cm is not None and delivery.package_length_cm > max_dims['length']:
                        raise ValidationError("Les dimensions du colis dépassent la capacité de votre véhicule")
                if getattr(delivery, 'package_width_cm', None) is not None:
                    if delivery.package_width_cm is not None and delivery.package_width_cm > max_dims['width']:
                        raise ValidationError("Les dimensions du colis dépassent la capacité de votre véhicule")

                # Auto-assignation : le driver accepte une livraison non encore assignée
                # Set to 'assigned' so the driver still needs to confirm pickup (signature/PIN)
                delivery.driver = driver
                delivery.status = 'assigned'
                delivery.assigned_at = timezone.now()
            elif delivery.status == 'assigned':
                # Acceptation normale : la livraison était déjà assignée à ce driver
                if delivery.driver != driver:
                    raise ValidationError("Cette livraison est assignée à un autre driver")
                delivery.status = 'in_progress'
            else:
                raise ValidationError(f"Impossible d'accepter une livraison en statut '{delivery.status}'")
            
            # Passer au statut suivant (déjà défini ci-dessus)
            delivery.save()
            
            # Notifier le merchant (DB) if present; guard against missing merchant
            merchant = getattr(delivery, 'merchant', None)
            if merchant is None:
                # Data inconsistency: delivery without merchant — log and skip merchant notifications
                self.logger.error(
                    f"Delivery {delivery.id} has no merchant attached; skipping merchant notifications"
                )
            else:
                try:
                    Notification.objects.create(
                        user=merchant.user,
                        notification_type='delivery_update',
                        title='Livreur en route',
                        message=f"Le livreur {driver.user.full_name} est en route pour récupérer votre colis {delivery.tracking_number}",
                        related_entity_type='delivery',
                        related_entity_id=delivery.id
                    )
                except Exception as e:
                    self.logger.exception(f"Failed to create DB notification for merchant on delivery {delivery.id}: {e}")

                # 🔔 Notification push FCM au merchant
                try:
                    notify_delivery_accepted(merchant, delivery)
                except Exception as e:
                    self.logger.exception(f"Failed to send push notification to merchant for delivery {delivery.id}: {e}")
            
            self.logger.info(
                f"✅ Livraison acceptée | {delivery.tracking_number} | "
                f"Driver: {driver.user.full_name}"
            )
            
            return {
                'success': True,
                'message': 'Livraison acceptée avec succès',
                'new_status': 'in_progress'
            }
            
        except Delivery.DoesNotExist:
            raise ValidationError("Livraison introuvable")
    
    @transaction.atomic
    def driver_reject_delivery(self, delivery_id, driver, reason):
        """
        Le livreur refuse une livraison.
        La livraison retourne en pending_assignment pour réassignation.
        
        Args:
            delivery_id: UUID de la livraison
            driver: Instance du Driver
            reason: Raison du refus
            
        Returns:
            dict: Confirmation de refus
        """
        try:
            delivery = Delivery.objects.select_for_update().get(id=delivery_id)
            
            if delivery.driver != driver:
                raise ValidationError("Cette livraison n'est pas assignée à vous")
            
            if delivery.status not in ['assigned', 'pickup_in_progress', 'in_progress']:
                raise ValidationError("Impossible de refuser cette livraison")
            
            # Retirer l'assignation
            old_driver = delivery.driver
            merchant = delivery.merchant
            delivery.driver = None
            # Normaliser vers le statut actuel 'pending'
            delivery.status = 'pending'
            delivery.assigned_at = None
            delivery.save()
            
            # Notifier le merchant (DB) if present; guard against missing merchant
            if merchant is None:
                self.logger.error(f"Delivery {delivery.id} has no merchant attached; skipping merchant notifications on reject")
            else:
                try:
                    Notification.objects.create(
                        user=merchant.user,
                        notification_type='delivery_update',
                        title='Livraison refusée',
                        message=f"Le livreur a refusé la livraison {delivery.tracking_number}. Recherche d'un autre livreur...",
                        related_entity_type='delivery',
                        related_entity_id=delivery.id
                    )
                except Exception as e:
                    self.logger.exception(f"Failed to create DB notification for merchant on delivery reject {delivery.id}: {e}")

                # 🔔 Notification push FCM au merchant
                try:
                    notify_delivery_rejected(merchant, delivery)
                except Exception as e:
                    self.logger.exception(f"Failed to send push notification to merchant for delivery reject {delivery.id}: {e}")
            
            # Notifier l'admin
            from apps.authentication.models import User
            admins = User.objects.filter(user_type='admin')
            for admin in admins:
                Notification.objects.create(
                    user=admin,
                    notification_type='delivery_update',
                    title='Livraison refusée par livreur',
                    message=f"{driver.user.full_name} a refusé la livraison {delivery.tracking_number}. Raison: {reason}",
                    related_entity_type='delivery',
                    related_entity_id=delivery.id
                )
            
            self.logger.warning(
                f"❌ Livraison refusée | {delivery.tracking_number} | "
                f"Driver: {driver.user.full_name} | Raison: {reason}"
            )
            
            return {
                'success': True,
                'message': 'Livraison refusée',
                'new_status': 'pending'
            }
            
        except Delivery.DoesNotExist:
            raise ValidationError("Livraison introuvable")
    
    # =========================================================================
    # MÉTHODES UTILITAIRES - NOTIFICATIONS
    # =========================================================================
    
    def _create_assignment_notification(self, delivery, driver):
        """Crée une notification pour le livreur nouvellement assigné"""
        # Notification dans la DB
        Notification.objects.create(
            user=driver.user,
            notification_type='delivery_assignment',
            title='Nouvelle livraison assignée',
            message=f"Vous avez été assigné à la livraison {delivery.tracking_number}. "
                    f"Destination: {delivery.delivery_commune}, {delivery.delivery_quartier}",
            related_entity_type='delivery',
            related_entity_id=delivery.id
        )
        
        # 🔔 Notification push FCM
        notify_new_delivery_assignment(driver, delivery)
    
    def _create_reassignment_notification(self, delivery, old_driver, new_driver, reason):
        """Crée des notifications lors d'une réassignation"""
        # Notification à l'ancien livreur
        Notification.objects.create(
            user=old_driver.user,
            notification_type='delivery_update',
            title='Livraison réassignée',
            message=f"La livraison {delivery.tracking_number} a été réassignée à un autre livreur. "
                    f"Raison: {reason or 'Non spécifiée'}",
            related_entity_type='delivery',
            related_entity_id=delivery.id
        )
        
        # Notification au nouveau livreur
        self._create_assignment_notification(delivery, new_driver)


# ==============================================================================
# SERVICE D'OPTIMISATION DE TOURNÉES
# ==============================================================================

class RouteOptimizationService:
    """
    Service pour optimiser les tournées de livraison.
    Utilise clustering géographique et calcul de distances.
    """
    
    def __init__(self):
        self.logger = logger
    
    def optimize_route_for_driver(self, driver_id, delivery_ids=None):
        """
        Optimise la route pour un livreur donné avec OR-Tools (VRP).
        """
        try:
            from ortools.constraint_solver import routing_enums_pb2
            from ortools.constraint_solver import pywrapcp
            import numpy as np
            driver = Driver.objects.get(id=driver_id)
            if delivery_ids:
                deliveries = Delivery.objects.filter(
                    id__in=delivery_ids,
                    driver=driver,
                    status__in=['assigned', 'picked_up']
                )
            else:
                deliveries = Delivery.objects.filter(
                    driver=driver,
                    status__in=['assigned', 'picked_up']
                ).order_by('created_at')
            if not deliveries.exists():
                return {
                    'success': False,
                    'message': 'Aucune livraison à optimiser',
                    'optimized_route': []
                }
            start_point = self._get_driver_current_location(driver)
            deliveries_list = list(deliveries.values('id', 'pickup_latitude', 'pickup_longitude', 'delivery_latitude', 'delivery_longitude', 'tracking_number'))
            optimized_route = self._vrp_ortools_algorithm(deliveries_list, start_point)
            return {
                'success': True,
                'driver': {
                    'id': str(driver.id),
                    'name': driver.user.full_name
                },
                'total_deliveries': len(optimized_route),
                'total_distance_km': sum(leg['distance_km'] for leg in optimized_route),
                'estimated_duration_minutes': sum(leg['duration_minutes'] for leg in optimized_route),
                'optimized_route': optimized_route
            }
        except Driver.DoesNotExist:
            return {
                'success': False,
                'message': 'Livreur introuvable'
            }
        except Exception as e:
            self.logger.error(f"Erreur optimisation route: {str(e)}")
            return {
                'success': False,
                'message': f'Erreur: {str(e)}'
            }

    def _vrp_ortools_algorithm(self, deliveries, start_point):
        """
        Utilise OR-Tools pour résoudre le VRP (1 livreur, plusieurs livraisons).
        """
        from ortools.constraint_solver import routing_enums_pb2
        from ortools.constraint_solver import pywrapcp
        import numpy as np
        # Points: start + pickups
        points = [(start_point['latitude'], start_point['longitude'])]
        for d in deliveries:
            points.append((d['pickup_latitude'], d['pickup_longitude']))
        # Distance matrix
        def compute_euclidean_distance_matrix(locations):
            n = len(locations)
            matrix = np.zeros((n, n))
            for i in range(n):
                for j in range(n):
                    if i == j:
                        matrix[i][j] = 0
                    else:
                        matrix[i][j] = geodesic(locations[i], locations[j]).km
            return matrix
        distance_matrix = compute_euclidean_distance_matrix(points)
        manager = pywrapcp.RoutingIndexManager(len(distance_matrix), 1, 0)
        routing = pywrapcp.RoutingModel(manager)
        def distance_callback(from_index, to_index):
            from_node = manager.IndexToNode(from_index)
            to_node = manager.IndexToNode(to_index)
            return int(distance_matrix[from_node][to_node] * 1000)
        transit_callback_index = routing.RegisterTransitCallback(distance_callback)
        routing.SetArcCostEvaluatorOfAllVehicles(transit_callback_index)
        search_parameters = pywrapcp.DefaultRoutingSearchParameters()
        search_parameters.first_solution_strategy = (
            routing_enums_pb2.FirstSolutionStrategy.PATH_CHEAPEST_ARC)
        solution = routing.SolveWithParameters(search_parameters)
        route = []
        if solution:
            index = routing.Start(0)
            order = 1
            while not routing.IsEnd(index):
                node = manager.IndexToNode(index)
                if node != 0:
                    d = deliveries[node-1]
                    pickup_distance = distance_matrix[0][node]
                    delivery_distance = geodesic(
                        (d['pickup_latitude'], d['pickup_longitude']),
                        (d['delivery_latitude'], d['delivery_longitude'])
                    ).km
                    total_distance = pickup_distance + delivery_distance
                    route.append({
                        'delivery_id': str(d['id']),
                        'tracking_number': d['tracking_number'],
                        'order': order,
                        'pickup_distance_km': round(pickup_distance, 2),
                        'delivery_distance_km': round(delivery_distance, 2),
                        'distance_km': round(total_distance, 2),
                        'duration_minutes': int(total_distance * 3)
                    })
                    order += 1
                index = solution.Value(routing.NextVar(index))
        return route
    
    def suggest_delivery_assignment(self, delivery_id):
        """
        Suggère les meilleurs livreurs pour une livraison donnée.
        
        Args:
            delivery_id: UUID de la livraison
            
        Returns:
            dict: Liste des livreurs suggérés avec scores
        """
        try:
            delivery = Delivery.objects.get(id=delivery_id)
            
            # Trouver les livreurs disponibles dans la zone
            available_drivers = Driver.objects.filter(
                is_available=True,
                zones__commune=delivery.pickup_commune
            ).distinct()
            
            if not available_drivers.exists():
                return {
                    'success': False,
                    'message': 'Aucun livreur disponible dans cette zone',
                    'suggestions': []
                }
            
            # Calculer un score pour chaque livreur
            suggestions = []
            for driver in available_drivers:
                score_data = self._calculate_driver_score(driver, delivery)
                suggestions.append({
                    'driver_id': str(driver.id),
                    'driver_name': driver.user.full_name,
                    'phone': driver.user.phone,
                    'vehicle_type': driver.vehicle_type,
                    'score': score_data['total_score'],
                    'distance_km': score_data['distance_km'],
                    'current_deliveries': score_data['current_deliveries'],
                    'success_rate': score_data['success_rate'],
                    'rating': score_data['rating']
                })
            
            # Trier par score décroissant
            suggestions.sort(key=lambda x: x['score'], reverse=True)
            
            return {
                'success': True,
                'delivery': {
                    'id': str(delivery.id),
                    'tracking_number': delivery.tracking_number,
                    'pickup_commune': delivery.pickup_commune
                },
                'total_suggestions': len(suggestions),
                'suggestions': suggestions[:10]  # Top 10
            }
            
        except Delivery.DoesNotExist:
            return {
                'success': False,
                'message': 'Livraison introuvable'
            }
    
    def _get_driver_current_location(self, driver):
        """Récupère la position actuelle du driver"""
        # TODO: Intégrer avec système GPS en temps réel
        # Pour l'instant, utilise la dernière livraison en cours
        last_delivery = Delivery.objects.filter(
            driver=driver,
            status='picked_up'
        ).order_by('-picked_up_at').first()
        
        if last_delivery:
            coords = last_delivery.get_coords('pickup')
            if coords:
                return {'latitude': coords[0], 'longitude': coords[1]}
            # fallback to raw fields if get_coords fails — convertir en float defensivement
            try:
                lat = float(last_delivery.pickup_latitude) if last_delivery.pickup_latitude is not None else None
                lon = float(last_delivery.pickup_longitude) if last_delivery.pickup_longitude is not None else None
                return {'latitude': lat, 'longitude': lon}
            except Exception:
                return {'latitude': None, 'longitude': None}
        
        # Sinon, utilise la zone principale du driver
        main_zone = driver.zones.first()
        if main_zone:
            # Coordonnées approximatives des communes (à améliorer)
            return self._get_commune_center(main_zone.commune)
        
        # Par défaut: Centre d'Abidjan
        return {'latitude': 5.3600, 'longitude': -4.0083}
    
    def _get_commune_center(self, commune):
        """Retourne les coordonnées approximatives du centre d'une commune"""
        # Coordonnées approximatives des communes d'Abidjan
        COMMUNE_COORDS = {
            'cocody': {'latitude': 5.3475, 'longitude': -3.9872},
            'plateau': {'latitude': 5.3200, 'longitude': -4.0250},
            'yopougon': {'latitude': 5.3364, 'longitude': -4.0881},
            'abobo': {'latitude': 5.4236, 'longitude': -4.0208},
            'adjame': {'latitude': 5.3569, 'longitude': -4.0205},
            'marcory': {'latitude': 5.2850, 'longitude': -3.9875},
            'treichville': {'latitude': 5.2950, 'longitude': -4.0050},
            'koumassi': {'latitude': 5.2969, 'longitude': -3.9331},
            'port_bouet': {'latitude': 5.2650, 'longitude': -3.9200},
            'attécoubé': {'latitude': 5.3400, 'longitude': -4.0550}
        }
        return COMMUNE_COORDS.get(commune.lower(), {'latitude': 5.3600, 'longitude': -4.0083})
    
    def _nearest_neighbor_algorithm(self, deliveries, start_point):
        """
        Algorithme du plus proche voisin pour optimiser la route.
        """
        from geopy.distance import geodesic
        
        route = []
        unvisited = list(deliveries)
        current_location = start_point
        
        while unvisited:
            # Trouver la livraison la plus proche (pickup)
            nearest = min(
                unvisited,
                key=lambda d: geodesic(
                    (current_location['latitude'], current_location['longitude']),
                    (d['pickup_latitude'], d['pickup_longitude'])
                ).km
            )
            
            # Calculer les distances
            pickup_distance = geodesic(
                (current_location['latitude'], current_location['longitude']),
                (nearest['pickup_latitude'], nearest['pickup_longitude'])
            ).km
            
            delivery_distance = geodesic(
                (nearest['pickup_latitude'], nearest['pickup_longitude']),
                (nearest['delivery_latitude'], nearest['delivery_longitude'])
            ).km
            
            total_distance = pickup_distance + delivery_distance
            
            # Ajouter à la route
            route.append({
                'delivery_id': str(nearest['id']),
                'tracking_number': nearest['tracking_number'],
                'order': len(route) + 1,
                'pickup_distance_km': round(pickup_distance, 2),
                'delivery_distance_km': round(delivery_distance, 2),
                'distance_km': round(total_distance, 2),
                'duration_minutes': int(total_distance * 3)  # ~20km/h moyenne en ville
            })
            
            # Mettre à jour la position actuelle (point de livraison)
            current_location = {
                'latitude': nearest['delivery_latitude'],
                'longitude': nearest['delivery_longitude']
            }
            
            # Retirer de la liste
            unvisited.remove(nearest)
        
        return route
    
    def _calculate_driver_score(self, driver, delivery):
        """
        Calcule un score pour un livreur basé sur plusieurs critères.
        Score sur 100.
        """
        from geopy.distance import geodesic
        
        score = 0
        
        # 1. Distance (40 points max)
        pickup = delivery.get_coords('pickup')
        driver_loc = self._get_driver_current_location(driver)
        try:
            driver_tuple = (driver_loc['latitude'], driver_loc['longitude'])
        except Exception:
            driver_tuple = (driver_loc.get('latitude'), driver_loc.get('longitude'))

        if pickup and driver_tuple[0] is not None and driver_tuple[1] is not None:
            distance_km = geodesic(pickup, driver_tuple).km
        else:
            # fallback: essayer de convertir les champs bruts en float puis calculer
            try:
                fallback_pickup = (
                    float(delivery.pickup_latitude) if delivery.pickup_latitude is not None else None,
                    float(delivery.pickup_longitude) if delivery.pickup_longitude is not None else None,
                )
                if fallback_pickup[0] is not None and fallback_pickup[1] is not None and driver_tuple[0] is not None and driver_tuple[1] is not None:
                    distance_km = geodesic(fallback_pickup, driver_tuple).km
                else:
                    # Aucune coordonnée disponible, appliquer une valeur large par défaut
                    distance_km = float('inf')
            except Exception:
                distance_km = float('inf')
        
        if distance_km < 2:
            distance_score = 40
        elif distance_km < 5:
            distance_score = 30
        elif distance_km < 10:
            distance_score = 20
        else:
            distance_score = 10
        
        score += distance_score
        
        # 2. Charge actuelle (30 points max)
        current_deliveries = Delivery.objects.filter(
            driver=driver,
            status__in=['assigned', 'picked_up']
        ).count()
        
        if current_deliveries == 0:
            workload_score = 30
        elif current_deliveries <= 2:
            workload_score = 20
        elif current_deliveries <= 5:
            workload_score = 10
        else:
            workload_score = 5
        
        score += workload_score
        
        # 3. Taux de succès (20 points max)
        total_deliveries = Delivery.objects.filter(driver=driver).count()
        successful = Delivery.objects.filter(driver=driver, status='delivered').count()
        
        success_rate = (successful / total_deliveries * 100) if total_deliveries > 0 else 0
        success_score = int(success_rate * 0.2)  # 0-20 points
        
        score += success_score
        
        # 4. Note moyenne (10 points max)
        rating = driver.rating or Decimal('0')
        rating_score = int(float(rating) * 2)  # 0-10 points
        
        score += rating_score
        
        return {
            'total_score': score,
            'distance_km': round(distance_km, 2),
            'current_deliveries': current_deliveries,
            'success_rate': round(success_rate, 1),
            'rating': float(rating)
        }
