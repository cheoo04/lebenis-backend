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
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadChatRoom();
  }

  Future<void> _loadChatRoom() async {
    try {
      // Charger les conversations si pas encore fait
      final chatRoomsState = ref.read(chatRoomsProvider);
      
      if (chatRoomsState.rooms.isEmpty) {
        await ref.read(chatRoomsProvider.notifier).loadRooms();
      }
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Erreur de chargement: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Chargement de la conversation...'),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Erreur')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(_error!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Retour'),
              ),
            ],
          ),
        ),
      );
    }

    final chatRoomsState = ref.watch(chatRoomsProvider);
    
    // Trouver la conversation par ID
    final chatRoom = chatRoomsState.rooms.firstWhere(
      (room) => room.id == widget.chatRoomId,
      orElse: () => throw Exception('Conversation introuvable'),
    );

    // Naviguer vers ChatScreen avec la room chargée
    return ChatScreen(chatRoom: chatRoom);
  }
}
