// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DeliveryInfoImpl _$$DeliveryInfoImplFromJson(Map<String, dynamic> json) =>
    _$DeliveryInfoImpl(
      id: json['id'] as String,
      trackingNumber: json['tracking_number'] as String,
      pickupAddress: json['pickup_address'] as String?,
      deliveryAddress: json['delivery_address'] as String?,
    );

Map<String, dynamic> _$$DeliveryInfoImplToJson(_$DeliveryInfoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tracking_number': instance.trackingNumber,
      'pickup_address': instance.pickupAddress,
      'delivery_address': instance.deliveryAddress,
    };
