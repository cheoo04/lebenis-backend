#!/bin/bash

# Script pour migrer les constantes Dimensions et TextStyles vers le nouveau système

FILES=$(find lib -name "*.dart" -type f -exec grep -l "Dimensions\.\|TextStyles\." {} \;)

for file in $FILES; do
  echo "Migration de $file..."
  
  # Remplacement des constantes Dimensions
  sed -i 's/Dimensions\.spacingXS/AppSpacing.xs/g' "$file"
  sed -i 's/Dimensions\.spacingS/AppSpacing.sm/g' "$file"
  sed -i 's/Dimensions\.spacingM/AppSpacing.md/g' "$file"
  sed -i 's/Dimensions\.spacingL/AppSpacing.lg/g' "$file"
  sed -i 's/Dimensions\.spacingXL/AppSpacing.xl/g' "$file"
  sed -i 's/Dimensions\.spacingXXL/AppSpacing.xxl/g' "$file"
  sed -i 's/Dimensions\.pagePadding/AppSpacing.lg/g' "$file"
  sed -i 's/Dimensions\.cardPadding/AppSpacing.md/g' "$file"
  
  sed -i 's/Dimensions\.radiusXS/AppRadius.xs/g' "$file"
  sed -i 's/Dimensions\.radiusS/AppRadius.sm/g' "$file"
  sed -i 's/Dimensions\.radiusM/AppRadius.md/g' "$file"
  sed -i 's/Dimensions\.radiusL/AppRadius.lg/g' "$file"
  sed -i 's/Dimensions\.radiusXL/AppRadius.xl/g' "$file"
  sed -i 's/Dimensions\.radiusButton/AppRadius.button/g' "$file"
  sed -i 's/Dimensions\.radiusCard/AppRadius.card/g' "$file"
  sed -i 's/Dimensions\.radiusInput/AppRadius.input/g' "$file"
  
  sed -i 's/Dimensions\.iconXS/16.0/g' "$file"
  sed -i 's/Dimensions\.iconS/20.0/g' "$file"
  sed -i 's/Dimensions\.iconM/24.0/g' "$file"
  sed -i 's/Dimensions\.iconL/32.0/g' "$file"
  sed -i 's/Dimensions\.iconXL/48.0/g' "$file"
  
  # Remplacement des TextStyles
  sed -i 's/TextStyles\.h1/AppTypography.h1/g' "$file"
  sed -i 's/TextStyles\.h2/AppTypography.h2/g' "$file"
  sed -i 's/TextStyles\.h3/AppTypography.h3/g' "$file"
  sed -i 's/TextStyles\.h4/AppTypography.h4/g' "$file"
  sed -i 's/TextStyles\.h5/AppTypography.h5/g' "$file"
  sed -i 's/TextStyles\.bodyLarge/AppTypography.bodyLarge/g' "$file"
  sed -i 's/TextStyles\.bodyMedium/AppTypography.bodyMedium/g' "$file"
  sed -i 's/TextStyles\.bodySmall/AppTypography.bodySmall/g' "$file"
  sed -i 's/TextStyles\.labelLarge/AppTypography.labelLarge/g' "$file"
  sed -i 's/TextStyles\.labelMedium/AppTypography.labelMedium/g' "$file"
  sed -i 's/TextStyles\.labelSmall/AppTypography.labelSmall/g' "$file"
  sed -i 's/TextStyles\.button/AppTypography.button/g' "$file"
  sed -i 's/TextStyles\.link/AppTypography.link/g' "$file"
  sed -i 's/TextStyles\.caption/AppTypography.caption/g' "$file"
  
done

echo "Migration terminée !"
