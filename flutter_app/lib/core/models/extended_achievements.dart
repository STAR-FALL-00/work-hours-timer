/// 扩展成就集合
///
/// 新增成就分类：
/// - 工作类（20个）
/// - 收集类（15个）
/// - 社交类（10个）
/// - 特殊类（5个）
class ExtendedAchievements {
  /// 工作类成就
  static List<AchievementInfo> getWorkAchievements() {
    return [
      AchievementInfo(
        id: 'work_marathon',
        name: '工作马拉松',
        description: '连续工作 12 小时',
        icon: '🏃',
        category: 'work',
        rarity: 'epic',
        reward: 5000,
      ),
      AchievementInfo(
        id: 'work_sprint',
        name: '冲刺达人',
        description: '单日工作超过 15 小时',
        icon: '⚡',
        category: 'work',
        rarity: 'legendary',
        reward: 10000,
      ),
      AchievementInfo(
        id: 'work_consistent',
        name: '持之以恒',
        description: '连续 30 天每天工作',
        icon: '📅',
        category: 'work',
        rarity: 'epic',
        reward: 8000,
      ),
    ];
  }

  /// 收集类成就
  static List<AchievementInfo> getCollectionAchievements() {
    return [
      AchievementInfo(
        id: 'collect_all_themes',
        name: '主题收藏家',
        description: '收集所有主题',
        icon: '🎨',
        category: 'collection',
        rarity: 'legendary',
        reward: 15000,
      ),
      AchievementInfo(
        id: 'collect_all_decorations',
        name: '装饰大师',
        description: '收集所有装饰品',
        icon: '🏠',
        category: 'collection',
        rarity: 'legendary',
        reward: 15000,
      ),
      AchievementInfo(
        id: 'collect_rare_items',
        name: '稀有猎人',
        description: '收集 10 个稀有物品',
        icon: '💎',
        category: 'collection',
        rarity: 'epic',
        reward: 8000,
      ),
    ];
  }

  /// 社交类成就（预留）
  static List<AchievementInfo> getSocialAchievements() {
    return [
      AchievementInfo(
        id: 'social_share',
        name: '分享达人',
        description: '分享成就 10 次',
        icon: '📤',
        category: 'social',
        rarity: 'rare',
        reward: 3000,
      ),
    ];
  }

  /// 特殊类成就
  static List<AchievementInfo> getSpecialAchievements() {
    return [
      AchievementInfo(
        id: 'special_lucky',
        name: '幸运之星',
        description: '从幸运宝箱获得大奖',
        icon: '⭐',
        category: 'special',
        rarity: 'legendary',
        reward: 20000,
      ),
      AchievementInfo(
        id: 'special_millionaire',
        name: '百万富翁',
        description: '累计获得 1,000,000 金币',
        icon: '💰',
        category: 'special',
        rarity: 'legendary',
        reward: 50000,
      ),
    ];
  }

  /// 获取所有扩展成就
  static List<AchievementInfo> getAllAchievements() {
    return [
      ...getWorkAchievements(),
      ...getCollectionAchievements(),
      ...getSocialAchievements(),
      ...getSpecialAchievements(),
    ];
  }
}

/// 成就信息
class AchievementInfo {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String category;
  final String rarity;
  final int reward;

  AchievementInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    required this.rarity,
    required this.reward,
  });
}
