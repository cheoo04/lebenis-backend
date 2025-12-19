import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/chat_provider.dart';
import '../../../data/models/chat/chat_room_model.dart';
import 'chat_screen.dart';
import '../../../main.dart'; // Pour firebaseEnabledProvider

class ConversationsListScreen extends ConsumerStatefulWidget {
  const ConversationsListScreen({super.key});

  @override
  ConsumerState<ConversationsListScreen> createState() =>
      _ConversationsListScreenState();
}

class _ConversationsListScreenState
    extends ConsumerState<ConversationsListScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late TabController _tabController;
  bool _showArchived = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _showArchived = _tabController.index == 1;
      });
      _loadConversations();
    });
    
    // Charger les conversations au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadConversations();
      _setupRealtimeUpdates();
    });
  }
  
  void _loadConversations() {
    ref.read(chatRoomsProvider.notifier).loadChatRooms(
      includeArchived: _showArchived,
    );
  }
  
  void _setupRealtimeUpdates() {
    // Écouter les mises à jour en temps réel
    ref.listen(conversationsUpdatesProvider, (previous, next) {
      // Quand il y a une mise à jour, recharger les conversations
      if (!next.isLoading && !next.hasError) {
        _loadConversations();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Vérifier si Firebase est disponible
    final firebaseEnabled = ref.watch(firebaseEnabledProvider);
    
    // Écouter les mises à jour temps réel (déclenche le rebuild)
    ref.watch(conversationsUpdatesProvider);
    
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

    // Filtrer les conversations selon la recherche et l'onglet actif
    final filteredRooms = chatRoomsState.rooms.where((room) {
      // Filtrer par onglet (archivé ou actif)
      final matchesTab = _showArchived ? room.isArchived : !room.isArchived;
      if (!matchesTab) return false;
      
      // Filtrer par recherche
      if (_searchQuery.isEmpty) return true;
      
      final query = _searchQuery.toLowerCase();
      final participantName = room.otherParticipant.fullName.toLowerCase();
      final deliveryNumber = room.deliveryInfo?.trackingNumber.toLowerCase() ?? '';
      
      return participantName.contains(query) || deliveryNumber.contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1E3A5F),
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
          // Badge avec nombre total de non lus
          totalUnreadAsync.when(
            data: (count) => count > 0
                ? Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
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
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(
              icon: Icon(Icons.chat_bubble_rounded),
              text: 'Actives',
            ),
            Tab(
              icon: Icon(Icons.archive_rounded),
              text: 'Archivées',
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Header avec gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1E3A5F), Color(0xFF2D5A87)],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher une conversation...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[500]),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.close_rounded, color: Colors.grey[500]),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
              ),
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
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A5F).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _showArchived ? Icons.archive_rounded : Icons.chat_bubble_outline_rounded,
                size: 48,
                color: const Color(0xFF1E3A5F),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _searchQuery.isEmpty
                  ? (_showArchived ? 'Aucune conversation archivée' : 'Aucune conversation')
                  : 'Aucun résultat pour "$_searchQuery"',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E3A5F),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _showArchived 
                  ? 'Les conversations archivées apparaîtront ici'
                  : 'Vos conversations avec les commerçants apparaîtront ici',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
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
          isArchived: _showArchived,
          onTap: () => _openConversation(room),
          onArchive: () => _doArchiveConversation(room.id, archive: !_showArchived),
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

  /// Archive/désarchive sans confirmation (utilisé par Dismissible qui a son propre dialogue)
  Future<void> _doArchiveConversation(String roomId, {required bool archive}) async {
    await ref.read(chatRoomsProvider.notifier).archiveChatRoom(
          roomId,
          archive: archive,
        );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Conversation ${archive ? 'archivée' : 'désarchivée'}'),
          backgroundColor: archive ? Colors.orange : Colors.green,
        ),
      );
    }
  }

  /// Archive/désarchive avec confirmation (utilisé par le menu long press)
  Future<void> _archiveConversation(String roomId, {required bool archive}) async {
    final actionText = archive ? 'archiver' : 'désarchiver';
    final actionTitle = archive ? 'Archiver' : 'Désarchiver';
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$actionTitle la conversation'),
        content: Text(
          'Voulez-vous vraiment $actionText cette conversation ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(actionTitle),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _doArchiveConversation(roomId, archive: archive);
    }
  }
}

