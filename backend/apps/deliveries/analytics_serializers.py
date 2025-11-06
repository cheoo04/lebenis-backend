"""
Serializers pour les endpoints Analytics
"""
from rest_framework import serializers
from datetime import datetime, timedelta
from django.utils import timezone


class DateRangeSerializer(serializers.Serializer):
    """Validation des paramètres de date"""
    start_date = serializers.DateTimeField(required=False)
    end_date = serializers.DateTimeField(required=False)
    period = serializers.ChoiceField(
        choices=['today', 'week', 'month', 'year', 'custom'],
        default='month'
    )
    
    def validate(self, data):
        """Calculer start_date et end_date selon le period"""
        period = data.get('period', 'month')
        now = timezone.now()
        
        if period == 'today':
            data['start_date'] = now.replace(hour=0, minute=0, second=0, microsecond=0)
            data['end_date'] = now
        elif period == 'week':
            data['start_date'] = now - timedelta(days=7)
            data['end_date'] = now
        elif period == 'month':
            data['start_date'] = now - timedelta(days=30)
            data['end_date'] = now
        elif period == 'year':
            data['start_date'] = now - timedelta(days=365)
            data['end_date'] = now
        elif period == 'custom':
            # Utiliser les dates fournies
            if not data.get('start_date') or not data.get('end_date'):
                raise serializers.ValidationError(
                    "start_date et end_date requis pour period=custom"
                )
        
        # Vérifier que start_date < end_date
        if data['start_date'] > data['end_date']:
            raise serializers.ValidationError(
                "start_date doit être antérieure à end_date"
            )
        
        return data


class StatsSummarySerializer(serializers.Serializer):
    """Résumé des statistiques"""
    total_deliveries = serializers.IntegerField()
    completed_deliveries = serializers.IntegerField()
    cancelled_deliveries = serializers.IntegerField()
    in_progress = serializers.IntegerField()
    total_earnings = serializers.FloatField()
    total_distance_km = serializers.FloatField()
    success_rate = serializers.FloatField()
    average_delivery_value = serializers.FloatField()


class TimelineDataSerializer(serializers.Serializer):
    """Point de données pour timeline"""
    date = serializers.CharField()
    deliveries = serializers.IntegerField()
    earnings = serializers.FloatField()


class StatusDistributionSerializer(serializers.Serializer):
    """Distribution par statut"""
    status = serializers.CharField()
    count = serializers.IntegerField()


class CommuneStatsSerializer(serializers.Serializer):
    """Statistiques par commune"""
    commune = serializers.CharField()
    deliveries = serializers.IntegerField()
    latitude = serializers.FloatField(allow_null=True)
    longitude = serializers.FloatField(allow_null=True)


class HeatmapPointSerializer(serializers.Serializer):
    """Point pour heatmap"""
    lat = serializers.FloatField()
    lng = serializers.FloatField()
    weight = serializers.IntegerField()


class PeakHourSerializer(serializers.Serializer):
    """Statistiques par heure"""
    hour = serializers.IntegerField()
    deliveries = serializers.IntegerField()
    earnings = serializers.FloatField()


class DistanceRangeSerializer(serializers.Serializer):
    """Distribution des distances"""
    range = serializers.CharField()
    count = serializers.IntegerField()


class EarningsBreakdownSerializer(serializers.Serializer):
    """Détail des revenus"""
    delivery = serializers.FloatField()
    bonus = serializers.FloatField()
    tip = serializers.FloatField()
    adjustment = serializers.FloatField()
    total = serializers.FloatField()
