from django.db import migrations


def normalize_string(s: str) -> str:
    import unicodedata
    import re

    if not s:
        return ""
    # decompose accents, drop them, uppercase
    nfkd = unicodedata.normalize('NFKD', s)
    ascii_only = nfkd.encode('ASCII', 'ignore').decode('ASCII')
    # keep only alphanumerics and uppercase
    cleaned = re.sub(r'[^A-Z0-9]', '', ascii_only.upper())
    return cleaned


def forwards(apps, schema_editor):
    DriverZone = apps.get_model('drivers', 'DriverZone')
    try:
        from apps.core.quartiers_data import get_communes_list
    except Exception:
        # If the helper is unavailable, skip migration to avoid partial state
        print('get_communes_list not available; skipping normalization')
        return

    communes = get_communes_list() or []
    # Build canonical normalization map: norm -> canonical
    norm_map = {}
    for c in communes:
        if not c:
            continue
        norm = normalize_string(c)
        norm_map[norm] = c

    updated = 0
    unmatched = []

    for dz in DriverZone.objects.all():
        raw = (dz.commune or '').strip()
        if not raw:
            continue
        # Quick exact uppercase match
        cu = raw.upper()
        if cu in communes:
            if dz.commune != cu:
                dz.commune = cu
                dz.save(update_fields=['commune'])
                updated += 1
            continue

        # Try normalized exact match
        norm_raw = normalize_string(raw)
        if not norm_raw:
            continue

        if norm_raw in norm_map:
            new = norm_map[norm_raw]
            if dz.commune != new:
                dz.commune = new
                dz.save(update_fields=['commune'])
                updated += 1
            continue

        # Heuristic: look for unique canonical whose norm is contained in norm_raw or vice-versa
        candidates = []
        for norm, canonical in norm_map.items():
            if norm in norm_raw or norm_raw in norm:
                candidates.append(canonical)

        # If we found a single candidate, apply it
        if len(candidates) == 1:
            new = candidates[0]
            if dz.commune != new:
                dz.commune = new
                dz.save(update_fields=['commune'])
                updated += 1
            continue

        # Could not resolve unambiguously
        unmatched.append({'id': dz.id, 'commune': dz.commune})

    print(f'Normalized DriverZone.commune rows updated: {updated}')
    if unmatched:
        print('Unmatched DriverZone rows (manual review recommended):')
        # print up to 200 to avoid extremely large outputs
        limit = 200
        for u in unmatched[:limit]:
            print(u)
        if len(unmatched) > limit:
            print(f"... and {len(unmatched)-limit} more rows not shown")


def reverse_func(apps, schema_editor):
    # Irreversible: we don't attempt to restore original free-text values
    return


class Migration(migrations.Migration):

    dependencies = [
        ('drivers', '0009_normalize_driverzone_communes'),
    ]

    operations = [
        migrations.RunPython(forwards, reverse_func),
    ]
