import 'package:freezed_annotation/freezed_annotation.dart';
part 'chat_participant.freezed.dart';
part 'chat_participant.g.dart';

@freezed
class ChatParticipant with _$ChatParticipant {
  const factory ChatParticipant({
    required String id,
    required String fullName,
    required String phoneNumber,
    required String userType,
    String? profilePhotoUrl,
  }) = _ChatParticipant;
  factory ChatParticipant.fromJson(Map<String, dynamic> json) =>
      _$ChatParticipantFromJson(json);
}
