import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_provider.dart';
import 'chat_screen.dart';

/// Écran wrapper qui charge une conversation par son ID
/// Utile pour la navigation depuis les notifications push
class ChatScreenById extends ConsumerStatefulWidget {
  final String chatRoomId;

  const ChatScreenById({
    super.key,
    required this.chatRoomId,
  });

  @override
  ConsumerState<ChatScreenById> createState() => _ChatScreenByIdState();
}

class _ChatScreenByIdState extends ConsumerState<ChatScreenById> {
  bool _hasTriedLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  int _retryCount = 0;
  static const int _maxRetries = 3;

  @override
  void initState() {
    super.initState();
    _loadChatRoom();
  }

  Future<void> _loadChatRoom() async {
    if (_hasTriedLoading && _retryCount >= _maxRetries) return;
    
    setState(() {
      _hasTriedLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      await ref.read(chatRoomsProvider.notifier).loadChatRooms();
      
      // Vérifier si la room existe après le chargement
      if (mounted) {
        final rooms = ref.read(chatRoomsProvider).rooms;
        final found = rooms.any((r) => r.id == widget.chatRoomId);
        
        if (!found && _retryCount < _maxRetries) {
          // Attendre un peu et réessayer (la room peut être nouvelle)
          await Future.delayed(const Duration(milliseconds: 500));
          _retryCount++;
          await _loadChatRoom();
        } else if (!found) {
          setState(() {
            _hasError = true;
            _errorMessage = 'Conversation introuvable';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Erreur de connexion: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatRoomsState = ref.watch(chatRoomsProvider);
    final theme = Theme.of(context);

    // Chercher la room dans les rooms existantes
    final roomIndex = chatRoomsState.rooms.indexWhere(
      (r) => r.id == widget.chatRoomId,
    );

    // Room trouvée ✅
    if (roomIndex != -1) {
      return ChatScreen(chatRoom: chatRoomsState.rooms[roomIndex]);
    }

    // Erreur ❌
    if (_hasError) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Conversation'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 64,
                  color: theme.colorScheme.error.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  _errorMessage ?? 'Conversation introuvable',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'ID: ${widget.chatRoomId}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () {
                    _retryCount = 0;
                    _loadChatRoom();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Réessayer'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Retour'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Chargement en cours ⏳
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversation'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Chargement de la conversation...',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            if (_retryCount > 0) ...[
              const SizedBox(height: 8),
              Text(
                'Tentative ${_retryCount + 1}/$_maxRetries',
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
