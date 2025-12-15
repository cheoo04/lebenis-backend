// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_participant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatParticipantImpl _$$ChatParticipantImplFromJson(
        Map<String, dynamic> json) =>
    _$ChatParticipantImpl(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      phoneNumber: json['phone'] as String,
      userType: json['user_type'] as String,
      profilePhotoUrl: json['profile_photo'] as String?,
    );

Map<String, dynamic> _$$ChatParticipantImplToJson(
        _$ChatParticipantImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'full_name': instance.fullName,
      'phone': instance.phoneNumber,
      'user_type': instance.userType,
      'profile_photo': instance.profilePhotoUrl,
    };
