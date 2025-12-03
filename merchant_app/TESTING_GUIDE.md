# 🧪 GUIDE DE TEST MERCHANT APP

## 🚀 Démarrage rapide

```bash
# 1. Aller dans le dossier
cd /home/cheoo/lebenis_project/merchant_app

# 2. Installer les dépendances
flutter pub get

# 3. Vérifier qu'il n'y a pas d'erreurs
flutter analyze

# 4. Lancer l'app
flutter run

# Ou pour choisir le device
flutter devices
flutter run -d <device-id>
```

---

## 📱 Scénarios de test

### Test 1: Inscription & Connexion ✅

1. **Ouvrir l'app**
2. Cliquer sur "S'inscrire"
3. Remplir le formulaire:
   - Nom du commerce: "Test Shop"
   - Email: "testshop@test.com"
   - Téléphone: "+225 0701020304"
   - Adresse: "Cocody, Abidjan"
   - Mot de passe: "Test1234!"
4. Soumettre
5. **Attendu:** Écran "En attente d'approbation"

**Backend:** Aller dans Django Admin et approuver le merchant

6. Se déconnecter et se reconnecter
7. **Attendu:** Redirection vers Dashboard

---

### Test 2: Dashboard ✅

1. **Vérifier affichage:**

   - Header avec gradient
   - "Bienvenue, Test Shop"
   - Badge de statut "Approuvé"
   - Grid 2x2 avec stats:
     - Livraisons
     - Taux succès
     - Revenus
     - En cours
   - Section "Actions rapides" avec 3 cards

2. **Tester pull-to-refresh**
   - Tirer vers le bas
   - **Attendu:** Stats rechargées

---

### Test 3: Création de livraison ✅

1. Cliquer sur FloatingActionButton "Nouvelle livraison"

2. **Remplir le formulaire:**

   **Destinataire:**

   - Nom: "Jean Kouassi"
   - Téléphone: "+225 0712345678"

   **Point de récupération:**

   - Commune: Sélectionner "Cocody"
   - Adresse: "Angré 7ème tranche, Villa 123"
   - Cliquer sur "Utiliser ma position GPS"
   - **Attendu:** Bouton devient vert "GPS activé ✓"

   **Adresse de livraison:**

   - Commune: Sélectionner "Yopougon"
   - Adresse: "Niangon Nord, Rue des Écoles"

   **Colis:**

   - Description: "Vêtements"
   - Poids: "2.5"

   **Paiement:**

   - Sélectionner "Prépayé"

3. **Vérifier estimation prix:**

   - Apparaît automatiquement
   - Card avec gradient bleu
   - Prix en FCFA

4. Cliquer sur "Créer la livraison"

5. **Attendu:**
   - SnackBar vert "✅ Livraison créée avec succès !"
   - Retour à l'écran précédent

---

### Test 4: Liste des livraisons ✅

1. Aller dans "Mes livraisons" (depuis dashboard ou menu)

2. **Vérifier affichage:**

   - Tabs: Toutes / En attente / En cours / Livrées
   - Cards de livraisons avec:
     - Nom destinataire
     - Badge de statut coloré
     - Itinéraire (pickup → delivery)
     - Description colis + poids
     - Date relative ("Il y a 2 min")
     - Prix

3. **Tester filtres:**

   - Cliquer sur tab "En attente"
   - **Attendu:** Uniquement livraisons pending
   - Cliquer sur tab "Livrées"
   - **Attendu:** Uniquement livraisons delivered

4. **Tester pull-to-refresh:**

   - Tirer vers le bas
   - **Attendu:** Liste rechargée

5. **Tester navigation:**
   - Cliquer sur une card
   - **Attendu:** Écran de détail

---

### Test 5: Détail de livraison ✅

1. **Vérifier affichage:**

   - Header avec statut (card gradient coloré)
   - Section Destinataire (nom + tél)
   - Section Itinéraire (pickup + delivery avec GPS)
   - Section Colis (description + poids + prix)
   - Section Paiement (méthode)
   - Section Livreur (si assigné)

