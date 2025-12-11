#!/usr/bin/env python
"""
Script pour synchroniser verification_status du Driver avec is_verified du User.

Exécuter avec:
    python manage.py shell < scripts/sync_driver_verification.py
"""

from apps.drivers.models import Driver
from apps.authentication.models import User

print("\n=== Synchronisation verification_status ↔ is_verified ===\n")

# Trouver tous les drivers vérifiés dont le user n'est pas marqué vérifié
drivers_to_fix = Driver.objects.filter(verification_status='verified').select_related('user')
fixed_count = 0

for driver in drivers_to_fix:
    if not driver.user.is_verified:
        print(f"  → Fix: {driver.user.email} - user.is_verified = False → True")
        driver.user.is_verified = True
        driver.user.save()
        fixed_count += 1

# Trouver tous les users vérifiés dont le driver n'est pas marqué vérifié
users_verified = User.objects.filter(user_type='driver', is_verified=True)
for user in users_verified:
    try:
        driver = Driver.objects.get(user=user)
        if driver.verification_status != 'verified':
            print(f"  → Fix: {user.email} - driver.verification_status = '{driver.verification_status}' → 'verified'")
            driver.verification_status = 'verified'
            driver.save()
            fixed_count += 1
    except Driver.DoesNotExist:
        pass

if fixed_count == 0:
    print("  ✅ Tous les drivers sont déjà synchronisés!")
else:
    print(f"\n  ✅ {fixed_count} driver(s) corrigé(s)")

print("\n=== Synchronisation terminée ===\n")
