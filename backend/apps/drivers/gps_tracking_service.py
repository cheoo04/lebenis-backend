"""
GPS Location Tracking Service
Handles adaptive GPS tracking and location updates
"""
from datetime import timedelta
from django.utils import timezone
from django.db.models import Avg
from geopy.distance import geodesic
from .location_models import LocationUpdate, LocationTrackingSession


class GPSTrackingService:
    """Service for managing GPS tracking with adaptive intervals"""
    
    # Tracking intervals (in seconds)
    INTERVAL_EN_ROUTE = 30      # En route vers livraison
    INTERVAL_STOPPED = 10        # Arrêté (pause, attente)
    INTERVAL_OFFLINE = 300       # Hors service (5 minutes)
    
    # Movement detection threshold
    MOVEMENT_THRESHOLD_MPS = 1.0  # 1 m/s (~3.6 km/h)
    
    @staticmethod
    def get_tracking_interval(driver_status, is_moving=False):
        """
        Determine GPS tracking interval based on driver status
        
        Args:
            driver_status: Driver availability status
            is_moving: Whether driver is currently moving
            
        Returns:
            int: Tracking interval in seconds
        """
        if driver_status == 'offline':
            return GPSTrackingService.INTERVAL_OFFLINE
        
        if driver_status in ['available', 'busy']:
            if is_moving:
                return GPSTrackingService.INTERVAL_EN_ROUTE
            else:
                return GPSTrackingService.INTERVAL_STOPPED
        
        # Default fallback
        return GPSTrackingService.INTERVAL_STOPPED
    
    @staticmethod
    def update_driver_location(driver, latitude, longitude, **kwargs):
        """
        Update driver location and create location history
        
        Args:
            driver: Driver instance
            latitude: GPS latitude
            longitude: GPS longitude
            **kwargs: Additional location data (accuracy, speed, etc.)
            
        Returns:
            LocationUpdate: Created location update instance
        """
        # Determine if driver is moving
        speed = kwargs.get('speed', 0)
        is_moving = speed > GPSTrackingService.MOVEMENT_THRESHOLD_MPS
        
        # Create location update record
        location_update = LocationUpdate.objects.create(
            driver=driver,
            latitude=latitude,
            longitude=longitude,
            accuracy=kwargs.get('accuracy'),
            speed=speed,
            heading=kwargs.get('heading'),
            altitude=kwargs.get('altitude'),
            driver_status=driver.availability_status,
            is_moving=is_moving,
            battery_level=kwargs.get('battery_level'),
            timestamp=kwargs.get('timestamp', timezone.now())
        )
        
        # Update driver's current location
        driver.current_latitude = latitude
        driver.current_longitude = longitude
        driver.save(update_fields=['current_latitude', 'current_longitude'])
        
        # Update tracking session
        GPSTrackingService._update_tracking_session(driver, location_update)
        
        return location_update
    
    @staticmethod
    def _update_tracking_session(driver, location_update):
        """Update or create tracking session"""
        # Get or create active session
        session = LocationTrackingSession.objects.filter(
            driver=driver,
            ended_at__isnull=True
        ).first()
        
        if not session:
            session = LocationTrackingSession.objects.create(
                driver=driver,
                initial_battery_level=location_update.battery_level
            )
        
        # Update session statistics
        session.total_updates += 1
        session.final_battery_level = location_update.battery_level
        
        # Calculate average accuracy
        avg_accuracy = LocationUpdate.objects.filter(
            driver=driver,
            timestamp__gte=session.started_at
        ).aggregate(avg_accuracy=Avg('accuracy'))['avg_accuracy']
        
        session.average_accuracy = avg_accuracy
        
        # Calculate total distance
        session.total_distance_km = GPSTrackingService._calculate_session_distance(
            driver, session
        )
        
        session.save()
    
    @staticmethod
    def _calculate_session_distance(driver, session):
        """Calculate total distance traveled during session"""
        updates = LocationUpdate.objects.filter(
            driver=driver,
            timestamp__gte=session.started_at
        ).order_by('timestamp')
        
        total_distance = 0.0
        previous_coords = None
        
        for update in updates:
            current_coords = update.coordinates
            if previous_coords:
                distance_km = geodesic(previous_coords, current_coords).kilometers
                total_distance += distance_km
            previous_coords = current_coords
        
        return total_distance
    
    @staticmethod
    def end_tracking_session(driver):
        """End current tracking session"""
        session = LocationTrackingSession.objects.filter(
            driver=driver,
            ended_at__isnull=True
        ).first()
        
        if session:
            session.ended_at = timezone.now()
            session.save()
    
    @staticmethod
    def get_location_history(driver, start_date=None, end_date=None, limit=100):
        """
        Get location history for driver
        
        Args:
            driver: Driver instance
            start_date: Optional start date filter
            end_date: Optional end date filter
            limit: Maximum number of records
            
        Returns:
            QuerySet: Location updates
        """
        queryset = LocationUpdate.objects.filter(driver=driver)
        
        if start_date:
            queryset = queryset.filter(timestamp__gte=start_date)
        
        if end_date:
            queryset = queryset.filter(timestamp__lte=end_date)
        
        return queryset.order_by('-timestamp')[:limit]
    
    @staticmethod
    def cleanup_old_locations(days_to_keep=30):
        """
        Clean up old location records
        
        Args:
            days_to_keep: Number of days of location history to keep
        """
        cutoff_date = timezone.now() - timedelta(days=days_to_keep)
        
        # Delete old location updates
        deleted_count = LocationUpdate.objects.filter(
            timestamp__lt=cutoff_date
        ).delete()[0]
        
        # Delete old completed sessions
        LocationTrackingSession.objects.filter(
            ended_at__isnull=False,
            ended_at__lt=cutoff_date
        ).delete()
        
        return deleted_count
    
    @staticmethod
    def get_tracking_statistics(driver, days=7):
        """
        Get tracking statistics for driver
        
        Args:
            driver: Driver instance
            days: Number of days to analyze
            
        Returns:
            dict: Tracking statistics
        """
        start_date = timezone.now() - timedelta(days=days)
        
        updates = LocationUpdate.objects.filter(
            driver=driver,
            timestamp__gte=start_date
        )
        
        sessions = LocationTrackingSession.objects.filter(
            driver=driver,
            started_at__gte=start_date
        )
        
        total_distance = sum(s.total_distance_km for s in sessions)
        avg_accuracy = updates.aggregate(avg=Avg('accuracy'))['avg'] or 0
        
        return {
            'total_updates': updates.count(),
            'total_sessions': sessions.count(),
            'total_distance_km': round(total_distance, 2),
            'average_accuracy_m': round(avg_accuracy, 2),
            'updates_per_day': round(updates.count() / days, 1),
        }