2. **Si livraison pending:**

   - Bouton rouge "Annuler la livraison" visible
   - Cliquer dessus
   - **Attendu:** Dialog de confirmation
   - Confirmer
   - **Attendu:** Livraison annulée, retour à la liste

3. **Si livreur assigné:**

   - Bouton vert "Appeler le livreur" visible
   - Cliquer
   - **Attendu:** App téléphone s'ouvre

4. **Si livraison in_transit:**
   - Bouton "Suivre la livraison en temps réel" visible
   - Cliquer
   - **Attendu:** Écran de tracking

---

### Test 6: Tracking en temps réel ✅

**Prérequis:** Avoir une livraison avec driver assigné + en transit

1. **Vérifier affichage carte:**

   - Google Maps visible
   - 3 markers:
     - 📍 Bleu (pickup)
     - 🚚 Orange (driver)
     - 📍 Vert (delivery)
   - Ligne pointillée reliant les points

2. **Vérifier info panel (bottom):**

   - Statut de la livraison
   - Itinéraire pickup → delivery
   - Info livreur (nom + téléphone)
   - Bouton refresh

3. **Tester auto-refresh:**

   - Badge "Mise à jour auto" en haut à droite
   - **Attendu:** Position driver se met à jour toutes les 10s

4. **Test avec driver_app en parallèle:**
   - Driver se déplace
   - **Attendu:** Marker orange bouge sur la carte merchant

---

### Test 7: Édition profil ✅

1. Aller dans Dashboard → "Modifier mon profil"

2. **Vérifier chargement:**

   - Champs pré-remplis avec données actuelles
   - Avatar avec icône store

3. **Modifier les champs:**

   - Nom: "Test Shop Updated"
   - Email: "newemail@test.com"
   - Téléphone: "+225 0799999999"
   - Adresse: "Plateau, Abidjan"

4. Cliquer sur "Enregistrer les modifications"

5. **Attendu:**

   - Loading button pendant save
   - SnackBar vert "✅ Profil mis à jour"
   - Retour à l'écran précédent

6. **Vérifier mise à jour:**
   - Retourner au dashboard
   - Pull-to-refresh
   - **Attendu:** Nouveau nom visible dans header

---

## 🎯 Tests d'intégration Merchant ↔ Driver

### Scénario complet:

1. **Merchant crée livraison**

   - Status: `pending`
   - Visible dans liste merchant "En attente"

2. **Admin assigne driver** (Django admin ou API)

   - Status: `assigned`
   - Merchant voit badge "Livreur assigné" en bleu
   - Bouton "Appeler le livreur" disponible

3. **Driver accepte et part au pickup**

   - Status: `pickup_confirmed` après récupération
   - Merchant voit badge "Colis récupéré" en indigo
   - Tracking disponible

4. **Driver en route vers delivery**

   - Status: `in_transit`
   - Merchant peut suivre en temps réel sur carte
   - Position se met à jour automatiquement

5. **Driver confirme livraison**
   - Status: `delivered`
   - Merchant voit badge vert "Livré avec succès"
   - Photo + signature visibles dans détail (si implémenté)

---

## ⚠️ Tests des erreurs

### Test 1: Création sans GPS

1. Ne pas cliquer sur "Utiliser ma position GPS"
2. Soumettre formulaire
3. **Attendu:** Livraison créée quand même (GPS optionnel)

### Test 2: Réseau coupé

1. Désactiver WiFi/Data
2. Essayer de créer une livraison
3. **Attendu:** SnackBar rouge avec erreur réseau

### Test 3: Communes non chargées

1. Vider le cache
2. Ouvrir formulaire création
3. **Attendu:** Loading indicator dans dropdown communes

### Test 4: Tracking sans position driver

1. Driver n'a pas envoyé sa position GPS
2. Ouvrir tracking
3. **Attendu:** Seulement markers pickup + delivery visibles

---

