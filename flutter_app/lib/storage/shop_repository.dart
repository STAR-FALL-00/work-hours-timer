import 'package:hive/hive.dart';
import '../core/models/inventory.dart';
import '../core/models/shop_item.dart';

class ShopRepository {
  static const String _boxName = 'inventory';
  late Box<Inventory> _box;

  Future<void> init() async {
    _box = await Hive.openBox<Inventory>(_boxName);
  }

  // 获取库存
  Inventory getInventory() {
    return _box.get('inventory', defaultValue: Inventory())!;
  }

  // 保存库存
  Future<void> saveInventory(Inventory inventory) async {
    await _box.put('inventory', inventory);
  }

  // 购买物品
  Future<void> purchaseItem(String itemId, {bool isConsumable = false}) async {
    final inventory = getInventory();

    if (isConsumable) {
      // 消耗品：增加数量
      final newConsumables = Map<String, int>.from(inventory.consumables);
      newConsumables[itemId] = (newConsumables[itemId] ?? 0) + 1;

      final updated = inventory.copyWith(consumables: newConsumables);
      await saveInventory(updated);
    } else {
      // 永久物品：添加到拥有列表
      if (inventory.hasItem(itemId)) {
        throw Exception('已拥有该物品');
      }

      final updated = inventory.copyWith(
        ownedItemIds: [...inventory.ownedItemIds, itemId],
      );
      await saveInventory(updated);
    }
  }

  // 使用消耗品
  Future<void> useConsumable(String itemId) async {
    final inventory = getInventory();
    final count = inventory.getConsumableCount(itemId);

    if (count <= 0) {
      throw Exception('物品不足');
    }

    final newConsumables = Map<String, int>.from(inventory.consumables);
    newConsumables[itemId] = count - 1;

    final updated = inventory.copyWith(consumables: newConsumables);
    await saveInventory(updated);
  }

  // 激活主题
  Future<void> activateTheme(String themeId) async {
    final inventory = getInventory();

    if (!inventory.hasItem(themeId)) {
      throw Exception('未拥有该主题');
    }

    final updated = inventory.copyWith(activeTheme: themeId);
    await saveInventory(updated);
  }

  // 切换装饰品
  Future<void> toggleDecoration(String decorationId) async {
    final inventory = getInventory();

    if (!inventory.hasItem(decorationId)) {
      throw Exception('未拥有该装饰品');
    }

    final newDecorations = List<String>.from(inventory.activeDecorations);

    if (inventory.isDecorationActive(decorationId)) {
      newDecorations.remove(decorationId);
    } else {
      newDecorations.add(decorationId);
    }

    final updated = inventory.copyWith(activeDecorations: newDecorations);
    await saveInventory(updated);
  }

  // 获取所有商品
  List<ShopItem> getAllItems() {
    return ShopItem.defaultItems;
  }

  // 按类型获取商品
  List<ShopItem> getItemsByType(String type) {
    return ShopItem.defaultItems.where((item) => item.type == type).toList();
  }

  // 获取单个商品
  ShopItem? getItem(String itemId) {
    try {
      return ShopItem.defaultItems.firstWhere((item) => item.id == itemId);
    } catch (e) {
      return null;
    }
  }

  // 检查是否拥有物品
  bool hasItem(String itemId) {
    return getInventory().hasItem(itemId);
  }

  // 获取消耗品数量
  int getConsumableCount(String itemId) {
    return getInventory().getConsumableCount(itemId);
  }
}
