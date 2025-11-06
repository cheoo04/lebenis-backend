"""
Service d'analytics pour générer des statistiques et rapports
"""
from django.db.models import Count, Sum, Avg, Q, F
from django.db.models.functions import TruncDate, TruncHour
from django.utils import timezone
from datetime import datetime, timedelta
from decimal import Decimal
from typing import Dict, List, Optional, Tuple
import logging

from apps.deliveries.models import Delivery
from apps.drivers.models import Driver
from apps.payments.models import DriverEarning

logger = logging.getLogger(__name__)


class AnalyticsService:
    """
    Service centralisé pour toutes les analytics du dashboard livreur
    """
    
    @staticmethod
    def get_driver_stats_summary(
        driver: Driver,
        start_date: Optional[datetime] = None,
        end_date: Optional[datetime] = None
    ) -> Dict:
        """
        Résumé des statistiques d'un livreur
        
        Args:
            driver: Instance du livreur
            start_date: Date de début (optionnel)
            end_date: Date de fin (optionnel)
            
        Returns:
            Dict avec: total_deliveries, completed_deliveries, total_earnings,
                      average_rating, distance_km, success_rate
        """
        # Filtrer les livraisons
        deliveries = Delivery.objects.filter(driver=driver)
        
        if start_date:
            deliveries = deliveries.filter(created_at__gte=start_date)
        if end_date:
            deliveries = deliveries.filter(created_at__lte=end_date)
        
        # Statistiques de base
        total_deliveries = deliveries.count()
        completed = deliveries.filter(status='delivered').count()
        cancelled = deliveries.filter(status='cancelled').count()
        
        # Revenus
        earnings = DriverEarning.objects.filter(driver=driver)
        if start_date:
            earnings = earnings.filter(created_at__gte=start_date)
        if end_date:
            earnings = earnings.filter(created_at__lte=end_date)
        
        total_earnings = earnings.aggregate(
            total=Sum('amount')
        )['total'] or Decimal('0.00')
        
        # Distance totale
        total_distance = deliveries.filter(
            status='delivered'
        ).aggregate(
            total=Sum('distance_km')
        )['total'] or Decimal('0.00')
        
        # Taux de succès
        success_rate = (completed / total_deliveries * 100) if total_deliveries > 0 else 0
        
        return {
            'total_deliveries': total_deliveries,
            'completed_deliveries': completed,
            'cancelled_deliveries': cancelled,
            'in_progress': total_deliveries - completed - cancelled,
            'total_earnings': float(total_earnings),
            'total_distance_km': float(total_distance),
            'success_rate': round(success_rate, 2),
            'average_delivery_value': float(total_earnings / completed) if completed > 0 else 0,
        }
    
    @staticmethod
    def get_deliveries_timeline(
        driver: Driver,
        start_date: datetime,
        end_date: datetime,
        granularity: str = 'day'
    ) -> List[Dict]:
        """
        Évolution des livraisons dans le temps
        
        Args:
            driver: Instance du livreur
            start_date: Date de début
            end_date: Date de fin
            granularity: 'day' ou 'hour'
            
        Returns:
            Liste de dicts avec date, count, earnings
        """
        deliveries = Delivery.objects.filter(
            driver=driver,
            created_at__gte=start_date,
            created_at__lte=end_date,
            status='delivered'
        )
        
        if granularity == 'hour':
            deliveries = deliveries.annotate(
                period=TruncHour('delivered_at')
            )
        else:
            deliveries = deliveries.annotate(
                period=TruncDate('delivered_at')
            )
        
        stats = deliveries.values('period').annotate(
            count=Count('id'),
            earnings=Sum('actual_price')
        ).order_by('period')
        
        return [
            {
                'date': item['period'].isoformat() if item['period'] else None,
                'deliveries': item['count'],
                'earnings': float(item['earnings'] or 0),
            }
            for item in stats
        ]
    
    @staticmethod
    def get_deliveries_by_status(
        driver: Driver,
        start_date: Optional[datetime] = None,
        end_date: Optional[datetime] = None
    ) -> Dict[str, int]:
        """
        Répartition des livraisons par statut
        
        Returns:
            Dict avec count par status
        """
        deliveries = Delivery.objects.filter(driver=driver)
        
        if start_date:
            deliveries = deliveries.filter(created_at__gte=start_date)
        if end_date:
            deliveries = deliveries.filter(created_at__lte=end_date)
        
        stats = deliveries.values('status').annotate(
            count=Count('id')
        )
        
        return {
            item['status']: item['count']
            for item in stats
        }
    
    @staticmethod
    def get_deliveries_by_commune(
        driver: Driver,
        start_date: Optional[datetime] = None,
        end_date: Optional[datetime] = None
    ) -> List[Dict]:
        """
        Livraisons par commune (pour la heatmap)
        
        Returns:
            Liste de dicts avec commune, count, coordinates
        """
        deliveries = Delivery.objects.filter(
            driver=driver,
            status='delivered'
        )
        
        if start_date:
            deliveries = deliveries.filter(delivered_at__gte=start_date)
        if end_date:
            deliveries = deliveries.filter(delivered_at__lte=end_date)
        
        # Grouper par commune
        stats = deliveries.values(
            'delivery_commune',
            'delivery_latitude',
            'delivery_longitude'
        ).annotate(
            count=Count('id')
        )
        
        return [
            {
                'commune': item['delivery_commune'],
                'deliveries': item['count'],
                'latitude': float(item['delivery_latitude']) if item['delivery_latitude'] else None,
                'longitude': float(item['delivery_longitude']) if item['delivery_longitude'] else None,
            }
            for item in stats
            if item['delivery_latitude'] and item['delivery_longitude']
        ]
    
    @staticmethod
    def get_heatmap_coordinates(
        driver: Driver,
        start_date: Optional[datetime] = None,
        end_date: Optional[datetime] = None,
        max_points: int = 500
    ) -> List[Dict]:
        """
        Points GPS pour la heatmap (toutes les livraisons)
        
        Args:
            driver: Instance du livreur
            start_date: Date de début
            end_date: Date de fin
            max_points: Nombre max de points (pour performance)
            
        Returns:
            Liste de {'lat': float, 'lng': float, 'weight': int}
        """
        deliveries = Delivery.objects.filter(
            driver=driver,
            status='delivered',
            delivery_latitude__isnull=False,
            delivery_longitude__isnull=False
        )
        
        if start_date:
            deliveries = deliveries.filter(delivered_at__gte=start_date)
        if end_date:
            deliveries = deliveries.filter(delivered_at__lte=end_date)
        
        # Limiter le nombre de points
        deliveries = deliveries[:max_points]
        
        return [
            {
                'lat': float(delivery.delivery_latitude),
                'lng': float(delivery.delivery_longitude),
                'weight': 1,  # Peut être ajusté selon le montant
            }
            for delivery in deliveries
        ]
    
    @staticmethod
    def get_peak_hours_stats(
        driver: Driver,
        start_date: Optional[datetime] = None,
        end_date: Optional[datetime] = None
    ) -> List[Dict]:
        """
        Statistiques par heure de la journée
        
        Returns:
            Liste de dicts avec hour (0-23), deliveries, earnings
        """
        deliveries = Delivery.objects.filter(
            driver=driver,
            status='delivered',
            delivered_at__isnull=False
        )
        
        if start_date:
            deliveries = deliveries.filter(delivered_at__gte=start_date)
        if end_date:
            deliveries = deliveries.filter(delivered_at__lte=end_date)
        
        # Extraire l'heure et grouper
        from django.db.models.functions import ExtractHour
        
        stats = deliveries.annotate(
            hour=ExtractHour('delivered_at')
        ).values('hour').annotate(
            count=Count('id'),
            earnings=Sum('actual_price')
        ).order_by('hour')
        
        return [
            {
                'hour': item['hour'],
                'deliveries': item['count'],
                'earnings': float(item['earnings'] or 0),
            }
            for item in stats
        ]
    
    @staticmethod
    def get_distance_distribution(
        driver: Driver,
        start_date: Optional[datetime] = None,
        end_date: Optional[datetime] = None
    ) -> Dict:
        """
        Distribution des distances de livraison
        
        Returns:
            Dict avec ranges et counts
        """
        deliveries = Delivery.objects.filter(
            driver=driver,
            status='delivered',
            distance_km__isnull=False
        )
        
        if start_date:
            deliveries = deliveries.filter(delivered_at__gte=start_date)
        if end_date:
            deliveries = deliveries.filter(delivered_at__lte=end_date)
        
        # Définir les ranges
        ranges = {
            '0-5km': deliveries.filter(distance_km__lt=5).count(),
            '5-10km': deliveries.filter(distance_km__gte=5, distance_km__lt=10).count(),
            '10-15km': deliveries.filter(distance_km__gte=10, distance_km__lt=15).count(),
            '15-20km': deliveries.filter(distance_km__gte=15, distance_km__lt=20).count(),
            '20km+': deliveries.filter(distance_km__gte=20).count(),
        }
        
        return ranges
    
    @staticmethod
    def get_earnings_breakdown(
        driver: Driver,
        start_date: Optional[datetime] = None,
        end_date: Optional[datetime] = None
    ) -> Dict:
        """
        Détail des revenus
        
        Returns:
            Dict avec base_earnings, tips, bonuses, total
        """
        earnings = DriverEarning.objects.filter(driver=driver)
        
        if start_date:
            earnings = earnings.filter(created_at__gte=start_date)
        if end_date:
            earnings = earnings.filter(created_at__lte=end_date)
        
        # Agréger par type
        breakdown = earnings.values('earning_type').annotate(
            total=Sum('amount')
        )
        
        result = {
            'delivery': 0,
            'bonus': 0,
            'tip': 0,
            'adjustment': 0,
            'total': 0,
        }
        
        for item in breakdown:
            result[item['earning_type']] = float(item['total'] or 0)
        
        result['total'] = sum(result.values())
        
        return result
