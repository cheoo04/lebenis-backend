from django.test import TestCase
from django.core import mail
from apps.authentication.models import User
from apps.merchants.models import Merchant
from apps.deliveries.models import Delivery

class DeliveryModelSignalTest(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            email='merchant@example.com',
            phone='+2250700000001',
            first_name='Merchant',
            last_name='Test',
            user_type='merchant',
            password='TestPassword123!'
        )
        self.merchant = Merchant.objects.create(
            user=self.user,
            business_name='Test Business',
            verification_status='verified'
        )

    @classmethod
    def tearDownClass(cls):
        super().tearDownClass()
        # Ferme toutes les connexions à la base de test PostgreSQL
        try:
            import psycopg2
            from django.conf import settings
            db_settings = settings.DATABASES['default']
            db_name = db_settings.get('TEST', {}).get('NAME') or f"test_{db_settings['NAME']}"
            conn = psycopg2.connect(
                dbname='postgres',
                user=db_settings['USER'],
                password=db_settings['PASSWORD'],
                host=db_settings.get('HOST', 'localhost'),
                port=db_settings.get('PORT', 5432)
            )
            conn.autocommit = True
            cur = conn.cursor()
            cur.execute(f"""
                SELECT pg_terminate_backend(pid)
                FROM pg_stat_activity
                WHERE datname = '{db_name}' AND pid <> pg_backend_pid();
            """)
            cur.close()
            conn.close()
        except Exception as e:
            print(f"Erreur lors de la fermeture des connexions à la base de test : {e}")

    def test_pin_generated_and_email_sent_on_save(self):
        delivery = Delivery.objects.create(
            merchant=self.merchant,
            delivery_address='Test Address',
            delivery_commune='Test Commune',
            package_weight_kg=1.0,
            recipient_name='Test Recipient',
            recipient_phone='+22500000000',
            payment_method='prepaid',
            calculated_price=1000,
        )
        delivery.refresh_from_db()
        self.assertTrue(delivery.delivery_confirmation_code)
        self.assertEqual(len(delivery.delivery_confirmation_code), 4)
        self.assertGreaterEqual(len(mail.outbox), 1)
        self.assertIn(delivery.delivery_confirmation_code, mail.outbox[0].body)
