import 'dart:math';
import '../models/item.dart';
import '../models/adventurer_profile.dart';

/// 道具服务
///
/// 功能：
/// - 道具购买
/// - 道具使用
/// - 道具效果计算
/// - 道具过期管理
class ItemService {
  static final ItemService _instance = ItemService._internal();
  factory ItemService() => _instance;
  ItemService._internal();

  // 当前激活的道具效果
  final Map<ItemEffectType, ItemInstance> _activeEffects = {};

  /// 购买道具
  Future<ItemInstance?> purchaseItem({
    required String itemId,
    required int currentGold,
  }) async {
    final item = PredefinedItems.getItemById(itemId);
    if (item == null) {
      throw Exception('道具不存在');
    }

    if (currentGold < item.price) {
      throw Exception('金币不足');
    }

    // 创建道具实例
    final instance = ItemInstance(
      id: '${itemId}_${DateTime.now().millisecondsSinceEpoch}',
      itemId: itemId,
      acquiredAt: DateTime.now(),
    );

    return instance;
  }

  /// 使用道具
  Future<ItemUseResult> useItem({
    required ItemInstance instance,
    required Item item,
    required AdventurerProfile profile,
  }) async {
    if (instance.isExpired) {
      throw Exception('道具已过期');
    }

    if (instance.isActive) {
      throw Exception('道具已在使用中');
    }

    // 检查是否有相同类型的道具正在使用
    if (_activeEffects.containsKey(item.effectType)) {
      throw Exception('已有相同类型的道具在使用中');
    }

    // 根据道具类型执行不同的效果
    switch (item.effectType) {
      case ItemEffectType.luckyBox:
        return await _openLuckyBox(profile);

      case ItemEffectType.skipCheckIn:
        return ItemUseResult(
          success: true,
          message: '✓ 免签卡已使用',
          goldEarned: 0,
          expEarned: 0,
        );

      default:
        // 激活道具效果
        final activatedInstance = instance.copyWith(
          isActive: true,
          usedAt: DateTime.now(),
          expiresAt: item.duration != null
              ? DateTime.now().add(Duration(minutes: item.duration!))
              : null,
        );

        _activeEffects[item.effectType] = activatedInstance;

        return ItemUseResult(
          success: true,
          message: '✓ ${item.name}已激活',
          goldEarned: 0,
          expEarned: 0,
          duration: item.duration,
        );
    }
  }

  /// 打开幸运宝箱
  Future<ItemUseResult> _openLuckyBox(AdventurerProfile profile) async {
    final random = Random();
    final luck = random.nextInt(100);

    int goldEarned = 0;
    int expEarned = 0;
    String message = '';

    if (luck < 10) {
      // 10% 概率：大奖
      goldEarned = 5000 + random.nextInt(5000);
      expEarned = 1000 + random.nextInt(1000);
      message = '🎉 恭喜！获得大奖！';
    } else if (luck < 30) {
      // 20% 概率：中奖
      goldEarned = 2000 + random.nextInt(3000);
      expEarned = 500 + random.nextInt(500);
      message = '✨ 不错！获得中奖！';
    } else if (luck < 60) {
      // 30% 概率：小奖
      goldEarned = 500 + random.nextInt(1500);
      expEarned = 200 + random.nextInt(300);
      message = '👍 获得小奖！';
    } else {
      // 40% 概率：安慰奖
      goldEarned = 100 + random.nextInt(400);
      expEarned = 50 + random.nextInt(150);
      message = '💫 获得安慰奖！';
    }

    return ItemUseResult(
      success: true,
      message: message,
      goldEarned: goldEarned,
      expEarned: expEarned,
    );
  }

  /// 计算工作奖励（应用道具效果）
  WorkReward calculateReward({
    required int baseGold,
    required int baseExp,
    required Duration workDuration,
  }) {
    double goldMultiplier = 1.0;
    double expMultiplier = 1.0;
    double timeMultiplier = 1.0;

    // 检查激活的道具效果
    _activeEffects.forEach((effectType, instance) {
      if (instance.isExpired) {
        _activeEffects.remove(effectType);
        return;
      }

      final item = PredefinedItems.getItemById(instance.itemId);
      if (item == null) return;

      switch (effectType) {
        case ItemEffectType.speedBoost:
          timeMultiplier *= item.effectValue;
          break;
        case ItemEffectType.expBoost:
          expMultiplier *= item.effectValue;
          break;
        case ItemEffectType.goldBoost:
          goldMultiplier *= item.effectValue;
          break;
        case ItemEffectType.doubleReward:
          goldMultiplier *= item.effectValue;
          expMultiplier *= item.effectValue;
          break;
        default:
          break;
      }
    });

    // 计算最终奖励
    final finalGold = (baseGold * goldMultiplier).round();
    final finalExp = (baseExp * expMultiplier).round();
    final effectiveDuration = Duration(
      seconds: (workDuration.inSeconds * timeMultiplier).round(),
    );

    return WorkReward(
      gold: finalGold,
      exp: finalExp,
      duration: effectiveDuration,
      goldMultiplier: goldMultiplier,
      expMultiplier: expMultiplier,
      timeMultiplier: timeMultiplier,
    );
  }

  /// 获取激活的道具效果
  Map<ItemEffectType, ItemInstance> getActiveEffects() {
    // 清理过期的效果
    _activeEffects.removeWhere((key, value) => value.isExpired);
    return Map.from(_activeEffects);
  }

  /// 停用道具
  void deactivateItem(ItemEffectType effectType) {
    _activeEffects.remove(effectType);
  }

  /// 清理所有过期道具
  void cleanupExpiredItems() {
    _activeEffects.removeWhere((key, value) => value.isExpired);
  }

  /// 检查是否有激活的道具
  bool hasActiveItem(ItemEffectType effectType) {
    final instance = _activeEffects[effectType];
    if (instance == null) return false;
    if (instance.isExpired) {
      _activeEffects.remove(effectType);
      return false;
    }
    return true;
  }

  /// 获取道具剩余时间
  Duration? getItemRemainingTime(ItemEffectType effectType) {
    final instance = _activeEffects[effectType];
    if (instance == null || instance.expiresAt == null) return null;

    final remaining = instance.expiresAt!.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }
}

/// 道具使用结果
class ItemUseResult {
  final bool success;
  final String message;
  final int goldEarned;
  final int expEarned;
  final int? duration; // 持续时间（分钟）

  ItemUseResult({
    required this.success,
    required this.message,
    this.goldEarned = 0,
    this.expEarned = 0,
    this.duration,
  });
}

/// 工作奖励
class WorkReward {
  final int gold;
  final int exp;
  final Duration duration;
  final double goldMultiplier;
  final double expMultiplier;
  final double timeMultiplier;

  WorkReward({
    required this.gold,
    required this.exp,
    required this.duration,
    this.goldMultiplier = 1.0,
    this.expMultiplier = 1.0,
    this.timeMultiplier = 1.0,
  });

  /// 是否有加成
  bool get hasBonus {
    return goldMultiplier > 1.0 || expMultiplier > 1.0 || timeMultiplier > 1.0;
  }

  /// 获取加成描述
  String get bonusDescription {
    final List<String> bonuses = [];

    if (timeMultiplier > 1.0) {
      bonuses.add('时间 x${timeMultiplier.toStringAsFixed(1)}');
    }
    if (goldMultiplier > 1.0) {
      bonuses.add('金币 x${goldMultiplier.toStringAsFixed(1)}');
    }
    if (expMultiplier > 1.0) {
      bonuses.add('经验 x${expMultiplier.toStringAsFixed(1)}');
    }

    return bonuses.join(' + ');
  }
}
