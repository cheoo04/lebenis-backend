# authentication/management/commands/cleanup_test_users.py

from django.core.management.base import BaseCommand
from apps.authentication.models import User


class Command(BaseCommand):
    """
    Commande pour supprimer les utilisateurs de test
    
    Usage:
        python manage.py cleanup_test_users
        python manage.py cleanup_test_users --dry-run  # Voir sans supprimer
    """
    
    help = 'Supprime les utilisateurs de test de la base de données'
    
    def add_arguments(self, parser):
        parser.add_argument(
            '--dry-run',
            action='store_true',
            help='Afficher les utilisateurs qui seraient supprimés sans les supprimer réellement',
        )
    
    def handle(self, *args, **options):
        dry_run = options['dry_run']
        
        # Liste des emails de test à supprimer
        test_emails = [
            'driver1@test.com',
            'driver2@test.com',
            'driver3@test.com',
            'driver4@test.com',
            'merchant1@test.com',
            'merchant2@test.com',
            'testprice@example.com',
        ]
        
        # Chercher les utilisateurs de test
        test_users = User.objects.filter(email__in=test_emails)
        count = test_users.count()
        
        if count == 0:
            self.stdout.write(
                self.style.WARNING('⚠️ Aucun utilisateur de test trouvé')
            )
            return
        
        # Afficher les utilisateurs qui seront supprimés
        self.stdout.write(
            self.style.WARNING(f'\n📋 {count} utilisateurs de test trouvés:\n')
        )
        
        for user in test_users:
            self.stdout.write(
                f'  • {user.email} ({user.user_type}) - '
                f'{"✅ Actif" if user.is_active else "❌ Inactif"}'
            )
        
        if dry_run:
            self.stdout.write(
                self.style.SUCCESS(
                    f'\n🔍 Mode DRY-RUN: {count} utilisateurs SERAIENT supprimés'
                )
            )
            return
        
        # Demander confirmation
        confirm = input(
            f'\n⚠️ Voulez-vous vraiment supprimer ces {count} utilisateurs ? [y/N]: '
        )
        
        if confirm.lower() != 'y':
            self.stdout.write(
                self.style.WARNING('❌ Annulé par l\'utilisateur')
            )
            return
        
        # Supprimer les utilisateurs
        deleted_count, _ = test_users.delete()
        
        self.stdout.write(
            self.style.SUCCESS(
                f'\n✅ {deleted_count} utilisateurs de test supprimés avec succès!'
            )
        )
