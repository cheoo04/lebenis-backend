# apps/drivers/views.py

from rest_framework import viewsets, permissions, filters, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django.db.models import Q, Count, Sum, Avg
from django.utils import timezone
from datetime import timedelta
from decimal import Decimal

from .models import Driver, DriverZone
from .serializers import DriverSerializer
from apps.deliveries.models import Delivery
from apps.deliveries.serializers import DeliverySerializer
from apps.payments.models import DriverEarning
from core.permissions import IsDriver, IsAdmin


class DriverViewSet(viewsets.ModelViewSet):
    """
    ViewSet pour gérer les livreurs avec endpoints spécialisés
    """
    queryset = Driver.objects.all()
    serializer_class = DriverSerializer

    filter_backends = [filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['user__email', 'vehicle_registration', 'user__first_name', 'user__last_name']
    ordering_fields = ['created_at', 'rating']

    def get_permissions(self):
        """
        Permissions adaptées :
        - Actions driver: my_deliveries, available_deliveries, me, my_stats, my_earnings, update_location, toggle_availability
        - Actions admin: available, stats
        - list/retrieve : Authentifié
        - create/update/delete : Admin uniquement
        """
        if self.action in [
            'my_deliveries', 
            'available_deliveries', 
            'me', 
            'my_stats', 
            'my_earnings',
            'update_location', 
            'toggle_availability'
        ]:
            permission_classes = [IsDriver]
        elif self.action in ['available', 'stats']:
            permission_classes = [IsAdmin]
        elif self.action in ['list', 'retrieve']:
            permission_classes = [permissions.IsAuthenticated]
        else:
            permission_classes = [permissions.IsAdminUser]
        return [permission() for permission in permission_classes]
    
    # =========================================================================
    # ENDPOINTS POUR LIVREURS
    # =========================================================================
    
    @action(detail=False, methods=['GET'])
    def my_deliveries(self, request):
        """
        GET /api/v1/drivers/my-deliveries/
        
        Retourne toutes les livraisons du livreur connecté.
        
        Query params optionnels :
        - status: Filtrer par statut (ex: ?status=assigned,pickup_in_progress)
        - date_from: Date de début (ex: ?date_from=2025-01-01)
        - date_to: Date de fin
        """
        try:
            driver = Driver.objects.get(user=request.user)
        except Driver.DoesNotExist:
            return Response(
                {'error': 'Profil livreur introuvable'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        # Base query
        deliveries = Delivery.objects.filter(driver=driver).select_related('merchant', 'driver')
        
        # Filtres optionnels
        status_filter = request.query_params.get('status')
        if status_filter:
            statuses = status_filter.split(',')
            deliveries = deliveries.filter(status__in=statuses)
        
        date_from = request.query_params.get('date_from')
        if date_from:
            deliveries = deliveries.filter(created_at__gte=date_from)
        
        date_to = request.query_params.get('date_to')
        if date_to:
            deliveries = deliveries.filter(created_at__lte=date_to)
        
        # Ordre : les plus récentes en premier
        deliveries = deliveries.order_by('-created_at')
        
        # Pagination
        page = self.paginate_queryset(deliveries)
        if page is not None:
            serializer = DeliverySerializer(page, many=True)
            return self.get_paginated_response(serializer.data)
        
        serializer = DeliverySerializer(deliveries, many=True)
        return Response(serializer.data)
    
    @action(detail=False, methods=['GET'])
    def available_deliveries(self, request):
        """
        GET /api/v1/drivers/available-deliveries/
        
        Retourne les livraisons disponibles pour le livreur dans ses zones de travail.
        Affiche uniquement les livraisons en pending_assignment.
        """
        try:
            driver = Driver.objects.get(user=request.user)
        except Driver.DoesNotExist:
            return Response(
                {'error': 'Profil livreur introuvable'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        # Récupérer les zones du livreur
        driver_zones = DriverZone.objects.filter(driver=driver).values_list('commune', flat=True)
        
        # Livraisons disponibles dans les zones du livreur
        deliveries = Delivery.objects.filter(
            status='pending_assignment',
            delivery_commune__in=driver_zones,
            package_weight_kg__lte=driver.vehicle_capacity_kg  # Capacité suffisante
        ).select_related('merchant').order_by('-created_at')
        
        # Si le livreur n'a pas de zones définies, afficher toutes les livraisons disponibles
        if not driver_zones:
            deliveries = Delivery.objects.filter(
                status='pending_assignment',
                package_weight_kg__lte=driver.vehicle_capacity_kg
            ).select_related('merchant').order_by('-created_at')
        
        serializer = DeliverySerializer(deliveries, many=True)
        return Response({
            'count': deliveries.count(),
            'deliveries': serializer.data,
            'driver_zones': list(driver_zones) if driver_zones else []
        })
    
    @action(detail=False, methods=['POST'])
    def update_location(self, request):
        """
        POST /api/v1/drivers/update-location/
        
        Met à jour la position GPS du livreur.
        
        Body JSON (2 formats supportés):
        Format 1:
        {
            "latitude": 5.3467,
            "longitude": -4.0305
        }
        
        Format 2 (utilisé par l'app):
        {
            "current_latitude": 5.3467,
            "current_longitude": -4.0305
        }
        """
        try:
            driver = Driver.objects.get(user=request.user)
        except Driver.DoesNotExist:
            return Response(
                {'error': 'Profil livreur introuvable'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        # Support des 2 formats
        latitude = request.data.get('latitude') or request.data.get('current_latitude')
        longitude = request.data.get('longitude') or request.data.get('current_longitude')
        
        if latitude is None or longitude is None:
            return Response(
                {'error': 'Les champs latitude et longitude sont requis'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            driver.current_latitude = float(latitude)
            driver.current_longitude = float(longitude)
            driver.save(update_fields=['current_latitude', 'current_longitude', 'updated_at'])
            
            return Response({
                'success': True,
                'message': 'Position mise à jour',
                'latitude': driver.current_latitude,
                'longitude': driver.current_longitude
            })
        
        except (ValueError, TypeError):
            return Response(
                {'error': 'Coordonnées GPS invalides'},
                status=status.HTTP_400_BAD_REQUEST
            )
    
    @action(detail=False, methods=['POST'])
    def toggle_availability(self, request):
        """
        POST /api/v1/drivers/toggle-availability/
        
        Active/désactive la disponibilité du livreur.
        
        Body JSON (2 formats supportés):
        Format 1 (ancien):
        {
            "is_available": true
        }
        
        Format 2 (nouveau - utilisé par l'app):
        {
            "availability_status": "available"  // available, busy, offline
        }
        """
        try:
            driver = Driver.objects.get(user=request.user)
        except Driver.DoesNotExist:
            return Response(
                {'error': 'Profil livreur introuvable'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        # Support des 2 formats
        is_available = request.data.get('is_available')
        availability_status = request.data.get('availability_status')
        
        if availability_status is not None:
            # Format nouveau : availability_status ("available", "busy", "offline")
            if availability_status not in ['available', 'busy', 'offline']:
                return Response(
                    {'error': 'availability_status doit être: available, busy ou offline'},
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            driver.availability_status = availability_status
            driver.is_available = (availability_status == 'available')
            driver.save(update_fields=['availability_status', 'is_available', 'updated_at'])
            
            serializer = DriverSerializer(driver)
            return Response({
                'success': True,
                'availability_status': driver.availability_status,
                'is_available': driver.is_available,
                'message': f"Statut changé en: {availability_status}",
                'driver': serializer.data
            })
        
        elif is_available is not None:
            # Format ancien : is_available (boolean)
            driver.is_available = bool(is_available)
            driver.availability_status = 'available' if is_available else 'offline'
            driver.save(update_fields=['is_available', 'availability_status', 'updated_at'])
            
            serializer = DriverSerializer(driver)
            return Response({
                'success': True,
                'is_available': driver.is_available,
                'message': f"Vous êtes maintenant {'disponible' if driver.is_available else 'indisponible'}",
                'driver': serializer.data
            })
        
        else:
            return Response(
                {'error': 'Le champ is_available ou availability_status est requis'},
                status=status.HTTP_400_BAD_REQUEST
            )
    
    # =========================================================================
    # ENDPOINT ADMIN : LIVREURS DISPONIBLES PAR ZONE
    # =========================================================================
    
    @action(detail=False, methods=['GET'])
    def available(self, request):
        """
        GET /api/v1/drivers/available/?commune=Cocody
        
        Retourne les livreurs disponibles (pour assignation manuelle par admin).
        
        Query params :
        - commune: Filtre par commune (optionnel)
        - min_rating: Rating minimum (optionnel)
        """
        # Base : livreurs vérifiés et disponibles
        drivers = Driver.objects.filter(
            verification_status='verified',
            is_available=True
        ).select_related('user')
        
        # Filtre par commune
        commune = request.query_params.get('commune')
        if commune:
            drivers = drivers.filter(zones__commune__iexact=commune).distinct()
        
        # Filtre par rating minimum
        min_rating = request.query_params.get('min_rating')
        if min_rating:
            try:
                drivers = drivers.filter(rating__gte=float(min_rating))
            except ValueError:
                pass
        
        # Trier par rating décroissant
        drivers = drivers.order_by('-rating', '-successful_deliveries')
        
        serializer = DriverSerializer(drivers, many=True)
        return Response({
            'count': drivers.count(),
            'drivers': serializer.data,
            'filters': {
                'commune': commune,
                'min_rating': min_rating
            }
        })
    
    @action(detail=False, methods=['GET', 'PATCH'])
    def me(self, request):
        """
        GET /api/v1/drivers/me/
        Retourne le profil complet du driver connecté.
        
        PATCH /api/v1/drivers/me/
        Met à jour le profil driver et user.
        
        Body JSON accepté:
        {
            "phone": "0150171387",           # Champ User
            "profile_photo": "url",          # Champ User
            "vehicle_type": "moto",          # Champ Driver
            "vehicle_plate": "AB-1234-CD"    # Champ Driver (vehicle_registration)
        }
        """
        try:
            driver = Driver.objects.get(user=request.user)
        except Driver.DoesNotExist:
            return Response(
                {'error': 'Profil driver introuvable'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        if request.method == 'GET':
            serializer = DriverSerializer(driver)
            return Response(serializer.data)
        
        # PATCH - Mise à jour
        user = request.user
        data = request.data.copy()
        
        # Mettre à jour les champs User
        if 'phone' in data:
            user.phone = data.pop('phone')
        if 'profile_photo' in data:
            user.profile_photo = data.pop('profile_photo')
        
        if user._state.fields_cache:  # Si des champs User ont changé
            user.save()
        
        # Mapper vehicle_plate → vehicle_registration
        if 'vehicle_plate' in data:
            data['vehicle_registration'] = data.pop('vehicle_plate')
        
        # Mettre à jour Driver
        serializer = DriverSerializer(driver, data=data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response({
                'success': True,
                'message': 'Profil mis à jour avec succès',
                'driver': serializer.data
            })
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    @action(detail=False, methods=['GET'])
    def my_stats(self, request):
        """
        GET /api/v1/drivers/my-stats/?period=30
        
        Statistiques du driver connecté.
        """
        try:
            driver = Driver.objects.get(user=request.user)
        except Driver.DoesNotExist:
            return Response(
                {'error': 'Profil driver introuvable'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        period_days = int(request.query_params.get('period', 30))
        period_start = timezone.now() - timedelta(days=period_days)
        
        # Livraisons
        deliveries = Delivery.objects.filter(driver=driver)
        period_deliveries = deliveries.filter(created_at__gte=period_start)
        
        total_deliveries = deliveries.count()
        period_count = period_deliveries.count()
        delivered_count = period_deliveries.filter(status='delivered').count()
        cancelled_count = period_deliveries.filter(status='cancelled').count()
        current_count = period_deliveries.filter(
            status__in=['assigned', 'picked_up', 'in_transit']
        ).count()
        
        # Gains
        earnings = DriverEarning.objects.filter(driver=driver)
        period_earnings = earnings.filter(created_at__gte=period_start)
        
        total_earned = period_earnings.aggregate(total=Sum('total_earning'))['total'] or Decimal('0')
        pending_earnings = period_earnings.filter(status='pending').aggregate(
            total=Sum('total_earning'))['total'] or Decimal('0')
        approved_earnings = period_earnings.filter(status='approved').aggregate(
            total=Sum('total_earning'))['total'] or Decimal('0')
        paid_earnings = period_earnings.filter(status='paid').aggregate(
            total=Sum('total_earning'))['total'] or Decimal('0')
        
        # Taux de succès
        success_rate = (delivered_count / period_count * 100) if period_count > 0 else 0
        
        # Performance
        avg_delivery_time = period_deliveries.filter(
            status='delivered',
            delivered_at__isnull=False
        ).aggregate(
            avg=Avg('delivered_at')
        )
        
        return Response({
            'driver': {
                'id': str(driver.id),
                'name': driver.user.full_name,
                'rating': str(driver.rating or 0),
                'is_available': driver.is_available
            },
            'period_days': period_days,
            'deliveries': {
                'total_all_time': total_deliveries,
                'period_total': period_count,
                'delivered': delivered_count,
                'current': current_count,
                'cancelled': cancelled_count,
                'success_rate': round(success_rate, 2)
            },
            'earnings': {
                'total_earned': str(total_earned),
                'pending': str(pending_earnings),
                'approved': str(approved_earnings),
                'paid': str(paid_earnings)
            },
            'performance': {
                'rating': str(driver.rating or 0),
                'total_deliveries': driver.total_deliveries,
                'successful_deliveries': driver.successful_deliveries
            }
        })
    
    @action(detail=False, methods=['GET'], url_path='me/earnings')
    def my_earnings(self, request):
        """
        GET /api/v1/drivers/me/earnings/?period=30
        
        Retourne les gains détaillés du driver connecté.
        
        Query params:
        - period: nombre de jours (défaut: 30)
        """
        try:
            driver = Driver.objects.get(user=request.user)
        except Driver.DoesNotExist:
            return Response(
                {'error': 'Profil driver introuvable'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        period_days = int(request.query_params.get('period', 30))
        period_start = timezone.now() - timedelta(days=period_days)
        
        # Récupérer les gains
        earnings = DriverEarning.objects.filter(driver=driver)
        period_earnings = earnings.filter(created_at__gte=period_start)
        
        # Agréger par statut
        total_earned = period_earnings.aggregate(total=Sum('total_earning'))['total'] or Decimal('0')
        pending_earnings = period_earnings.filter(status='pending').aggregate(
            total=Sum('total_earning'))['total'] or Decimal('0')
        approved_earnings = period_earnings.filter(status='approved').aggregate(
            total=Sum('total_earning'))['total'] or Decimal('0')
        paid_earnings = period_earnings.filter(status='paid').aggregate(
            total=Sum('total_earning'))['total'] or Decimal('0')
        
        # Gains par jour (derniers 7 jours)
        last_7_days = timezone.now() - timedelta(days=7)
        daily_earnings = period_earnings.filter(created_at__gte=last_7_days).extra(
            select={'day': 'date(created_at)'}
        ).values('day').annotate(
            total=Sum('total_earning')
        ).order_by('day')
        
        return Response({
            'driver': {
                'id': str(driver.id),
                'name': driver.user.full_name,
                'is_available': driver.is_available
            },
            'period_days': period_days,
            'summary': {
                'total_earned': str(total_earned),
                'pending': str(pending_earnings),
                'approved': str(approved_earnings),
                'paid': str(paid_earnings)
            },
            'daily_breakdown': [
                {
                    'date': item['day'],
                    'amount': str(item['total'])
                }
                for item in daily_earnings
            ]
        })
    
    @action(detail=True, methods=['GET'])
    def stats(self, request, pk=None):
        """
        GET /api/v1/drivers/{id}/stats/?period=30
        
        Statistiques d'un driver (admin).
        """
        driver = self.get_object()
        period_days = int(request.query_params.get('period', 30))
        period_start = timezone.now() - timedelta(days=period_days)
        
        deliveries = Delivery.objects.filter(driver=driver)
        period_deliveries = deliveries.filter(created_at__gte=period_start)
        
        earnings = DriverEarning.objects.filter(driver=driver, created_at__gte=period_start)
        
        return Response({
            'driver': {
                'id': str(driver.id),
                'name': driver.user.full_name,
                'phone': driver.user.phone,
                'rating': str(driver.rating or 0),
                'vehicle_type': driver.vehicle_type
            },
            'period_days': period_days,
            'deliveries': {
                'total': period_deliveries.count(),
                'by_status': {
                    'pending': period_deliveries.filter(status='pending').count(),
                    'assigned': period_deliveries.filter(status='assigned').count(),
                    'picked_up': period_deliveries.filter(status='picked_up').count(),
                    'delivered': period_deliveries.filter(status='delivered').count(),
                    'cancelled': period_deliveries.filter(status='cancelled').count()
                }
            },
            'earnings': {
                'total': str(earnings.aggregate(total=Sum('total_earning'))['total'] or 0),
                'pending': str(earnings.filter(status='pending').aggregate(
                    total=Sum('total_earning'))['total'] or 0),
                'approved': str(earnings.filter(status='approved').aggregate(
                    total=Sum('total_earning'))['total'] or 0),
                'paid': str(earnings.filter(status='paid').aggregate(
                    total=Sum('total_earning'))['total'] or 0)
            }
        })
