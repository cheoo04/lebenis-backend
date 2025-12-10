// lib/shared/widgets/break_toggle_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_typography.dart';
import '../../core/constants/app_colors.dart';
import '../../data/providers/break_provider.dart';

/// Widget affichant le toggle de pause avec timer en temps réel
/// 
/// Affiche :
/// - Bouton Pause / Reprendre
/// - Durée actuelle de la pause (si en pause)
/// - Total des pauses du jour
class BreakToggleWidget extends ConsumerStatefulWidget {
  const BreakToggleWidget({super.key});

  @override
  ConsumerState<BreakToggleWidget> createState() => _BreakToggleWidgetState();
}

class _BreakToggleWidgetState extends ConsumerState<BreakToggleWidget> {
  @override
  void initState() {
    super.initState();
    // Charger le statut au démarrage (guarded to avoid using `ref` after unmount)
    Future.microtask(() async {
      if (!mounted) return;
      await ref.read(breakProvider.notifier).loadBreakStatus();
    });
  }

  Future<void> _toggleBreak() async {
    final messenger = ScaffoldMessenger.of(context);
    final state = ref.read(breakProvider);
    final isOnBreak = state.breakStatus?.isOnBreak ?? false;

    try {
      if (isOnBreak) {
        // Confirmer avant de reprendre
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Reprendre le travail'),
            content: Text(
              'Voulez-vous terminer votre pause ?\n\n'
              'Durée actuelle : ${_formatDuration(state.currentDuration)}',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                ),
                child: const Text('Reprendre'),
              ),
            ],
          ),
        );

        if (confirm == true) {
          await ref.read(breakProvider.notifier).endBreak();
          if (mounted) {
            messenger.showSnackBar(
              SnackBar(
                content: Text(
                  'Pause terminée (${_formatDuration(state.currentDuration)})',
                ),
                backgroundColor: AppColors.success,
              ),
            );
          }
        }
      } else {
        // Démarrer la pause directement
        await ref.read(breakProvider.notifier).startBreak();
        if (mounted) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text('☕ Pause démarrée - Bon repos !'),
              backgroundColor: AppColors.warning,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes.toString().padLeft(2, '0')}min';
    } else if (minutes > 0) {
      return '${minutes}min ${seconds.toString().padLeft(2, '0')}s';
    } else {
      return '${seconds}s';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(breakProvider);
    final isOnBreak = state.breakStatus?.isOnBreak ?? false;
    final isLoading = state.isLoading || state.isStarting || state.isEnding;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isOnBreak 
            ? AppColors.warning.withValues(alpha: 0.1)
            : AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOnBreak ? AppColors.warning : AppColors.border,
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Bouton toggle
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : _toggleBreak,
              icon: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(isOnBreak ? Icons.play_arrow : Icons.pause),
              label: Text(
                isLoading
                    ? 'Chargement...'
                    : isOnBreak
                        ? 'Reprendre le travail'
                        : 'Prendre une pause',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isOnBreak ? AppColors.success : AppColors.warning,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: AppTypography.button,
              ),
            ),
          ),

          // Affichage des durées
          if (state.breakStatus != null) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Durée actuelle (si en pause)
            if (isOnBreak) ...[
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.timer,
                      color: AppColors.warning,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pause en cours',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDuration(state.currentDuration),
                          style: AppTypography.h3.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],

            // Total du jour
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.today,
                    color: AppColors.info,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total aujourd\'hui',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        state.breakStatus!.formattedTotalBreak,
                        style: AppTypography.bodyLarge.copyWith(
                          color: AppColors.info,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],

          // Message d'erreur
          if (state.error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.error!,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
