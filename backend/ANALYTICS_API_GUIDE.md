# Analytics API - Documentation

## 📊 Vue d'ensemble

L'API Analytics fournit des statistiques détaillées pour le dashboard du livreur, incluant :
- Résumé des performances
- Évolution temporelle (timeline)
- Heatmap GPS des livraisons
- Distribution par statut, commune, distance
- Heures de pointe
- Détail des revenus

## 🔗 Base URL

```
/api/v1/deliveries/analytics/
```

## 🔐 Authentication

Tous les endpoints requièrent l'authentification JWT :
```
Authorization: Bearer <access_token>
```

## 📅 Paramètres de Date Communs

Tous les endpoints supportent ces query parameters :

| Paramètre | Type | Valeurs | Description |
|-----------|------|---------|-------------|
| `period` | string | `today`, `week`, `month`, `year`, `custom` | Période prédéfinie (défaut: `month`) |
| `start_date` | datetime | ISO 8601 | Date de début (requis si `period=custom`) |
| `end_date` | datetime | ISO 8601 | Date de fin (requis si `period=custom`) |

**Exemples** :
```
# Derniers 30 jours (défaut)
GET /analytics/summary/

# Aujourd'hui
GET /analytics/summary/?period=today

# Période personnalisée
GET /analytics/summary/?period=custom&start_date=2025-01-01T00:00:00Z&end_date=2025-01-31T23:59:59Z
```

---

## 📍 Endpoints

### 1. Résumé des Statistiques

**GET** `/analytics/summary/`

Retourne un résumé complet des performances du livreur.

**Response**:
```json
{
  "total_deliveries": 45,
  "completed_deliveries": 42,
  "cancelled_deliveries": 3,
  "in_progress": 0,
  "total_earnings": 125000.0,
  "total_distance_km": 234.5,
  "success_rate": 93.33,
  "average_delivery_value": 2976.19
}
```

**Champs** :
- `total_deliveries` : Nombre total de livraisons
- `completed_deliveries` : Livraisons terminées avec succès
- `cancelled_deliveries` : Livraisons annulées
- `in_progress` : Livraisons en cours
- `total_earnings` : Revenus totaux (FCFA)
- `total_distance_km` : Distance totale parcourue
- `success_rate` : Taux de réussite (%)
- `average_delivery_value` : Valeur moyenne par livraison

---

### 2. Timeline (Évolution)

**GET** `/analytics/timeline/`

Évolution des livraisons et revenus dans le temps.

**Query Parameters** :
- `granularity` : `day` (défaut) ou `hour`

**Response**:
```json
[
  {
    "date": "2025-01-15",
    "deliveries": 5,
    "earnings": 15000.0
  },
  {
    "date": "2025-01-16",
    "deliveries": 7,
    "earnings": 21000.0
  }
]
```

---

### 3. Distribution par Statut

**GET** `/analytics/status-distribution/`

Répartition des livraisons par statut.

**Response**:
```json
{
  "delivered": 42,
  "cancelled": 3,
  "in_transit": 2,
  "picked_up": 1
}
```

---

### 4. Statistiques par Commune

**GET** `/analytics/commune-stats/`

Nombre de livraisons par commune avec coordonnées GPS.

**Response**:
```json
[
  {
    "commune": "Cocody",
    "deliveries": 15,
    "latitude": 5.3599,
    "longitude": -4.0082
  },
  {
    "commune": "Plateau",
    "deliveries": 12,
    "latitude": 5.3247,
    "longitude": -4.0169
  }
]
```

---

### 5. Heatmap GPS

**GET** `/analytics/heatmap/`

Points GPS pour afficher une heatmap des livraisons.

**Query Parameters** :
- `max_points` : Nombre max de points (défaut: 500)

**Response**:
```json
[
  {
    "lat": 5.3599,
    "lng": -4.0082,
    "weight": 1
  },
  {
    "lat": 5.3247,
    "lng": -4.0169,
    "weight": 1
  }
]
```

**Usage avec Google Maps** :
```javascript
const heatmapData = response.map(point => ({
  location: new google.maps.LatLng(point.lat, point.lng),
  weight: point.weight
}));

new google.maps.visualization.HeatmapLayer({
  data: heatmapData,
  map: map
});
```

---

### 6. Heures de Pointe

**GET** `/analytics/peak-hours/`

Statistiques par heure de la journée (0-23h).

**Response**:
```json
[
  {
    "hour": 9,
    "deliveries": 5,
    "earnings": 15000.0
  },
  {
    "hour": 12,
    "deliveries": 8,
    "earnings": 24000.0
  },
  {
    "hour": 18,
    "deliveries": 6,
    "earnings": 18000.0
  }
]
```

---

### 7. Distribution des Distances

**GET** `/analytics/distance-distribution/`

Répartition des livraisons par tranche de distance.

**Response**:
```json
{
  "0-5km": 20,
  "5-10km": 15,
  "10-15km": 8,
  "15-20km": 3,
  "20km+": 1
}
```