/// Widget pour afficher une conversation dans la liste
class _ConversationTile extends StatelessWidget {
  final ChatRoomModel room;
  final bool isArchived;
  final VoidCallback onTap;
  final VoidCallback onArchive;

  const _ConversationTile({
    required this.room,
    required this.isArchived,
    required this.onTap,
    required this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    final hasUnread = room.unreadCount > 0;
    final actionText = isArchived ? 'Désarchiver' : 'Archiver';
    final actionIcon = isArchived ? Icons.unarchive_rounded : Icons.archive_rounded;
    final actionColor = isArchived 
        ? const Color(0xFF27AE60) 
        : const Color(0xFFF39C12);

    return Dismissible(
      key: Key('${room.id}_${isArchived ? 'archived' : 'active'}'),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isArchived 
                ? [const Color(0xFF27AE60), const Color(0xFF2ECC71)]
                : [const Color(0xFFF39C12), const Color(0xFFE67E22)],
          ),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(actionIcon, color: Colors.white, size: 28),
            const SizedBox(height: 4),
            Text(
              actionText, 
              style: const TextStyle(
                color: Colors.white, 
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (_) async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(actionIcon, color: actionColor),
                const SizedBox(width: 12),
                Text(actionText),
              ],
            ),
            content: Text('Voulez-vous ${actionText.toLowerCase()} cette conversation ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('Annuler', style: TextStyle(color: Colors.grey[600])),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: actionColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(actionText),
              ),
            ],
          ),
        ) ?? false;
        
        if (confirmed) {
          onArchive();
        }
        return false;
      },
      child: Material(
        color: hasUnread ? const Color(0xFFF0F7FF) : Colors.white,
        child: InkWell(
          onTap: onTap,
          onLongPress: () {
            showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (ctx) => SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: actionColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(actionIcon, color: actionColor),
                        ),
                        title: Text(
                          '$actionText la conversation',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        onTap: () {
                          Navigator.pop(ctx);
                          onArchive();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: hasUnread 
                  ? const Border(left: BorderSide(color: Color(0xFF1E3A5F), width: 4))
                  : null,
            ),
            child: Row(
              children: [
                _buildAvatar(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room.otherParticipant.fullName,
                        style: TextStyle(
                          fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w500,
                          fontSize: 16,
                          color: const Color(0xFF1E3A5F),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (room.deliveryInfo != null) ...[
                        const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E3A5F).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.local_shipping_rounded, size: 12, color: Color(0xFF1E3A5F)),
                            const SizedBox(width: 4),
                            Text(
                              room.deliveryInfo!.trackingNumber,
                              style: const TextStyle(
                                fontSize: 11, 
                                color: Color(0xFF1E3A5F),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      room.lastMessageText ?? 'Nouvelle conversation',
                      style: TextStyle(
                        color: hasUnread ? const Color(0xFF1E3A5F) : Colors.grey[600],
                        fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                        fontSize: 14,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (room.lastMessageAt != null)
                    Text(
                      _formatTime(room.lastMessageAt!),
                      style: TextStyle(
                        fontSize: 12,
                        color: hasUnread ? const Color(0xFF1E3A5F) : Colors.grey[500],
                        fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  const SizedBox(height: 6),
                  if (hasUnread)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E3A5F), Color(0xFF2D5A87)],
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
  }

  Widget _buildAvatar() {
    final photoUrl = room.otherParticipant.profilePhotoUrl;
    final hasUnread = room.unreadCount > 0;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: hasUnread 
                ? Border.all(color: const Color(0xFF1E3A5F), width: 2)
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
            backgroundColor: const Color(0xFF1E3A5F),
            backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                ? CachedNetworkImageProvider(
                    photoUrl,
                    cacheKey: 'conv_avatar_${room.otherParticipant.id}',
                  )
                : null,
            child: photoUrl == null || photoUrl.isEmpty
                ? Text(
                    room.otherParticipant.fullName.isNotEmpty 
                        ? room.otherParticipant.fullName[0].toUpperCase() 
                        : '?',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
        ),
        if (hasUnread)
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
