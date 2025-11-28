from apps.authentication.models import User
from apps.drivers.models import Driver

print("\n=== Vérification des users et profils Driver ===")
for user in User.objects.filter(user_type='driver'):
    print(f"User: {user.email} | id={user.id}")
    try:
        driver = Driver.objects.get(user=user)
        print(f"  -> Profil Driver trouvé: driver_id={driver.id}")
    except Driver.DoesNotExist:
        print(f"  -> Aucun profil Driver trouvé pour cet utilisateur !")
    except Exception as e:
        print(f"  -> Erreur inattendue: {e}")
print("\n=== Vérification terminée ===")
