# 🔄 Guide de Migration vers le Design Moderne

Ce guide vous aide à migrer vos écrans existants vers le nouveau design system.

---

## 📋 Checklist de Migration

Pour chaque écran, suivez ces étapes :

### ✅ 1. Mettre à jour les imports

**Avant** :

```dart
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/dimensions.dart';
import '../../../../shared/theme/text_styles.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_textfield.dart';
```

**Après** :

```dart
import '../../../../core/constants/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_radius.dart';
import '../../../../shared/widgets/modern_button.dart';
import '../../../../shared/widgets/modern_text_field.dart';
```

---

### ✅ 2. Remplacer les constantes

| Ancien                   | Nouveau                              |
| ------------------------ | ------------------------------------ |
| `Dimensions.pagePadding` | `AppSpacing.screenPaddingHorizontal` |
| `Dimensions.spacingXS`   | `AppSpacing.xs`                      |
| `Dimensions.spacingS`    | `AppSpacing.sm`                      |
| `Dimensions.spacingM`    | `AppSpacing.md`                      |
| `Dimensions.spacingL`    | `AppSpacing.lg`                      |
| `Dimensions.spacingXL`   | `AppSpacing.xl`                      |
| `Dimensions.spacingXXL`  | `AppSpacing.xxl`                     |
| `Dimensions.radiusS`     | `AppRadius.sm`                       |
| `Dimensions.radiusM`     | `AppRadius.md`                       |
| `Dimensions.radiusL`     | `AppRadius.lg`                       |
| `TextStyles.h1`          | `AppTypography.h1`                   |
| `TextStyles.bodyMedium`  | `AppTypography.bodyMedium`           |
| `TextStyles.caption`     | `AppTypography.caption`              |

---

### ✅ 3. Remplacer les widgets

#### CustomButton → ModernButton

**Avant** :

```dart
CustomButton(
  text: 'Valider',
  onPressed: () {},
  isLoading: false,
  icon: Icons.check,
)
```

**Après** :

```dart
ModernButton(
  text: 'Valider',
  onPressed: () {},
  isLoading: false,
  icon: Icons.check,
  type: ModernButtonType.primary,
  size: ModernButtonSize.large,
)
```

#### CustomTextField → ModernTextField

**Avant** :

```dart
CustomTextField(
  controller: _controller,
  label: 'Email',
  hint: 'exemple@email.com',
  prefixIcon: Icons.email_outlined,
)
```

**Après** :

```dart
ModernTextField(
  controller: _controller,
  label: 'Email',
  hint: 'exemple@email.com',
  prefixIcon: Icons.email_outlined,
)
```

---

### ✅ 4. Modifier la structure Scaffold

#### AppBar Simple

**Avant** :

```dart
Scaffold(
  appBar: AppBar(
    title: Text('Mon Titre'),
    centerTitle: true,
  ),
  backgroundColor: Colors.white,
  body: // ...
)
```

**Après** :

```dart
Scaffold(
  appBar: ModernAppBar(
    title: 'Mon Titre',
    showBackButton: true,
  ),
  backgroundColor: AppColors.background,
  body: // ...
)
```

#### AppBar avec Gradient (pour formulaires)

**Après** :

```dart
Scaffold(
  backgroundColor: AppColors.surface,
  body: SafeArea(
    child: Column(
      children: [
        // Header avec gradient
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: AppColors.greenGradient,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(AppRadius.xxxl),
              bottomRight: Radius.circular(AppRadius.xxxl),
            ),
          ),
          padding: EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            children: [
              // Icône
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.textWhite.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(/* ... */),
              ),
              SizedBox(height: AppSpacing.lg),
              Text(
                'Titre',
                style: AppTypography.h2.copyWith(
                  color: AppColors.textWhite,
                ),
              ),
            ],
          ),
        ),

        // Contenu scrollable
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.screenPaddingHorizontal),
            child: // Votre formulaire
          ),
        ),
      ],
    ),
  ),
)
```

---

### ✅ 5. Mettre à jour les cartes

#### Carte Simple

**Avant** :

```dart
Card(
  child: Padding(
    padding: EdgeInsets.all(16),
    child: // contenu
  ),
)
```

**Après** :

```dart
ModernCard(
  padding: EdgeInsets.all(AppSpacing.lg),
  child: // contenu
)
```

#### Carte de Liste avec Image

**Après** :

```dart
ListItemCard(
  imageUrl: 'https://...',
  title: 'Titre',
  subtitle: 'Description',
  price: '\$12',
  rating: 4.8,
  onTap: () {},
)
```

---

### ✅ 6. Moderniser les listes

#### ListView avec Cartes

**Avant** :

```dart
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return Card(
      child: ListTile(/* ... */),
    );
  },
)
```

**Après** :

```dart
ListView.builder(
  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
  itemCount: items.length,
  itemBuilder: (context, index) {
    final item = items[index];
    return ModernDeliveryCard(
      deliveryId: item.id,
      merchantName: item.merchantName,
      status: item.status,
      // ...
      onTap: () {},
    );
  },
)
```

---

### ✅ 7. Ajouter des Chips de Filtres

**Après** :

