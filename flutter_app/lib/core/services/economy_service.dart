import '../models/adventurer_profile.dart';

/// 经济系统服务
/// 负责金币计算、连击奖励等经济相关逻辑
class EconomyService {
  // 基础汇率：1分钟 = 1金币
  static const int goldPerMinute = 1;

  // 连击奖励：连续工作60分钟（无暂停）额外奖励50金币
  static const int comboThreshold = 60; // 分钟
  static const int comboBonus = 50; // 金币

  // 经验值计算：1小时 = 100经验
  static const int expPerHour = 100;

  /// 计算工作时长获得的金币
  /// [duration] 工作时长
  /// [hasCombo] 是否触发连击奖励
  static int calculateGoldEarned(Duration duration, {bool hasCombo = false}) {
    final minutes = duration.inMinutes;
    int gold = minutes * goldPerMinute;

    // 连击奖励
    if (hasCombo && minutes >= comboThreshold) {
      gold += comboBonus;
    }

    return gold;
  }

  /// 计算工作时长获得的经验值
  /// [duration] 工作时长
  static int calculateExpEarned(Duration duration) {
    final hours = duration.inHours;
    final remainingMinutes = duration.inMinutes % 60;

    // 基础经验：每小时100经验
    int exp = hours * expPerHour;

    // 不足1小时的部分按比例计算
    if (remainingMinutes > 0) {
      exp += (remainingMinutes / 60 * expPerHour).round();
    }

    return exp;
  }

  /// 检查是否触发连击奖励
  /// [duration] 工作时长
  /// [breakCount] 暂停次数（如果有午休等暂停，则不算连击）
  static bool checkComboBonus(Duration duration, {int breakCount = 0}) {
    return duration.inMinutes >= comboThreshold && breakCount == 0;
  }

  /// 计算完整的工作奖励
  /// 返回 {gold, exp, hasCombo}
  static Map<String, dynamic> calculateWorkRewards(
    Duration duration, {
    int breakCount = 0,
  }) {
    final hasCombo = checkComboBonus(duration, breakCount: breakCount);
    final gold = calculateGoldEarned(duration, hasCombo: hasCombo);
    final exp = calculateExpEarned(duration);

    return {
      'gold': gold,
      'exp': exp,
      'hasCombo': hasCombo,
      'comboBonus': hasCombo ? comboBonus : 0,
    };
  }

  /// 处理购买物品
  /// [profile] 冒险者资料
  /// [itemPrice] 物品价格
  /// 返回更新后的资料，如果金币不足则抛出异常
  static AdventurerProfile purchaseItem(
    AdventurerProfile profile,
    int itemPrice,
  ) {
    if (!profile.canAfford(itemPrice)) {
      throw InsufficientGoldException(
        current: profile.gold,
        required: itemPrice,
      );
    }

    return profile.spendGold(itemPrice);
  }

  /// 使用免签卡恢复连续签到
  /// [profile] 冒险者资料
  /// [daysToRestore] 要恢复的天数（默认1天）
  static AdventurerProfile useRestoreTicket(
    AdventurerProfile profile, {
    int daysToRestore = 1,
  }) {
    final newDays = profile.consecutiveWorkDays + daysToRestore;
    return profile.updateConsecutiveDays(newDays);
  }

  /// 计算项目完成奖励
  /// [estimatedHours] 项目预估工时
  /// 返回 {gold, exp}
  static Map<String, int> calculateProjectRewards(double estimatedHours) {
    // 项目完成奖励：每小时10金币 + 50经验
    final gold = (estimatedHours * 10).toInt();
    final exp = (estimatedHours * 50).toInt();

    return {
      'gold': gold,
      'exp': exp,
    };
  }

  /// 格式化金币显示
  /// 例如：1234 -> "1,234"
  static String formatGold(int gold) {
    return gold.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  /// 计算金币获取效率（金币/小时）
  static double calculateGoldEfficiency(int totalGold, int totalHours) {
    if (totalHours == 0) return 0;
    return totalGold / totalHours;
  }

  /// 预测达到目标金币所需时间
  /// [currentGold] 当前金币
  /// [targetGold] 目标金币
  /// [avgGoldPerHour] 平均每小时获得金币
  /// 返回所需小时数
  static double predictHoursToTarget(
    int currentGold,
    int targetGold,
    double avgGoldPerHour,
  ) {
    if (avgGoldPerHour <= 0) return double.infinity;
    final remaining = targetGold - currentGold;
    if (remaining <= 0) return 0;
    return remaining / avgGoldPerHour;
  }
}

/// 金币不足异常
class InsufficientGoldException implements Exception {
  final int current;
  final int required;

  InsufficientGoldException({
    required this.current,
    required this.required,
  });

  int get shortage => required - current;

  @override
  String toString() {
    return '金币不足！当前：$current，需要：$required，还差：$shortage';
  }
}
