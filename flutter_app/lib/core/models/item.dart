import 'package:hive/hive.dart';

part 'item.g.dart';

/// 道具类型
enum ItemType {
  consumable, // 消耗品
  permanent, // 永久道具
  decoration, // 装饰品
  theme, // 主题
}

/// 道具效果类型
enum ItemEffectType {
  speedBoost, // 加速（工作时间倍率）
  expBoost, // 经验加成
  goldBoost, // 金币加成
  skipCheckIn, // 免签卡
  timeFreeze, // 时间冻结
  luckyBox, // 幸运宝箱
  autoWork, // 自动工作
  doubleReward, // 双倍奖励
}

/// 道具模型
@HiveType(typeId: 10)
class Item {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final ItemType type;

  @HiveField(4)
  final ItemEffectType effectType;

  @HiveField(5)
  final int price;

  @HiveField(6)
  final String icon;

  @HiveField(7)
  final double effectValue; // 效果值（如 1.5 表示 1.5倍）

  @HiveField(8)
  final int? duration; // 持续时间（分钟），null 表示永久

  @HiveField(9)
  final int? maxStack; // 最大堆叠数量，null 表示无限

  @HiveField(10)
  final String? rarity; // 稀有度：common, rare, epic, legendary

  Item({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.effectType,
    required this.price,
    required this.icon,
    this.effectValue = 1.0,
    this.duration,
    this.maxStack,
    this.rarity = 'common',
  });

  /// 获取稀有度颜色
  String get rarityColor {
    switch (rarity) {
      case 'rare':
        return '#3B82F6'; // 蓝色
      case 'epic':
        return '#A855F7'; // 紫色
      case 'legendary':
        return '#F59E0B'; // 金色
      default:
        return '#6B7280'; // 灰色
    }
  }

  /// 获取稀有度名称
  String get rarityName {
    switch (rarity) {
      case 'rare':
        return '稀有';
      case 'epic':
        return '史诗';
      case 'legendary':
        return '传说';
      default:
        return '普通';
    }
  }

  /// 获取效果描述
  String get effectDescription {
    switch (effectType) {
      case ItemEffectType.speedBoost:
        return '工作时间 x${effectValue.toStringAsFixed(1)}';
      case ItemEffectType.expBoost:
        return '经验值 x${effectValue.toStringAsFixed(1)}';
      case ItemEffectType.goldBoost:
        return '金币 x${effectValue.toStringAsFixed(1)}';
      case ItemEffectType.skipCheckIn:
        return '跳过一次打卡';
      case ItemEffectType.timeFreeze:
        return '暂停不扣时间';
      case ItemEffectType.luckyBox:
        return '随机奖励';
      case ItemEffectType.autoWork:
        return '自动工作';
      case ItemEffectType.doubleReward:
        return '双倍奖励';
    }
  }

  /// 获取持续时间描述
  String get durationDescription {
    if (duration == null) {
      return '永久';
    } else if (duration! < 60) {
      return '$duration分钟';
    } else {
      final hours = duration! ~/ 60;
      return '$hours小时';
    }
  }

  /// 是否为消耗品
  bool get isConsumable => type == ItemType.consumable;

  /// 是否为永久道具
  bool get isPermanent => type == ItemType.permanent;

  /// 复制并修改
  Item copyWith({
    String? id,
    String? name,
    String? description,
    ItemType? type,
    ItemEffectType? effectType,
    int? price,
    String? icon,
    double? effectValue,
    int? duration,
    int? maxStack,
    String? rarity,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      effectType: effectType ?? this.effectType,
      price: price ?? this.price,
      icon: icon ?? this.icon,
      effectValue: effectValue ?? this.effectValue,
      duration: duration ?? this.duration,
      maxStack: maxStack ?? this.maxStack,
      rarity: rarity ?? this.rarity,
    );
  }
}

/// 道具实例（用户拥有的道具）
@HiveType(typeId: 11)
class ItemInstance {
  @HiveField(0)
  final String id; // 实例ID

  @HiveField(1)
  final String itemId; // 道具ID

  @HiveField(2)
  final DateTime acquiredAt; // 获得时间

  @HiveField(3)
  final DateTime? usedAt; // 使用时间

  @HiveField(4)
  final DateTime? expiresAt; // 过期时间

  @HiveField(5)
  final bool isActive; // 是否激活中

  @HiveField(6)
  final int quantity; // 数量（用于可堆叠道具）

  ItemInstance({
    required this.id,
    required this.itemId,
    required this.acquiredAt,
    this.usedAt,
    this.expiresAt,
    this.isActive = false,
    this.quantity = 1,
  });

  /// 是否已过期
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// 是否可用
  bool get isAvailable {
    return !isExpired && !isActive;
  }

