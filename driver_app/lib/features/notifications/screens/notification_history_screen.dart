// lib/features/notifications/screens/notification_history_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers/notification_provider.dart';
import '../../../data/models/notification_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_radius.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart' as app_error;
import '../widgets/notification_card.dart';

/// Écran affichant l'historique des notifications avec filtres et actions
class NotificationHistoryScreen extends ConsumerStatefulWidget {
  const NotificationHistoryScreen({super.key});

  @override
  ConsumerState<NotificationHistoryScreen> createState() =>
      _NotificationHistoryScreenState();
}

class _NotificationHistoryScreenState
    extends ConsumerState<NotificationHistoryScreen> {
  final ScrollController _scrollController = ScrollController();
  String? _selectedType;

  @override
  void initState() {
    super.initState();
    // Charger les notifications au démarrage
    Future.microtask(() => ref.read(notificationProvider.notifier).loadNotifications());
    
    // Écouter le scroll pour pagination
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(notificationProvider.notifier).loadMoreNotifications();
    }
  }

  Future<void> _onRefresh() async {
    await ref.read(notificationProvider.notifier).refresh();
  }

  void _showNotificationDetails(NotificationModel notification) {
    // Marquer comme lue automatiquement quand on ouvre les détails
    if (!notification.isRead) {
      ref.read(notificationProvider.notifier).markAsRead(notification.id);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _NotificationDetailsSheet(notification: notification),
    );
  }

  void _showTypeFilter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _TypeFilterSheet(
        selectedType: _selectedType,
        onApply: (type) {
          setState(() => _selectedType = type);
          ref.read(notificationProvider.notifier).filterByType(type);
          Navigator.pop(context);
        },
        onClear: () {
          setState(() => _selectedType = null);
          ref.read(notificationProvider.notifier).filterByType(null);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showDeleteConfirmation(NotificationModel notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la notification'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette notification ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              ref.read(notificationProvider.notifier).deleteNotification(notification.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notification supprimée')),
              );
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          // Bouton filtre par type
          IconButton(
            icon: Badge(
              isLabelVisible: _selectedType != null,
              backgroundColor: AppColors.error,
              child: const Icon(Icons.filter_list),
            ),
            tooltip: 'Filtrer par type',
            onPressed: _showTypeFilter,
          ),
          // Bouton "Tout marquer comme lu"
          if (state.unreadCount > 0)
            IconButton(
              icon: const Icon(Icons.mark_email_read),
              tooltip: 'Tout marquer comme lu',
              onPressed: () {
                ref.read(notificationProvider.notifier).markAllAsRead();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Toutes les notifications ont été marquées comme lues'),
                  ),
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Badge compteur de non lues
          if (state.unreadCount > 0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: AppColors.primary.withValues(alpha: 0.1),
              child: Row(
                children: [
                  Icon(Icons.notifications_active, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${state.unreadCount} notification${state.unreadCount > 1 ? 's' : ''} non lue${state.unreadCount > 1 ? 's' : ''}',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          // Filtre actif
          if (_selectedType != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Text('Filtre: '),
                  Chip(
                    label: Text(_getTypeLabel(_selectedType!)),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () {
                      setState(() => _selectedType = null);
                      ref.read(notificationProvider.notifier).filterByType(null);
                    },
                  ),
                ],
              ),
            ),

          // Liste des notifications
          Expanded(
            child: state.isLoading
                ? const Center(child: LoadingWidget())
                : state.error != null
                    ? app_error.ErrorDisplayWidget(
                        message: state.error!,
                        onRetry: () =>
                            ref.read(notificationProvider.notifier).loadNotifications(),
                      )
                    : state.notifications.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: _onRefresh,
                            child: ListView.builder(
                              controller: _scrollController,
                              itemCount: state.notifications.length + (state.isLoadingMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == state.notifications.length) {
                                  return const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Center(child: CircularProgressIndicator()),
                                  );
                                }

                                final notification = state.notifications[index];
                                return Dismissible(
                                  key: Key(notification.id),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 20),
                                    color: AppColors.error,
                                    child: const Icon(Icons.delete, color: Colors.white),
                                  ),
                                  confirmDismiss: (direction) async {
                                    _showDeleteConfirmation(notification);
                                    return false; // On gère la suppression manuellement
                                  },
                                  child: NotificationCard(
                                    notification: notification,
                                    onTap: () => _showNotificationDetails(notification),
                                    onMarkAsRead: !notification.isRead
                                        ? () => ref
                                            .read(notificationProvider.notifier)
                                            .markAsRead(notification.id)
                                        : null,
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _selectedType != null ? Icons.filter_list_off : Icons.notifications_off,
            size: 64,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            _selectedType != null
                ? 'Aucune notification de ce type'
                : 'Aucune notification',
            style: AppTypography.h3.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedType != null
                ? 'Essayez un autre filtre'
                : 'Vous recevrez ici vos notifications',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'new_delivery':
        return 'Nouvelle livraison';
      case 'delivery_accepted':
        return 'Livraison acceptée';
      case 'delivery_rejected':
        return 'Livraison refusée';
      case 'delivery_status_change':
        return 'Changement de statut';
      case 'payment_received':
        return 'Paiement reçu';
      case 'rating_received':
        return 'Notation reçue';
      case 'system':
        return 'Système';
      case 'promo':
        return 'Promotion';
      default:
        return type;
    }
  }
}

// ========== BOTTOM SHEET DÉTAILS ==========

class _NotificationDetailsSheet extends StatelessWidget {
  final NotificationModel notification;

  const _NotificationDetailsSheet({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barre de drag
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Type + icône
          Row(
            children: [
              Text(
                notification.typeIcon,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  notification.typeLabel,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (notification.isRead)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Lue',
                    style: AppTypography.caption.copyWith(color: AppColors.success),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Titre
          Text(
            notification.title,
            style: AppTypography.h3.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          // Corps
          Text(
            notification.body,
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: 16),
          // Date
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                notification.relativeTime,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          // Données additionnelles
          if (notification.data.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Informations complémentaires',
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            ...notification.data.entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 120,
                        child: Text(
                          '${entry.key}:',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          entry.value.toString(),
                          style: AppTypography.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
          const SizedBox(height: 24),
          // Bouton fermer
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Fermer'),
            ),
          ),
        ],
      ),
    );
  }
}

// ========== BOTTOM SHEET FILTRE TYPE ==========

class _TypeFilterSheet extends StatefulWidget {
  final String? selectedType;
  final Function(String?) onApply;
  final VoidCallback onClear;

  const _TypeFilterSheet({
    required this.selectedType,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<_TypeFilterSheet> createState() => _TypeFilterSheetState();
}

class _TypeFilterSheetState extends State<_TypeFilterSheet> {
  String? _tempSelectedType;

  @override
  void initState() {
    super.initState();
    _tempSelectedType = widget.selectedType;
  }

  @override
  Widget build(BuildContext context) {
    final types = [
      {'value': 'new_delivery', 'label': 'Nouvelle livraison', 'icon': '📦'},
      {'value': 'delivery_accepted', 'label': 'Livraison acceptée', 'icon': '✅'},
      {'value': 'delivery_rejected', 'label': 'Livraison refusée', 'icon': '❌'},
      {'value': 'delivery_status_change', 'label': 'Changement de statut', 'icon': '🔄'},
      {'value': 'payment_received', 'label': 'Paiement reçu', 'icon': '💰'},
      {'value': 'rating_received', 'label': 'Notation reçue', 'icon': '⭐'},
      {'value': 'system', 'label': 'Système', 'icon': '🔔'},
      {'value': 'promo', 'label': 'Promotion', 'icon': '🎁'},
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filtrer par type', style: AppTypography.h3),
          const SizedBox(height: 16),
          // Custom radio group to avoid deprecated groupValue/onChanged
          ...types.map((type) {
            final selected = _tempSelectedType == type['value'];
            return GestureDetector(
              onTap: () => setState(() => _tempSelectedType = type['value']),
              child: Row(
                children: [
                  Icon(
                    selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: selected ? AppColors.primary : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 12),
                  Text(type['icon']!, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Text(type['label']!),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onClear,
                  child: const Text('Effacer'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => widget.onApply(_tempSelectedType),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text('Appliquer'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
