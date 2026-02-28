// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InventoryAdapter extends TypeAdapter<Inventory> {
  @override
  final int typeId = 6;

  @override
  Inventory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Inventory(
      ownedItemIds: (fields[0] as List?)?.cast<String>(),
      activeTheme: fields[1] as String?,
      consumables: (fields[2] as Map?)?.cast<String, int>(),
      activeDecorations: (fields[3] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Inventory obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.ownedItemIds)
      ..writeByte(1)
      ..write(obj.activeTheme)
      ..writeByte(2)
      ..write(obj.consumables)
      ..writeByte(3)
      ..write(obj.activeDecorations);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InventoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
