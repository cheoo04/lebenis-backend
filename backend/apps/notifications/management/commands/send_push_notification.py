# apps/notifications/management/commands/send_push_notification.py

from django.core.management.base import BaseCommand, CommandError
from apps.authentication.models import User
from apps.notifications.models import Notification, DeviceToken
from apps.notifications.firebase_service import FirebaseService


class Command(BaseCommand):
    help = 'Envoie une notification push à un ou plusieurs utilisateurs'

    def add_arguments(self, parser):
        parser.add_argument(
            '--user',
            type=str,
            help='Email de l\'utilisateur destinataire',
        )
        parser.add_argument(
            '--all',
            action='store_true',
            help='Envoyer à tous les utilisateurs',
        )
        parser.add_argument(
            '--user-type',
            type=str,
            choices=['merchant', 'driver', 'admin'],
            help='Envoyer à tous les utilisateurs d\'un type spécifique',
        )
        parser.add_argument(
            '--title',
            type=str,
            required=True,
            help='Titre de la notification',
        )
        parser.add_argument(
            '--message',
            type=str,
            required=True,
            help='Message de la notification',
        )
        parser.add_argument(
            '--type',
            type=str,
            default='general',
            help='Type de notification (general, delivery_update, payment, etc.)',
        )

    def handle(self, *args, **options):
        title = options['title']
        message = options['message']
        notification_type = options['type']
        
        # Déterminer les utilisateurs cibles
        if options['user']:
            try:
                users = [User.objects.get(email=options['user'])]
                self.stdout.write(f"📧 Envoi à: {options['user']}")
            except User.DoesNotExist:
                raise CommandError(f"Utilisateur {options['user']} introuvable")
        
        elif options['all']:
            users = User.objects.filter(is_active=True)
            self.stdout.write(f"📢 Envoi à tous les utilisateurs ({users.count()})")
        
        elif options['user_type']:
            users = User.objects.filter(is_active=True, user_type=options['user_type'])
            self.stdout.write(f"📢 Envoi à tous les {options['user_type']}s ({users.count()})")
        
        else:
            raise CommandError(
                "Spécifiez --user, --all ou --user-type pour cibler les destinataires"
            )
        
        # Créer les notifications en base
        notifications = []
        for user in users:
            notification = Notification.objects.create(
                user=user,
                title=title,
                message=message,
                notification_type=notification_type
            )
            notifications.append(notification)
        
        self.stdout.write(
            self.style.SUCCESS(f"✅ {len(notifications)} notifications créées en base")
        )
        
        # Récupérer tous les tokens FCM actifs
        tokens = DeviceToken.objects.filter(
            user__in=users,
            is_active=True
        )
        
        if not tokens.exists():
            self.stdout.write(
                self.style.WARNING("⚠️ Aucun token FCM actif trouvé")
            )
            return
        
        token_list = [t.token for t in tokens]
        self.stdout.write(f"📱 {len(token_list)} appareils trouvés")
        
        # Envoyer les notifications push
        self.stdout.write("📤 Envoi des notifications push...")
        
        result = FirebaseService.send_multicast(
            fcm_tokens=token_list,
            title=title,
            body=message,
            data={'notification_type': notification_type}
        )
        
        # Afficher les résultats
        self.stdout.write(
            self.style.SUCCESS(
                f"\n✅ Envoi terminé:\n"
                f"   - Succès: {result['success_count']}\n"
                f"   - Échecs: {result['failure_count']}\n"
            )
        )
        
        # Désactiver les tokens invalides si nécessaire
        if result['failure_count'] > 0 and 'responses' in result:
            invalid_tokens = []
            for idx, response in enumerate(result['responses']):
                if not response.success:
                    # Si le token est invalide, le désactiver
                    if 'invalid' in str(response.exception).lower():
                        invalid_tokens.append(token_list[idx])
            
            if invalid_tokens:
                DeviceToken.objects.filter(token__in=invalid_tokens).update(is_active=False)
                self.stdout.write(
                    self.style.WARNING(
                        f"⚠️ {len(invalid_tokens)} tokens invalides désactivés"
                    )
                )
