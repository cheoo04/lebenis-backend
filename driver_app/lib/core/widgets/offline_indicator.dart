import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/offline_provider.dart';
import '../database/offline_sync_service.dart';

/// Widget qui affiche un indicateur de connectivité en haut de l'écran
/// 
/// Usage:
/// ```dart
/// Scaffold(
///   body: Column(
///     children: [
///       const OfflineIndicator(),
///       Expanded(child: YourContent()),
///     ],
///   ),
/// )
/// ```
class OfflineIndicator extends ConsumerWidget {
  const OfflineIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);
    final pendingCount = ref.watch(pendingRequestCountProvider);
    final syncProgress = ref.watch(syncProgressProvider);
    
    // Si en ligne et pas de requêtes en attente, ne rien afficher
    if (isOnline && pendingCount == 0) {
      return const SizedBox.shrink();
    }
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: isOnline ? Colors.orange : Colors.red.shade700,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Icon(
              isOnline ? Icons.sync : Icons.cloud_off,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: syncProgress.when(
                data: (progress) {
                  if (progress.status == SyncStatus.syncing) {
                    return Text(
                      'Synchronisation... ${progress.current}/${progress.total}',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    );
                  }
                  if (!isOnline) {
                    return Text(
                      'Hors-ligne${pendingCount > 0 ? ' • $pendingCount en attente' : ''}',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    );
                  }
                  return Text(
                    '$pendingCount action(s) en attente',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  );
                },
                loading: () => const Text(
                  'Vérification...',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                error: (e, st) => const Text(
                  'Erreur de connexion',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
            if (isOnline && pendingCount > 0)
              TextButton(
                onPressed: () {
                  ref.read(syncControllerProvider.notifier).forceSync();
                },
                child: const Text(
                  'Sync',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Widget qui enveloppe le contenu et affiche l'indicateur offline automatiquement
class OfflineAwareScaffold extends ConsumerWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final Color? backgroundColor;
  
  const OfflineAwareScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: appBar,
      backgroundColor: backgroundColor,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      drawer: drawer,
      body: Column(
        children: [
          const OfflineIndicator(),
          Expanded(child: body),
        ],
      ),
    );
  }
}

/// Badge qui affiche le nombre de requêtes en attente
class PendingSyncBadge extends ConsumerWidget {
  final Widget child;
  
  const PendingSyncBadge({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingCount = ref.watch(pendingRequestCountProvider);
    
    if (pendingCount == 0) {
      return child;
    }
    
    return Badge(
      label: Text('$pendingCount'),
      backgroundColor: Colors.orange,
      child: child,
    );
  }
}

/// SnackBar pour les notifications offline
void showOfflineSnackBar(BuildContext context, {required String message}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.cloud_off, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: Colors.orange.shade700,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
    ),
  );
}

/// SnackBar pour les notifications de sync réussie
void showSyncSuccessSnackBar(BuildContext context, {int syncedCount = 0}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.cloud_done, color: Colors.white),
          const SizedBox(width: 8),
          Text(syncedCount > 0 
            ? '$syncedCount élément(s) synchronisé(s)'
            : 'Synchronisation terminée'),
        ],
      ),
      backgroundColor: Colors.green.shade700,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ),
  );
}
