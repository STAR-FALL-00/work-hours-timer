// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ItemAdapter extends TypeAdapter<Item> {
  @override
  final int typeId = 10;

  @override
  Item read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Item(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      type: fields[3] as ItemType,
      effectType: fields[4] as ItemEffectType,
      price: fields[5] as int,
      icon: fields[6] as String,
      effectValue: fields[7] as double,
      duration: fields[8] as int?,
      maxStack: fields[9] as int?,
      rarity: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Item obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.effectType)
      ..writeByte(5)
      ..write(obj.price)
      ..writeByte(6)
      ..write(obj.icon)
      ..writeByte(7)
      ..write(obj.effectValue)
      ..writeByte(8)
      ..write(obj.duration)
      ..writeByte(9)
      ..write(obj.maxStack)
      ..writeByte(10)
      ..write(obj.rarity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ItemInstanceAdapter extends TypeAdapter<ItemInstance> {
  @override
  final int typeId = 11;

  @override
  ItemInstance read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ItemInstance(
      id: fields[0] as String,
      itemId: fields[1] as String,
      acquiredAt: fields[2] as DateTime,
      usedAt: fields[3] as DateTime?,
      expiresAt: fields[4] as DateTime?,
      isActive: fields[5] as bool,
      quantity: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ItemInstance obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.itemId)
      ..writeByte(2)
      ..write(obj.acquiredAt)
      ..writeByte(3)
      ..write(obj.usedAt)
      ..writeByte(4)
      ..write(obj.expiresAt)
      ..writeByte(5)
      ..write(obj.isActive)
      ..writeByte(6)
      ..write(obj.quantity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemInstanceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ItemTypeAdapter extends TypeAdapter<ItemType> {
  @override
  final int typeId = 12;

  @override
  ItemType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ItemType.consumable;
      case 1:
        return ItemType.permanent;
      case 2:
        return ItemType.decoration;
      case 3:
        return ItemType.theme;
      default:
        return ItemType.consumable;
    }
  }

  @override
  void write(BinaryWriter writer, ItemType obj) {
    switch (obj) {
      case ItemType.consumable:
        writer.writeByte(0);
        break;
      case ItemType.permanent:
        writer.writeByte(1);
        break;
      case ItemType.decoration:
        writer.writeByte(2);
        break;
      case ItemType.theme:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ItemEffectTypeAdapter extends TypeAdapter<ItemEffectType> {
  @override
  final int typeId = 13;

  @override
  ItemEffectType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ItemEffectType.speedBoost;
      case 1:
        return ItemEffectType.expBoost;
      case 2:
        return ItemEffectType.goldBoost;
      case 3:
        return ItemEffectType.skipCheckIn;
      case 4:
        return ItemEffectType.timeFreeze;
      case 5:
        return ItemEffectType.luckyBox;
      case 6:
        return ItemEffectType.autoWork;
      case 7:
        return ItemEffectType.doubleReward;
      default:
        return ItemEffectType.speedBoost;
    }
  }

  @override
  void write(BinaryWriter writer, ItemEffectType obj) {
    switch (obj) {
      case ItemEffectType.speedBoost:
        writer.writeByte(0);
        break;
      case ItemEffectType.expBoost:
        writer.writeByte(1);
        break;
      case ItemEffectType.goldBoost:
        writer.writeByte(2);
        break;
      case ItemEffectType.skipCheckIn:
        writer.writeByte(3);
        break;
      case ItemEffectType.timeFreeze:
        writer.writeByte(4);
        break;
      case ItemEffectType.luckyBox:
        writer.writeByte(5);
        break;
      case ItemEffectType.autoWork:
        writer.writeByte(6);
        break;
      case ItemEffectType.doubleReward:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemEffectTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
