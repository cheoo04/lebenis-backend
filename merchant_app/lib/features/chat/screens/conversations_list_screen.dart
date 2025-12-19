import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/models/chat/chat_room_model.dart';
import '../providers/chat_provider.dart';
import 'chat_screen.dart';

class ConversationsListScreen extends ConsumerStatefulWidget {
  const ConversationsListScreen({super.key});

  @override
  ConsumerState<ConversationsListScreen> createState() => _ConversationsListScreenState();
}

class _ConversationsListScreenState extends ConsumerState<ConversationsListScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Forcer le rechargement des conversations à l'ouverture de l'écran
    Future.microtask(() {
      debugPrint('📬 [CHAT] Chargement des conversations...');
      ref.read(chatRoomsProvider.notifier).loadChatRooms(includeArchived: true);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatRoomsState = ref.watch(chatRoomsProvider);
    
    // Debug logging
    debugPrint('📬 [CHAT] État: isLoading=${chatRoomsState.isLoading}, rooms=${chatRoomsState.rooms.length}, error=${chatRoomsState.error}');

    // Séparer les conversations actives et archivées
    final activeRooms = chatRoomsState.rooms.where((r) => !r.isArchived).toList();
    final archivedRooms = chatRoomsState.rooms.where((r) => r.isArchived).toList();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF6B46C1),
        foregroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.chat_rounded, size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              'Messages',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
            ),
          ],
        ),
        actions: [
          // Bouton refresh
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () {
                ref.read(chatRoomsProvider.notifier).loadChatRooms(includeArchived: true);
              },
            ),
          ),
          if (chatRoomsState.totalUnread > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6B6B), Color(0xFFEE5A24)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF6B6B).withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '${chatRoomsState.totalUnread}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.chat_bubble_rounded, size: 18),
                  const SizedBox(width: 8),
                  Text('Actives (${activeRooms.length})'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.archive_rounded, size: 18),
                  const SizedBox(width: 8),
                  Text('Archivées (${archivedRooms.length})'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: chatRoomsState.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6B46C1)))
          : chatRoomsState.error != null
              ? _buildErrorState(chatRoomsState.error!)
              : TabBarView(
                  controller: _tabController,
                  children: [
                    // Onglet Actives
                    _buildConversationsList(activeRooms, showArchived: false),
                    // Onglet Archivées
                    _buildConversationsList(archivedRooms, showArchived: true),
                  ],
                ),
    );
  }

  Widget _buildConversationsList(List<ChatRoomModel> rooms, {required bool showArchived}) {
    if (rooms.isEmpty) {
      return _buildEmptyState(showArchived);
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(chatRoomsProvider.notifier).loadChatRooms(includeArchived: true);
      },
      child: ListView.separated(
        itemCount: rooms.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final room = rooms[index];
          return Dismissible(
            key: Key('${room.id}_${showArchived ? 'archived' : 'active'}'),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              color: showArchived ? Colors.green : Colors.orange,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    showArchived ? Icons.unarchive : Icons.archive,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    showArchived ? 'Désarchiver' : 'Archiver',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            confirmDismiss: (direction) async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(showArchived ? 'Désarchiver la conversation' : 'Archiver la conversation'),
                  content: Text(
                    showArchived
                        ? 'Voulez-vous vraiment désarchiver cette conversation ?'
                        : 'Voulez-vous vraiment archiver cette conversation ?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Annuler'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: showArchived ? Colors.green : Colors.orange,
                      ),
                      child: Text(showArchived ? 'Désarchiver' : 'Archiver'),
                    ),
                  ],
                ),
              ) ?? false;
              
              if (confirmed) {
                // Exécuter l'action
                if (showArchived) {
                  ref.read(chatRoomsProvider.notifier).unarchiveChatRoom(room.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Conversation désarchivée'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } else {
                  ref.read(chatRoomsProvider.notifier).archiveChatRoom(room.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Conversation archivée'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                }
              }
              // Toujours retourner false - la liste sera mise à jour par le provider
              return false;
            },
            // Pas de onDismissed - tout est géré dans confirmDismiss
            child: Material(
              color: room.unreadCount > 0 ? const Color(0xFFF5F0FF) : Colors.white,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(chatRoom: room),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: room.unreadCount > 0
                        ? const Border(left: BorderSide(color: Color(0xFF6B46C1), width: 4))
                        : null,
                  ),
                  child: Row(
                    children: [
                      // Avatar amélioré
                      Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: room.unreadCount > 0
                                  ? Border.all(color: const Color(0xFF6B46C1), width: 2)
                                  : null,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 26,
                              backgroundColor: showArchived ? Colors.grey[400] : const Color(0xFF6B46C1),
                              child: Text(
                                room.driver.fullName[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                          if (room.unreadCount > 0)
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF27AE60),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      // Contenu
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              room.driver.fullName,
                              style: TextStyle(
                                fontWeight: room.unreadCount > 0 ? FontWeight.w600 : FontWeight.w500,
                                fontSize: 16,
                                color: const Color(0xFF2C3E50),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              room.lastMessage ?? 'Nouvelle conversation',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: room.unreadCount > 0 ? const Color(0xFF6B46C1) : Colors.grey[600],
                                fontWeight: room.unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
                                fontSize: 14,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Heure et badge
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (room.lastMessageAt != null)
                            Text(
                              _formatTime(room.lastMessageAt!),
                              style: TextStyle(
                                fontSize: 12,
                                color: room.unreadCount > 0 ? const Color(0xFF6B46C1) : Colors.grey[500],
                                fontWeight: room.unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          const SizedBox(height: 6),
                          if (room.unreadCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF6B46C1), Color(0xFF8B5CF6)],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                room.unreadCount > 9 ? '9+' : '${room.unreadCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          else
                            Icon(Icons.chevron_right_rounded, color: Colors.grey[400], size: 20),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(bool showArchived) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF6B46C1).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              showArchived ? Icons.archive_rounded : Icons.chat_bubble_outline_rounded,
              size: 48,
              color: const Color(0xFF6B46C1),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            showArchived ? 'Aucune conversation archivée' : 'Aucune conversation',
            style: const TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B46C1),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              showArchived
                  ? 'Les conversations archivées apparaîtront ici'
                  : 'Vos conversations avec les livreurs apparaîtront ici',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            const Text(
              'Erreur de chargement',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(chatRoomsProvider.notifier).loadChatRooms(includeArchived: true);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      if (difference.inDays == 1) return 'Hier';
      return DateFormat('dd/MM').format(time);
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}min';
    } else {
      return 'Maintenant';
    }
  }
}
