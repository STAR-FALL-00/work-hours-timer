// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkSettingsAdapter extends TypeAdapter<WorkSettings> {
  @override
  final int typeId = 1;

  @override
  WorkSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkSettings(
      standardWorkHours: fields[0] as int,
      startTime: fields[1] as String?,
      endTime: fields[2] as String?,
      monthlySalary: fields[3] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, WorkSettings obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.standardWorkHours)
      ..writeByte(1)
      ..write(obj.startTime)
      ..writeByte(2)
      ..write(obj.endTime)
      ..writeByte(3)
      ..write(obj.monthlySalary);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
