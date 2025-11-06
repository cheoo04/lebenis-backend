class NotificationModel {
  final String id;
  final String userId;
  final String userName;
  final String notificationType;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final String? action;
  final String? actionUrl;
  final bool isRead;
  final DateTime? readAt;
  final bool sentViaFcm;
  final String? fcmMessageId;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.notificationType,
    required this.title,
    required this.body,
    this.data = const {},
    this.action,
    this.actionUrl,
    required this.isRead,
    this.readAt,
    required this.sentViaFcm,
    this.fcmMessageId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['user'] as String,
      userName: json['user_name'] as String? ?? '',
      notificationType: json['notification_type'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      data: json['data'] as Map<String, dynamic>? ?? {},
      action: json['action'] as String?,
      actionUrl: json['action_url'] as String?,
      isRead: json['is_read'] as bool,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      sentViaFcm: json['sent_via_fcm'] as bool? ?? false,
      fcmMessageId: json['fcm_message_id'] as String?,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': userId,
      'user_name': userName,
      'notification_type': notificationType,
      'title': title,
      'body': body,
      'data': data,
      'action': action,
      'action_url': actionUrl,
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
      'sent_via_fcm': sentViaFcm,
      'fcm_message_id': fcmMessageId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Retourne le libellé du type de notification en français
  String get typeLabel {
    switch (notificationType) {
      case 'new_delivery':
        return 'Nouvelle livraison';
      case 'delivery_accepted':
        return 'Livraison acceptée';
      case 'delivery_rejected':
        return 'Livraison refusée';
      case 'delivery_status_change':
        return 'Changement de statut';
      case 'payment_received':
        return 'Paiement reçu';
      case 'rating_received':
        return 'Notation reçue';
      case 'system':
        return 'Système';
      case 'promo':
        return 'Promotion';
      default:
        return notificationType;
    }
  }

  /// Retourne l'icône selon le type de notification
  String get typeIcon {
    switch (notificationType) {
      case 'new_delivery':
        return '📦';
      case 'delivery_accepted':
        return '✅';
      case 'delivery_rejected':
        return '❌';
      case 'delivery_status_change':
        return '🔄';
      case 'payment_received':
        return '💰';
      case 'rating_received':
        return '⭐';
      case 'system':
        return '🔔';
      case 'promo':
        return '🎁';
      default:
        return '📬';
    }
  }

  /// Vérifie si c'est aujourd'hui
  bool get isToday {
    final now = DateTime.now();
    return createdAt.year == now.year &&
        createdAt.month == now.month &&
        createdAt.day == now.day;
  }

  /// Vérifie si c'est hier
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return createdAt.year == yesterday.year &&
        createdAt.month == yesterday.month &&
        createdAt.day == yesterday.day;
  }

  /// Retourne le temps relatif (ex: "Il y a 5 min", "Aujourd'hui à 14:30")
  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (isToday) {
      return 'Aujourd\'hui à ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
    } else if (isYesterday) {
      return 'Hier à ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else {
      return '${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}';
    }
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? notificationType,
    String? title,
    String? body,
    Map<String, dynamic>? data,
    String? action,
    String? actionUrl,
    bool? isRead,
    DateTime? readAt,
    bool? sentViaFcm,
    String? fcmMessageId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      notificationType: notificationType ?? this.notificationType,
      title: title ?? this.title,
      body: body ?? this.body,
      data: data ?? this.data,
      action: action ?? this.action,
      actionUrl: actionUrl ?? this.actionUrl,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      sentViaFcm: sentViaFcm ?? this.sentViaFcm,
      fcmMessageId: fcmMessageId ?? this.fcmMessageId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
