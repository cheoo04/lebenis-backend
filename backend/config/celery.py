# config/celery.py

import os
from celery import Celery
from celery.schedules import crontab
from django.conf import settings

# Set the default Django settings module for the 'celery' program.
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings.development')

app = Celery('lebenis')

# Using a string here means the worker doesn't have to serialize
# the configuration object to child processes.
# - namespace='CELERY' means all celery-related configuration keys
#   should have a `CELERY_` prefix.
app.config_from_object('django.conf:settings', namespace='CELERY')

# Celery 6.0 compatibility: explicitly set retry behavior on startup
app.conf.broker_connection_retry_on_startup = True

# Load task modules from all registered Django apps.
app.autodiscover_tasks(lambda: settings.INSTALLED_APPS)

# Celery Beat Schedule
app.conf.beat_schedule = {
    'process-daily-payouts': {
        'task': 'payments.tasks.process_daily_payouts',
        'schedule': crontab(hour=23, minute=59),  # 23h59 chaque jour
    },
    'cleanup-old-gps-data': {
        'task': 'drivers.cleanup_old_gps_data',
        'schedule': crontab(hour=2, minute=0),  # 2h du matin chaque jour
    },
    'send-tracking-statistics': {
        'task': 'drivers.send_tracking_statistics',
        'schedule': crontab(hour=6, minute=0),  # 6h du matin chaque jour
    },
}

app.conf.timezone = 'UTC'


@app.task(bind=True, ignore_result=True)
def debug_task(self):
    """Debug task pour tester Celery"""
    print(f'Request: {self.request!r}')

