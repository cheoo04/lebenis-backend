import 'package:freezed_annotation/freezed_annotation.dart';
part 'delivery_info.freezed.dart';
part 'delivery_info.g.dart';

@freezed
class DeliveryInfo with _$DeliveryInfo {
  const factory DeliveryInfo({
    required String id,
    @JsonKey(name: 'tracking_number') required String trackingNumber,
    @JsonKey(name: 'pickup_address') String? pickupAddress,
    @JsonKey(name: 'delivery_address') String? deliveryAddress,
  }) = _DeliveryInfo;

  factory DeliveryInfo.fromJson(Map<String, dynamic> json) =>
      _$DeliveryInfoFromJson(json);
}
