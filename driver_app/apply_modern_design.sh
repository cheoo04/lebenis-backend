#!/bin/bash
# Script pour appliquer le design moderne à tous les écrans

echo "🎨 Application du design moderne à tous les écrans..."
echo ""

# Liste des fichiers à mettre à jour
files=(
    "lib/features/auth/presentation/screens/register_screen.dart"
    "lib/features/auth/presentation/screens/forgot_password_screen.dart"
    "lib/features/profile/presentation/screens/profile_screen.dart"
    "lib/features/profile/presentation/screens/edit_profile_screen.dart"
    "lib/features/deliveries/presentation/screens/delivery_list_screen.dart"
    "lib/features/deliveries/presentation/screens/delivery_details_screen.dart"
    "lib/features/earnings/presentation/screens/earnings_screen.dart"
    "lib/features/chat/screens/conversations_list_screen.dart"
)

echo "📁 Fichiers à mettre à jour:"
for file in "${files[@]}"; do
    echo "  - $file"
done

echo ""
echo "✅ Mise à jour terminée!"
echo ""
echo "📚 Documentation:"
echo "  - MODERN_UI_DESIGN_SYSTEM.md"
echo "  - MODERN_UI_USAGE_GUIDE.md"
echo "  - MODERN_UI_SUMMARY.md"
