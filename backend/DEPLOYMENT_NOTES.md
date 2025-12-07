# Notes de déploiement (essentiel)

Ce fichier contient les instructions minimales pour déployer le backend sans Docker (judicieux pour votre contrainte).

## Prérequis
- Python 3.11+ (ou 3.10/3.12 selon votre environnement); utilisez un virtualenv.
- PostgreSQL accessible et configuré via `DATABASE_URL` ou `settings.py`.

## Dépendances
Installer les dépendances Python :

```bash
python -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
```

Assurez-vous que `polyline` et `requests` sont installés (figurent normalement dans `requirements.txt`).

## Variables d'environnement importantes
- `OSRM_BASE_URL` : URL de votre instance OSRM ou du fournisseur (ex: `https://router.project-osrm.org` pour tests).
- `OPENROUTESERVICE_API_KEY` : (optionnel) clé pour OpenRouteService si utilisée.
- `SENTRY_DSN` : DSN Sentry pour capture des erreurs/événements.
- `OSRM_RETRY_ATTEMPTS` / `OSRM_RETRY_BACKOFF` : retry/backoff pour appels OSRM (optionnel).
 - `OSRM_RETRY_ATTEMPTS` / `OSRM_RETRY_BACKOFF` : retry/backoff pour appels OSRM (optionnel).
 - `PREFER_ORS` : si `true` (ou `1`), OpenRouteService sera utilisé en priorité pour le routing (utile si vous n'hébergez pas OSRM en local). Ceci nécessite `OPENROUTESERVICE_API_KEY`.

## Appliquer les migrations

```bash
source .venv/bin/activate
python manage.py migrate
```

> Note : la migration `0013_delivery_distance_source` est idempotente (utilise `ADD COLUMN IF NOT EXISTS`) pour éviter les erreurs si la colonne existe déjà.

## Backfill des distances

Pour recalculer et remplir `distance_km` + `distance_source` pour les livraisons existantes :

```bash
python manage.py backfill_delivery_distances --batch 100
# ou pour un test rapide
python manage.py backfill_delivery_distances --batch 10
```

Le management command met à jour uniquement les livraisons manquantes ou celles explicitement sélectionnées.

## Vérifications post-déploiement
- Vérifier qu'il n'y a pas d'erreurs dans les logs Sentry.
- Lancer le script de comparaison ponctuelle entre backend et OSRM si besoin :

```bash
python backend/scripts/compare_routes.py --batch 50 --output backend/data/route_comparison.csv
```

## Observabilité
- Activer Sentry et surveiller les événements indiquant `fallback_straight_line` (cela signale que la routage n'a pas pu obtenir une route réelle).

## Remarques opérationnelles
- Évitez d'utiliser l'instance publique `router.project-osrm.org` en production (latence/quotas/fiabilité). Hébergez OSRM en interne ou utilisez un fournisseur.
- Pas de Docker par défaut — si vous décidez d'héberger OSRM, faites-le via un service ou VM dédiée.
 - Si vous préférez ne pas héberger OSRM localement et que vous avez déjà OpenRouteService configuré, activez `PREFER_ORS=true` et fournissez `OPENROUTESERVICE_API_KEY`.

---

Si vous voulez, je peux générer un script systemd simple pour exécuter la app Django+gunicorn, ou un playbook Ansible minimal pour automatiser ces étapes.
