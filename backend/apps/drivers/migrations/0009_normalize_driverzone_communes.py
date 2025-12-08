from django.db import migrations


def normalize_communes(apps, schema_editor):
    DriverZone = apps.get_model('drivers', 'DriverZone')
    try:
        from apps.core.quartiers_data import get_communes_list
    except Exception:
        return

    communes = get_communes_list()
    for dz in DriverZone.objects.all():
        raw = (dz.commune or '').strip()
        if not raw:
            continue
        cu = raw.upper()
        if cu in communes:
            new = cu
            if dz.commune != new:
                dz.commune = new
                dz.save(update_fields=['commune'])


def reverse_func(apps, schema_editor):
    # Pas d'opération de reverse simple (on laisse les valeurs normalisées)
    return


class Migration(migrations.Migration):

    dependencies = [
        ('drivers', '0008_alter_driver_driver_license'),
    ]

    operations = [
        migrations.RunPython(normalize_communes, reverse_func),
    ]
