// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_profile_cache.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DriverProfileCacheAdapter extends TypeAdapter<DriverProfileCache> {
  @override
  final int typeId = 2;

  @override
  DriverProfileCache read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DriverProfileCache()
      ..serverId = fields[0] as String
      ..userId = fields[1] as String
      ..firstName = fields[2] as String
      ..lastName = fields[3] as String
      ..email = fields[4] as String
      ..phone = fields[5] as String
      ..profilePhoto = fields[6] as String?
      ..vehicleType = fields[7] as String
      ..licensePlate = fields[8] as String?
      ..isVerified = fields[9] as bool
      ..isAvailable = fields[10] as bool
      ..rating = fields[11] as double
      ..totalDeliveries = fields[12] as int
      ..currentCommune = fields[13] as String?
      ..currentQuartier = fields[14] as String?
      ..currentLatitude = fields[15] as double?
      ..currentLongitude = fields[16] as double?
      ..todayEarnings = fields[17] as double
      ..weekEarnings = fields[18] as double
      ..monthEarnings = fields[19] as double
      ..totalEarnings = fields[20] as double
      ..cachedAt = fields[21] as DateTime
      ..lastOnlineAt = fields[22] as DateTime?;
  }

  @override
  void write(BinaryWriter writer, DriverProfileCache obj) {
    writer
      ..writeByte(23)
      ..writeByte(0)
      ..write(obj.serverId)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.firstName)
      ..writeByte(3)
      ..write(obj.lastName)
      ..writeByte(4)
      ..write(obj.email)
      ..writeByte(5)
      ..write(obj.phone)
      ..writeByte(6)
      ..write(obj.profilePhoto)
      ..writeByte(7)
      ..write(obj.vehicleType)
      ..writeByte(8)
      ..write(obj.licensePlate)
      ..writeByte(9)
      ..write(obj.isVerified)
      ..writeByte(10)
      ..write(obj.isAvailable)
      ..writeByte(11)
      ..write(obj.rating)
      ..writeByte(12)
      ..write(obj.totalDeliveries)
      ..writeByte(13)
      ..write(obj.currentCommune)
      ..writeByte(14)
      ..write(obj.currentQuartier)
      ..writeByte(15)
      ..write(obj.currentLatitude)
      ..writeByte(16)
      ..write(obj.currentLongitude)
      ..writeByte(17)
      ..write(obj.todayEarnings)
      ..writeByte(18)
      ..write(obj.weekEarnings)
      ..writeByte(19)
      ..write(obj.monthEarnings)
      ..writeByte(20)
      ..write(obj.totalEarnings)
      ..writeByte(21)
      ..write(obj.cachedAt)
      ..writeByte(22)
      ..write(obj.lastOnlineAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverProfileCacheAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