---

### 8. Détail des Revenus

**GET** `/analytics/earnings-breakdown/`

Répartition des revenus par type.

**Response**:
```json
{
  "delivery": 100000.0,
  "bonus": 15000.0,
  "tip": 5000.0,
  "adjustment": 0.0,
  "total": 120000.0
}
```

**Types de revenus** :
- `delivery` : Revenus de livraisons normales
- `bonus` : Bonus de performance
- `tip` : Pourboires
- `adjustment` : Ajustements manuels

---

## 📱 Exemples d'Utilisation Flutter

### Récupérer le résumé

```dart
final response = await dioClient.get(
  '/deliveries/analytics/summary/',
  queryParameters: {'period': 'month'},
);

final stats = response.data;
print('Total livraisons: ${stats['total_deliveries']}');
print('Revenus: ${stats['total_earnings']} FCFA');
```

### Timeline pour un graphique

```dart
final response = await dioClient.get(
  '/deliveries/analytics/timeline/',
  queryParameters: {
    'period': 'week',
    'granularity': 'day',
  },
);

final List<FlSpot> chartData = (response.data as List)
    .asMap()
    .entries
    .map((entry) => FlSpot(
          entry.key.toDouble(),
          entry.value['earnings'].toDouble(),
        ))
    .toList();
```

### Heatmap Google Maps

```dart
final response = await dioClient.get(
  '/deliveries/analytics/heatmap/',
  queryParameters: {'max_points': 500},
);

final List<LatLng> heatmapPoints = (response.data as List)
    .map((point) => LatLng(
          point['lat'],
          point['lng'],
        ))
    .toList();

// Afficher sur GoogleMap avec HeatmapLayer
```

---

## 🔒 Sécurité & Permissions

- ✅ Authentification JWT obligatoire
- ✅ Chaque livreur ne voit que ses propres statistiques
- ✅ Validation des dates (start_date < end_date)
- ✅ Limite de points pour performance (heatmap)

---

## ⚡ Performance

### Optimisations Implémentées

1. **Requêtes optimisées** :
   - Utilisation de `select_related()` et `prefetch_related()`
   - Agrégations au niveau DB (Sum, Count, Avg)

2. **Limites** :
   - Heatmap: max 500 points par défaut
   - Timeline: agrégation par jour/heure

3. **Indexation DB** :
   - Index sur `driver_id`, `status`, `created_at`
   - Index composite sur (`driver_id`, `delivered_at`)

### Recommandations

- Utiliser `period=month` pour le dashboard principal
- Limiter `max_points` pour la heatmap sur mobile
- Mettre en cache les stats du jour (Redis)

---

## 🐛 Gestion d'Erreurs

### Codes de Réponse

| Code | Description |
|------|-------------|
| 200 | Succès |
| 400 | Paramètres invalides |
| 401 | Non authentifié |
| 404 | Profil livreur introuvable |
| 500 | Erreur serveur |

### Exemples d'Erreurs

```json
{
  "error": "Profil livreur introuvable"
}
```

```json
{
  "start_date": ["start_date doit être antérieure à end_date"]
}
```

---

## 📊 Cas d'Usage Recommandés

### Dashboard Principal
```
GET /analytics/summary/?period=today
GET /analytics/timeline/?period=week&granularity=day
GET /analytics/earnings-breakdown/?period=month
```

### Analyse Géographique
```
GET /analytics/heatmap/?period=month&max_points=500
GET /analytics/commune-stats/?period=month
```

### Analyse Temporelle
```
GET /analytics/peak-hours/?period=week
GET /analytics/timeline/?period=month&granularity=day
```

### Rapport Mensuel
```
GET /analytics/summary/?period=custom&start_date=2025-01-01&end_date=2025-01-31
GET /analytics/earnings-breakdown/?period=custom&start_date=2025-01-01&end_date=2025-01-31
GET /analytics/distance-distribution/?period=custom&start_date=2025-01-01&end_date=2025-01-31
```

---

## 🧪 Tests

### Test avec cURL

```bash
# Résumé du mois
curl -H "Authorization: Bearer YOUR_TOKEN" \
  "http://localhost:8000/api/v1/deliveries/analytics/summary/?period=month"

# Timeline de la semaine
curl -H "Authorization: Bearer YOUR_TOKEN" \
  "http://localhost:8000/api/v1/deliveries/analytics/timeline/?period=week"

# Heatmap
curl -H "Authorization: Bearer YOUR_TOKEN" \
  "http://localhost:8000/api/v1/deliveries/analytics/heatmap/?max_points=100"
```

---

## 📚 Ressources

- [Django Aggregation](https://docs.djangoproject.com/en/5.0/topics/db/aggregation/)
- [Google Maps Heatmap Layer](https://developers.google.com/maps/documentation/javascript/heatmaplayer)
- [fl_chart Flutter](https://pub.dev/packages/fl_chart)
