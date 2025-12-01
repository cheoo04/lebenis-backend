# 📖 Guide d'Utilisation - Modern UI Design System

## 🚀 Démarrage Rapide

Ce guide vous aide à utiliser le nouveau design system moderne dans l'application LeBenis Driver.

---

## 📦 Imports Nécessaires

### Pour un nouvel écran, importez :

```dart
// Thème et styles
import 'package:driver_app/theme/app_theme.dart';
import 'package:driver_app/theme/app_typography.dart';
import 'package:driver_app/theme/app_spacing.dart';
import 'package:driver_app/theme/app_radius.dart';

// Couleurs
import 'package:driver_app/core/constants/app_colors.dart';

// Widgets modernes
import 'package:driver_app/shared/widgets/modern_button.dart';
import 'package:driver_app/shared/widgets/modern_card.dart';
import 'package:driver_app/shared/widgets/modern_text_field.dart';
import 'package:driver_app/shared/widgets/modern_app_bar.dart';

// Ou importer tous les widgets en une fois
import 'package:driver_app/shared/widgets/modern_widgets.dart';
```

---

## 🎨 Exemples de Code

### 1. Créer un Écran Simple

```dart
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ModernAppBar(
        title: 'Mon Écran',
        showBackButton: true,
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.screenPaddingHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Titre', style: AppTypography.h3),
            SizedBox(height: AppSpacing.lg),
            ModernCard(
              child: Text('Contenu de la carte'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 2. Créer un Formulaire

```dart
class LoginForm extends StatefulWidget {
  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Champ Email
          ModernTextField(
            label: 'Email',
            hint: 'exemple@email.com',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre email';
              }
              return null;
            },
          ),

          SizedBox(height: AppSpacing.lg),

          // Champ Mot de passe
          ModernTextField(
            label: 'Mot de passe',
            hint: '••••••••',
            controller: _passwordController,
            obscureText: _obscurePassword,
            prefixIcon: Icons.lock_outlined,
            suffixIcon: _obscurePassword
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
            onSuffixIconTap: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre mot de passe';
              }
              return null;
            },
          ),

          SizedBox(height: AppSpacing.xxl),

          // Bouton de connexion
          ModernButton(
            text: 'Se connecter',
            icon: Icons.login,
            type: ModernButtonType.primary,
            size: ModernButtonSize.large,
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // Traiter la connexion
              }
            },
          ),
        ],
      ),
    );
  }
}
```

### 3. Créer un Dashboard avec Grille

```dart
class DashboardGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.lg,
      crossAxisSpacing: AppSpacing.lg,
      childAspectRatio: 1,
      children: [
        ColoredDashboardCard(
          icon: Icons.local_shipping_outlined,
          title: 'Livraisons',
          subtitle: 'Gérer vos courses',
          color: AppColors.cardBlue,
          onTap: () => Navigator.pushNamed(context, '/deliveries'),
        ),
        ColoredDashboardCard(
          icon: Icons.chat_bubble_outline,
          title: 'Messages',
          subtitle: 'Discuter',
          color: AppColors.cardOrange,
          onTap: () => Navigator.pushNamed(context, '/messages'),
        ),
        ColoredDashboardCard(
          icon: Icons.attach_money,
          title: 'Gains',
          subtitle: 'Vos revenus',
          color: AppColors.cardGreen,
          onTap: () => Navigator.pushNamed(context, '/earnings'),
        ),
        ColoredDashboardCard(
          icon: Icons.person_outline,
          title: 'Profil',
          subtitle: 'Vos infos',
          color: AppColors.cardPurple,
          onTap: () => Navigator.pushNamed(context, '/profile'),
        ),
      ],
    );
  }
}
```

### 4. Créer une Liste avec Cards

```dart
class DeliveryList extends StatelessWidget {
  final List<Delivery> deliveries;

