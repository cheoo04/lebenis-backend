#!/bin/bash

# Remplacer CustomButton par ModernButton dans les fichiers problématiques

FILES="
lib/features/deliveries/presentation/screens/active_delivery_screen.dart
lib/features/deliveries/presentation/screens/delivery_details_screen.dart
"

for file in $FILES; do
  echo "Migration de $file..."
  
  # Remplacer CustomButton par ModernButton
  sed -i 's/CustomButton(/ModernButton(/g' "$file"
  sed -i 's/OutlineButton(/ModernButton.outline(/g' "$file"
  
  # Remplacer ButtonType par ModernButtonType
  sed -i 's/ButtonType\.primary/type: ModernButtonType.primary/g' "$file"
  sed -i 's/ButtonType\.secondary/type: ModernButtonType.secondary/g' "$file"
  sed -i 's/ButtonType\.outline/type: ModernButtonType.outline/g' "$file"
  sed -i 's/ButtonType\.text/type: ModernButtonType.text/g' "$file"
  
done

echo "Migration terminée !"
