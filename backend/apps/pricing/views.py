# pricing/views.py
from django.db import transaction
from rest_framework import viewsets, filters, permissions, status
from rest_framework.decorators import action
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, IsAdminUser
from .assign_serializers import AssignZonesSerializer

from .models import PricingZone, ZonePricingMatrix
from .serializers import PricingZoneSerializer, ZonePricingMatrixSerializer, CalculatePriceSerializer
from .calculator import PricingCalculator
from apps.drivers.models import DriverZone


# ============================================================================
# VIEWSET : GESTION DES ZONES TARIFAIRES
# ============================================================================

class PricingZoneViewSet(viewsets.ModelViewSet):
    """
    ViewSet pour gérer les zones tarifaires.
    
    Endpoints disponibles :
    - GET /api/v1/pricing/zones/ - Liste toutes les zones
    - POST /api/v1/pricing/zones/ - Créer une zone (admin)
    - GET /api/v1/pricing/zones/{id}/ - Détail d'une zone
    - PUT /api/v1/pricing/zones/{id}/ - Modifier une zone (admin)
    - DELETE /api/v1/pricing/zones/{id}/ - Supprimer une zone (admin)
    """
    
    queryset = PricingZone.objects.all()
    serializer_class = PricingZoneSerializer
    
    # Recherche par zone_name, commune, quartier
    filter_backends = [filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['zone_name', 'commune', 'quartier']
    ordering_fields = ['zone_name', 'commune']
    
    def get_permissions(self):
        """
        Permissions :
        - Liste/Détail : Authentifié
        - Créer/Modifier/Supprimer : Admin uniquement
        """
        if self.action in ['list', 'retrieve']:
            permission_classes = [IsAuthenticated]
        else:
            permission_classes = [IsAdminUser]
        
        return [permission() for permission in permission_classes]


    @action(detail=False, methods=['get'], url_path='with-selection', permission_classes=[IsAuthenticated])
    def with_selection(self, request):
        """
        Retourne toutes les zones avec un champ 'selected' indiquant si la zone est assignée au livreur courant.
        """
        queryset = self.get_queryset()
        serializer = PricingZoneSerializer(queryset, many=True, context={'request': request})
        return Response(serializer.data)


# ============================================================================
# VIEWSET : GESTION DE LA MATRICE TARIFAIRE
# ============================================================================

class ZonePricingMatrixViewSet(viewsets.ModelViewSet):
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
    
    def get_permissions(self):
        """
        Permissions :
        - Liste/Détail : Authentifié
        - Créer/Modifier/Supprimer : Admin uniquement
        """
        if self.action in ['list', 'retrieve']:
            permission_classes = [IsAuthenticated]
        else:
            permission_classes = [IsAdminUser]
        
        return [permission() for permission in permission_classes]

# ============================================================================
# VUE API : CALCUL DE PRIX (MODIFIÉE)
# ============================================================================

class CalculatePriceView(APIView):
    """
    POST /api/v1/pricing/calculate/
    
    Endpoint pour calculer le prix d'une livraison.
    Utilise la classe PricingCalculator pour faire les calculs.
    
    """
    
    permission_classes = [IsAuthenticated]
    
    def get_serializer(self):
        """
        Retourne une instance du serializer.
        Nécessaire pour que Swagger génère le formulaire.
        """
        return CalculatePriceSerializer()
    
    def post(self, request):
        try:
            # Valider les données entrantes avec le serializer
            serializer = CalculatePriceSerializer(data=request.data)
            
            if not serializer.is_valid():
                # Retourner les erreurs de validation
                return Response(
                    {'errors': serializer.errors},
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            # Préparer les données pour le calculateur
            validated_data = serializer.validated_data
            
            # Construire les tuples de coordonnées si fournies
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
            
            # Ajouter les coordonnées aux données
            if pickup_coords:
                validated_data['pickup_coords'] = pickup_coords
            if delivery_coords:
                validated_data['delivery_coords'] = delivery_coords
            
            # Créer une instance du calculateur
            calculator = PricingCalculator()
            
            # Appeler calculate_price avec les données validées
            result = calculator.calculate_price(validated_data)
            
            # Retourner le résultat
            return Response(result, status=status.HTTP_200_OK)
        
        except ValueError as e:
            # Erreur métier (zone non trouvée, commune invalide, etc.)
            return Response(
                {'error': str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        except Exception as e:
            # Erreur générale de calcul
            import traceback
            return Response(
                {
                    'error': f'Erreur de calcul: {str(e)}',
                    'details': traceback.format_exc()  # Pour déboguer
                },
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


# ==========================================================================
# ENDPOINT DÉDIÉ : ASSIGNATION DES ZONES PAR LE LIVREUR
# ==========================================================================

class AssignZonesView(APIView):
    """
    POST /api/v1/pricing/zones/assign/
    Permet à un livreur authentifié de définir ses zones de travail.
    """
    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = AssignZonesSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        zone_ids = serializer.validated_data['zone_ids']
        driver = getattr(request.user, 'driver_profile', None)
        if not driver:
            return Response({'detail': "Seuls les livreurs peuvent modifier leurs zones."}, status=403)
        with transaction.atomic():
            # Supprimer les anciennes zones
            DriverZone.objects.filter(driver=driver).delete()
            # Créer les nouvelles zones
            for zone_id in zone_ids:
                # On récupère la commune de la zone tarifaire
                from apps.pricing.models import PricingZone
                try:
                    pricing_zone = PricingZone.objects.get(id=zone_id)
                except PricingZone.DoesNotExist:
                    return Response({'detail': f"Zone introuvable: {zone_id}"}, status=400)
                DriverZone.objects.create(driver=driver, commune=pricing_zone.commune)
        return Response({'success': True, 'assigned_zone_ids': zone_ids})