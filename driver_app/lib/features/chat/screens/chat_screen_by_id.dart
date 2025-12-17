import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_provider.dart';
import 'chat_screen.dart';

/// Écran wrapper qui charge une conversation par son ID
/// Utile pour la navigation depuis les notifications push
class ChatScreenById extends ConsumerWidget {
  final String chatRoomId;

  const ChatScreenById({
    super.key,
    required this.chatRoomId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatRoomsState = ref.watch(chatRoomsProvider);

    // Si les rooms sont en chargement et vides, afficher loader
    if (chatRoomsState.isLoading && chatRoomsState.rooms.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Chercher la room dans les rooms existantes
    final roomIndex = chatRoomsState.rooms.indexWhere((r) => r.id == chatRoomId);
    
    if (roomIndex != -1) {
      // Room trouvée, naviguer directement
      return ChatScreen(chatRoom: chatRoomsState.rooms[roomIndex]);
    }

    // Room non trouvée, déclencher le chargement si pas déjà fait
    if (!chatRoomsState.isLoading) {
      // Charger les rooms en arrière-plan
      Future.microtask(() => ref.read(chatRoomsProvider.notifier).loadRooms());
    }

    // En attendant, afficher un loader
    return Scaffold(
      appBar: AppBar(title: const Text('Conversation')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Chargement...'),
          ],
        ),
      ),
    );
  }
}
