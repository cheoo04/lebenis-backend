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
    @JsonKey(name: 'room_type') required RoomType roomType,
    @JsonKey(name: 'other_user_info') required ChatParticipant otherParticipant,
    @JsonKey(name: 'delivery_info') DeliveryInfo? deliveryInfo,
    @JsonKey(name: 'last_message_text') String? lastMessageText,
    @JsonKey(name: 'last_message_at') DateTime? lastMessageAt,
    @JsonKey(name: 'unread_count', defaultValue: 0) required int unreadCount,
    @JsonKey(name: 'is_archived', defaultValue: false) required bool isArchived,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'firebase_path') String? firebasePath,
  }) = _ChatRoomModel;

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) =>
      _$ChatRoomModelFromJson(json);
}

