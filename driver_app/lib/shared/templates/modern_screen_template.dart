// lib/shared/templates/modern_screen_template.dart

import 'package:flutter/material.dart' hide FilterChip;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_radius.dart';
import '../widgets/modern_widgets.dart';

/// Template d'écran moderne - À copier pour créer de nouveaux écrans
class ModernScreenTemplate extends ConsumerStatefulWidget {
  const ModernScreenTemplate({super.key});

  @override
  ConsumerState<ModernScreenTemplate> createState() => _ModernScreenTemplateState();
}

class _ModernScreenTemplateState extends ConsumerState<ModernScreenTemplate> {
  @override
  void initState() {
    super.initState();
    // Initialisation
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ModernAppBar(
        title: 'Mon Écran',
        showBackButton: true,
      ),
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPaddingHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.lg),
              
              // En-tête
              Text(
                'Titre de Section',
                style: AppTypography.h3,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Sous-titre ou description',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              
              const SizedBox(height: AppSpacing.xl),
              
              // Contenu principal
              ModernCard(
                child: Column(
                  children: [
                    ModernInfoRow(
                      icon: Icons.info_outline,
                      label: 'Label',
                      value: 'Valeur',
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppSpacing.lg),
              
              // Bouton d'action
              ModernButton(
                text: 'Action Principale',
                onPressed: _handleAction,
                type: ModernButtonType.primary,
                icon: Icons.check,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    // Logique de rafraîchissement
  }

  void _handleAction() {
    // Logique d'action
  }
}

/// Template d'écran avec header gradient
class ModernFormScreenTemplate extends ConsumerStatefulWidget {
  const ModernFormScreenTemplate({super.key});

  @override
  ConsumerState<ModernFormScreenTemplate> createState() => _ModernFormScreenTemplateState();
}

class _ModernFormScreenTemplateState extends ConsumerState<ModernFormScreenTemplate> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header avec gradient
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: AppColors.greenGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(AppRadius.xxxl),
                  bottomRight: Radius.circular(AppRadius.xxxl),
                ),
              ),
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                children: [
                  // Bouton retour
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: AppColors.textWhite),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Spacer(),
                    ],
                  ),
                  
                  // Icône
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.textWhite.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit_outlined,
                      size: 40,
                      color: AppColors.textWhite,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  
                  // Titre
                  Text(
                    'Titre du Formulaire',
                    style: AppTypography.h2.copyWith(
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  
                  Text(
                    'Description du formulaire',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textWhite.withValues(alpha: 0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Formulaire
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.screenPaddingHorizontal),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: AppSpacing.xl),
                      
                      ModernTextField(
                        controller: _controller,
                        label: 'Champ',
                        hint: 'Entrez une valeur',
                        prefixIcon: Icons.edit_outlined,
                      ),
                      
                      const SizedBox(height: AppSpacing.xxl),
                      
                      ModernButton(
                        text: 'Valider',
                        onPressed: _handleSubmit,
                        type: ModernButtonType.primary,
                        size: ModernButtonSize.large,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      // Logique de soumission
    }
  }
}

/// Template de liste moderne
class ModernListScreenTemplate extends ConsumerStatefulWidget {
  const ModernListScreenTemplate({super.key});

  @override
  ConsumerState<ModernListScreenTemplate> createState() => _ModernListScreenTemplateState();
}

class _ModernListScreenTemplateState extends ConsumerState<ModernListScreenTemplate> {
  String _selectedFilter = 'Tous';
  final List<String> _filters = ['Tous', 'Actifs', 'Terminés'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ModernAppBar(
        title: 'Ma Liste',
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _handleSearch,
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Filtres
          SizedBox(
            height: 50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPaddingHorizontal,
                vertical: AppSpacing.sm,
              ),
              itemCount: _filters.length,
              separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                final filter = _filters[index];
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
          ),
          
          // Liste
          Expanded(
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                itemCount: 10,
                itemBuilder: (context, index) {
                  return ModernListTile(
                    leadingIcon: Icons.folder_outlined,
                    title: 'Item ${index + 1}',
                    subtitle: 'Description de l\'item',
                    trailingIcon: Icons.arrow_forward_ios,
                    onTap: () => _handleItemTap(index),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _handleAdd,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    // Logique de rafraîchissement
  }

  void _handleSearch() {
    // Logique de recherche
  }

  void _handleItemTap(int index) {
    // Logique de tap sur item
  }

  void _handleAdd() {
    // Logique d'ajout
  }
}
