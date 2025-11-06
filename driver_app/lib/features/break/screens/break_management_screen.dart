// lib/features/break/screens/break_management_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers/break_provider.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/text_styles.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/break_toggle_widget.dart';

/// Écran de gestion des pauses
/// 
/// Affiche :
/// - Toggle pause avec timer en temps réel
/// - Statistiques des pauses du jour
/// - Conseils et informations
class BreakManagementScreen extends ConsumerStatefulWidget {
  const BreakManagementScreen({super.key});

  @override
  ConsumerState<BreakManagementScreen> createState() => _BreakManagementScreenState();
}

class _BreakManagementScreenState extends ConsumerState<BreakManagementScreen> {
  @override
  void initState() {
    super.initState();
    // Charger le statut au démarrage
    Future.microtask(() => ref.read(breakProvider.notifier).loadBreakStatus());
  }

  Future<void> _onRefresh() async {
    await ref.read(breakProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(breakProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Gestion des pauses'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser',
            onPressed: _onRefresh,
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: LoadingWidget())
          : RefreshIndicator(
              onRefresh: _onRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Widget toggle pause
                    const BreakToggleWidget(),
                    
                    const SizedBox(height: 24),

                    // Statistiques du jour
                    _buildStatsSection(state),

                    const SizedBox(height: 24),

                    // Informations et conseils
                    _buildInfoSection(),

                    const SizedBox(height: 24),

                    // Règles des pauses
                    _buildRulesSection(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatsSection(BreakState state) {
    final isOnBreak = state.breakStatus?.isOnBreak ?? false;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistiques du jour',
            style: TextStyles.h3.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Statut actuel
          _buildStatRow(
            icon: Icons.circle,
            iconColor: isOnBreak ? AppColors.warning : AppColors.success,
            label: 'Statut',
            value: isOnBreak ? 'En pause' : 'Disponible',
          ),

          const Divider(height: 24),

          // Durée actuelle
          if (isOnBreak)
            _buildStatRow(
              icon: Icons.timer,
              iconColor: AppColors.warning,
              label: 'Pause actuelle',
              value: _formatDuration(state.currentDuration),
            ),

          if (isOnBreak) const Divider(height: 24),

          // Total du jour
          _buildStatRow(
            icon: Icons.access_time,
            iconColor: AppColors.info,
            label: 'Total pauses',
            value: state.breakStatus?.formattedTotalBreak ?? '0min',
          ),

          const Divider(height: 24),

          // Heure de début (si en pause)
          if (isOnBreak && state.breakStatus?.breakStartedAt != null)
            _buildStatRow(
              icon: Icons.play_circle_outline,
              iconColor: AppColors.textSecondary,
              label: 'Démarrée à',
              value: _formatTime(state.breakStatus!.breakStartedAt!),
            ),
        ],
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.info.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Conseils bien-être',
                style: TextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTipItem('☕', 'Prenez une pause toutes les 2 heures'),
          _buildTipItem('💧', 'Hydratez-vous régulièrement'),
          _buildTipItem('🚶', 'Bougez pendant vos pauses'),
          _buildTipItem('😌', 'Le repos améliore votre concentration'),
        ],
      ),
    );
  }

  Widget _buildTipItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRulesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.info),
              const SizedBox(width: 8),
              Text(
                'Règles des pauses',
                style: TextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildRuleItem(
            '📅',
            'Les durées sont réinitialisées chaque jour à minuit',
          ),
          _buildRuleItem(
            '🚫',
            'Vous ne pouvez pas accepter de livraisons pendant une pause',
          ),
          _buildRuleItem(
            '✅',
            'Terminez toujours vos livraisons avant de prendre une pause',
          ),
          _buildRuleItem(
            '⏱️',
            'Le timer continue même si vous fermez l\'application',
          ),
        ],
      ),
    );
  }

  Widget _buildRuleItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes.toString().padLeft(2, '0')}min ${seconds.toString().padLeft(2, '0')}s';
    } else if (minutes > 0) {
      return '${minutes}min ${seconds.toString().padLeft(2, '0')}s';
    } else {
      return '${seconds}s';
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
