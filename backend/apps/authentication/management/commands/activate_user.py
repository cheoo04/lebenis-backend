# apps/authentication/management/commands/activate_user.py

from django.core.management.base import BaseCommand
from apps.authentication.models import User


class Command(BaseCommand):
    help = 'Activer un utilisateur par email'

    def add_arguments(self, parser):
        parser.add_argument('email', type=str, help='Email de l\'utilisateur')

    def handle(self, *args, **options):
        email = options['email']
        
        try:
            user = User.objects.get(email=email)
            
            self.stdout.write(f"\n{'='*50}")
            self.stdout.write(f"Utilisateur trouvé: {user.email}")
            self.stdout.write(f"is_active: {user.is_active}")
            self.stdout.write(f"is_verified AVANT: {user.is_verified}")
            self.stdout.write(f"{'='*50}\n")
            
            # Activer
            user.is_verified = True
            user.is_active = True
            user.save()
            
            self.stdout.write(f"✅ is_verified APRÈS: {user.is_verified}")
            self.stdout.write(self.style.SUCCESS(f'\n✅ Utilisateur {email} activé avec succès!'))
            
        except User.DoesNotExist:
            self.stdout.write(self.style.ERROR(f'\n❌ Utilisateur {email} introuvable'))
