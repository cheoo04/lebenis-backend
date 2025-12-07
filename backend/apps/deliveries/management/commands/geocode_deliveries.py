# backend/apps/deliveries/management/commands/geocode_deliveries.py
from django.core.management.base import BaseCommand
from apps.deliveries.models import Delivery
from apps.core.location_service import LocationService


class Command(BaseCommand):
    help = 'Géocode les livraisons sans coordonnées GPS'

    def handle(self, *args, **options):
        location_service = LocationService()
        
        # Trouver les livraisons sans coordonnées (on filtre par champs NULL)
        deliveries = Delivery.objects.filter(
            pickup_latitude__isnull=True
        ) | Delivery.objects.filter(
            delivery_latitude__isnull=True
        )
        
        count = deliveries.count()
        self.stdout.write(f'📍 {count} livraisons à géocoder...')
        
        geocoded = 0
        for delivery in deliveries:
            try:
                # Géocoder l'adresse de récupération si manquante
                if not delivery.get_coords('pickup') and delivery.pickup_address:
                    pickup_coords = location_service.geocode_address(
                        f"{delivery.pickup_address.street_address}, {delivery.pickup_commune}"
                    )
                    if pickup_coords:
                        lat, lon = pickup_coords  # Tuple unpacking
                        delivery.pickup_latitude = lat
                        delivery.pickup_longitude = lon
                
                # Géocoder l'adresse de livraison si manquante
                if not delivery.get_coords('delivery'):
                    delivery_coords = location_service.geocode_address(
                        f"{delivery.delivery_address}, {delivery.delivery_commune}"
                    )
                    if delivery_coords:
                        lat, lon = delivery_coords  # Tuple unpacking
                        delivery.delivery_latitude = lat
                        delivery.delivery_longitude = lon
                
                delivery.save()
                geocoded += 1
                self.stdout.write(self.style.SUCCESS(f'✅ {delivery.tracking_number}'))
                
            except Exception as e:
                self.stdout.write(self.style.ERROR(f'❌ {delivery.tracking_number}: {e}'))
        
        self.stdout.write(self.style.SUCCESS(f'\n🎉 {geocoded}/{count} livraisons géocodées !'))
