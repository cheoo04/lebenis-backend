"""
GPS Tracking Serializers
"""
from rest_framework import serializers
from .location_models import LocationUpdate, LocationTrackingSession


class LocationUpdateSerializer(serializers.ModelSerializer):
    """Serializer for location updates"""
    
    class Meta:
        model = LocationUpdate
        fields = [
            'id',
            'latitude',
            'longitude',
            'accuracy',
            'speed',
            'heading',
            'altitude',
            'driver_status',
            'is_moving',
            'battery_level',
            'timestamp',
        ]
        read_only_fields = ['id', 'driver_status', 'is_moving']


class LocationUpdateCreateSerializer(serializers.Serializer):
    """Serializer for creating location updates"""
    latitude = serializers.DecimalField(
        max_digits=10,
        decimal_places=8,
        required=True
    )
    longitude = serializers.DecimalField(
        max_digits=11,
        decimal_places=8,
        required=True
    )
    accuracy = serializers.FloatField(required=False, allow_null=True)
    speed = serializers.FloatField(required=False, allow_null=True)
    heading = serializers.FloatField(required=False, allow_null=True)
    altitude = serializers.FloatField(required=False, allow_null=True)
    battery_level = serializers.IntegerField(
        required=False,
        allow_null=True,
        min_value=0,
        max_value=100
    )
    timestamp = serializers.DateTimeField(required=False, allow_null=True)


class TrackingIntervalSerializer(serializers.Serializer):
    """Serializer for tracking interval response"""
    interval_seconds = serializers.IntegerField()
    driver_status = serializers.CharField()
    is_moving = serializers.BooleanField()
    recommended_accuracy = serializers.CharField()


class TrackingSessionSerializer(serializers.ModelSerializer):
    """Serializer for tracking sessions"""
    duration_seconds = serializers.SerializerMethodField()
    battery_consumption = serializers.SerializerMethodField()
    
    class Meta:
        model = LocationTrackingSession
        fields = [
            'id',
            'started_at',
            'ended_at',
            'total_updates',
            'average_accuracy',
            'total_distance_km',
            'initial_battery_level',
            'final_battery_level',
            'duration_seconds',
            'battery_consumption',
        ]
    
    def get_duration_seconds(self, obj):
        duration = obj.duration
        return int(duration.total_seconds()) if duration else None
    
    def get_battery_consumption(self, obj):
        return obj.battery_consumption


class TrackingStatisticsSerializer(serializers.Serializer):
    """Serializer for tracking statistics"""
    total_updates = serializers.IntegerField()
    total_sessions = serializers.IntegerField()
    total_distance_km = serializers.FloatField()
    average_accuracy_m = serializers.FloatField()
    updates_per_day = serializers.FloatField()
