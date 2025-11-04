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

from .models import Delivery
from .serializers import DeliverySerializer, DeliveryCreateSerializer
from .services import DeliveryAssignmentService, RouteOptimizationService
from apps.pricing.calculator import PricingCalculator
from apps.merchants.models import Merchant
from apps.drivers.models import Driver
from core.permissions import IsMerchant, IsDriver, IsAdmin

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
        - create: Merchants uniquement
        - assign/reassign: Admins uniquement
        - accept/reject: Drivers uniquement
        - list/retrieve: Tous authentifiés
        """
        if self.action == 'create':
            permission_classes = [IsMerchant]
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
        """Calcule le prix automatiquement lors de la création"""
        try:
            # Récupère le merchant
            merchant = Merchant.objects.filter(user=self.request.user).first()
            if not merchant:
                raise ValidationError("Vous n'avez pas de profil merchant")
            
            # Récupère l'adresse principale
            pickup_address = merchant.addresses.filter(is_primary=True).first()
            if not pickup_address:
                raise ValidationError("Vous devez avoir une adresse principale")
            
            # Prépare les données pour le calcul
            delivery_data = serializer.validated_data
            pricing_data = {
                'pickup_commune': pickup_address.commune,
                'delivery_commune': delivery_data.get('delivery_commune'),
                'package_weight_kg': float(delivery_data.get('package_weight_kg', 0)),
                'is_fragile': delivery_data.get('is_fragile', False),
                'scheduling_type': delivery_data.get('scheduling_type', 'immediate'),
            }
            
            # Calcule le prix
            calculator = PricingCalculator()
            price_result = calculator.calculate_price(pricing_data)
            calculated_price = price_result['total_price']
            
            # Valide le prix
            if calculated_price <= 0:
                raise ValidationError("Le prix calculé est invalide")
            
            # Sauvegarde la livraison
            serializer.save(
                merchant=merchant,
                calculated_price=calculated_price
            )
            
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
                return Delivery.objects.filter(merchant=merchant).select_related('merchant', 'driver')
            except Merchant.DoesNotExist:
                return Delivery.objects.none()
        
        elif user.user_type == 'driver':
            # Drivers voient leurs livraisons assignées
            try:
                driver = Driver.objects.get(user=user)
                return Delivery.objects.filter(driver=driver).select_related('merchant', 'driver')
            except Driver.DoesNotExist:
                return Delivery.objects.none()
        
        # Admins voient tout
        return Delivery.objects.all().select_related('merchant', 'driver')
    
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
        
        except ValidationError as e:
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
        
        except ValidationError as e:
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
        
        except ValidationError as e:
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
        delivery = self.get_object()
        
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
        
        except ValidationError as e:
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
        if delivery.status != 'assigned':
            return Response(
                {'error': f'Impossible de confirmer la récupération. Statut actuel: {delivery.status}'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Mettre à jour le statut
        delivery.status = 'picked_up'
        delivery.picked_up_at = timezone.now()
        delivery.save(update_fields=['status', 'picked_up_at', 'updated_at'])
        
        logger.info(f"✅ Livraison {delivery.tracking_number} récupérée par driver {driver.user.email}")
        
        serializer = DeliverySerializer(delivery)
        return Response({
            'success': True,
            'message': 'Colis récupéré avec succès',
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
        
        # Vérifier le statut actuel (doit être picked_up ou in_transit)
        if delivery.status not in ['picked_up', 'in_transit']:
            return Response(
                {'error': f'Impossible de confirmer la livraison. Statut actuel: {delivery.status}'},
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
        
        # Mettre à jour les stats du driver
        driver.total_deliveries += 1
        driver.successful_deliveries += 1
        driver.save(update_fields=['total_deliveries', 'successful_deliveries', 'updated_at'])
        
        logger.info(f"✅ Livraison {delivery.tracking_number} confirmée par driver {driver.user.email}")
        
        serializer = DeliverySerializer(delivery)
        return Response({
            'success': True,
            'message': 'Livraison confirmée avec succès',
            'delivery': serializer.data
        }, status=status.HTTP_200_OK)
    
    @action(detail=True, methods=['POST'], permission_classes=[IsDriver])
    def cancel(self, request, pk=None):
        """
        POST /api/v1/deliveries/{id}/cancel/
        
        Le livreur annule une livraison.
        
        Body JSON :
        {
            "reason": "Raison de l'annulation"
        }
        """
        delivery = self.get_object()
        reason = request.data.get('reason', 'Annulé par le livreur')
        
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
        
        logger.warning(f"⚠️ Livraison {delivery.tracking_number} annulée par driver {driver.user.email}: {reason}")
        
        serializer = DeliverySerializer(delivery)
        return Response({
            'success': True,
            'message': 'Livraison annulée',
            'delivery': serializer.data
        }, status=status.HTTP_200_OK)
    
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
        stats_by_status = period_deliveries.aggregate(
            total=Count('id'),
            pending=Count('id', filter=Q(status='pending')),
            assigned=Count('id', filter=Q(status='assigned')),
            picked_up=Count('id', filter=Q(status='picked_up')),
            in_transit=Count('id', filter=Q(status='in_transit')),
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
