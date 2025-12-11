// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_participant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatParticipantImpl _$$ChatParticipantImplFromJson(
        Map<String, dynamic> json) =>
    _$ChatParticipantImpl(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      phoneNumber: json['phoneNumber'] as String,
      userType: json['userType'] as String,
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
    );

Map<String, dynamic> _$$ChatParticipantImplToJson(
        _$ChatParticipantImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullName': instance.fullName,
      'phoneNumber': instance.phoneNumber,
      'userType': instance.userType,
      'profilePhotoUrl': instance.profilePhotoUrl,
    };
