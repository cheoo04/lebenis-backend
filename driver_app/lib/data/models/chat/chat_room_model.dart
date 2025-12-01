import 'package:freezed_annotation/freezed_annotation.dart';
import 'chat_participant.dart';
import 'delivery_info.dart';
part 'chat_room_model.freezed.dart';
part 'chat_room_model.g.dart';

enum RoomType {
  @JsonValue('delivery')
  delivery,
  @JsonValue('support')
  support,
}

@freezed
class ChatRoomModel with _$ChatRoomModel {
  const factory ChatRoomModel({
    required String id,
    required RoomType roomType,
    required ChatParticipant otherParticipant,
    DeliveryInfo? deliveryInfo,
    String? lastMessageText,
    DateTime? lastMessageAt,
    required int unreadCount,
    required bool isArchived,
    required DateTime createdAt,
    String? firebasePath,
  }) = _ChatRoomModel;

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) =>
      _$ChatRoomModelFromJson(json);
}

