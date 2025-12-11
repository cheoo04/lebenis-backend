// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_cache.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DeliveryCacheAdapter extends TypeAdapter<DeliveryCache> {
  @override
  final int typeId = 0;

  @override
  DeliveryCache read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DeliveryCache()
      ..serverId = fields[0] as String
      ..trackingNumber = fields[1] as String
      ..status = fields[2] as String
      ..pickupAddress = fields[3] as String
      ..pickupCommune = fields[4] as String
      ..pickupQuartier = fields[5] as String
      ..pickupPrecision = fields[6] as String
      ..pickupLatitude = fields[7] as double?
      ..pickupLongitude = fields[8] as double?
      ..deliveryAddress = fields[9] as String
      ..deliveryCommune = fields[10] as String
      ..deliveryQuartier = fields[11] as String
      ..deliveryPrecision = fields[12] as String
      ..deliveryLatitude = fields[13] as double?
      ..deliveryLongitude = fields[14] as double?
      ..recipientName = fields[15] as String
      ..recipientPhone = fields[16] as String
      ..packageDescription = fields[17] as String
      ..weight = fields[18] as double
      ..price = fields[19] as double
      ..distanceKm = fields[20] as double
      ..notes = fields[21] as String?
      ..paymentMethod = fields[22] as String?
      ..codAmount = fields[23] as double?
      ..merchantJson = fields[24] as String?
      ..pickupPhoto = fields[25] as String?
      ..deliveryPhoto = fields[26] as String?
      ..recipientSignature = fields[27] as String?
      ..cancellationReason = fields[28] as String?
      ..createdAt = fields[29] as DateTime
      ..assignedAt = fields[30] as DateTime?
      ..pickupTime = fields[31] as DateTime?
      ..deliveryTime = fields[32] as DateTime?
      ..cancelledAt = fields[33] as DateTime?
      ..cachedAt = fields[34] as DateTime
      ..needsSync = fields[35] as bool;
  }

  @override
  void write(BinaryWriter writer, DeliveryCache obj) {
    writer
      ..writeByte(36)
      ..writeByte(0)
      ..write(obj.serverId)
      ..writeByte(1)
      ..write(obj.trackingNumber)
      ..writeByte(2)
      ..write(obj.status)
      ..writeByte(3)
      ..write(obj.pickupAddress)
      ..writeByte(4)
      ..write(obj.pickupCommune)
      ..writeByte(5)
      ..write(obj.pickupQuartier)
      ..writeByte(6)
      ..write(obj.pickupPrecision)
      ..writeByte(7)
      ..write(obj.pickupLatitude)
      ..writeByte(8)
      ..write(obj.pickupLongitude)
      ..writeByte(9)
      ..write(obj.deliveryAddress)
      ..writeByte(10)
      ..write(obj.deliveryCommune)
      ..writeByte(11)
      ..write(obj.deliveryQuartier)
      ..writeByte(12)
      ..write(obj.deliveryPrecision)
      ..writeByte(13)
      ..write(obj.deliveryLatitude)
      ..writeByte(14)
      ..write(obj.deliveryLongitude)
      ..writeByte(15)
      ..write(obj.recipientName)
      ..writeByte(16)
      ..write(obj.recipientPhone)
      ..writeByte(17)
      ..write(obj.packageDescription)
      ..writeByte(18)
      ..write(obj.weight)
      ..writeByte(19)
      ..write(obj.price)
      ..writeByte(20)
      ..write(obj.distanceKm)
      ..writeByte(21)
      ..write(obj.notes)
      ..writeByte(22)
      ..write(obj.paymentMethod)
      ..writeByte(23)
      ..write(obj.codAmount)
      ..writeByte(24)
      ..write(obj.merchantJson)
      ..writeByte(25)
      ..write(obj.pickupPhoto)
      ..writeByte(26)
      ..write(obj.deliveryPhoto)
      ..writeByte(27)
      ..write(obj.recipientSignature)
      ..writeByte(28)
      ..write(obj.cancellationReason)
      ..writeByte(29)
      ..write(obj.createdAt)
      ..writeByte(30)
      ..write(obj.assignedAt)
      ..writeByte(31)
      ..write(obj.pickupTime)
      ..writeByte(32)
      ..write(obj.deliveryTime)
      ..writeByte(33)
      ..write(obj.cancelledAt)
      ..writeByte(34)
      ..write(obj.cachedAt)
      ..writeByte(35)
      ..write(obj.needsSync);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeliveryCacheAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
