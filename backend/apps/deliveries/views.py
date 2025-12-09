# deliveries/views.py

import logging
from django.db import transaction
from django.db.models import Count, Sum, Avg, Q
from django.utils import timezone
from datetime import timedelta
from rest_framework import viewsets, filters, status
from rest_framework.permissions import IsAuthenticated, IsAdminUser
from rest_framework.response import Response
from rest_framework.decorators import action
from rest_framework.exceptions import ValidationError
from django.core.exceptions import ValidationError as DjangoValidationError
from django.http import Http404

from apps.payments.models import DriverEarning
from decimal import Decimal
from apps.pricing.calculator import PricingCalculator

from .models import Delivery
from .models_rating import DeliveryRating
from .serializers import DeliverySerializer, DeliveryCreateSerializer
from .serializers_rating import DeliveryRatingSerializer
from .services import DeliveryAssignmentService, RouteOptimizationService
from apps.merchants.models import Merchant
from apps.drivers.models import Driver
from core.permissions import IsMerchant, IsDriver, IsAdmin, IsMerchantOrIndividual
from apps.notifications.services import notify_delivery_status_change
from geopy.distance import geodesic
from apps.core.location_service import LocationService
import os

logger = logging.getLogger(__name__)


class DeliveryViewSet(viewsets.ModelViewSet):
    """ViewSet pour gérer les livraisons"""
    
    queryset = Delivery.objects.select_related('merchant', 'driver').all()
    filter_backends = [filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['tracking_number', 'recipient_name']
    ordering_fields = ['created_at', 'delivered_at']
    
    def get_serializer_class(self):
        """Utilise DeliveryCreateSerializer pour la création, DeliverySerializer pour le reste"""
        if self.action == 'create':
            return DeliveryCreateSerializer
        return DeliverySerializer
    
    def get_permissions(self):
        """
        Permissions adaptées par action :
        - create: Merchants et Particuliers
        - assign/reassign: Admins uniquement
        - accept/reject: Drivers uniquement
        - list/retrieve: Tous authentifiés
        """
        if self.action == 'create':
            permission_classes = [IsMerchantOrIndividual]
        elif self.action in ['assign', 'auto_assign', 'reassign']:
            permission_classes = [IsAdmin]
        elif self.action in ['accept', 'reject']:
            permission_classes = [IsDriver]
        elif self.action in ['update', 'partial_update', 'destroy']:
            permission_classes = [IsAdminUser]
        else:
            permission_classes = [IsAuthenticated]
        return [permission() for permission in permission_classes]
    
    @transaction.atomic
    def perform_create(self, serializer):
        """Calcule le prix automatiquement lors de la création et envoie le code PIN par email."""
        try:
            # Récupère le merchant ou l'individual
            merchant = Merchant.objects.filter(user=self.request.user).first()
            
            delivery_data = serializer.validated_data

            if merchant:
                # Cas merchant : privilégier la valeur fournie dans la payload si présente
                pickup_commune = delivery_data.get('pickup_commune')
                if not pickup_commune:
                    # fallback sur l'adresse principale du merchant
                    pickup_address = merchant.addresses.filter(is_primary=True).first()
                    if not pickup_address:
                        raise ValidationError("Vous devez avoir une adresse principale ou fournir 'pickup_commune' dans la requête")
                    pickup_commune = pickup_address.commune
            else:
                # Cas particulier : utilise pickup_commune fourni dans les données
                from apps.individuals.models import Individual
                individual = Individual.objects.filter(user=self.request.user).first()
                if not individual:
                    raise ValidationError("Vous n'avez pas de profil")

                pickup_commune = delivery_data.get('pickup_commune')
                if not pickup_commune:
                    raise ValidationError("pickup_commune est requis pour les particuliers")

            # Prépare les données pour le calcul
            delivery_data = serializer.validated_data
            pricing_data = {
                'pickup_commune': pickup_commune,
                'delivery_commune': delivery_data.get('delivery_commune'),
                'package_weight_kg': float(delivery_data.get('package_weight_kg', 0)),
                'is_fragile': delivery_data.get('is_fragile', False),
                'scheduling_type': delivery_data.get('scheduling_type', 'immediate'),
            }
            
            # Ajouter les quartiers optionnels pour plus de précision
            # Normaliser / ignorer les valeurs vides ou non-textuelles
            pk_quartier = delivery_data.get('pickup_quartier')
            if pk_quartier is not None:
                if isinstance(pk_quartier, str):
                    pk_quartier = pk_quartier.strip()
                if pk_quartier:
                    pricing_data['pickup_quartier'] = pk_quartier

            dl_quartier = delivery_data.get('delivery_quartier')
            if dl_quartier is not None:
                if isinstance(dl_quartier, str):
                    dl_quartier = dl_quartier.strip()
                if dl_quartier:
                    pricing_data['delivery_quartier'] = dl_quartier

            # Si le client fournit des coordonnées GPS, les transmettre au calculateur
            try:
                pl = delivery_data.get('pickup_latitude')
                pr = delivery_data.get('pickup_longitude')
                dl = delivery_data.get('delivery_latitude')
                dr = delivery_data.get('delivery_longitude')

                if pl is not None and pr is not None:
                    # convertir en float si nécessaire
                    pricing_data['pickup_coords'] = (float(pl), float(pr))
                if dl is not None and dr is not None:
                    pricing_data['delivery_coords'] = (float(dl), float(dr))
            except (TypeError, ValueError):
                # ignorer si conversion échoue — le calculateur utilisera le fallback
                logger.warning('Coordonnées GPS fournies invalides; fallback sur zones')
            # Instancier le PricingCalculator une seule fois et prioriser
            calculator = PricingCalculator()
            # Prioriser coordonnées de quartier/zone si le client n'a pas fourni de coords
            try:

                # pickup coords from zone centroid (quartier -> commune)
                if not pricing_data.get('pickup_coords'):
                    try:
                        origin_zone = calculator.get_zone_from_quartier(
                            pricing_data.get('pickup_quartier'),
                            pricing_data.get('pickup_commune')
                        )
                        if getattr(origin_zone, 'default_latitude', None) is not None and getattr(origin_zone, 'default_longitude', None) is not None:
                            pricing_data['pickup_coords'] = (
                                float(origin_zone.default_latitude),
                                float(origin_zone.default_longitude)
                            )
                    except Exception:
                        # ignore zone lookup errors — calculator will fallback
                        logger.debug('No origin zone coords available')

                # delivery coords from zone centroid (quartier -> commune)
                if not pricing_data.get('delivery_coords'):
                    try:
                        destination_zone = calculator.get_zone_from_quartier(
                            pricing_data.get('delivery_quartier'),
                            pricing_data.get('delivery_commune')
                        )
                        if getattr(destination_zone, 'default_latitude', None) is not None and getattr(destination_zone, 'default_longitude', None) is not None:
                            pricing_data['delivery_coords'] = (
                                float(destination_zone.default_latitude),
                                float(destination_zone.default_longitude)
                            )
                    except Exception:
                        logger.debug('No destination zone coords available')

            except Exception:
                logger.exception('Erreur lors de la récupération des coordonnées de zone pour pricing')

            # Calcule le prix (réutilise l'instance existante)
            price_result = calculator.calculate_price(pricing_data)
            calculated_price = price_result['total_price']
            # Extract distance_km from the price result details when available
            try:
                distance_km = price_result.get('details', {}).get('distance_km')
            except Exception:
                distance_km = None

            # Valide le prix
            if calculated_price <= 0:
                raise ValidationError("Le prix calculé est invalide")

            # Génère un code PIN à 4 chiffres
            delivery_confirmation_code = Delivery().generate_confirmation_code()
            # Sauvegarde la livraison
            # Save the delivery including calculated distance if available
            save_kwargs = {
                'merchant': merchant,
                'created_by': self.request.user,
                'calculated_price': calculated_price,
                'delivery_confirmation_code': delivery_confirmation_code,
            }
            if distance_km is not None:
                try:
                    # store as Decimal-compatible float
                    from decimal import Decimal
                    save_kwargs['distance_km'] = Decimal(str(distance_km))
                except Exception:
                    # ignore if conversion fails
                    pass

            serializer.save(**save_kwargs)

            # Envoie le code PIN par email au créateur (merchant ou individual)
            from .email_service import send_delivery_pin_email
            recipient_email = getattr(self.request.user, 'email', None) or 'yahmardoch@gmail.com'
            send_delivery_pin_email(delivery_confirmation_code, recipient_email, serializer.instance)

        except ValidationError as e:
            logger.warning(f"⚠️ Validation error: {str(e)}")
            raise

        except Exception as e:
            logger.error(f"❌ Erreur création: {str(e)}", exc_info=True)
            raise ValidationError("Erreur lors du calcul du prix")
    
    def create(self, request, *args, **kwargs):
        """Override create() pour retourner la réponse complète"""
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        self.perform_create(serializer)
        
        # Récupérer l'objet créé avec DeliverySerializer
        delivery = serializer.instance
        output_serializer = DeliverySerializer(delivery)
        
        headers = self.get_success_headers(output_serializer.data)
        return Response(output_serializer.data, status=status.HTTP_201_CREATED, headers=headers)
    
    def get_queryset(self):
        """
        Filtre les livraisons selon le type d'utilisateur :
        - Merchants : voient uniquement leurs livraisons
        - Drivers : voient les livraisons qui leur sont assignées
        - Admins : voient tout
        
        Supporte aussi le filtrage par statut via le query parameter 'status'
        """
        # Support pour la génération de schéma Swagger
        if getattr(self, 'swagger_fake_view', False):
            return Delivery.objects.none()
        
        user = self.request.user
        
        # Gérer les utilisateurs anonymes
        if not user.is_authenticated:
            return Delivery.objects.none()
        
        if user.user_type == 'merchant':
            # Merchants voient uniquement leurs livraisons
            try:
                merchant = Merchant.objects.get(user=user)
                queryset = Delivery.objects.filter(merchant=merchant).select_related('merchant', 'driver')
            except Merchant.DoesNotExist:
                return Delivery.objects.none()
        
        elif user.user_type == 'driver':
            # Drivers voient leurs livraisons assignées
            try:
                driver = Driver.objects.get(user=user)
                queryset = Delivery.objects.filter(driver=driver).select_related('merchant', 'driver')
            except Driver.DoesNotExist:
                return Delivery.objects.none()
        elif user.user_type == 'individual':
            # Particuliers voient uniquement les livraisons qu'ils ont créées
            queryset = Delivery.objects.filter(created_by=user).select_related('merchant', 'driver')

        elif user.user_type == 'admin' or getattr(user, 'is_staff', False):
            # Admins voient tout
            queryset = Delivery.objects.all().select_related('merchant', 'driver')

        else:
            # Tout autre type (sécurité) : ne rien retourner
            return Delivery.objects.none()
        
        # Filtrer par statut si le paramètre est fourni
        status = self.request.query_params.get('status')
        if status:
            queryset = queryset.filter(status=status)
        
        return queryset

    @action(detail=False, methods=['GET'], url_path='my-stats', permission_classes=[IsAuthenticated])
    def my_stats(self, request):
        """Return aggregated delivery stats for the current user (merchant or individual).

        GET params:
        - period: optional int days to compute period totals (default: 30)
        """
        try:
            period = int(request.query_params.get('period', 30))
        except (TypeError, ValueError):
            period = 30

        qs = self.filter_queryset(self.get_queryset())

        # Use shared helper to compute stats
        from apps.deliveries.services import compute_delivery_stats
        merchant = None
        try:
            if getattr(request.user, 'user_type', None) == 'merchant':
                merchant = Merchant.objects.filter(user=request.user).first()
        except Exception:
            merchant = None

        stats = compute_delivery_stats(qs, period_days=period, merchant=merchant)

        # If the caller is a merchant, include merchant metadata for parity with merchants.my-stats
        response = stats
        if merchant:
            response = {
                'merchant': {
                    'id': str(merchant.id),
                    'business_name': merchant.business_name,
                    'verification_status': merchant.verification_status,
                }
            }
            response.update(stats)

        return Response(response)
    
    # =========================================================================
    # ENDPOINTS D'ASSIGNATION (ADMIN)
    # =========================================================================
    
    @action(detail=True, methods=['POST'], permission_classes=[IsAdmin])
    def assign(self, request, pk=None):
        """
        POST /api/v1/deliveries/{id}/assign/
        
        Assigne manuellement un livreur à une livraison (Admin uniquement).
        
        Body JSON :
        {
            "driver_id": "uuid-du-livreur"
        }
        """
        delivery = self.get_object()
        driver_id = request.data.get('driver_id')
        
        if not driver_id:
            return Response(
                {'error': 'Le champ driver_id est requis'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            assignment_service = DeliveryAssignmentService()
            result = assignment_service.assign_driver_manually(
                delivery_id=delivery.id,
                driver_id=driver_id,
                assigned_by_user=request.user
            )
            
            return Response(result, status=status.HTTP_200_OK)
        
        except (ValidationError, DjangoValidationError) as e:
            return Response(
                {'error': str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )
    
    @action(detail=True, methods=['POST'], permission_classes=[IsAdmin])
    def auto_assign(self, request, pk=None):
        """
        POST /api/v1/deliveries/{id}/auto-assign/
        
        Assigne automatiquement le meilleur livreur disponible (Admin uniquement).
        """
        delivery = self.get_object()
        
        try:
            assignment_service = DeliveryAssignmentService()
            result = assignment_service.assign_driver_automatically(
                delivery_id=delivery.id
            )
            
            return Response(result, status=status.HTTP_200_OK)
        
        except (ValidationError, DjangoValidationError) as e:
            return Response(
                {'error': str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )
    
    @action(detail=True, methods=['POST'], permission_classes=[IsAdmin])
    def reassign(self, request, pk=None):
        """
        POST /api/v1/deliveries/{id}/reassign/
        
        Réassigne une livraison à un autre livreur (Admin uniquement).
        
        Body JSON :
        {
            "driver_id": "uuid-du-nouveau-livreur",
            "reason": "Raison de la réassignation"
        }
        """
        delivery = self.get_object()
        driver_id = request.data.get('driver_id')
        reason = request.data.get('reason', '')
        
        if not driver_id:
            return Response(
                {'error': 'Le champ driver_id est requis'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            assignment_service = DeliveryAssignmentService()
            result = assignment_service.reassign_delivery(
                delivery_id=delivery.id,
                new_driver_id=driver_id,
                reason=reason
            )
            
            return Response(result, status=status.HTTP_200_OK)
        
        except (ValidationError, DjangoValidationError) as e:
            return Response(
                {'error': str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )
    
    # =========================================================================
    # ENDPOINTS POUR LIVREURS
    # =========================================================================
    
    @action(detail=True, methods=['POST'], permission_classes=[IsDriver])
    def accept(self, request, pk=None):
        """
        POST /api/v1/deliveries/{id}/accept/
        
        Le livreur accepte une livraison qui lui a été assignée.
        """
        # Récupérer la livraison par PK sans utiliser self.get_object()
        # car pour l'action d'acceptation nous autorisons un driver
        # à accepter une livraison non encore assignée (status 'pending' ou 'pending_assignment').
        try:
            delivery = Delivery.objects.select_related('merchant', 'driver').get(id=pk)
        except Delivery.DoesNotExist:
            # Log diagnostic info to help debug 404s caused by wrong PK
            try:
                logger.warning("accept: delivery not found for request user", extra={
                    'user_id': getattr(request.user, 'id', None),
                    'is_authenticated': getattr(request.user, 'is_authenticated', False),
                    'user_type': getattr(request.user, 'user_type', None),
                    'requested_pk': pk,
                })
            except Exception:
                logger.warning('accept: delivery not found and failed to log user info')
            raise Http404
        
        try:
            driver = Driver.objects.get(user=request.user)
        except Driver.DoesNotExist:
            return Response(
                {'error': 'Profil livreur introuvable'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        try:
            assignment_service = DeliveryAssignmentService()
            result = assignment_service.driver_accept_delivery(
                delivery_id=delivery.id,
                driver=driver
            )
            
            return Response(result, status=status.HTTP_200_OK)
        
        except (ValidationError, DjangoValidationError) as e:
            return Response(
                {'error': str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )
    
    @action(detail=True, methods=['POST'], permission_classes=[IsDriver])
    def reject(self, request, pk=None):
        """
        POST /api/v1/deliveries/{id}/reject/
        
        Le livreur refuse une livraison.
        
        Body JSON :
        {
            "reason": "Raison du refus"
        }
        """
        delivery = self.get_object()
        reason = request.data.get('reason', 'Non spécifiée')
        
        try:
            driver = Driver.objects.get(user=request.user)
        except Driver.DoesNotExist:
            return Response(
                {'error': 'Profil livreur introuvable'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        try:
            assignment_service = DeliveryAssignmentService()
            result = assignment_service.driver_reject_delivery(
                delivery_id=delivery.id,
                driver=driver,
                reason=reason
            )
            
            return Response(result, status=status.HTTP_200_OK)
        
        except ValidationError as e:
            return Response(
                {'error': str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )
    
    @action(detail=True, methods=['POST'], permission_classes=[IsDriver], url_path='confirm-pickup')
    def confirm_pickup(self, request, pk=None):
        """
        POST /api/v1/deliveries/{id}/confirm-pickup/
        
        Le livreur confirme qu'il a récupéré le colis chez le merchant.
        Change le statut de 'assigned' à 'picked_up'.
        """
        delivery = self.get_object()
        
        try:
            driver = Driver.objects.get(user=request.user)
        except Driver.DoesNotExist:
            return Response(
                {'error': 'Profil livreur introuvable'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        # Vérifier que c'est bien le driver assigné
        if delivery.driver != driver:
            return Response(
                {'error': 'Cette livraison n\'est pas assignée à vous'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        # Vérifier le statut actuel
        # Accept both 'assigned' (normal flow) and 'in_progress' (idempotent/no-op)
        already_picked = (delivery.status == 'in_progress')

        if not already_picked and delivery.status != 'assigned':
            return Response(
                {'error': f'Impossible de confirmer la récupération. Statut actuel: {delivery.status}'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Si pas déjà récupéré, effectuer la transition et notifier
        if not already_picked:
            # Vérifier la proximité GPS entre le driver et le point d'enlèvement
            pickup_coords = delivery.get_coords('pickup')
            driver_lat = getattr(driver, 'current_latitude', None)
            driver_lon = getattr(driver, 'current_longitude', None)

            # Lire la configuration pour exiger la position GPS
            try:
                REQUIRE_GPS_FOR_PICKUP = os.getenv('REQUIRE_GPS_FOR_PICKUP', 'False').lower() in ('1', 'true', 'yes')
            except Exception:
                REQUIRE_GPS_FOR_PICKUP = False

            # Seuil configurable via env (en km). Par défaut 10 km (~200 m).
            try:
                PICKUP_PROXIMITY_KM = float(os.getenv('PICKUP_PROXIMITY_KM', '10'))
            except Exception:
                PICKUP_PROXIMITY_KM = 10

            close_enough = True
            distance_km = None
            try:
                if pickup_coords and driver_lat is not None and driver_lon is not None:
                    # Tenter d'utiliser le routing (route réelle) pour une mesure plus exacte
                    try:
                        route = LocationService.get_route(float(driver_lat), float(driver_lon), float(pickup_coords[0]), float(pickup_coords[1]))
                        if route and isinstance(route, dict) and route.get('distance_km') is not None:
                            distance_km = float(route.get('distance_km'))
                            logger.debug(f"confirm_pickup: routed distance_km={distance_km}")
                        else:
                            # Fallback: utiliser la distance géodésique
                            driver_pos = (float(driver_lat), float(driver_lon))
                            distance_km = geodesic(pickup_coords, driver_pos).km
                            logger.debug(f"confirm_pickup: fallback geodesic distance_km={distance_km}")
                    except Exception as e:
                        # Si le service de routing échoue, fallback sur géodesic
                        logger.exception(f"Routing check failed in confirm_pickup, falling back to geodesic: {e}")
                        driver_pos = (float(driver_lat), float(driver_lon))
                        distance_km = geodesic(pickup_coords, driver_pos).km
                else:
                    # Si l'une des coordonnées manque
                    logger.debug(f"confirm_pickup: missing gps data pickup={pickup_coords} driver=({driver_lat},{driver_lon})")
                    if REQUIRE_GPS_FOR_PICKUP:
                        return Response({
                            'error': 'Coordonnées GPS du livreur manquantes. Autorisation de confirmation refusée.',
                        }, status=status.HTTP_400_BAD_REQUEST)
            except Exception as e:
                logger.exception(f"Error computing distance for confirm_pickup: {e}")

            if distance_km is not None and distance_km > PICKUP_PROXIMITY_KM:
                return Response({
                    'error': f"Vous devez être à proximité du point d'enlèvement pour confirmer la récupération (≈{PICKUP_PROXIMITY_KM} km).",
                    'distance_km': round(distance_km, 3)
                }, status=status.HTTP_400_BAD_REQUEST)

            # Optionnel: accepter preuve photo/signature fournie au moment de l'enlèvement
            pickup_photo = request.data.get('pickup_photo') or request.data.get('photo_url') or request.data.get('pickup_photo_url')
            pickup_signature = request.data.get('pickup_signature') or request.data.get('signature_url') or request.data.get('pickup_signature_url')
            if pickup_photo or pickup_signature:
                # Store in dedicated fields (new) and keep a trace in delivery_notes for compatibility
                if pickup_photo:
                    try:
                        delivery.pickup_photo_url = str(pickup_photo)
                    except Exception:
                        # ignore malformed values
                        pass
                if pickup_signature:
                    try:
                        delivery.pickup_signature_url = str(pickup_signature)
                    except Exception:
                        pass

                # Also append to free-text notes for older clients/tools that parse it
                try:
                    notes = delivery.delivery_notes or ''
                    if pickup_photo:
                        notes += f"\n[PICKUP_PHOTO:{pickup_photo}]"
                    if pickup_signature:
                        notes += f"\n[PICKUP_SIGNATURE:{pickup_signature}]"
                    delivery.delivery_notes = notes.strip()
                except Exception:
                    logger.exception('Failed to append pickup proofs to delivery_notes')
            # Mettre à jour le statut -> maintenant en cours de livraison
            # (le driver a récupéré le colis chez le merchant)
            delivery.status = 'in_progress'
            delivery.picked_up_at = timezone.now()
            delivery.save(update_fields=['status', 'picked_up_at', 'updated_at'])

            # 🔔 Notifier le merchant (statut 'in_progress') si présent
            merchant = getattr(delivery, 'merchant', None)
            if merchant and getattr(merchant, 'user', None):
                try:
                    notify_delivery_status_change(merchant.user, delivery, 'in_progress')
                except Exception:
                    logger.exception(f"Failed to notify merchant about pickup for delivery {delivery.id}")

            logger.info(f"Livraison {delivery.tracking_number} récupérée par driver {driver.user.email}")

        # Retour unique (idempotent)
        serializer = DeliverySerializer(delivery)
        return Response({
            'success': True,
            'message': 'Colis déjà récupéré' if already_picked else 'Colis récupéré avec succès',
            'delivery': serializer.data
        }, status=status.HTTP_200_OK)
    
    @action(detail=True, methods=['POST'], permission_classes=[IsDriver], url_path='confirm-delivery')
    def confirm_delivery(self, request, pk=None):
        """
        POST /api/v1/deliveries/{id}/confirm-delivery/
        
        Le livreur confirme que la livraison a été effectuée.
        
        Body JSON :
        {
            "delivery_photo": "url-photo",  // optionnel
            "recipient_signature": "url-signature",  // optionnel
            "notes": "Notes de livraison"  // optionnel
        }
        """
        delivery = self.get_object()
        
        try:
            driver = Driver.objects.get(user=request.user)
        except Driver.DoesNotExist:
            return Response(
                {'error': 'Profil livreur introuvable'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        # Vérifier que c'est bien le driver assigné
        if delivery.driver != driver:
            return Response(
                {'error': 'Cette livraison n\'est pas assignée à vous'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        # Vérifier le statut actuel (doit être in_progress)
        if delivery.status not in ['in_progress']:
            return Response(
                {'error': f'Impossible de confirmer la livraison. Statut actuel: {delivery.status}'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Vérifier le code PIN fourni
        pin = request.data.get('confirmation_code')
        if not pin or pin != delivery.delivery_confirmation_code:
            return Response(
                {'error': 'Code de confirmation invalide'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Récupérer les données optionnelles (support des 2 formats)
        delivery_photo = request.data.get('delivery_photo') or request.data.get('photo_url')
        recipient_signature = request.data.get('recipient_signature') or request.data.get('signature_url')
        notes = request.data.get('notes') or request.data.get('delivery_notes')

        # Mettre à jour la livraison
        delivery.status = 'delivered'
        delivery.delivered_at = timezone.now()

        if delivery_photo:
            delivery.photo_url = delivery_photo
        if recipient_signature:
            delivery.signature_url = recipient_signature
        if notes:
            delivery.delivery_notes = notes


        delivery.save()

        # --- Création automatique du gain du livreur (DriverEarning) ---
        # Vérifie qu'aucun gain n'existe déjà pour cette livraison
        if not hasattr(delivery, 'driver_earning'):
            # Utilise le PricingCalculator pour recalculer le montant exact
            calculator = PricingCalculator()
            # Prepare numeric fields safely: attributes may exist but be None.
            _pw = getattr(delivery, 'package_weight_kg', None)
            package_weight_kg = float(_pw) if _pw is not None else 0.0

            _pl = getattr(delivery, 'package_length_cm', None)
            package_length_cm = float(_pl) if _pl is not None else None

            _pwid = getattr(delivery, 'package_width_cm', None)
            package_width_cm = float(_pwid) if _pwid is not None else None

            _ph = getattr(delivery, 'package_height_cm', None)
            package_height_cm = float(_ph) if _ph is not None else None

            pricing_data = {
                'pickup_commune': getattr(delivery, 'pickup_commune', ''),
                'delivery_commune': delivery.delivery_commune,
                'package_weight_kg': package_weight_kg,
                'package_length_cm': package_length_cm,
                'package_width_cm': package_width_cm,
                'package_height_cm': package_height_cm,
                'is_fragile': getattr(delivery, 'is_fragile', False),
                'scheduling_type': getattr(delivery, 'scheduling_type', 'immediate'),
                'scheduled_pickup_time': getattr(delivery, 'scheduled_pickup_time', None),
                'pickup_coords': delivery.get_coords('pickup'),
                'delivery_coords': delivery.get_coords('delivery'),
            }
            price_result = calculator.calculate_price(pricing_data)
            base_earning = Decimal(str(price_result['total_price']))
            earning = DriverEarning.objects.create(
                driver=delivery.driver,
                delivery=delivery,
                base_earning=base_earning,
                total_earning=base_earning,  # à ajuster si bonus/penalités
                status='pending',
                notes='Gain généré automatiquement à la validation de la livraison.'
            )
            earning.save()
            logger.info(f"[AUTO] Gain créé: {earning.driver.user.full_name} | Livraison: {delivery.tracking_number} | {earning.total_earning} CFA (statut: pending)")

        # Mettre à jour les stats du driver
        driver.total_deliveries += 1
        driver.successful_deliveries += 1
        driver.save(update_fields=['total_deliveries', 'successful_deliveries', 'updated_at'])

        # 🔔 Notifier le merchant (si présent)
        merchant = getattr(delivery, 'merchant', None)
        if merchant and getattr(merchant, 'user', None):
            try:
                notify_delivery_status_change(merchant.user, delivery, 'delivered')
            except Exception:
                logger.exception(f"Failed to notify merchant about delivery {delivery.id}")

        logger.info(f"✅ Livraison {delivery.tracking_number} confirmée par driver {driver.user.email}")

        serializer = DeliverySerializer(delivery)
        return Response({
            'success': True,
            'message': 'Livraison confirmée avec succès',
            'delivery': serializer.data
        }, status=status.HTTP_200_OK)
    
    @action(detail=True, methods=['POST'], permission_classes=[IsAuthenticated])
    def cancel(self, request, pk=None):
        """
        POST /api/v1/deliveries/{id}/cancel/
        
        Annuler une livraison.
        - Driver: peut annuler une livraison assignée à lui
        - Merchant: peut annuler ses propres livraisons
        - Individual: peut annuler ses propres livraisons
        
        Body JSON :
        {
            "reason": "Raison de l'annulation"
        }
        """
        delivery = self.get_object()
        reason = request.data.get('reason', 'Annulé par le client')
        user = request.user
        
        # Vérifier les permissions selon le type d'utilisateur
        can_cancel = False
        cancelled_by = ""
        
        # Vérifier d'abord si l'utilisateur a créé la livraison (pour les particuliers)
        if delivery.created_by == user:
            can_cancel = True
            cancelled_by = f"creator {user.email}"
        elif user.user_type == 'driver':
            try:
                driver = Driver.objects.get(user=user)
                if delivery.driver == driver:
                    can_cancel = True
                    cancelled_by = f"driver {driver.user.email}"
            except Driver.DoesNotExist:
                pass
        elif user.user_type == 'merchant':
            try:
                merchant = Merchant.objects.get(user=user)
                if delivery.merchant == merchant:
                    can_cancel = True
                    cancelled_by = f"merchant {merchant.business_name}"
            except Merchant.DoesNotExist:
                pass
        
        if not can_cancel:
            return Response(
                {'error': 'Vous n\'avez pas la permission d\'annuler cette livraison'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        # Vérifier qu'elle n'est pas déjà terminée
        if delivery.status in ['delivered', 'cancelled', 'failed']:
            return Response(
                {'error': f'Impossible d\'annuler. Statut actuel: {delivery.status}'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Annuler la livraison
        delivery.status = 'cancelled'
        delivery.cancellation_reason = reason
        delivery.cancelled_at = timezone.now()
        delivery.save()
        
        logger.warning(f"⚠️ Livraison {delivery.tracking_number} annulée par {cancelled_by}: {reason}")
        
        serializer = DeliverySerializer(delivery)
        return Response({
            'success': True,
            'message': 'Livraison annulée',
            'delivery': serializer.data
        }, status=status.HTTP_200_OK)
    
    # ==========================================================================
    # ENDPOINT NOTATION : MERCHANT NOTE LE DRIVER
    # ==========================================================================
    
    @action(detail=True, methods=['POST'], permission_classes=[IsMerchant], url_path='rate-driver')
    def rate_driver(self, request, pk=None):
        """
        POST /api/v1/deliveries/{id}/rate-driver/
        
        Le marchand note le livreur après une livraison terminée.
        
        Body JSON :
        {
            "rating": 4.5,  // Note de 1 à 5
            "comment": "Excellent service !",  // Optionnel
            "punctuality_rating": 5,  // Optionnel (1-5)
            "professionalism_rating": 4,  // Optionnel (1-5)
            "care_rating": 5  // Optionnel (1-5)
        }
        """
        from .models_rating import DeliveryRating
        from .serializers_rating import DeliveryRatingCreateSerializer
        
        delivery = self.get_object()
        
        try:
            merchant = Merchant.objects.get(user=request.user)
        except Merchant.DoesNotExist:
            return Response(
                {'error': 'Profil marchand introuvable'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        # Vérifications
        if delivery.merchant != merchant:
            return Response(
                {'error': 'Cette livraison ne vous appartient pas'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        if delivery.status != 'delivered':
            return Response(
                {'error': f'Vous ne pouvez noter qu\'une livraison terminée. Statut actuel: {delivery.status}'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        if not delivery.driver:
            return Response(
                {'error': 'Aucun livreur assigné à cette livraison'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Vérifier si déjà noté
        if hasattr(delivery, 'rating'):
            return Response(
                {'error': 'Vous avez déjà noté cette livraison'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Créer l'évaluation
        serializer = DeliveryRatingCreateSerializer(data=request.data)
        
        if serializer.is_valid():
            serializer.save(
                delivery=delivery,
                merchant=merchant,
                driver=delivery.driver
            )
            
            logger.info(
                f"⭐ Nouvelle évaluation | "
                f"Livraison: {delivery.tracking_number} | "
                f"Driver: {delivery.driver.user.full_name} | "
                f"Note: {serializer.data['rating']}"
            )
            
            return Response({
                'success': True,
                'message': 'Merci pour votre évaluation !',
                'rating': serializer.data
            }, status=status.HTTP_201_CREATED)
        
        return Response(
            {'error': serializer.errors},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    # ==========================================================================
    # ENDPOINTS D'OPTIMISATION DE TOURNÉES
    # ==========================================================================
    
    @action(detail=False, methods=['POST'], permission_classes=[IsAdmin])
    def optimize_route(self, request):
        """
        POST /api/v1/deliveries/optimize-route/
        
        Optimise la tournée d'un livreur.
        
        Body:
        {
            "driver_id": "uuid",
            "delivery_ids": ["uuid1", "uuid2"] // optionnel
        }
        """
        driver_id = request.data.get('driver_id')
        delivery_ids = request.data.get('delivery_ids')
        
        if not driver_id:
            return Response(
                {'error': 'Le champ driver_id est requis'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        optimizer = RouteOptimizationService()
        result = optimizer.optimize_route_for_driver(driver_id, delivery_ids)
        
        if result['success']:
            return Response(result, status=status.HTTP_200_OK)
        else:
            return Response(result, status=status.HTTP_400_BAD_REQUEST)
    
    @action(detail=True, methods=['GET'], permission_classes=[IsAdmin])
    def suggest_drivers(self, request, pk=None):
        """
        GET /api/v1/deliveries/{id}/suggest-drivers/
        
        Suggère les meilleurs livreurs pour une livraison.
        """
        delivery = self.get_object()
        
        optimizer = RouteOptimizationService()
        result = optimizer.suggest_delivery_assignment(delivery.id)
        
        if result['success']:
            return Response(result, status=status.HTTP_200_OK)
        else:
            return Response(result, status=status.HTTP_400_BAD_REQUEST)
    
    # ==========================================================================
    # DASHBOARD ADMIN - STATISTIQUES GLOBALES
    # ==========================================================================
    
    @action(detail=False, methods=['GET'], permission_classes=[IsAdmin])
    def dashboard(self, request):
        """
        GET /api/v1/deliveries/dashboard/?period=30
        
        Statistiques globales pour le dashboard admin.
        """
        period_days = int(request.query_params.get('period', 30))
        period_start = timezone.now() - timedelta(days=period_days)
        
        # Toutes les livraisons
        all_deliveries = Delivery.objects.all()
        period_deliveries = all_deliveries.filter(created_at__gte=period_start)
        
        # Stats par statut
        # Some deployments still have legacy status values. Count both
        # legacy and current statuses so the dashboard remains accurate.
        stats_by_status = period_deliveries.aggregate(
            total=Count('id'),
            pending=Count('id', filter=Q(status__in=['pending', 'pending_assignment'])),
            assigned=Count('id', filter=Q(status__in=['assigned'])),
            picked_up=Count('id', filter=Q(status__in=['picked_up'])),
            in_transit=Count('id', filter=Q(status__in=['in_transit'])),
            # Aggregate any status that represents an in-progress delivery
            in_progress=Count('id', filter=Q(status__in=[
                'in_progress', 'pickup_in_progress', 'assigned', 'picked_up', 'in_transit'
            ])),
            delivered=Count('id', filter=Q(status='delivered')),
            cancelled=Count('id', filter=Q(status='cancelled')),
            failed=Count('id', filter=Q(status='failed'))
        )
        
        # Revenus
        revenue_data = period_deliveries.filter(status='delivered').aggregate(
            total_revenue=Sum('calculated_price'),
            avg_delivery_price=Avg('calculated_price')
        )
        
        # Stats par commune (top 5)
        top_communes = period_deliveries.values('delivery_commune').annotate(
            count=Count('id')
        ).order_by('-count')[:5]
        
        # Merchants actifs
        active_merchants = period_deliveries.values('merchant').distinct().count()
        top_merchants = period_deliveries.values(
            'merchant__business_name'
        ).annotate(
            deliveries_count=Count('id')
        ).order_by('-deliveries_count')[:5]
        
        # Drivers actifs
        active_drivers = period_deliveries.filter(driver__isnull=False).values('driver').distinct().count()
        top_drivers = period_deliveries.filter(driver__isnull=False).values(
            'driver__user__first_name', 'driver__user__last_name'
        ).annotate(
            deliveries_count=Count('id')
        ).order_by('-deliveries_count')[:5]
        
        # Taux de succès
        total_completed = stats_by_status['delivered'] + stats_by_status['cancelled']
        success_rate = (stats_by_status['delivered'] / total_completed * 100) if total_completed > 0 else 0
        
        # Tendances (comparaison avec période précédente)
        previous_period_start = period_start - timedelta(days=period_days)
        previous_deliveries = all_deliveries.filter(
            created_at__gte=previous_period_start,
            created_at__lt=period_start
        )
        previous_count = previous_deliveries.count()
        current_count = period_deliveries.count()
        growth_rate = ((current_count - previous_count) / previous_count * 100) if previous_count > 0 else 0
        
        return Response({
            'period': {
                'days': period_days,
                'start': period_start.isoformat(),
                'end': timezone.now().isoformat()
            },
            'overview': {
                'total_deliveries': stats_by_status['total'],
                'total_revenue': str(revenue_data['total_revenue'] or 0),
                'avg_delivery_price': str(revenue_data['avg_delivery_price'] or 0),
                'success_rate': round(success_rate, 2),
                'growth_rate': round(growth_rate, 2)
            },
            'deliveries_by_status': {
                'pending': stats_by_status['pending'],
                'assigned': stats_by_status['assigned'],
                'picked_up': stats_by_status['picked_up'],
                'in_transit': stats_by_status['in_transit'],
                'in_progress': stats_by_status.get('in_progress', 0),
                'delivered': stats_by_status['delivered'],
                'cancelled': stats_by_status['cancelled'],
                'failed': stats_by_status['failed']
            },
            'top_communes': [
                {'commune': item['delivery_commune'], 'count': item['count']}
                for item in top_communes
            ],
            'merchants': {
                'active_count': active_merchants,
                'top_5': [
                    {'business_name': item['merchant__business_name'], 'deliveries': item['deliveries_count']}
                    for item in top_merchants
                ]
            },
            'drivers': {
                'active_count': active_drivers,
                'top_5': [
                    {
                        'name': f"{item['driver__user__first_name']} {item['driver__user__last_name']}",
                        'deliveries': item['deliveries_count']
                    }
                    for item in top_drivers
                ]
            }
        })
    
    @action(detail=True, methods=['post'], permission_classes=[IsAuthenticated])
    def rate_driver(self, request, pk=None):
        """
        Permet à un merchant de noter un livreur après une livraison.
        
        POST /deliveries/{id}/rate-driver/
        Body: {
            "rating": 4.5,
            "comment": "Très professionnel",
            "punctuality_rating": 5,
            "professionalism_rating": 5,
            "care_rating": 4
        }
        """
        delivery = self.get_object()
        
        # Vérifications
        if delivery.status != 'delivered':
            return Response(
                {'detail': 'Vous ne pouvez noter que les livraisons terminées'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Vérifier que l'utilisateur est le merchant de cette livraison
        if not hasattr(request.user, 'merchant_profile') or \
           delivery.merchant.id != request.user.merchant_profile.id:
            return Response(
                {'detail': 'Vous ne pouvez noter que vos propres livraisons'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        # Vérifier si une notation existe déjà
        if hasattr(delivery, 'rating'):
            return Response(
                {'detail': 'Cette livraison a déjà été notée'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Créer la notation
        serializer = DeliveryRatingSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save(delivery=delivery)
        
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    
    @action(detail=True, methods=['GET'], url_path='report-pdf')
    def generate_pdf_report(self, request, pk=None):
        """
        Génère un rapport PDF pour une livraison.
        Accessible par le merchant/individual propriétaire ou les admins.
        """
        from .pdf_service import PDFReportService
        from django.http import HttpResponse
        
        delivery = self.get_object()
        
        # Vérifier les permissions
        if not request.user.is_staff:
            # Vérifier que c'est le merchant/individual de la livraison
            if delivery.merchant and delivery.merchant.user != request.user:
                return Response(
                    {'detail': 'Vous n\'avez pas accès à ce rapport'},
                    status=status.HTTP_403_FORBIDDEN
                )
            elif not delivery.merchant and not hasattr(request.user, 'individual_profile'):
                return Response(
                    {'detail': 'Vous n\'avez pas accès à ce rapport'},
                    status=status.HTTP_403_FORBIDDEN
                )
        
        try:
            pdf_content = PDFReportService.generate_delivery_report(delivery)
            # `generate_delivery_report` retourne un BytesIO; lire son contenu
            try:
                pdf_bytes = pdf_content.read()
            except Exception:
                logger.exception('Failed to read PDF BytesIO')
                pdf_bytes = b''

            response = HttpResponse(pdf_bytes, content_type='application/pdf')
            response['Content-Disposition'] = f'attachment; filename="livraison_{delivery.tracking_number}.pdf"'
            
            return response
        except Exception as e:
            logger.error(f"Erreur génération PDF: {e}", exc_info=True)
            return Response(
                {'error': f'Erreur lors de la génération du PDF: {str(e)}'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
