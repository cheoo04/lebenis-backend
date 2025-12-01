// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DeliveryInfoImpl _$$DeliveryInfoImplFromJson(Map<String, dynamic> json) =>
    _$DeliveryInfoImpl(
      id: json['id'] as String,
      trackingNumber: json['trackingNumber'] as String,
      pickupAddress: json['pickupAddress'] as String?,
      deliveryAddress: json['deliveryAddress'] as String?,
    );

Map<String, dynamic> _$$DeliveryInfoImplToJson(_$DeliveryInfoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'trackingNumber': instance.trackingNumber,
      'pickupAddress': instance.pickupAddress,
      'deliveryAddress': instance.deliveryAddress,
    };
