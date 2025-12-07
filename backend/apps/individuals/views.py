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
        - Actions individual: my_profile, update_profile, my_stats, profile, update_profile_endpoint
        - list/retrieve : Authentifié
        """
        if self.action in ['my_profile', 'update_profile', 'my_stats', 'profile', 'update_profile_endpoint', 'my_profile']:
            permission_classes = [permissions.IsAuthenticated]
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
        
        # Les utilisateurs voient uniquement leur propre profil
        # Sauf si c'est un admin
        if user.is_staff:
            return Individual.objects.all()
        
        return Individual.objects.filter(user=user)
    
    @action(detail=False, methods=['GET'], url_path='profile', permission_classes=[permissions.IsAuthenticated], name='profile')
    def profile(self, request):
        """
        GET /api/v1/individuals/profile/
        
        Récupérer le profil du particulier connecté.
        Crée automatiquement s'il n'existe pas encore.
        """
        if not request.user.is_authenticated:
            return Response(
                {'error': 'Non authentifié'},
                status=status.HTTP_401_UNAUTHORIZED
            )
        
        try:
            individual = Individual.objects.get(user=request.user)
            logger.info(f"✅ Profil particulier trouvé pour {request.user.email}")
        except Individual.DoesNotExist:
            # Créer automatiquement le profil si non existant
            individual = Individual.objects.create(user=request.user)
            logger.info(f"✅ Profil particulier créé automatiquement pour {request.user.email}")
        
        serializer = IndividualSerializer(individual)
        data = serializer.data
        
        # Ajouter les infos user
        data['user_id'] = str(request.user.id)
        data['email'] = request.user.email
        data['first_name'] = request.user.first_name
        data['last_name'] = request.user.last_name
        data['phone'] = getattr(request.user, 'phone', '')
        
        return Response(data)
    
    @action(detail=False, methods=['GET'], url_path='my-profile', permission_classes=[permissions.IsAuthenticated], name='my_profile')
    def my_profile(self, request):
        """
        GET /api/v1/individuals/my-profile/
        
        Récupérer le profil du particulier connecté (alias de profile).
        """
        return self.profile(request)
    
    @action(detail=False, methods=['PATCH'], url_path='profile', permission_classes=[permissions.IsAuthenticated], name='update_profile_endpoint')
    def update_profile_endpoint(self, request):
        """
        PATCH /api/v1/individuals/profile/
        
        Mettre à jour le profil du particulier connecté.
        """
        try:
            individual = Individual.objects.get(user=request.user)
        except Individual.DoesNotExist:
            return Response(
                {'error': 'Profil particulier introuvable. Veuillez d\'abord créer votre profil.'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        # Mise à jour des champs autorisés
        if 'address' in request.data:
            individual.address = request.data['address']
        
        individual.save()
        
        # Mise à jour des infos user si fournies
        user = request.user
        updated_fields = []
        if 'first_name' in request.data:
            user.first_name = request.data['first_name']
            updated_fields.append('first_name')
        if 'last_name' in request.data:
            user.last_name = request.data['last_name']
            updated_fields.append('last_name')
        if 'phone' in request.data:
            user.phone = request.data['phone']
            updated_fields.append('phone')
        
        if updated_fields:
            user.save()
            logger.info(f"✅ Profil particulier mis à jour: {updated_fields} pour {user.email}")
        
        serializer = IndividualSerializer(individual)
        return Response(serializer.data)
    
    @action(detail=False, methods=['PATCH'], permission_classes=[IsIndividual])
    def update_profile(self, request):
        """
        PATCH /api/v1/individuals/update-profile/
        
        Mettre à jour le profil du particulier (alias).
        """
        return self.update_profile_endpoint(request)
    
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
            status__in=['in_progress']
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
