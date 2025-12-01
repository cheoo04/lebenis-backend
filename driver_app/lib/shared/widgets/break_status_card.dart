// lib/shared/widgets/break_status_card.dart

import 'package:flutter/material.dart';
import '../../theme/app_typography.dart';
import '../../core/constants/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/break_provider.dart';
import '../../features/break/screens/break_management_screen.dart';

/// Widget compact affichant le statut de pause dans le dashboard
/// 
/// Affiche :
/// - Indicateur visuel (En pause / Disponible)
/// - Durée actuelle si en pause
/// - Bouton vers l'écran complet
class BreakStatusCard extends ConsumerStatefulWidget {
  const BreakStatusCard({super.key});

  @override
  ConsumerState<BreakStatusCard> createState() => _BreakStatusCardState();
}

class _BreakStatusCardState extends ConsumerState<BreakStatusCard> {
  @override
  void initState() {
    super.initState();
    // Charger le statut au démarrage
    Future.microtask(() => ref.read(breakProvider.notifier).loadBreakStatus());
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

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isOnBreak ? AppColors.warning : AppColors.border,
          width: isOnBreak ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const BreakManagementScreen(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  // Indicateur de statut
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: isOnBreak ? AppColors.warning : AppColors.success,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (isOnBreak ? AppColors.warning : AppColors.success)
                              .withValues(alpha: 0.4),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Statut',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ],
              ),
              
              const SizedBox(height: 12),

              // Statut principal
              Row(
                children: [
                  Icon(
                    isOnBreak ? Icons.pause_circle : Icons.check_circle,
                    color: isOnBreak ? AppColors.warning : AppColors.success,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isOnBreak ? 'En pause' : 'Disponible',
                          style: AppTypography.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isOnBreak ? AppColors.warning : AppColors.success,
                          ),
                        ),
                        if (isOnBreak) ...[
                          const SizedBox(height: 4),
                          Text(
                            _formatDuration(state.currentDuration),
                            style: AppTypography.h3.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ] else if (state.breakStatus != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Total: ${state.breakStatus!.formattedTotalBreak}',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
