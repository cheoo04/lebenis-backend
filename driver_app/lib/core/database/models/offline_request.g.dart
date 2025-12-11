// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_request.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OfflineRequestAdapter extends TypeAdapter<OfflineRequest> {
  @override
  final int typeId = 1;

  @override
  OfflineRequest read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OfflineRequest()
      ..method = fields[0] as String
      ..endpoint = fields[1] as String
      ..dataJson = fields[2] as String?
      ..queryParamsJson = fields[3] as String?
      ..createdAt = fields[4] as DateTime
      ..retryCount = fields[5] as int
      ..lastError = fields[6] as String?
      ..priority = fields[7] as int
      ..status = fields[8] as String
      ..entityType = fields[9] as String?
      ..entityId = fields[10] as String?;
  }

  @override
  void write(BinaryWriter writer, OfflineRequest obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.method)
      ..writeByte(1)
      ..write(obj.endpoint)
      ..writeByte(2)
      ..write(obj.dataJson)
      ..writeByte(3)
      ..write(obj.queryParamsJson)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.retryCount)
      ..writeByte(6)
      ..write(obj.lastError)
      ..writeByte(7)
      ..write(obj.priority)
      ..writeByte(8)
      ..write(obj.status)
      ..writeByte(9)
      ..write(obj.entityType)
      ..writeByte(10)
      ..write(obj.entityId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OfflineRequestAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
