import os
import django

print("=== ENVIRONNEMENT DJANGO ===")
print(f"DJANGO_SETTINGS_MODULE: {os.environ.get('DJANGO_SETTINGS_MODULE')}")
print(f"DATABASE_URL: {os.environ.get('DATABASE_URL')}")
print(f"DEBUG: {os.environ.get('DEBUG')}")
print(f"BASE_DIR: {os.getcwd()}")

try:
    import apps.authentication.models as auth_models
    import apps.drivers.models as driver_models
    print("Import models: OK")
except Exception as e:
    print(f"Erreur import models: {e}")

try:
    django.setup()
    print("django.setup() OK")
    print("\n--- DIAGNOSTIC BASE ---")
    from apps.authentication.models import User
    from apps.drivers.models import Driver
    print(f"Total users: {User.objects.count()}")
    print(f"Users driver (user_type='driver'): {User.objects.filter(user_type='driver').count()}")
    print(f"Total profils Driver: {Driver.objects.count()}")
    print("\nListe users driver:")
    for user in User.objects.filter(user_type='driver'):
        print(f"User: {user.email} | id={user.id}")
    print("\nListe profils Driver:")
    for driver in Driver.objects.all():
        print(f"Driver: {driver.user.email} | user_id={driver.user.id} | driver_id={driver.id}")
except Exception as e:
    print(f"Erreur django.setup(): {e}")
