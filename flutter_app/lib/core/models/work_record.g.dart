// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkRecordAdapter extends TypeAdapter<WorkRecord> {
  @override
  final int typeId = 0;

  @override
  WorkRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkRecord(
      id: fields[0] as String,
      startTime: fields[1] as DateTime,
      endTime: fields[2] as DateTime,
      date: fields[3] as DateTime,
      durationInMilliseconds: fields[4] as int,
      notes: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, WorkRecord obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.startTime)
      ..writeByte(2)
      ..write(obj.endTime)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.durationInMilliseconds)
      ..writeByte(5)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