```dart
SizedBox(
  height: 40,
  child: ListView.separated(
    scrollDirection: Axis.horizontal,
    padding: EdgeInsets.symmetric(
      horizontal: AppSpacing.screenPaddingHorizontal,
    ),
    itemCount: filters.length,
    separatorBuilder: (_, __) => SizedBox(width: AppSpacing.sm),
    itemBuilder: (context, index) {
      final filter = filters[index];
      return FilterChip(
        label: filter,
        isSelected: _selectedFilter == filter,
        color: AppColors.primary,
        onTap: () {
          setState(() {
            _selectedFilter = filter;
          });
        },
      );
    },
  ),
)
```

---

### ✅ 8. Moderniser les Messages d'Erreur

**Avant** :

```dart
if (errorMessage != null)
  Container(
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.red.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.red),
    ),
    child: Row(
      children: [
        Icon(Icons.error_outline, color: Colors.red),
        SizedBox(width: 8),
        Expanded(child: Text(errorMessage)),
      ],
    ),
  )
```

**Après** :

```dart
if (errorMessage != null)
  Container(
    margin: EdgeInsets.only(bottom: AppSpacing.lg),
    padding: EdgeInsets.all(AppSpacing.md),
    decoration: BoxDecoration(
      color: AppColors.error.withOpacity(0.1),
      borderRadius: BorderRadius.circular(AppRadius.md),
      border: Border.all(color: AppColors.error, width: 1),
    ),
    child: Row(
      children: [
        Icon(Icons.error_outline, color: AppColors.error, size: 20),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            errorMessage,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.error,
            ),
          ),
        ),
      ],
    ),
  )
```

---

## 🎯 Écrans Prioritaires à Migrer

### 1️⃣ Haute Priorité

- ✅ LoginScreen (Déjà fait)
- ✅ SplashScreen (Déjà fait)
- ✅ DashboardScreen (Déjà fait)
- ✅ HomeScreen (Déjà fait)
- ⏳ RegisterScreen (En cours)
- ⏳ ProfileScreen
- ⏳ DeliveryListScreen
- ⏳ DeliveryDetailsScreen

### 2️⃣ Moyenne Priorité

- ⏳ EarningsScreen
- ⏳ ConversationsListScreen
- ⏳ ChatScreen
- ⏳ EditProfileScreen
- ⏳ ForgotPasswordScreen

### 3️⃣ Basse Priorité

- ⏳ ActiveDeliveryScreen
- ⏳ ConfirmDeliveryScreen
- ⏳ TransactionsScreen
- ⏳ PayoutsScreen
- ⏳ ZoneSelectionScreen
- ⏳ QRScannerScreen

---

## 🔧 Script de Migration Rapide

Pour accélérer la migration, utilisez ces commandes de remplacement :

### Avec sed (Linux/Mac)

```bash
# Remplacer les imports
sed -i 's/shared\/theme\/app_colors/core\/constants\/app_colors/g' *.dart
sed -i 's/shared\/theme\/dimensions/theme\/app_spacing/g' *.dart
sed -i 's/shared\/theme\/text_styles/theme\/app_typography/g' *.dart

# Remplacer les widgets
sed -i 's/CustomButton/ModernButton/g' *.dart
sed -i 's/CustomTextField/ModernTextField/g' *.dart

# Remplacer les constantes
sed -i 's/Dimensions\./AppSpacing\./g' *.dart
sed -i 's/TextStyles\./AppTypography\./g' *.dart
```

### Avec PowerShell (Windows)

```powershell
# Remplacer les imports
Get-ChildItem *.dart | ForEach-Object {
    (Get-Content $_) -replace 'shared/theme/app_colors', 'core/constants/app_colors' | Set-Content $_
}
```

---

## ✅ Checklist de Vérification

Après migration, vérifier que :

- [ ] Tous les imports sont à jour
- [ ] Aucune référence à `Dimensions` ou `TextStyles`
- [ ] Les `CustomButton` sont remplacés par `ModernButton`
- [ ] Les `CustomTextField` sont remplacés par `ModernTextField`
- [ ] Les espacements utilisent `AppSpacing`
- [ ] Les radius utilisent `AppRadius`
- [ ] Les couleurs utilisent `AppColors`
- [ ] Les styles de texte utilisent `AppTypography`
- [ ] L'écran compile sans erreur
- [ ] L'écran s'affiche correctement
- [ ] Les interactions fonctionnent

---

## 🐛 Problèmes Courants

### Erreur: "Undefined name 'Dimensions'"

**Solution** : Remplacer par `AppSpacing`

### Erreur: "Undefined name 'TextStyles'"

**Solution** : Remplacer par `AppTypography`

### Erreur: "The method 'withValues' isn't defined"

**Solution** : Vérifier la version de Flutter (requires Flutter 3.16+)
Ou utiliser `.withOpacity()` à la place

### Les couleurs ne s'affichent pas

**Solution** : Vérifier que vous importez `app_colors.dart` depuis `core/constants/`

---

## 📚 Ressources

- [Documentation Design System](./MODERN_UI_DESIGN_SYSTEM.md)
- [Guide d'Utilisation](./MODERN_UI_USAGE_GUIDE.md)
- [Résumé des Changements](./MODERN_UI_SUMMARY.md)

---

## 🤝 Besoin d'Aide ?

Si vous rencontrez des difficultés lors de la migration :

1. Consultez les écrans déjà migrés comme référence
2. Référez-vous à la documentation complète
3. Testez sur un petit écran d'abord
4. Demandez de l'aide à l'équipe

---

**Bonne migration ! 🎨✨**
