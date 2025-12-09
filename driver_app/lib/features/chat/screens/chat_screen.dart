import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../../../data/models/chat/chat_room_model.dart';
import '../../../data/models/chat/message_model.dart';
import '../providers/chat_provider.dart';
import '../../../core/providers/cloudinary_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final ChatRoomModel chatRoom;

  const ChatScreen({
    super.key,
    required this.chatRoom,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    
    // Marquer comme lu au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatRoomsProvider.notifier).markAsRead(widget.chatRoom.id);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    
    // Arrêter le typing indicator
    if (_isTyping) {
      ref.read(chatMessagesProvider(widget.chatRoom.id).notifier)
          .setTyping(false);
    }
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Écouter les messages en temps réel depuis Firebase
    final messagesAsync = ref.watch(messagesStreamProvider(widget.chatRoom.id));
    
    // Écouter les typing indicators
    final typingAsync = ref.watch(typingIndicatorsStreamProvider(widget.chatRoom.id));
    
    final chatState = ref.watch(chatMessagesProvider(widget.chatRoom.id));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.chatRoom.otherParticipant.fullName),
            if (widget.chatRoom.deliveryInfo != null)
              Text(
                widget.chatRoom.deliveryInfo!.trackingNumber,
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
        actions: [
          // Indicateur de typing
          typingAsync.when(
            data: (indicators) {
              final isOtherUserTyping = indicators.values.any((v) => v);
              return isOtherUserTyping
                  ? const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Center(
                        child: Text(
                          '✍️',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    )
                  : const SizedBox.shrink();
            },
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Liste des messages
          Expanded(
            child: messagesAsync.when(
              data: (messages) => _buildMessagesList(messages),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Text('Erreur: $error'),
              ),
            ),
          ),

          // Zone de saisie
          _buildInputArea(chatState),
        ],
      ),
    );
  }

  Widget _buildMessagesList(List<MessageModel> messages) {
    if (messages.isEmpty) {
      return const Center(
        child: Text(
          'Aucun message.\nCommencez la conversation !',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    // Scroller vers le bas après le build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isFirstInGroup = index == 0 ||
            messages[index - 1].sender.id != message.sender.id;
        final showTimestamp = index == 0 ||
            message.createdAt.difference(messages[index - 1].createdAt).inMinutes > 5;

        return Column(
          children: [
            if (showTimestamp) _buildTimestamp(message.createdAt),
            _MessageBubble(
              message: message,
              showAvatar: isFirstInGroup,
            ),
          ],
        );
      },
    );
  }

  Widget _buildTimestamp(DateTime dateTime) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        DateFormat('dd MMM yyyy, HH:mm', 'fr').format(dateTime),
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildInputArea(ChatMessagesState state) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          // Bouton image
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: state.isSending ? null : _pickImage,
          ),

          // Bouton localisation
          IconButton(
            icon: const Icon(Icons.location_on),
            onPressed: state.isSending ? null : _sendLocation,
          ),

          // Champ de texte
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Votre message...',
                border: InputBorder.none,
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              onChanged: _onTextChanged,
            ),
          ),

          // Bouton envoyer
          IconButton(
            icon: state.isSending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
            onPressed: state.isSending ? null : _sendMessage,
          ),
        ],
      ),
    );
  }

  void _onTextChanged(String text) {
    final isTypingNow = text.isNotEmpty;
    if (isTypingNow != _isTyping) {
      setState(() => _isTyping = isTypingNow);
      ref.read(chatMessagesProvider(widget.chatRoom.id).notifier)
          .setTyping(isTypingNow);
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    setState(() => _isTyping = false);

    final success = await ref
        .read(chatMessagesProvider(widget.chatRoom.id).notifier)
        .sendTextMessage(text);

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de l\'envoi du message')),
      );
    }
  }

  Future<void> _pickImage() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (image == null) return;

    // Afficher dialog de progression
    if (!mounted) return;
    
    double uploadProgress = 0.0;
    bool isUploading = true;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Envoi de l\'image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LinearProgressIndicator(value: uploadProgress),
              const SizedBox(height: 16),
              Text('${(uploadProgress * 100).toStringAsFixed(0)}%'),
            ],
          ),
        ),
      ),
    );

    try {
      // Upload vers Cloudinary
      final cloudinaryService = ref.read(cloudinaryServiceProvider);
      final imageUrl = await cloudinaryService.uploadChatImage(
        image.path,
        onProgress: (progress) {
          if (mounted && isUploading) {
            setState(() => uploadProgress = progress);
          }
        },
      );

      isUploading = false;
      
      // Fermer le dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Envoyer le message avec l'URL Cloudinary
      final success = await ref
          .read(chatMessagesProvider(widget.chatRoom.id).notifier)
          .sendImageMessage(imageUrl);

      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de l\'envoi de l\'image')),
        );
      }
    } catch (e) {
      isUploading = false;
      
      // Fermer le dialog
      if (mounted) {
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur upload: $e')),
        );
      }
    }
  }

  Future<void> _sendLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      
      final success = await ref
          .read(chatMessagesProvider(widget.chatRoom.id).notifier)
          .sendLocationMessage(
            latitude: position.latitude,
            longitude: position.longitude,
            text: 'Ma position',
          );

      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de l\'envoi de la position')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }
}

/// Widget pour afficher une bulle de message
class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool showAvatar;

  const _MessageBubble({
    required this.message,
    required this.showAvatar,
  });

  @override
  Widget build(BuildContext context) {
    final isMine = message.isMine;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMine && showAvatar) _buildAvatar(),
          if (!isMine && !showAvatar) const SizedBox(width: 40),
          
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: isMine ? Colors.blue : Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMessageContent(),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat('HH:mm').format(message.createdAt),
                        style: TextStyle(
                          fontSize: 10,
                          color: isMine ? Colors.white70 : Colors.grey[600],
                        ),
                      ),
                      if (isMine) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.isRead ? Icons.done_all : Icons.done,
                          size: 14,
                          color: message.isRead ? Colors.blue[200] : Colors.white70,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          if (isMine) const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final photoUrl = message.sender.profilePhotoUrl;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: CircleAvatar(
        radius: 16,
        backgroundImage: photoUrl != null && photoUrl.isNotEmpty
            ? NetworkImage(photoUrl)
            : null,
        child: photoUrl == null || photoUrl.isEmpty
            ? Text(
                message.sender.fullName[0].toUpperCase(),
                style: const TextStyle(fontSize: 12),
              )
            : null,
      ),
    );
  }

  Widget _buildMessageContent() {
    final isMine = message.isMine;

    switch (message.messageType) {
      case MessageType.text:
        return Text(
          message.text ?? '',
          style: TextStyle(
            color: isMine ? Colors.white : Colors.black87,
            fontSize: 15,
          ),
        );

      case MessageType.image:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: message.imageUrl!,
                  width: 200,
                  placeholder: (context, url) => const SizedBox(
                    width: 200,
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.error),
                ),
              ),
            if (message.text != null && message.text!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                message.text!,
                style: TextStyle(
                  color: isMine ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ],
        );

      case MessageType.location:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_on,
                  color: isMine ? Colors.white : Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  'Position partagée',
                  style: TextStyle(
                    color: isMine ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            if (message.latitude != null && message.longitude != null)
              Text(
                '${message.latitude}, ${message.longitude}',
                style: TextStyle(
                  fontSize: 12,
                  color: isMine ? Colors.white70 : Colors.grey[600],
                ),
              ),
          ],
        );

      case MessageType.system:
        return Text(
          message.text ?? '',
          style: const TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        );
    }
  }
}
