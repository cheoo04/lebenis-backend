import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/chat_provider.dart';
import '../../../data/models/chat/chat_room_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_radius.dart';
import '../../../shared/widgets/status_chip.dart';
import 'chat_screen.dart';
import '../../../main.dart'; // Pour firebaseEnabledProvider

class ConversationsListScreen extends ConsumerStatefulWidget {
  const ConversationsListScreen({super.key});

  @override
  ConsumerState<ConversationsListScreen> createState() =>
      _ConversationsListScreenState();
}

class _ConversationsListScreenState
    extends ConsumerState<ConversationsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Vérifier si Firebase est disponible
    final firebaseEnabled = ref.watch(firebaseEnabledProvider);
    
    // Si Firebase n'est pas disponible, afficher un message
    if (!firebaseEnabled) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Messages'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Chat non disponible',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'La fonctionnalité de chat n\'est pas disponible sur cette plateforme.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    final chatRoomsState = ref.watch(chatRoomsProvider);
    final totalUnreadAsync = ref.watch(totalUnreadCountProvider);

    // Filtrer les conversations selon la recherche
    final filteredRooms = chatRoomsState.rooms.where((room) {
      if (_searchQuery.isEmpty) return true;
      
      final query = _searchQuery.toLowerCase();
      final participantName = room.otherParticipant.fullName.toLowerCase();
      final deliveryNumber = room.deliveryInfo?.trackingNumber.toLowerCase() ?? '';
      
      return participantName.contains(query) || deliveryNumber.contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          // Badge avec nombre total de non lus
          totalUnreadAsync.when(
            data: (count) => count > 0
                ? Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          count > 99 ? '99+' : '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher une conversation...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),

          // Liste des conversations
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref.read(chatRoomsProvider.notifier).refresh();
              },
              child: _buildConversationsList(
                chatRoomsState,
                filteredRooms,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationsList(
    ChatRoomsState state,
    List<ChatRoomModel> rooms,
  ) {
    if (state.isLoading && rooms.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Erreur: ${state.error}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(chatRoomsProvider.notifier).refresh();
              },
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (rooms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty
                  ? 'Aucune conversation'
                  : 'Aucun résultat pour "$_searchQuery"',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: rooms.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final room = rooms[index];
        return _ConversationTile(
          room: room,
          onTap: () => _openConversation(room),
          onArchive: () => _archiveConversation(room.id),
        );
      },
    );
  }

  void _openConversation(ChatRoomModel room) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(chatRoom: room),
      ),
    ).then((_) {
      // Rafraîchir après retour du chat
      ref.read(chatRoomsProvider.notifier).refresh();
    });
  }

  Future<void> _archiveConversation(String roomId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archiver la conversation'),
        content: const Text(
          'Voulez-vous vraiment archiver cette conversation ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Archiver'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(chatRoomsProvider.notifier).archiveChatRoom(
            roomId,
            archive: true,
          );
    }
  }
}

/// Widget pour afficher une conversation dans la liste
class _ConversationTile extends StatelessWidget {
  final ChatRoomModel room;
  final VoidCallback onTap;
  final VoidCallback onArchive;

  const _ConversationTile({
    required this.room,
    required this.onTap,
    required this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    final hasUnread = room.unreadCount > 0;

    return Dismissible(
      key: Key(room.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.archive, color: Colors.white),
      ),
      confirmDismiss: (_) async => false,
      onDismissed: (_) => onArchive(),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: _buildAvatar(),
        title: Row(
          children: [
            Expanded(
              child: Text(
                room.otherParticipant.fullName,
                style: TextStyle(
                  fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (room.lastMessageAt != null)
              Text(
                _formatTime(room.lastMessageAt!),
                style: TextStyle(
                  fontSize: 12,
                  color: hasUnread ? Colors.blue : Colors.grey[600],
                  fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (room.deliveryInfo != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.local_shipping,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    room.deliveryInfo!.trackingNumber,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 4),
            Text(
              room.lastMessageText ?? 'Nouvelle conversation',
              style: TextStyle(
                color: hasUnread ? Colors.black87 : Colors.grey[600],
                fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: hasUnread
            ? Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  room.unreadCount > 9 ? '9+' : '${room.unreadCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }

  Widget _buildAvatar() {
    final photoUrl = room.otherParticipant.profilePhotoUrl;

    return CircleAvatar(
      radius: 28,
      backgroundImage: photoUrl != null && photoUrl.isNotEmpty
          ? NetworkImage(photoUrl)
          : null,
      child: photoUrl == null || photoUrl.isEmpty
          ? Text(
              room.otherParticipant.fullName[0].toUpperCase(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      // Aujourd'hui: afficher l'heure
      return DateFormat('HH:mm').format(dateTime);
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      // Cette semaine: afficher le jour
      return DateFormat('EEEE', 'fr').format(dateTime);
    } else {
      // Plus ancien: afficher la date
      return DateFormat('dd/MM/yy').format(dateTime);
    }
  }
}
