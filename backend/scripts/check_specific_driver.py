# Script pour vérifier si un user donné a bien un profil driver
from apps.authentication.models import User
from apps.drivers.models import Driver

# Remplace cet email par celui de ton compte driver connecté
EMAIL = "cheo@gmail.com"

try:
    user = User.objects.get(email=EMAIL)
    try:
        driver = Driver.objects.get(user=user)
        print(f"OK : Le user {EMAIL} a un profil driver (driver_id={driver.id})")
    except Driver.DoesNotExist:
        print(f"ERREUR : Le user {EMAIL} n'a PAS de profil driver !")
except User.DoesNotExist:
    print(f"ERREUR : Aucun user trouvé avec l'email {EMAIL}")
