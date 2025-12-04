# 🚀 Driver App - Améliorations à venir

**Date**: 3 décembre 2025  
**Status**: Liste des fonctionnalités à ajouter

---

## 📋 Fonctionnalités manquantes

### 🔴 PRIORITÉ HAUTE

#### 1. PDF de livraison individuelle

**Objectif**: Permettre au driver de télécharger le reçu d'une livraison spécifique

**Backend**: ✅ Déjà disponible

```
GET /api/v1/deliveries/{id}/generate-pdf/
```

**À implémenter côté driver_app**:

- [ ] Ajouter méthode `downloadDeliveryPDF()` dans `PDFReportService`
- [ ] Ajouter bouton "Télécharger le PDF" dans l'écran de détails de livraison
- [ ] Ajouter progress indicator pendant le téléchargement
- [ ] Dialog post-téléchargement (Ouvrir/Partager/Fermer)
- [ ] Gestion des permissions pour le driver (vérifier que c'est sa livraison)

**Avantages**:

- Le driver peut partager le reçu avec le client
- Preuve de livraison pour litiges
- Archive personnelle des livraisons effectuées

**Référence**: Voir `merchant_app` qui a déjà cette fonctionnalité implémentée

---

## 📊 État actuel des PDF

### ✅ Déjà implémenté

- **PDF Analytics** : Rapports de performance du driver
  - Endpoint : `POST /api/v1/deliveries/reports/analytics-pdf/`
  - Écran : `PDFReportsScreen` (features/analytics/screens/)
  - Service : `PDFReportService` avec `downloadAnalyticsPDF()` et `downloadTestPDF()`
  - Contenu : Stats, earnings, timeline, peak hours, etc.

### ❌ À implémenter

- **PDF Livraison individuelle** : Reçu d'une livraison spécifique
  - Endpoint backend : ✅ Disponible
  - Service Flutter : ❌ Méthode manquante
  - UI : ❌ Bouton manquant
  - Contenu : Infos merchant, destinataire, colis, tarification, notation

---

## 🔮 Autres améliorations potentielles

### 🟡 PRIORITÉ MOYENNE

#### 2. Export batch des livraisons

- Télécharger plusieurs PDFs en une fois
- Export CSV de l'historique complet

#### 3. Statistiques offline

- Cache des stats pour consultation sans connexion
- Synchronisation automatique

#### 4. Personnalisation des rapports

- Choisir les métriques à inclure
- Format personnalisé (PDF, Excel, CSV)

### 🟢 PRIORITÉ BASSE

#### 5. Notifications push améliorées

- Grouping des notifications similaires
- Actions directes depuis la notification

#### 6. Mode hors-ligne avancé

- Queue des actions à synchroniser
- Indicateurs visuels de sync

---

## 📝 Notes

**Priorité actuelle** : Focus sur la complétude de l'app **merchant** d'abord.

Les améliorations driver seront implémentées après que l'app merchant atteigne **70-75% de complétion** (actuellement **45%**).

**Prochaines étapes merchant** :

1. ✅ ~~Upload documents~~ (FAIT)
2. ✅ ~~PDF Rapports~~ (FAIT)
3. ❌ Notifications Push (Priorité 1)
4. ❌ Chat temps réel (Priorité 3)
5. ❌ Factures & Mobile Money (Priorité 4)
