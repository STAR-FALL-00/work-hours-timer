import 'package:hive/hive.dart';

part 'inventory.g.dart';

@HiveType(typeId: 6)
class Inventory extends HiveObject {
  @HiveField(0)
  final List<String> ownedItemIds;

  @HiveField(1)
  final String? activeTheme;

  @HiveField(2)
  final Map<String, int> consumables;

  @HiveField(3)
  final List<String> activeDecorations;

  Inventory({
    List<String>? ownedItemIds,
    this.activeTheme,
    Map<String, int>? consumables,
    List<String>? activeDecorations,
  })  : ownedItemIds = ownedItemIds ?? [],
        consumables = consumables ?? {},
        activeDecorations = activeDecorations ?? [];

  bool hasItem(String itemId) => ownedItemIds.contains(itemId);

  int getConsumableCount(String itemId) => consumables[itemId] ?? 0;

  bool isDecorationActive(String itemId) => activeDecorations.contains(itemId);

  Inventory copyWith({
    List<String>? ownedItemIds,
    String? activeTheme,
    Map<String, int>? consumables,
    List<String>? activeDecorations,
  }) {
    return Inventory(
      ownedItemIds: ownedItemIds ?? this.ownedItemIds,
      activeTheme: activeTheme ?? this.activeTheme,
      consumables: consumables ?? this.consumables,
      activeDecorations: activeDecorations ?? this.activeDecorations,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ownedItemIds': ownedItemIds,
      'activeTheme': activeTheme,
      'consumables': consumables,
      'activeDecorations': activeDecorations,
    };
  }

  factory Inventory.fromJson(Map<String, dynamic> json) {
    return Inventory(
      ownedItemIds: (json['ownedItemIds'] as List?)?.cast<String>() ?? [],
      activeTheme: json['activeTheme'],
      consumables: (json['consumables'] as Map?)?.cast<String, int>() ?? {},
      activeDecorations:
          (json['activeDecorations'] as List?)?.cast<String>() ?? [],
    );
  }
}