  /// 剩余时间（分钟）
  int? get remainingMinutes {
    if (expiresAt == null) return null;
    final remaining = expiresAt!.difference(DateTime.now());
    return remaining.inMinutes;
  }

  /// 复制并修改
  ItemInstance copyWith({
    String? id,
    String? itemId,
    DateTime? acquiredAt,
    DateTime? usedAt,
    DateTime? expiresAt,
    bool? isActive,
    int? quantity,
  }) {
    return ItemInstance(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      acquiredAt: acquiredAt ?? this.acquiredAt,
      usedAt: usedAt ?? this.usedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isActive: isActive ?? this.isActive,
      quantity: quantity ?? this.quantity,
    );
  }
}

/// 预定义道具列表
class PredefinedItems {
  static final List<Item> items = [
    // 加速卡
    Item(
      id: 'item_speed_boost',
      name: '加速卡',
      description: '工作时间按 1.5 倍计算，让你的努力更有价值',
      type: ItemType.consumable,
      effectType: ItemEffectType.speedBoost,
      price: 2000,
      icon: '⚡',
      effectValue: 1.5,
      duration: 60, // 60分钟
      maxStack: 10,
      rarity: 'rare',
    ),

    // 双倍经验卡
    Item(
      id: 'item_exp_boost',
      name: '双倍经验卡',
      description: '获得的经验值翻倍，快速升级',
      type: ItemType.consumable,
      effectType: ItemEffectType.expBoost,
      price: 1500,
      icon: '🎯',
      effectValue: 2.0,
      duration: 120, // 120分钟
      maxStack: 10,
      rarity: 'rare',
    ),

    // 金币加成卡
    Item(
      id: 'item_gold_boost',
      name: '金币加成卡',
      description: '获得的金币增加 50%，财富积累更快',
      type: ItemType.consumable,
      effectType: ItemEffectType.goldBoost,
      price: 1500,
      icon: '💰',
      effectValue: 1.5,
      duration: 120, // 120分钟
      maxStack: 10,
      rarity: 'rare',
    ),

    // 免签卡
    Item(
      id: 'item_skip_checkin',
      name: '免签卡',
      description: '跳过一次打卡，保持连续记录',
      type: ItemType.consumable,
      effectType: ItemEffectType.skipCheckIn,
      price: 1000,
      icon: '🛡️',
      effectValue: 1.0,
      duration: null, // 一次性使用
      maxStack: 5,
      rarity: 'common',
    ),

    // 时间冻结卡
    Item(
      id: 'item_time_freeze',
      name: '时间冻结卡',
      description: '暂停时不扣除工作时间，完美的休息方案',
      type: ItemType.consumable,
      effectType: ItemEffectType.timeFreeze,
      price: 2500,
      icon: '⏰',
      effectValue: 1.0,
      duration: 30, // 30分钟
      maxStack: 5,
      rarity: 'epic',
    ),

    // 幸运宝箱
    Item(
      id: 'item_lucky_box',
      name: '幸运宝箱',
      description: '打开获得随机奖励：金币、经验或稀有道具',
      type: ItemType.consumable,
      effectType: ItemEffectType.luckyBox,
      price: 3000,
      icon: '🎁',
      effectValue: 1.0,
      duration: null, // 一次性使用
      maxStack: 3,
      rarity: 'epic',
    ),

    // 超级加速卡（传说）
    Item(
      id: 'item_super_speed',
      name: '超级加速卡',
      description: '工作时间按 2 倍计算，传说级效率提升',
      type: ItemType.consumable,
      effectType: ItemEffectType.speedBoost,
      price: 5000,
      icon: '⚡⚡',
      effectValue: 2.0,
      duration: 60, // 60分钟
      maxStack: 3,
      rarity: 'legendary',
    ),

    // 双倍奖励卡（传说）
    Item(
      id: 'item_double_reward',
      name: '双倍奖励卡',
      description: '金币和经验同时翻倍，终极奖励提升',
      type: ItemType.consumable,
      effectType: ItemEffectType.doubleReward,
      price: 8000,
      icon: '💎',
      effectValue: 2.0,
      duration: 60, // 60分钟
      maxStack: 2,
      rarity: 'legendary',
    ),
  ];

  /// 根据ID获取道具
  static Item? getItemById(String id) {
    try {
      return items.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 获取所有消耗品
  static List<Item> getConsumables() {
    return items.where((item) => item.type == ItemType.consumable).toList();
  }

  /// 获取所有永久道具
  static List<Item> getPermanentItems() {
    return items.where((item) => item.type == ItemType.permanent).toList();
  }

  /// 根据稀有度获取道具
  static List<Item> getItemsByRarity(String rarity) {
    return items.where((item) => item.rarity == rarity).toList();
  }
}
