"""
Celery Tasks for Driver App
"""
from celery import shared_task
from .gps_tracking_service import GPSTrackingService


@shared_task(name='drivers.cleanup_old_gps_data')
def cleanup_old_gps_data(days_to_keep=30):
    """
    Clean up old GPS location data
    
    Args:
        days_to_keep: Number of days of location history to keep (default: 30)
        
    Returns:
        str: Summary message
    """
    deleted_count = GPSTrackingService.cleanup_old_locations(days_to_keep=days_to_keep)
    return f"Deleted {deleted_count} old location records (kept last {days_to_keep} days)"


@shared_task(name='drivers.send_tracking_statistics')
def send_tracking_statistics():
    """
    Send tracking statistics summary (optional - for monitoring)
    
    Returns:
        str: Summary message
    """
    from .models import Driver
    
    active_drivers = Driver.objects.filter(availability_status__in=['available', 'busy'])
    
    stats = []
    for driver in active_drivers:
        driver_stats = GPSTrackingService.get_tracking_statistics(driver, days=1)
        if driver_stats['total_updates'] > 0:
            stats.append({
                'driver_id': driver.id,
                'phone': driver.user.phone_number,
                'updates': driver_stats['total_updates'],
                'distance_km': driver_stats['total_distance_km'],
            })
    
    return f"Tracking stats collected for {len(stats)} active drivers"
