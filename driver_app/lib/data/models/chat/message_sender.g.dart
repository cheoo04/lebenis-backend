// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_sender.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MessageSenderImpl _$$MessageSenderImplFromJson(Map<String, dynamic> json) =>
    _$MessageSenderImpl(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      profilePhotoUrl: json['profile_photo_url'] as String?,
    );

Map<String, dynamic> _$$MessageSenderImplToJson(_$MessageSenderImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'full_name': instance.fullName,
      'profile_photo_url': instance.profilePhotoUrl,
    };
