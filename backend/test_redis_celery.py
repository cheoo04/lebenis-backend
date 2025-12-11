#!/usr/bin/env python
"""
Script de test pour vérifier la connexion Redis Cloud et Celery
Usage: python test_redis_celery.py
"""
import os
import sys
import django

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings.production')
django.setup()

from django.conf import settings
import redis
from celery import current_app
from urllib.parse import urlparse

def test_redis_connection():
    """Test la connexion Redis directe"""
    print("=" * 70)
    print("🔍 TEST 1: Connexion Redis directe")
    print("=" * 70)
    
    redis_url = settings.REDIS_URL if hasattr(settings, 'REDIS_URL') else settings.CELERY_BROKER_URL
    print(f"📡 URL Redis: {mask_url(redis_url)}")
    
    try:
        # Déterminer si SSL est requis
        parsed = urlparse(redis_url)
        use_ssl = parsed.scheme == 'rediss'
        
        # Connexion
        if use_ssl:
            import ssl
            r = redis.from_url(
                redis_url,
                ssl_cert_reqs=ssl.CERT_NONE,
                socket_connect_timeout=5,
                socket_timeout=5
            )
        else:
            r = redis.from_url(
                redis_url,
                socket_connect_timeout=5,
                socket_timeout=5
            )
        
        # Test PING
        result = r.ping()
        print(f"✅ PING réussi: {result}")
        
        # Test SET/GET
        test_key = 'test:connection'
        test_value = 'LeBeni Redis Test'
        r.set(test_key, test_value, ex=60)  # Expire après 60 secondes
        retrieved = r.get(test_key).decode('utf-8')
        print(f"✅ SET/GET réussi: {retrieved}")
        
        # Info serveur
        info = r.info('server')
        print(f"📊 Redis version: {info.get('redis_version')}")
        print(f"📊 Mode: {info.get('redis_mode', 'standalone')}")
        
        # Nettoyage
        r.delete(test_key)
        
        return True
        
    except redis.ConnectionError as e:
        print(f"❌ Erreur de connexion: {e}")
        return False
    except Exception as e:
        print(f"❌ Erreur: {e}")
        return False


def test_celery_broker():
    """Test la connexion Celery au broker"""
    print("\n" + "=" * 70)
    print("🔍 TEST 2: Connexion Celery Broker")
    print("=" * 70)
    
    broker_url = settings.CELERY_BROKER_URL
    print(f"📡 Broker URL: {mask_url(broker_url)}")
    
    try:
        # Inspecter les workers actifs
        inspect = current_app.control.inspect(timeout=5)
        active_workers = inspect.active()
        
        if active_workers:
            print(f"✅ Workers actifs trouvés: {len(active_workers)}")
            for worker_name, tasks in active_workers.items():
                print(f"   - {worker_name}: {len(tasks)} tâche(s) en cours")
        else:
            print("⚠️  Aucun worker actif (normal si worker pas encore démarré)")
        
        # Tester une tâche simple
        print("\n🧪 Test d'une tâche simple...")
        from config.celery import debug_task
        result = debug_task.delay()
        print(f"✅ Tâche envoyée: {result.id}")
        print(f"   Status: {result.status}")
        
        return True
        
    except Exception as e:
        print(f"❌ Erreur: {e}")
        return False


def test_celery_result_backend():
    """Test le backend de résultats Celery"""
    print("\n" + "=" * 70)
    print("🔍 TEST 3: Celery Result Backend")
    print("=" * 70)
    
    result_backend = settings.CELERY_RESULT_BACKEND
    print(f"📡 Result Backend URL: {mask_url(result_backend)}")
    
    try:
        # Vérifier les résultats de tâches récentes
        from django_celery_results.models import TaskResult
        
        recent_tasks = TaskResult.objects.all().order_by('-date_done')[:5]
        count = recent_tasks.count()
        
        if count > 0:
            print(f"✅ {count} résultats de tâches trouvés")
            for task in recent_tasks:
                status_emoji = "✅" if task.status == "SUCCESS" else "❌"
                print(f"   {status_emoji} {task.task_name} - {task.status} - {task.date_done}")
        else:
            print("ℹ️  Aucun résultat de tâche (normal si première utilisation)")
        
        return True
        
    except Exception as e:
        print(f"❌ Erreur: {e}")
        return False


def test_celery_beat_schedule():
    """Test la configuration Celery Beat"""
    print("\n" + "=" * 70)
    print("🔍 TEST 4: Celery Beat Schedule")
    print("=" * 70)
    
    try:
        schedule = settings.CELERY_BEAT_SCHEDULE
        print(f"✅ {len(schedule)} tâches planifiées:")
        
        for task_name, task_config in schedule.items():
            task_path = task_config['task']
            schedule_info = task_config['schedule']
            print(f"   📅 {task_name}")
            print(f"      Task: {task_path}")
            print(f"      Schedule: {schedule_info}")
        
        return True
        
    except Exception as e:
        print(f"❌ Erreur: {e}")
        return False


def mask_url(url):
    """Masque les credentials dans une URL"""
    try:
        parsed = urlparse(url)
        if parsed.password:
            return url.replace(parsed.password, '***')
        return url
    except:
        return url


def print_configuration():
    """Affiche la configuration actuelle"""
    print("\n" + "=" * 70)
    print("⚙️  CONFIGURATION ACTUELLE")
    print("=" * 70)
    
    print(f"Django Settings: {settings.SETTINGS_MODULE}")
    print(f"Debug Mode: {settings.DEBUG}")
    print(f"Timezone: {settings.TIME_ZONE}")
    
    if hasattr(settings, 'CELERY_TIMEZONE'):
        print(f"Celery Timezone: {settings.CELERY_TIMEZONE}")
    
    if hasattr(settings, 'CELERY_BROKER_USE_SSL'):
        print(f"Broker SSL: {settings.CELERY_BROKER_USE_SSL is not None}")
    
    if hasattr(settings, 'CELERY_REDIS_BACKEND_USE_SSL'):
        print(f"Result Backend SSL: {settings.CELERY_REDIS_BACKEND_USE_SSL is not None}")


def main():
    """Exécute tous les tests"""
    print("🚀 LeBeni - Test Redis Cloud + Celery")
    print("=" * 70)
    
    print_configuration()
    
    tests = [
        ("Redis Connection", test_redis_connection),
        ("Celery Broker", test_celery_broker),
        ("Celery Result Backend", test_celery_result_backend),
        ("Celery Beat Schedule", test_celery_beat_schedule),
    ]
    
    results = {}
    for test_name, test_func in tests:
        try:
            results[test_name] = test_func()
        except Exception as e:
            print(f"\n❌ Test '{test_name}' a échoué avec exception: {e}")
            results[test_name] = False
    
    # Résumé
    print("\n" + "=" * 70)
    print("📊 RÉSUMÉ DES TESTS")
    print("=" * 70)
    
    passed = sum(1 for result in results.values() if result)
    total = len(results)
    
    for test_name, result in results.items():
        status = "✅ PASS" if result else "❌ FAIL"
        print(f"{status} - {test_name}")
    
    print(f"\n🎯 Score: {passed}/{total} tests réussis")
    
    if passed == total:
        print("\n🎉 Tous les tests sont passés ! Redis Cloud + Celery est prêt.")
        return 0
    else:
        print("\n⚠️  Certains tests ont échoué. Vérifiez la configuration.")
        return 1


if __name__ == '__main__':
    sys.exit(main())
