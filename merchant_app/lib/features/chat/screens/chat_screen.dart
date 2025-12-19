import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/chat/chat_room_model.dart';
import '../providers/chat_provider.dart';
import '../../../data/providers/auth_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final ChatRoomModel chatRoom;

  const ChatScreen({super.key, required this.chatRoom});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  bool _userHasScrolledUp = false;
  int _previousMessageCount = 0;
  bool _isSending = false;
  bool _showScrollToBottom = false;

  @override
  void initState() {
    super.initState();
    // Marquer comme lu au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatRepositoryProvider).markAsRead(widget.chatRoom.id);
    });
    
    // Détecter si l'utilisateur a scrollé vers le haut
    _scrollController.addListener(_onScroll);
  }
  
  void _onScroll() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.offset;
      // Si l'utilisateur est à plus de 100 pixels du bas, il a scrollé vers le haut
      final hasScrolledUp = (maxScroll - currentScroll) > 100;
      
      if (hasScrolledUp != _userHasScrolledUp) {
        setState(() {
          _userHasScrolledUp = hasScrolledUp;
          _showScrollToBottom = hasScrolledUp;
        });
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool force = false}) {
    if (!_scrollController.hasClients) return;
    
    // Ne pas auto-scroll si l'utilisateur a scrollé vers le haut (sauf si forcé)
    if (_userHasScrolledUp && !force) return;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    final messageText = text;
    _messageController.clear();
    setState(() {
      _isTyping = false;
      _isSending = true;
    });

    try {
      await ref.read(chatRoomsProvider.notifier).sendMessage(
            widget.chatRoom.id,
            messageText,
          );
      _scrollToBottom(force: true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Échec de l\'envoi du message'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Réessayer',
              textColor: Colors.white,
              onPressed: () {
                _messageController.text = messageText;
                _sendMessage();
              },
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatMessagesProvider(widget.chatRoom.id));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF6B46C1),
        foregroundColor: Colors.white,
        leadingWidth: 30,
        title: Row(
          children: [
            // Avatar avec indicateur en ligne
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Text(
                      widget.chatRoom.driver.fullName[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF27AE60),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF6B46C1), width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.chatRoom.driver.fullName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.chatRoom.driver.phoneNumber != null)
                    Row(
                      children: [
                        Icon(
                          Icons.phone_rounded,
                          size: 12,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.chatRoom.driver.phoneNumber!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                messagesAsync.when(
                  data: (messages) {
                    if (messages.isEmpty) {
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
                              child: const Icon(
                                Icons.chat_outlined, 
                                size: 48, 
                                color: Color(0xFF6B46C1),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Aucun message',
                              style: TextStyle(
                                fontSize: 18, 
                                color: Color(0xFF6B46C1),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Envoyez le premier message !',
                              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      );
                    }

                    // Auto-scroll intelligent - seulement si nouveaux messages et utilisateur en bas
                    if (messages.length != _previousMessageCount) {
                      _previousMessageCount = messages.length;
                      _scrollToBottom();
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        // Comparer avec l'ID de l'utilisateur actuel (marchand)
                        final authState = ref.read(authStateProvider);
                        final currentUserId = authState.value?.id.toString() ?? '';
                        final isMine = message.senderId == currentUserId;
                        final showTime = index == 0 ||
                            message.timestamp.difference(messages[index - 1].timestamp).inMinutes > 5;

                        return _MessageBubble(
                          message: message,
                          isMine: isMine,
                          showTime: showTime,
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
                        const SizedBox(height: 16),
                        Text('Erreur: ${error.toString()}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => ref.refresh(chatMessagesProvider(widget.chatRoom.id)),
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  ),
                ),
                // Bouton scroll to bottom
                if (_showScrollToBottom)
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6B46C1).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: FloatingActionButton.small(
                        onPressed: () => _scrollToBottom(force: true),
                        backgroundColor: const Color(0xFF6B46C1),
                        child: const Icon(Icons.keyboard_double_arrow_down_rounded, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _isTyping 
                        ? const Color(0xFF6B46C1).withOpacity(0.3)
                        : Colors.transparent,
                  ),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Écrire un message...',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (value) {
                    final isTyping = value.trim().isNotEmpty;
                    if (_isTyping != isTyping) {
                      setState(() => _isTyping = isTyping);
                      final authState = ref.read(authStateProvider);
                      final userId = authState.value?.id.toString() ?? '';
                      if (userId.isNotEmpty) {
                        ref.read(chatRepositoryProvider).setTypingIndicator(
                              roomId: widget.chatRoom.id,
                              userId: userId,
                              isTyping: isTyping,
                            );
                      }
                    }
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Bouton envoyer
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isTyping 
                      ? [const Color(0xFF6B46C1), const Color(0xFF8B5CF6)]
                      : [Colors.grey[300]!, Colors.grey[400]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: _isTyping ? [
                  BoxShadow(
                    color: const Color(0xFF6B46C1).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ] : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: _isTyping && !_isSending ? _sendMessage : null,
                  child: Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    child: _isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMine;
  final bool showTime;

  const _MessageBubble({
    required this.message,
    required this.isMine,
    required this.showTime,
  });

  // Couleurs personnalisées modernes
  static const Color _myBubbleColor = Color(0xFF6B46C1);
  static const Color _otherBubbleColor = Colors.white;
  static const Color _myTextColor = Colors.white;
  static const Color _otherTextColor = Color(0xFF2C3E50);

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isMine ? _myBubbleColor : _otherBubbleColor;
    final textColor = isMine ? _myTextColor : _otherTextColor;
    final subtitleColor = isMine 
        ? Colors.white.withOpacity(0.7) 
        : Colors.grey[600]!;
    
    return Padding(
      padding: EdgeInsets.only(
        bottom: 4,
        left: isMine ? 48 : 0,
        right: isMine ? 0 : 48,
      ),
      child: Column(
        crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (showTime)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _formatTimestamp(message.timestamp),
                    style: TextStyle(
                      fontSize: 12, 
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          Row(
            mainAxisAlignment: isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMine) ...[
                _buildAvatar(context),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isMine ? 18 : 4),
                      bottomRight: Radius.circular(isMine ? 4 : 18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildMessageContent(textColor),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            DateFormat('HH:mm').format(message.timestamp),
                            style: TextStyle(
                              fontSize: 11,
                              color: subtitleColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (isMine) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.done_all_rounded,
                              size: 14,
                              color: message.isRead 
                                  ? const Color(0xFF4FC3F7)
                                  : Colors.white.withOpacity(0.7),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (isMine) const SizedBox(width: 4),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildAvatar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 16,
        backgroundColor: const Color(0xFF6B46C1),
        child: Text(
          message.senderName.isNotEmpty 
              ? message.senderName[0].toUpperCase() 
              : 'D',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
  
  Widget _buildMessageContent(Color textColor) {
    // Message de localisation
    if (message.messageType == 'location' && 
        message.latitude != null && 
        message.longitude != null) {
      return GestureDetector(
        onTap: () async {
          final url = Uri.parse(
            'https://www.google.com/maps/search/?api=1&query=${message.latitude},${message.longitude}'
          );
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          }
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: textColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: textColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Position GPS',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.open_in_new, size: 12, color: textColor.withOpacity(0.6)),
                  const SizedBox(width: 4),
                  Text(
                    'Ouvrir dans Maps',
                    style: TextStyle(
                      fontSize: 12,
                      color: textColor.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
    
    // Message image
    if (message.imageUrl != null && message.imageUrl!.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              key: ValueKey('img_${message.id}_${message.imageUrl}'),
              imageUrl: message.imageUrl!,
              cacheKey: 'chat_img_${message.id}',
              width: 200,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 200,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                width: 200,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image, color: Colors.grey),
                    SizedBox(height: 4),
                    Text('Image indisponible', 
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ),
          if (message.messageText.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              message.messageText,
              style: TextStyle(
                color: textColor,
                fontSize: 15,
                height: 1.3,
              ),
            ),
          ],
        ],
      );
    }
    
    // Message texte simple
    return SelectableText(
      message.messageText,
      style: TextStyle(
        color: textColor,
        fontSize: 15,
        height: 1.3,
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (messageDate == today) {
      return "Aujourd'hui";
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Hier';
    } else {
      return DateFormat('dd MMMM yyyy', 'fr_FR').format(timestamp);
    }
  }
}
