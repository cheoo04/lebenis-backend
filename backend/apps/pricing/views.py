# pricing/views.py
from django.db import transaction
from rest_framework import viewsets, filters, permissions, status
from rest_framework.decorators import action
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, IsAdminUser
from .assign_permissions import AssignZonesPermissionMixin
from .permissions import PricingViewSetPermissionMixin
from .assign_serializers import AssignZonesSerializer
import logging
from .models import PricingZone, ZonePricingMatrix
from .serializers import PricingZoneSerializer, ZonePricingMatrixSerializer, CalculatePriceSerializer
from .calculator import PricingCalculator
from apps.drivers.models import DriverZone, Driver


# ============================================================================
# VIEWSET : GESTION DES ZONES TARIFAIRES
# ============================================================================

class PricingZoneViewSet(PricingViewSetPermissionMixin, viewsets.ModelViewSet):
    queryset = PricingZone.objects.all()
    serializer_class = PricingZoneSerializer
    filter_backends = [filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['zone_name', 'commune', 'quartier']
    ordering_fields = ['zone_name', 'commune']


    @action(detail=False, methods=['post'], url_path='assign')
    def assign(self, request):
        """
        Permet à un livreur authentifié de définir ses zones de travail.
        """
        logger = logging.getLogger('django')
        serializer = AssignZonesSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        zone_ids = serializer.validated_data['zone_ids']
        logger.info(f"[assign_zones] Tentative assignation zones: user.id={request.user.id}, email={getattr(request.user, 'email', None)}, zone_ids={zone_ids}")
        try:
            driver = Driver.objects.get(user=request.user)
            logger.info(f"[assign_zones] Driver trouvé: id={driver.id}, user_id={driver.user.id}")
        except Exception as e:
            logger.error(f"[assign_zones] Aucun profil Driver pour user.id={request.user.id}, erreur={e}")
            return Response({'detail': "Seuls les livreurs peuvent modifier leurs zones. Aucun profil driver trouvé."}, status=403)
        with transaction.atomic():
            # Récupère les communes actuelles du driver
            current_communes = set(DriverZone.objects.filter(driver=driver).values_list('commune', flat=True))
            # Récupère les nouvelles communes à assigner
            new_communes = set()
            for zone_id in zone_ids:
                try:
                    pricing_zone = PricingZone.objects.get(id=zone_id)
                except PricingZone.DoesNotExist:
                    logger.error(f"[assign_zones] Zone introuvable: {zone_id}")
                    return Response({'detail': f"Zone introuvable: {zone_id}"}, status=400)
                new_communes.add(pricing_zone.commune)
            # Supprime les communes qui ne sont plus sélectionnées
            to_remove = current_communes - new_communes
            if to_remove:
                DriverZone.objects.filter(driver=driver, commune__in=to_remove).delete()
            # Ajoute seulement les nouvelles communes non déjà présentes
            to_add = new_communes - current_communes
            for commune in to_add:
                DriverZone.objects.create(driver=driver, commune=commune)
        logger.info(f"[assign_zones] Zones assignées avec succès pour driver.id={driver.id}, zones={zone_ids}")
        return Response({'success': True, 'assigned_zone_ids': zone_ids})

    @action(detail=False, methods=['post'], url_path='calculate', permission_classes=[permissions.AllowAny])
    def calculate(self, request):
        """
        Endpoint pour calculer le prix d'une livraison.
        Accessible sans authentification pour permettre aux particuliers de calculer les prix.
        """
        try:
            serializer = CalculatePriceSerializer(data=request.data)
            if not serializer.is_valid():
                return Response({'errors': serializer.errors}, status=status.HTTP_400_BAD_REQUEST)
            validated_data = serializer.validated_data
            pickup_coords = None
            if validated_data.get('pickup_latitude') and validated_data.get('pickup_longitude'):
                pickup_coords = (
                    float(validated_data['pickup_latitude']),
                    float(validated_data['pickup_longitude'])
                )
            delivery_coords = None
            if validated_data.get('delivery_latitude') and validated_data.get('delivery_longitude'):
                delivery_coords = (
                    float(validated_data['delivery_latitude']),
                    float(validated_data['delivery_longitude'])
                )
            if pickup_coords:
                validated_data['pickup_coords'] = pickup_coords
            if delivery_coords:
                validated_data['delivery_coords'] = delivery_coords
            calculator = PricingCalculator()
            result = calculator.calculate_price(validated_data)
            return Response(result, status=status.HTTP_200_OK)
        except ValueError as e:
            return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            import traceback
            return Response({'error': f'Erreur de calcul: {str(e)}', 'details': traceback.format_exc()}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


    @action(detail=False, methods=['get'], url_path='with-selection')
    def with_selection(self, request):
        """
        Retourne toutes les zones avec un champ 'selected' indiquant si la zone est assignée au livreur courant.
        Utilise une requête explicite Driver.objects.get(user=user) pour éviter les problèmes de cache ou de relation inverse.
        """
        user = request.user
        logger = logging.getLogger('django')
        try:
            driver = Driver.objects.get(user=user)
            logger.info(f"[with_selection] Driver trouvé: id={driver.id}, user_id={driver.user.id}")
        except Exception as e:
            logger.error(f"[with_selection] Aucun profil Driver trouvé pour user.id={user.id}, email={getattr(user, 'email', None)}, erreur={e}")
            return Response({'detail': "Seuls les livreurs peuvent accéder à leurs zones. Aucun profil driver trouvé pour cet utilisateur."}, status=403)
        queryset = self.get_queryset()
        serializer = PricingZoneSerializer(queryset, many=True, context={'request': request})
        return Response(serializer.data)


# ============================================================================
# VIEWSET : GESTION DE LA MATRICE TARIFAIRE
# ============================================================================

    
    
class ZonePricingMatrixViewSet(PricingViewSetPermissionMixin, viewsets.ModelViewSet):
    """
    ViewSet pour gérer la matrice tarifaire (paires de zones).

    Endpoints disponibles :
    - GET /api/v1/pricing/matrix/ - Liste toutes les matrices
    - POST /api/v1/pricing/matrix/ - Créer une matrice (admin)
    - GET /api/v1/pricing/matrix/{id}/ - Détail d'une matrice
    - PUT /api/v1/pricing/matrix/{id}/ - Modifier une matrice (admin)
    - DELETE /api/v1/pricing/matrix/{id}/ - Supprimer une matrice (admin)
    """
    queryset = ZonePricingMatrix.objects.select_related(
        'origin_zone',
        'destination_zone'
    ).all()
    serializer_class = ZonePricingMatrixSerializer
    # Recherche par zones
    filter_backends = [filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['origin_zone__zone_name', 'destination_zone__zone_name']
    ordering_fields = ['effective_from', 'base_rate']
