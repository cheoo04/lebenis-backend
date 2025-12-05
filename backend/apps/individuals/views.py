from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from .models import Individual
from .serializers import IndividualSerializer
from core.permissions import IsIndividual
from apps.deliveries.models import Delivery
from apps.deliveries.serializers import DeliverySerializer
from django.db.models import Count, Sum
from django.utils import timezone
from datetime import timedelta
import logging

logger = logging.getLogger(__name__)


class IndividualViewSet(viewsets.ModelViewSet):
    queryset = Individual.objects.all()
    serializer_class = IndividualSerializer
    
    def get_permissions(self):
        """
        Permissions adaptées :
        - Actions individual: my_profile, update_profile, my_stats
        - list/retrieve : Authentifié
        """
        if self.action in ['my_profile', 'update_profile', 'my_stats']:
            permission_classes = [permissions.IsAuthenticated, IsIndividual]
        elif self.action in ['list', 'retrieve']:
            permission_classes = [permissions.IsAuthenticated]
        else:
            permission_classes = [permissions.IsAdminUser]
        return [permission() for permission in permission_classes]
    
    def get_queryset(self):
        """Support Swagger"""
        if getattr(self, 'swagger_fake_view', False):
            return Individual.objects.none()
        
        user = self.request.user
        
        if not user.is_authenticated:
            return Individual.objects.none()
        
        # Les particuliers voient uniquement leur propre profil
        if user.user_type == 'individual':
            return Individual.objects.filter(user=user)
        
        # Admins voient tout
        return Individual.objects.all()
    
    @action(detail=False, methods=['GET'], permission_classes=[IsIndividual])
    def my_profile(self, request):
        """
        GET /api/v1/individuals/my-profile/
        
        Récupérer le profil du particulier connecté.
        """
        try:
            individual = Individual.objects.get(user=request.user)
            serializer = IndividualSerializer(individual)
            return Response(serializer.data)
        except Individual.DoesNotExist:
            return Response(
                {'error': 'Profil particulier introuvable'},
                status=status.HTTP_404_NOT_FOUND
            )
    
    @action(detail=False, methods=['PATCH'], permission_classes=[IsIndividual])
    def update_profile(self, request):
        """
        PATCH /api/v1/individuals/update-profile/
        
        Mettre à jour le profil du particulier.
        """
        try:
            individual = Individual.objects.get(user=request.user)
            
            # Mise à jour des champs autorisés
            if 'address' in request.data:
                individual.address = request.data['address']
            
            individual.save()
            
            # Mise à jour des infos user si fournies
            user = request.user
            if 'first_name' in request.data:
                user.first_name = request.data['first_name']
            if 'last_name' in request.data:
                user.last_name = request.data['last_name']
            if 'phone' in request.data:
                user.phone = request.data['phone']
            user.save()
            
            serializer = IndividualSerializer(individual)
            return Response({
                'success': True,
                'message': 'Profil mis à jour avec succès',
                'individual': serializer.data
            })
            
        except Individual.DoesNotExist:
            return Response(
                {'error': 'Profil particulier introuvable'},
                status=status.HTTP_404_NOT_FOUND
            )
    
    @action(detail=False, methods=['GET'], permission_classes=[IsIndividual])
    def my_stats(self, request):
        """
        GET /api/v1/individuals/my-stats/?period=30
        
        Statistiques du particulier connecté.
        """
        try:
            individual = Individual.objects.get(user=request.user)
        except Individual.DoesNotExist:
            return Response(
                {'error': 'Profil particulier introuvable'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        period_days = int(request.query_params.get('period', 30))
        period_start = timezone.now() - timedelta(days=period_days)
        
        # Statistiques des livraisons créées par le particulier
        deliveries = Delivery.objects.filter(
            created_by=request.user,
            merchant__isnull=True  # Livraisons de particuliers
        )
        period_deliveries = deliveries.filter(created_at__gte=period_start)
        
        total_deliveries = deliveries.count()
        period_count = period_deliveries.count()
        delivered_count = period_deliveries.filter(status='delivered').count()
        cancelled_count = period_deliveries.filter(status='cancelled').count()
        pending_count = period_deliveries.filter(status='pending').count()
        in_progress_count = period_deliveries.filter(
            status__in=['assigned', 'picked_up', 'in_transit']
        ).count()
        
        # Coût total des livraisons
        total_cost = period_deliveries.filter(
            status='delivered'
        ).aggregate(total=Sum('calculated_price'))['total'] or 0
        
        # Taux de succès
        success_rate = (delivered_count / period_count * 100) if period_count > 0 else 0
        
        return Response({
            'individual': {
                'id': str(individual.id),
                'full_name': individual.full_name,
            },
            'period_days': period_days,
            'deliveries': {
                'total_all_time': total_deliveries,
                'period_total': period_count,
                'delivered': delivered_count,
                'cancelled': cancelled_count,
                'pending': pending_count,
                'in_progress': in_progress_count,
                'success_rate': round(success_rate, 1),
            },
            'costs': {
                'total_spent': float(total_cost),
            },
        })
