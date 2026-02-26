import 'package:hive/hive.dart';

part 'adventurer_profile.g.dart';

@HiveType(typeId: 2)
class AdventurerProfile extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final int level;

  @HiveField(2)
  final int experience;

  @HiveField(3)
  final int totalWorkHours; // 总工作小时数

  @HiveField(4)
  final int totalGold; // 总金币（基于收入）

  @HiveField(5)
  final List<String> achievements; // 已获得的成就

  @HiveField(6)
  final int consecutiveWorkDays; // 连续工作天数

  AdventurerProfile({
    this.name = '新手冒险者',
    this.level = 1,
    this.experience = 0,
    this.totalWorkHours = 0,
    this.totalGold = 0,
    this.achievements = const [],
    this.consecutiveWorkDays = 0,
  });

  // 获取当前等级称号
  String get title {
    if (level >= 50) return '传说打工人';
    if (level >= 40) return '史诗打工人';
    if (level >= 30) return '精英打工人';
    if (level >= 20) return '资深打工人';
    if (level >= 10) return '熟练打工人';
    if (level >= 5) return '见习打工人';
    return '新手打工人';
  }

  // 获取等级图标
  String get rankIcon {
    if (level >= 50) return '👑';
    if (level >= 40) return '💎';
    if (level >= 30) return '⚔️';
    if (level >= 20) return '🛡️';
    if (level >= 10) return '🗡️';
    if (level >= 5) return '🔰';
    return '🌱';
  }

  // 计算升级所需经验
  int get experienceToNextLevel {
    return level * 100;
  }

  // 计算经验进度百分比
  double get experienceProgress {
    return experience / experienceToNextLevel;
  }

  // 添加工作经验（每工作1小时 = 10经验）
  AdventurerProfile addWorkExperience(int hours) {
    final newExp = experience + (hours * 10);
    final expNeeded = experienceToNextLevel;
    
    if (newExp >= expNeeded) {
      // 升级！
      return copyWith(
        level: level + 1,
        experience: newExp - expNeeded,
        totalWorkHours: totalWorkHours + hours,
      );
    } else {
      return copyWith(
        experience: newExp,
        totalWorkHours: totalWorkHours + hours,
      );
    }
  }

  // 添加金币（基于收入）
  AdventurerProfile addGold(int gold) {
    return copyWith(totalGold: totalGold + gold);
  }

  // 解锁成就
  AdventurerProfile unlockAchievement(String achievement) {
    if (achievements.contains(achievement)) return this;
    return copyWith(achievements: [...achievements, achievement]);
  }

  // 更新连续工作天数
  AdventurerProfile updateConsecutiveDays(int days) {
    return copyWith(consecutiveWorkDays: days);
  }

  AdventurerProfile copyWith({
    String? name,
    int? level,
    int? experience,
    int? totalWorkHours,
    int? totalGold,
    List<String>? achievements,
    int? consecutiveWorkDays,
  }) {
    return AdventurerProfile(
      name: name ?? this.name,
      level: level ?? this.level,
      experience: experience ?? this.experience,
      totalWorkHours: totalWorkHours ?? this.totalWorkHours,
      totalGold: totalGold ?? this.totalGold,
      achievements: achievements ?? this.achievements,
      consecutiveWorkDays: consecutiveWorkDays ?? this.consecutiveWorkDays,
    );
  }
}

// 成就定义
class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  final bool Function(AdventurerProfile) condition;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.condition,
  });

  static final List<Achievement> all = [
    Achievement(
      id: 'first_quest',
      name: '初次任务',
      description: '完成第一次工作记录',
      icon: '🎯',
      condition: (profile) => profile.totalWorkHours > 0,
    ),
    Achievement(
      id: 'work_8_hours',
      name: '标准打工人',
      description: '单日工作满8小时',
      icon: '⏰',
      condition: (profile) => profile.totalWorkHours >= 8,
    ),
    Achievement(
      id: 'level_5',
      name: '见习毕业',
      description: '达到5级',
      icon: '🎓',
      condition: (profile) => profile.level >= 5,
    ),
    Achievement(
      id: 'level_10',
      name: '熟练工',
      description: '达到10级',
      icon: '⚒️',
      condition: (profile) => profile.level >= 10,
    ),
    Achievement(
      id: 'consecutive_7',
      name: '全勤战士',
      description: '连续工作7天',
      icon: '🔥',
      condition: (profile) => profile.consecutiveWorkDays >= 7,
    ),
    Achievement(
      id: 'gold_1000',
      name: '小富即安',
      description: '累计赚取1000金币',
      icon: '💰',
      condition: (profile) => profile.totalGold >= 1000,
    ),
    Achievement(
      id: 'gold_10000',
      name: '财富自由',
      description: '累计赚取10000金币',
      icon: '💎',
      condition: (profile) => profile.totalGold >= 10000,
    ),
    Achievement(
      id: 'work_100_hours',
      name: '百小时勇士',
      description: '累计工作100小时',
      icon: '⚔️',
      condition: (profile) => profile.totalWorkHours >= 100,
    ),
    Achievement(
      id: 'work_1000_hours',
      name: '千小时大师',
      description: '累计工作1000小时',
      icon: '👑',
      condition: (profile) => profile.totalWorkHours >= 1000,
    ),
  ];
}