## 📊 Vérifications Backend

Pendant les tests, vérifier dans Django Admin:

### Après création livraison:

```python
# Check in Django shell
from apps.deliveries.models import Delivery

d = Delivery.objects.latest('created_at')
print(f"Merchant: {d.merchant.business_name}")
print(f"Pickup: {d.pickup_commune} ({d.pickup_latitude}, {d.pickup_longitude})")
print(f"Delivery: {d.delivery_commune} ({d.delivery_latitude}, {d.delivery_longitude})")
print(f"Status: {d.status}")
print(f"Price: {d.price}")
```

### Vérifier GPS:

- `pickup_latitude` et `pickup_longitude` doivent être remplis
- `delivery_latitude` et `delivery_longitude` doivent être remplis
- Valeurs autour de Abidjan: lat ~5.3, lng ~-4.0

---

## 🐛 Debug

### Afficher les logs:

```bash
# Android
adb logcat | grep -i "flutter\|dio\|error"

# iOS
# Ouvrir Xcode et voir console
```

### Logs Dio (requêtes HTTP):

Dans `dio_client.dart`, vérifier que les intercepteurs loggent les requêtes/réponses.

### Erreurs communes:

1. **"Failed to load communes"**

   - Vérifier que backend tourne
   - Vérifier URL dans `app_config.dart`
   - Vérifier token d'authentification

2. **"Delivery creation failed"**

   - Voir logs Dio pour response backend
   - Vérifier que tous les champs requis sont envoyés

3. **"Google Maps not showing"**
   - Voir [GOOGLE_MAPS_SETUP.md](./GOOGLE_MAPS_SETUP.md)
   - Vérifier API key configurée

---

## ✅ Checklist complète

### Fonctionnalités de base:

- [ ] Inscription merchant
- [ ] Connexion merchant
- [ ] Dashboard s'affiche
- [ ] Stats chargent depuis API

### Création de livraison:

- [ ] Formulaire complet visible
- [ ] Dropdown communes charge depuis API
- [ ] GPS position fonctionne
- [ ] Estimation prix calcule automatiquement
- [ ] Livraison créée avec succès
- [ ] Toast de confirmation
- [ ] Retour à l'écran précédent

### Liste de livraisons:

- [ ] Liste charge depuis API
- [ ] Filtres par status fonctionnent
- [ ] Pull-to-refresh fonctionne
- [ ] Navigation vers détail
- [ ] Empty state si aucune livraison

### Détail de livraison:

- [ ] Toutes les infos affichées
- [ ] Bouton appeler driver fonctionne (si assigné)
- [ ] Bouton tracking fonctionne (si en cours)
- [ ] Bouton annuler fonctionne (si pending)

### Tracking temps réel:

- [ ] Carte Google Maps s'affiche
- [ ] Markers pickup + delivery visibles
- [ ] Marker driver visible (si position disponible)
- [ ] Polyline reliant les points
- [ ] Auto-refresh toutes les 10s
- [ ] Info panel en bas

### Édition profil:

- [ ] Profil charge depuis API
- [ ] Champs pré-remplis
- [ ] Modifications sauvegardées
- [ ] Toast de confirmation

---

## 🎯 Résultat attendu

Après tous ces tests, le merchant doit pouvoir:

1. ✅ Créer une livraison complète avec GPS
2. ✅ Voir toutes ses livraisons
3. ✅ Suivre une livraison en temps réel
4. ✅ Contacter le driver
5. ✅ Annuler une livraison
6. ✅ Modifier son profil

**L'app est prête pour la production ! 🚀**

---

## 📞 Support

En cas de problème:

1. Vérifier les logs (`flutter run -v`)
2. Vérifier que le backend tourne
3. Vérifier les tokens d'authentification
4. Relire [MERCHANT_APP_IMPLEMENTATION_COMPLETE.md](./MERCHANT_APP_IMPLEMENTATION_COMPLETE.md)

**Temps de test estimé:** 30-45 minutes pour tous les scénarios
