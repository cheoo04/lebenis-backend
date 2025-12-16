import 'package:freezed_annotation/freezed_annotation.dart';
part 'message_sender.freezed.dart';

@freezed
class MessageSender with _$MessageSender {
  const MessageSender._();
  
  const factory MessageSender({
    required String id,
    @JsonKey(name: 'full_name') required String fullName,
    @JsonKey(name: 'profile_photo_url') String? profilePhotoUrl,
  }) = _MessageSender;

  factory MessageSender.fromJson(Map<String, dynamic> json) {
    // Parse robuste pour gérer différents formats
    return MessageSender(
      id: json['id']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      profilePhotoUrl: json['profile_photo_url']?.toString(),
    );
  }
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'full_name': fullName,
    'profile_photo_url': profilePhotoUrl,
  };
}
