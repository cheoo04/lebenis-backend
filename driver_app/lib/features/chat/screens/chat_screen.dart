import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/chat/chat_room_model.dart';
import '../../../data/models/chat/message_model.dart';
import '../providers/chat_provider.dart';
import '../../../core/providers/cloudinary_provider.dart';
import '../../../core/constants/app_colors.dart';

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
  bool _userHasScrolledUp = false; // Track si l'utilisateur a scrollé vers le haut
  int _previousMessageCount = 0;

  @override
  void initState() {
    super.initState();
    
    // Écouter le scroll pour détecter si l'utilisateur scroll vers le haut
    _scrollController.addListener(_onScroll);
    
    // Marquer comme lu au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(chatRoomsProvider.notifier).markAsRead(widget.chatRoom.id);
    });
  }
  
  void _onScroll() {
    if (!_scrollController.hasClients) return;
    
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    // L'utilisateur est considéré "en bas" s'il est à moins de 100px du bas
    final isNearBottom = (maxScroll - currentScroll) < 100;
    
    if (_userHasScrolledUp != !isNearBottom) {
      setState(() {
        _userHasScrolledUp = !isNearBottom;
      });
    }
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
    
    final photoUrl = widget.chatRoom.otherParticipant.profilePhotoUrl;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
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
                    backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                        ? CachedNetworkImageProvider(
                            photoUrl,
                            cacheKey: 'chat_avatar_${widget.chatRoom.otherParticipant.id}',
                          )
                        : null,
                    child: photoUrl == null || photoUrl.isEmpty
                        ? Text(
                            widget.chatRoom.otherParticipant.fullName.isNotEmpty
                                ? widget.chatRoom.otherParticipant.fullName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          )
                        : null,
                  ),
                ),
                // Indicateur en ligne
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF27AE60),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2),
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
                    widget.chatRoom.otherParticipant.fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.chatRoom.deliveryInfo != null)
                    Row(
                      children: [
                        Icon(
                          Icons.local_shipping_rounded,
                          size: 12,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.chatRoom.deliveryInfo!.trackingNumber,
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
        actions: [
          // Indicateur de typing animé
          typingAsync.when(
            data: (indicators) {
              final isOtherUserTyping = indicators.values.any((v) => v);
              return isOtherUserTyping
                  ? Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('✍️', style: TextStyle(fontSize: 14)),
                          SizedBox(width: 4),
                          Text(
                            'écrit...',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ],
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
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (error, stack) => _buildErrorWidget(error, stack),
            ),
          ),

          // Zone de saisie
          _buildInputArea(chatState),
        ],
      ),
    );
  }
  
  /// Widget d'erreur avec option de retry
  Widget _buildErrorWidget(Object error, StackTrace? stack) {
    final theme = Theme.of(context);
    final isNetworkError = error.toString().contains('SocketException') ||
        error.toString().contains('Connection') ||
        error.toString().contains('network');
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isNetworkError ? Icons.wifi_off : Icons.error_outline,
              size: 48,
              color: theme.colorScheme.error.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              isNetworkError 
                  ? 'Connexion perdue'
                  : 'Impossible de charger les messages',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isNetworkError
                  ? 'Vérifiez votre connexion internet'
                  : error.toString(),
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                // Forcer le refresh du stream
                ref.invalidate(messagesStreamProvider(widget.chatRoom.id));
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
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

    // Scroll intelligent: seulement si nouveau message ET l'utilisateur n'a pas scrollé vers le haut
    final hasNewMessages = messages.length > _previousMessageCount;
    _previousMessageCount = messages.length;
    
    if (hasNewMessages && !_userHasScrolledUp) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_scrollController.hasClients) return;
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }

    return Stack(
      children: [
        ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: messages.length,
          // Optimisation: cache des items
          cacheExtent: 500,
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
        ),
        
        // Bouton "Scroll to bottom" quand l'utilisateur a scrollé vers le haut
        if (_userHasScrolledUp)
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton.small(
                onPressed: _scrollToBottom,
                backgroundColor: AppColors.primary,
                child: const Icon(
                  Icons.keyboard_double_arrow_down_rounded,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
  
  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Widget _buildTimestamp(DateTime dateTime) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          DateFormat('dd MMM yyyy, HH:mm', 'fr').format(dateTime),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea(ChatMessagesState state) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Boutons attachments dans un container
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.image_rounded, size: 22),
                    color: AppColors.primary,
                    onPressed: state.isSending ? null : _pickImage,
                    tooltip: 'Envoyer une image',
                  ),
                  IconButton(
                    icon: const Icon(Icons.location_on_rounded, size: 22),
                    color: AppColors.primary,
                    onPressed: state.isSending ? null : _sendLocation,
                    tooltip: 'Envoyer ma position',
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 8),

            // Champ de texte
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _messageController.text.isNotEmpty 
                        ? AppColors.primary.withOpacity(0.3)
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
                  onChanged: _onTextChanged,
                ),
              ),
            ),
            
            const SizedBox(width: 8),

            // Bouton envoyer
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: state.isSending ? null : _sendMessage,
                  child: Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    child: state.isSending
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

    final messenger = ScaffoldMessenger.of(context);
    final notifier = ref.read(chatMessagesProvider(widget.chatRoom.id).notifier);
    
    bool success = await notifier.sendTextMessage(text);

    // Retry automatique une fois en cas d'échec
    if (!success && mounted) {
      await Future.delayed(const Duration(milliseconds: 500));
      success = await notifier.sendTextMessage(text);
    }

    if (!success && mounted) {
      final error = ref.read(chatMessagesProvider(widget.chatRoom.id)).error;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Erreur: ${error ?? "Impossible d\'envoyer"}'),
          action: SnackBarAction(
            label: 'Réessayer',
            onPressed: () async {
              await notifier.sendTextMessage(text);
            },
          ),
          duration: const Duration(seconds: 5),
        ),
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

    final messenger = ScaffoldMessenger.of(context);
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
        final error = ref.read(chatMessagesProvider(widget.chatRoom.id)).error;
        messenger.showSnackBar(
          SnackBar(content: Text('Erreur image: ${error ?? "Inconnue"}')),
        );
      }
    } catch (e) {
      isUploading = false;
      
      // Fermer le dialog
      if (mounted) {
        Navigator.of(context).pop();

        messenger.showSnackBar(
          SnackBar(content: Text('Erreur upload: $e')),
        );
      }
    }
  }

  Future<void> _sendLocation() async {
    try {
      // Vérifier et demander les permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Permission de localisation refusée')),
            );
          }
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Activez la localisation dans les paramètres'),
              action: SnackBarAction(
                label: 'Ouvrir',
                onPressed: Geolocator.openAppSettings,
              ),
            ),
          );
        }
        return;
      }

      // Vérifier si le service de localisation est activé
      if (!await Geolocator.isLocationServiceEnabled()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Activez le GPS'),
              action: SnackBarAction(
                label: 'Ouvrir',
                onPressed: Geolocator.openLocationSettings,
              ),
            ),
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      
      final success = await ref
          .read(chatMessagesProvider(widget.chatRoom.id).notifier)
          .sendLocationMessage(
            latitude: position.latitude,
            longitude: position.longitude,
            text: 'Ma position',
          );

      if (!success && mounted) {
        final error = ref.read(chatMessagesProvider(widget.chatRoom.id)).error;
        final messenger = ScaffoldMessenger.of(context);
        messenger.showSnackBar(
          SnackBar(content: Text('Erreur position: ${error ?? "Inconnue"}')),
        );
      }
    } catch (e) {
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.showSnackBar(
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

  // Couleurs personnalisées modernes
  static const Color _myBubbleColor = AppColors.primary;
  static const Color _otherBubbleColor = Colors.white;
  static const Color _myTextColor = Colors.white;
  static const Color _otherTextColor = Color(0xFF2C3E50);

  @override
  Widget build(BuildContext context) {
    final isMine = message.isMine;

    // Couleurs selon l'expéditeur
    final bubbleColor = isMine ? _myBubbleColor : _otherBubbleColor;
    final textColor = isMine ? _myTextColor : _otherTextColor;
    final subtitleColor = isMine 
        ? Colors.white.withOpacity(0.7) 
        : Colors.grey[600]!;

    return Padding(
      padding: EdgeInsets.only(
        top: showAvatar ? 8 : 2,
        bottom: 2,
        left: isMine ? 48 : 0,
        right: isMine ? 0 : 48,
      ),
      child: Row(
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMine && showAvatar) _buildAvatar(context),
          if (!isMine && !showAvatar) const SizedBox(width: 40),
          
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: message.messageType == MessageType.image ? 4 : 14,
                vertical: message.messageType == MessageType.image ? 4 : 10,
              ),
              decoration: BoxDecoration(
                color: bubbleColor,
                gradient: isMine 
                    ? const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isMine ? 20 : 6),
                  bottomRight: Radius.circular(isMine ? 6 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isMine 
                        ? AppColors.primary.withOpacity(0.2)
                        : Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMessageContent(textColor),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat('HH:mm').format(message.createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: subtitleColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (isMine) ...[
                        const SizedBox(width: 4),
                        _buildStatusIcon(),
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
    );
  }
  
  Widget _buildStatusIcon() {
    IconData icon;
    Color color;
    
    switch (message.status) {
      case MessageStatus.sending:
        icon = Icons.access_time_rounded;
        color = Colors.white.withOpacity(0.5);
        break;
      case MessageStatus.sent:
        icon = Icons.done_rounded;
        color = Colors.white.withOpacity(0.7);
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all_rounded;
        color = Colors.white.withOpacity(0.7);
        break;
      case MessageStatus.read:
        icon = Icons.done_all_rounded;
        color = const Color(0xFF4FC3F7); // Light blue
        break;
      case MessageStatus.failed:
        icon = Icons.error_outline_rounded;
        color = const Color(0xFFFF6B6B);
        break;
    }
    
    // Utiliser isRead du modèle si disponible
    if (message.isRead) {
      icon = Icons.done_all_rounded;
      color = const Color(0xFF4FC3F7);
    }
    
    return Icon(icon, size: 14, color: color);
  }

  Widget _buildAvatar(BuildContext context) {
    final photoUrl = message.sender.profilePhotoUrl;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
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
          backgroundColor: AppColors.primary,
          backgroundImage: photoUrl != null && photoUrl.isNotEmpty
              ? CachedNetworkImageProvider(
                  photoUrl,
                  cacheKey: 'msg_avatar_${message.sender.id}',
                )
              : null,
          child: photoUrl == null || photoUrl.isEmpty
              ? Text(
                  message.sender.fullName.isNotEmpty 
                      ? message.sender.fullName[0].toUpperCase() 
                      : '?',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildMessageContent(Color textColor) {
    switch (message.messageType) {
      case MessageType.text:
        return SelectableText(
          message.text ?? '',
          style: TextStyle(
            color: textColor,
            fontSize: 15,
            height: 1.4,
            letterSpacing: 0.1,
          ),
        );

      case MessageType.image:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  key: ValueKey('img_${message.id}_${message.imageUrl}'),
                  imageUrl: message.imageUrl!,
                  cacheKey: 'chat_img_${message.id}',
                  width: 220,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 220,
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 220,
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
            if (message.text != null && message.text!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                message.text!,
                style: TextStyle(color: textColor, height: 1.3),
              ),
            ],
          ],
        );

      case MessageType.location:
        return GestureDetector(
          onTap: () async {
            if (message.latitude != null && message.longitude != null) {
              final url = Uri.parse(
                'https://www.google.com/maps/search/?api=1&query=${message.latitude},${message.longitude}'
              );
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.all(12),
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
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Position partagée',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.open_in_new, size: 14, color: textColor.withOpacity(0.6)),
                    const SizedBox(width: 4),
                    Text(
                      'Ouvrir dans Google Maps',
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

      case MessageType.system:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            message.text ?? '',
            style: const TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
        );
    }
  }
}
