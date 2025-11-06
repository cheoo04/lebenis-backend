// lib/features/earnings/presentation/widgets/transaction_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../data/models/payment_model.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/dimensions.dart';
import '../../../../shared/theme/text_styles.dart';
import '../../../../shared/utils/formatters.dart';

/// Card pour afficher une transaction individuelle (TransactionHistory)
class TransactionCard extends StatelessWidget {
  final TransactionHistoryModel transaction;
  final VoidCallback? onTap;

  const TransactionCard({
    super.key,
    required this.transaction,
    this.onTap,
  });

  Color _getTransactionTypeColor() {
    switch (transaction.transactionType) {
      case 'collection':
        return AppColors.success; // Vert pour paiement reçu
      case 'disbursement':
        return AppColors.primary; // Bleu pour versement
      case 'refund':
        return AppColors.warning; // Orange pour remboursement
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getTransactionTypeIcon() {
    switch (transaction.transactionType) {
      case 'collection':
        return Icons.arrow_downward; // Entrée d'argent
      case 'disbursement':
        return Icons.arrow_upward; // Sortie d'argent
      case 'refund':
        return Icons.replay; // Remboursement
      default:
        return Icons.swap_horiz;
    }
  }

  Color _getStatusColor() {
    switch (transaction.status) {
      case 'success':
        return AppColors.success;
      case 'failed':
        return AppColors.error;
      case 'pending':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon() {
    switch (transaction.status) {
      case 'success':
        return Icons.check_circle;
      case 'failed':
        return Icons.error;
      case 'pending':
        return Icons.pending;
      default:
        return Icons.help_outline;
    }
  }

  String _getProviderIcon() {
    switch (transaction.provider) {
      case 'orange_money':
        return '🧡';
      case 'mtn_momo':
        return '💛';
      case 'wave':
        return '💙';
      case 'moov_money':
        return '💚';
      default:
        return '💰';
    }
  }

  String _formatTransactionDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final transactionDay = DateTime(date.year, date.month, date.day);

    String dateStr;
    if (transactionDay == today) {
      dateStr = 'Aujourd\'hui';
    } else if (transactionDay == yesterday) {
      dateStr = 'Hier';
    } else {
      dateStr = DateFormat('d MMM yyyy', 'fr_FR').format(date);
    }

    final timeStr = DateFormat('HH:mm', 'fr_FR').format(date);
    return '$dateStr à $timeStr';
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _getTransactionTypeColor();
    final statusColor = _getStatusColor();
    final isPositive = transaction.transactionType == 'collection';

    return Card(
      margin: const EdgeInsets.only(bottom: Dimensions.spacingM),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Dimensions.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.cardPadding),
          child: Row(
            children: [
              // Icône type de transaction
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(Dimensions.radiusM),
                ),
                child: Icon(
                  _getTransactionTypeIcon(),
                  color: typeColor,
                  size: Dimensions.iconM,
                ),
              ),

              const SizedBox(width: Dimensions.spacingM),

              // Détails transaction
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type + Provider
                    Row(
                      children: [
                        Text(
                          transaction.transactionTypeLabel,
                          style: TextStyles.labelLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: Dimensions.spacingS),
                        Text(
                          _getProviderIcon(),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: Dimensions.spacingXS),
                        Expanded(
                          child: Text(
                            transaction.providerLabel,
                            style: TextStyles.caption,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: Dimensions.spacingXS),

                    // Date
                    Text(
                      _formatTransactionDate(transaction.createdAt),
                      style: TextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),

                    // Référence externe (si disponible)
                    if (transaction.externalReference != null) ...[
                      const SizedBox(height: Dimensions.spacingXS),
                      Row(
                        children: [
                          Icon(
                            Icons.tag,
                            size: Dimensions.iconXS,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: Dimensions.spacingXS),
                          Expanded(
                            child: Text(
                              transaction.externalReference!,
                              style: TextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                                fontFamily: 'monospace',
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],

                    // Message d'erreur (si échec)
                    if (transaction.status == 'failed' && 
                        transaction.errorMessage != null) ...[
                      const SizedBox(height: Dimensions.spacingS),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.spacingS,
                          vertical: Dimensions.spacingXS,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(Dimensions.radiusS),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: Dimensions.iconXS,
                              color: AppColors.error,
                            ),
                            const SizedBox(width: Dimensions.spacingXS),
                            Expanded(
                              child: Text(
                                transaction.errorMessage!,
                                style: TextStyles.caption.copyWith(
                                  color: AppColors.error,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: Dimensions.spacingM),

              // Montant + Status
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Montant avec signe
                  Text(
                    '${isPositive ? '+' : '-'} ${Formatters.formatPrice(transaction.amount)}',
                    style: TextStyles.labelLarge.copyWith(
                      color: isPositive ? AppColors.success : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: Dimensions.spacingXS),

                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.spacingS,
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
                          transaction.statusLabel,
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
            ],
          ),
        ),
      ),
    );
  }
}
