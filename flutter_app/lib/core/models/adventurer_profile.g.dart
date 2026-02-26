// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adventurer_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AdventurerProfileAdapter extends TypeAdapter<AdventurerProfile> {
  @override
  final int typeId = 2;

  @override
  AdventurerProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AdventurerProfile(
      name: fields[0] as String,
      level: fields[1] as int,
      experience: fields[2] as int,
      totalWorkHours: fields[3] as int,
      totalGold: fields[4] as int,
      achievements: (fields[5] as List).cast<String>(),
      consecutiveWorkDays: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, AdventurerProfile obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.level)
      ..writeByte(2)
      ..write(obj.experience)
      ..writeByte(3)
      ..write(obj.totalWorkHours)
      ..writeByte(4)
      ..write(obj.totalGold)
      ..writeByte(5)
      ..write(obj.achievements)
      ..writeByte(6)
      ..write(obj.consecutiveWorkDays);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdventurerProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