  const DeliveryList({required this.deliveries});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
      itemCount: deliveries.length,
      itemBuilder: (context, index) {
        final delivery = deliveries[index];
        return ModernDeliveryCard(
          deliveryId: delivery.id,
          merchantName: delivery.merchantName,
          pickupAddress: delivery.pickupAddress,
          deliveryAddress: delivery.deliveryAddress,
          status: delivery.status,
          amount: '\$${delivery.amount}',
          distance: '${delivery.distance} km',
          onTap: () {
            Navigator.pushNamed(
              context,
              '/delivery-details',
              arguments: delivery.id,
            );
          },
        );
      },
    );
  }
}
```

### 5. Créer un Header avec Gradient

```dart
class GradientHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const GradientHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            child: Icon(icon, size: 40, color: AppColors.textWhite),
          ),
          SizedBox(height: AppSpacing.lg),

          // Titre
          Text(
            title,
            style: AppTypography.h2.copyWith(
              color: AppColors.textWhite,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.sm),

          // Sous-titre
          Text(
            subtitle,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textWhite.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
```

### 6. Créer des Chips de Filtres

```dart
class FilterChips extends StatefulWidget {
  @override
  State<FilterChips> createState() => _FilterChipsState();
}

class _FilterChipsState extends State<FilterChips> {
  String _selectedFilter = 'Tous';

  final filters = ['Tous', 'En cours', 'Terminées', 'Annulées'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
    );
  }
}
```

### 7. Créer des Contrôles de Quantité

```dart
class ProductQuantity extends StatefulWidget {
  @override
  State<ProductQuantity> createState() => _ProductQuantityState();
}

class _ProductQuantityState extends State<ProductQuantity> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Quantité:', style: AppTypography.label),
        QuantityControls(
          quantity: _quantity,
          minQuantity: 1,
          maxQuantity: 10,
          onIncrement: () {
            setState(() => _quantity++);
          },
          onDecrement: () {
            setState(() => _quantity--);
          },
        ),
      ],
    );
  }
}
```

---

## 🎯 Bonnes Pratiques

### ✅ À FAIRE

1. **Utiliser les constantes** : Toujours utiliser `AppSpacing`, `AppRadius`, `AppColors`
2. **Réutiliser les widgets** : Privilégier les widgets modernes existants
3. **Respecter les espacements** : Utiliser multiples de 4px
4. **Coins arrondis** : Utiliser 12-20px selon le composant
5. **Icônes outline** : Préférer les icônes `_outlined` de Material Icons

### ❌ À ÉVITER

1. **Valeurs en dur** : Ne pas écrire `padding: EdgeInsets.all(16)`, utiliser `AppSpacing.lg`
2. **Couleurs personnalisées** : Ne pas créer de nouvelles couleurs sans les ajouter à `AppColors`
3. **Styles de texte custom** : Utiliser `AppTypography` plutôt que `TextStyle()`
4. **Ombres lourdes** : Garder les ombres légères et subtiles
5. **Radius inconsistants** : Ne pas mélanger différents radius sans raison

---

## 🔧 Personnalisation

### Modifier les couleurs d'un bouton

```dart
ModernButton(
  text: 'Supprimer',
  type: ModernButtonType.danger,  // Rouge
  onPressed: () {},
)

ModernButton(
  text: 'Valider',
  type: ModernButtonType.success,  // Vert
  onPressed: () {},
)
```

### Modifier la taille d'un bouton

```dart
// Petit bouton
ModernButton(
  text: 'Annuler',
  size: ModernButtonSize.small,
  onPressed: () {},
)

// Grand bouton (pour CTA)
ModernButton(
  text: 'Confirmer',
  size: ModernButtonSize.large,
  onPressed: () {},
)
```

### Ajouter un gradient à une carte

```dart
ModernCard(
  gradient: AppColors.primaryGradient,
  child: Text(
    'Carte avec gradient',
    style: AppTypography.h5.copyWith(color: AppColors.textWhite),
  ),
)
```

---

## 📱 Exemples d'Écrans Complets

Consultez ces fichiers pour des exemples complets :

- `lib/features/auth/presentation/screens/splash_screen.dart` - Écran Splash
- `lib/features/auth/presentation/screens/login_screen.dart` - Écran Login
- `lib/features/home/presentation/screens/dashboard_screen.dart` - Dashboard
- `lib/features/home/presentation/screens/home_screen.dart` - Navigation

---

## 🐛 Dépannage

### Les couleurs ne s'affichent pas correctement

→ Vérifiez que vous importez `app_colors.dart` depuis `core/constants/`

### Les espacements semblent incorrects

→ Assurez-vous d'utiliser les constantes de `AppSpacing`

### Le thème ne s'applique pas

→ Vérifiez que `AppTheme.lightTheme` est défini dans `MaterialApp`

### Les widgets ne sont pas trouvés

→ Importez `package:driver_app/shared/widgets/modern_widgets.dart`

---

## 📚 Ressources

- [Documentation complète du Design System](./MODERN_UI_DESIGN_SYSTEM.md)
- [Material Design 3 Guidelines](https://m3.material.io/)
- [Flutter Widget Catalog](https://docs.flutter.dev/ui/widgets)

---

**Besoin d'aide ?** Consultez la documentation complète ou contactez l'équipe de développement.
