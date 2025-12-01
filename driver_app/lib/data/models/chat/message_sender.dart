import 'package:freezed_annotation/freezed_annotation.dart';
part 'message_sender.freezed.dart';
part 'message_sender.g.dart';

@freezed
class MessageSender with _$MessageSender {
  const factory MessageSender({
    required String id,
    @JsonKey(name: 'full_name') required String fullName,
    @JsonKey(name: 'profile_photo_url') String? profilePhotoUrl,
  }) = _MessageSender;

  factory MessageSender.fromJson(Map<String, dynamic> json) =>
      _$MessageSenderFromJson(json);
}
