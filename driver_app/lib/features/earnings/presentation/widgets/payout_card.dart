// lib/features/earnings/presentation/widgets/payout_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../data/models/payment_model.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/dimensions.dart';
import '../../../../shared/theme/text_styles.dart';
import '../../../../shared/utils/formatters.dart';

/// Card pour afficher un versement quotidien (DailyPayout)
class PayoutCard extends StatelessWidget {
  final DailyPayoutModel payout;
  final VoidCallback? onTap;

  const PayoutCard({
    super.key,
    required this.payout,
    this.onTap,
  });

  Color _getStatusColor() {
    switch (payout.status) {
      case 'completed':
        return AppColors.success;
      case 'processing':
        return AppColors.warning;
      case 'failed':
        return AppColors.error;
      case 'pending':
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon() {
    switch (payout.status) {
      case 'completed':
        return Icons.check_circle;
      case 'processing':
        return Icons.hourglass_empty;
      case 'failed':
        return Icons.error;
      case 'pending':
        return Icons.pending;
      default:
        return Icons.help_outline;
    }
  }

  String _formatPayoutDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final payoutDay = DateTime(date.year, date.month, date.day);

    if (payoutDay == today) {
      return 'Aujourd\'hui';
    } else if (payoutDay == yesterday) {
      return 'Hier';
    } else {
      return DateFormat('d MMM yyyy', 'fr_FR').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();

    return Card(
      margin: const EdgeInsets.only(bottom: Dimensions.spacingM),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Dimensions.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Date + Status
              Row(
                children: [
                  // Icône calendrier
                  Container(
                    padding: const EdgeInsets.all(Dimensions.spacingS),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(Dimensions.radiusS),
                    ),
                    child: Icon(
                      Icons.calendar_today,
                      size: Dimensions.iconS,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: Dimensions.spacingM),
                  
                  // Date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatPayoutDate(payout.payoutDate),
                          style: TextStyles.labelLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          DateFormat('HH:mm', 'fr_FR').format(payout.createdAt),
                          style: TextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.spacingM,
                      vertical: Dimensions.spacingXS,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(Dimensions.radiusS),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(),
                          size: Dimensions.iconXS,
                          color: statusColor,
                        ),
                        const SizedBox(width: Dimensions.spacingXS),
                        Text(
                          payout.statusLabel,
                          style: TextStyles.caption.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: Dimensions.spacingM),
              const Divider(height: 1),
              const SizedBox(height: Dimensions.spacingM),

              // Montant + Nombre de paiements
              Row(
                children: [
                  // Montant total
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Montant versé',
                          style: TextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: Dimensions.spacingXS),
                        Text(
                          Formatters.formatPrice(payout.totalAmount),
                          style: TextStyles.h3.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Séparateur vertical
                  Container(
                    width: 1,
                    height: 40,
                    color: AppColors.border,
                  ),

                  // Nombre de paiements
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: Dimensions.spacingM),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Paiements groupés',
                            style: TextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: Dimensions.spacingXS),
                          Row(
                            children: [
                              Icon(
                                Icons.payment,
                                size: Dimensions.iconS,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: Dimensions.spacingXS),
                              Text(
                                '${payout.paymentCount}',
                                style: TextStyles.h3.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Méthode de paiement + Transaction ID (si complété)
              if (payout.status == 'completed' || payout.transactionId != null) ...[
                const SizedBox(height: Dimensions.spacingM),
                const Divider(height: 1),
                const SizedBox(height: Dimensions.spacingM),
                
                Row(
                  children: [
                    Icon(
                      Icons.smartphone,
                      size: Dimensions.iconS,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: Dimensions.spacingS),
                    Text(
                      _getPaymentMethodLabel(payout.paymentMethod),
                      style: TextStyles.bodySmall,
                    ),
                    if (payout.transactionId != null) ...[
                      const Spacer(),
                      Text(
                        '#${payout.transactionId}',
                        style: TextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],

              // Message d'erreur (si échoué)
              if (payout.status == 'failed' && payout.errorMessage != null) ...[
                const SizedBox(height: Dimensions.spacingM),
                Container(
                  padding: const EdgeInsets.all(Dimensions.spacingM),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(Dimensions.radiusS),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: Dimensions.iconS,
                        color: AppColors.error,
                      ),
                      const SizedBox(width: Dimensions.spacingS),
                      Expanded(
                        child: Text(
                          payout.errorMessage!,
                          style: TextStyles.caption.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Bouton voir détails (si on peut expand)
              if (onTap != null) ...[
                const SizedBox(height: Dimensions.spacingS),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Voir détails',
                      style: TextStyles.caption.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: Dimensions.iconXS,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getPaymentMethodLabel(String method) {
    switch (method) {
      case 'orange_money':
        return 'Orange Money';
      case 'mtn_momo':
        return 'MTN Mobile Money';
      case 'wave':
        return 'Wave';
      case 'moov_money':
        return 'Moov Money';
      case 'bank_transfer':
        return 'Virement bancaire';
      default:
        return method;
    }
  }
}
