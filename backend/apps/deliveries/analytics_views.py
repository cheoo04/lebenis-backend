"""
ViewSet pour les endpoints Analytics
"""
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
import logging

from .analytics_service import AnalyticsService
from .analytics_serializers import (
    DateRangeSerializer,
    StatsSummarySerializer,
    TimelineDataSerializer,
    CommuneStatsSerializer,
    HeatmapPointSerializer,
    PeakHourSerializer,
    EarningsBreakdownSerializer,
)

logger = logging.getLogger(__name__)


class AnalyticsViewSet(viewsets.ViewSet):
    """
    ViewSet pour les analytics du dashboard livreur
    
    Endpoints:
    - GET /analytics/summary/ - Résumé des stats
    - GET /analytics/timeline/ - Évolution dans le temps
    - GET /analytics/status-distribution/ - Répartition par statut
    - GET /analytics/commune-stats/ - Stats par commune
    - GET /analytics/heatmap/ - Points GPS pour heatmap
    - GET /analytics/peak-hours/ - Heures de pointe
    - GET /analytics/distance-distribution/ - Distribution des distances
    - GET /analytics/earnings-breakdown/ - Détail des revenus
    """
    
    permission_classes = [IsAuthenticated]
    
    def _get_driver(self, request):
        """Récupère le profil driver de l'utilisateur connecté"""
        if not hasattr(request.user, 'driver_profile'):
            return None
        return request.user.driver_profile
    
    def _validate_date_range(self, request):
        """Valide et retourne les paramètres de date"""
        serializer = DateRangeSerializer(data=request.query_params)
        serializer.is_valid(raise_exception=True)
        return serializer.validated_data
    
    @action(detail=False, methods=['GET'])
    def summary(self, request):
        """
        GET /analytics/summary/
        
        Résumé des statistiques du livreur.
        
        Query params:
            - period: today|week|month|year|custom (default: month)
            - start_date: ISO datetime (requis si period=custom)
            - end_date: ISO datetime (requis si period=custom)
        
        Returns:
            {
                "total_deliveries": 45,
                "completed_deliveries": 42,
                "cancelled_deliveries": 3,
                "in_progress": 0,
                "total_earnings": 125000.0,
                "total_distance_km": 234.5,
                "success_rate": 93.33,
                "average_delivery_value": 2976.19
            }
        """
        driver = self._get_driver(request)
        if not driver:
            return Response(
                {'error': 'Profil livreur introuvable'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        date_params = self._validate_date_range(request)
        
        stats = AnalyticsService.get_driver_stats_summary(
            driver=driver,
            start_date=date_params.get('start_date'),
            end_date=date_params.get('end_date')
        )
        
        serializer = StatsSummarySerializer(stats)
        return Response(serializer.data)
    
    @action(detail=False, methods=['GET'])
    def timeline(self, request):
        """
        GET /analytics/timeline/
        
        Évolution des livraisons et revenus dans le temps.
        
        Query params:
            - period: today|week|month|year|custom
            - granularity: day|hour (default: day)
        
        Returns:
            [
                {
                    "date": "2025-01-15",
                    "deliveries": 5,
                    "earnings": 15000.0
                },
                ...
            ]
        """
        driver = self._get_driver(request)
        if not driver:
            return Response(
                {'error': 'Profil livreur introuvable'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        date_params = self._validate_date_range(request)
        granularity = request.query_params.get('granularity', 'day')
        
        timeline = AnalyticsService.get_deliveries_timeline(
            driver=driver,
            start_date=date_params['start_date'],
            end_date=date_params['end_date'],
            granularity=granularity
        )
        
        serializer = TimelineDataSerializer(timeline, many=True)
        return Response(serializer.data)
    
    @action(detail=False, methods=['GET'])
    def status_distribution(self, request):
        """
        GET /analytics/status-distribution/
        
        Répartition des livraisons par statut.
        
        Returns:
            {
                "delivered": 42,
                "cancelled": 3,
                "in_transit": 2
            }
        """
        driver = self._get_driver(request)
        if not driver:
            return Response(
                {'error': 'Profil livreur introuvable'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        date_params = self._validate_date_range(request)
        
        distribution = AnalyticsService.get_deliveries_by_status(
            driver=driver,
            start_date=date_params.get('start_date'),
            end_date=date_params.get('end_date')
        )
        
        return Response(distribution)
    
    @action(detail=False, methods=['GET'])
    def commune_stats(self, request):
        """
        GET /analytics/commune-stats/
        
        Statistiques par commune.
        
        Returns:
            [
                {
                    "commune": "Cocody",
                    "deliveries": 15,
                    "latitude": 5.3599,
                    "longitude": -4.0082
                },
                ...
            ]
        """
        driver = self._get_driver(request)
        if not driver:
            return Response(
                {'error': 'Profil livreur introuvable'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        date_params = self._validate_date_range(request)
        
        stats = AnalyticsService.get_deliveries_by_commune(
            driver=driver,
            start_date=date_params.get('start_date'),
            end_date=date_params.get('end_date')
        )
        
        serializer = CommuneStatsSerializer(stats, many=True)
        return Response(serializer.data)
    
    @action(detail=False, methods=['GET'])
    def heatmap(self, request):
        """
        GET /analytics/heatmap/
        
        Points GPS pour afficher une heatmap.
        
        Query params:
            - max_points: Nombre max de points (default: 500)
        
        Returns:
            [
                {
                    "lat": 5.3599,
                    "lng": -4.0082,
                    "weight": 1
                },
                ...
            ]
        """
        driver = self._get_driver(request)
        if not driver:
            return Response(
                {'error': 'Profil livreur introuvable'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        date_params = self._validate_date_range(request)
        max_points = int(request.query_params.get('max_points', 500))
        
        points = AnalyticsService.get_heatmap_coordinates(
            driver=driver,
            start_date=date_params.get('start_date'),
            end_date=date_params.get('end_date'),
            max_points=max_points
        )
        
        serializer = HeatmapPointSerializer(points, many=True)
        return Response(serializer.data)
    
    @action(detail=False, methods=['GET'])
    def peak_hours(self, request):
        """
        GET /analytics/peak-hours/
        
        Statistiques par heure de la journée.
        
        Returns:
            [
                {
                    "hour": 9,
                    "deliveries": 5,
                    "earnings": 15000.0
                },
                ...
            ]
        """
        driver = self._get_driver(request)
        if not driver:
            return Response(
                {'error': 'Profil livreur introuvable'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        date_params = self._validate_date_range(request)
        
        stats = AnalyticsService.get_peak_hours_stats(
            driver=driver,
            start_date=date_params.get('start_date'),
            end_date=date_params.get('end_date')
        )
        
        serializer = PeakHourSerializer(stats, many=True)
        return Response(serializer.data)
    
    @action(detail=False, methods=['GET'])
    def distance_distribution(self, request):
        """
        GET /analytics/distance-distribution/
        
        Distribution des distances de livraison.
        
        Returns:
            {
                "0-5km": 20,
                "5-10km": 15,
                "10-15km": 8,
                "15-20km": 3,
                "20km+": 1
            }
        """
        driver = self._get_driver(request)
        if not driver:
            return Response(
                {'error': 'Profil livreur introuvable'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        date_params = self._validate_date_range(request)
        
        distribution = AnalyticsService.get_distance_distribution(
            driver=driver,
            start_date=date_params.get('start_date'),
            end_date=date_params.get('end_date')
        )
        
        return Response(distribution)
    
    @action(detail=False, methods=['GET'])
    def earnings_breakdown(self, request):
        """
        GET /analytics/earnings-breakdown/
        
        Détail des revenus par type.
        
        Returns:
            {
                "delivery": 100000.0,
                "bonus": 15000.0,
                "tip": 5000.0,
                "adjustment": 0.0,
                "total": 120000.0
            }
        """
        driver = self._get_driver(request)
        if not driver:
            return Response(
                {'error': 'Profil livreur introuvable'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        date_params = self._validate_date_range(request)
        
        breakdown = AnalyticsService.get_earnings_breakdown(
            driver=driver,
            start_date=date_params.get('start_date'),
            end_date=date_params.get('end_date')
        )
        
        serializer = EarningsBreakdownSerializer(breakdown)
        return Response(serializer.data)
