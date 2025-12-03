# Generated migration for adding GPS coordinates to PricingZone
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('pricing', '0002_alter_pricingzone_options_and_more'),
    ]

    operations = [
        migrations.AddField(
            model_name='pricingzone',
            name='default_latitude',
            field=models.DecimalField(blank=True, decimal_places=8, help_text='Latitude du centre de la commune (ex: 5.3599517 pour Cocody)', max_digits=10, null=True),
        ),
        migrations.AddField(
            model_name='pricingzone',
            name='default_longitude',
            field=models.DecimalField(blank=True, decimal_places=8, help_text='Longitude du centre de la commune (ex: -4.0082563 pour Cocody)', max_digits=11, null=True),
        ),
    ]
