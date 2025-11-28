# Script pour lister les utilisateurs authentifiés sans profil driver associé
from apps.authentication.models import User
from apps.drivers.models import Driver

users = User.objects.filter(is_active=True)
users_without_driver = []

for user in users:
    try:
        driver = Driver.objects.get(user=user)
    except Driver.DoesNotExist:
        users_without_driver.append(user)

print(f"Utilisateurs actifs sans profil driver associé : {len(users_without_driver)}")
for user in users_without_driver:
    print(f"User ID: {user.id}, Email: {getattr(user, 'email', None)}")
