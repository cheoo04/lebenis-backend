import 'package:freezed_annotation/freezed_annotation.dart';
part 'chat_participant.freezed.dart';
part 'chat_participant.g.dart';

@freezed
class ChatParticipant with _$ChatParticipant {
  const factory ChatParticipant({
    required String id,
    @JsonKey(name: 'full_name') required String fullName,
    @JsonKey(name: 'phone') required String phoneNumber,
    @JsonKey(name: 'user_type') required String userType,
    @JsonKey(name: 'profile_photo') String? profilePhotoUrl,
  }) = _ChatParticipant;
  factory ChatParticipant.fromJson(Map<String, dynamic> json) =>
      _$ChatParticipantFromJson(json);
}
