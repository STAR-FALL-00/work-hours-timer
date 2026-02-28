import '../models/adventurer_profile.dart';
import '../models/project.dart';
import 'economy_service.dart';
import 'project_service.dart';
import 'audio_service.dart';

/// 工作会话管理器
/// 整合经济系统、项目系统和音效系统，管理完整的工作流程
class WorkSessionManager {
  final ProjectService? _projectService;
  final AudioService _audioService;

  WorkSessionManager({
    ProjectService? projectService,
    AudioService? audioService,
  })  : _projectService = projectService,
        _audioService = audioService ?? AudioService();

  /// 开始工作会话
  Future<void> startWorkSession() async {
    await _audioService.playStartWork();
  }

  /// 结束工作会话并结算奖励
  /// [duration] 工作时长
  /// [profile] 冒险者资料
  /// [projectId] 关联的项目ID（可选）
  /// [breakCount] 暂停次数
  /// 返回更新后的资料和工作记录数据
  Future<WorkSessionResult> endWorkSession({
    required Duration duration,
    required AdventurerProfile profile,
    String? projectId,
    int breakCount = 0,
  }) async {
    // 1. 计算基础奖励（金币和经验）
    final rewards = EconomyService.calculateWorkRewards(
      duration,
      breakCount: breakCount,
    );

    final goldEarned = rewards['gold'] as int;
    final expEarned = rewards['exp'] as int;
    final hasCombo = rewards['hasCombo'] as bool;

    // 2. 更新冒险者资料
    var updatedProfile = profile.earnGold(goldEarned);

    // 添加经验并检查升级
    var currentExp = updatedProfile.experience + expEarned;
    var currentLevel = updatedProfile.level;
    var leveledUp = false;

    while (currentExp >= currentLevel * 100) {
      currentExp -= currentLevel * 100;
      currentLevel++;
      leveledUp = true;
    }

    updatedProfile = updatedProfile.copyWith(
      level: currentLevel,
      experience: currentExp,
      totalWorkHours: updatedProfile.totalWorkHours + duration.inHours,
    );

    // 3. 如果有关联项目，添加工时到项目
    Project? updatedProject;
    bool projectCompleted = false;
    int projectGoldReward = 0;
    int projectExpReward = 0;

    if (projectId != null && _projectService != null) {
      try {
        final result = await _projectService.addWorkHours(
          projectId,
          duration.inHours.toDouble() + (duration.inMinutes % 60) / 60,
        );

        updatedProject = result.project;
        projectCompleted = result.isCompleted;

        if (projectCompleted) {
          // 项目完成，发放额外奖励
          projectGoldReward = result.rewardGold;
          projectExpReward = result.rewardExp;

          updatedProfile = updatedProfile.earnGold(projectGoldReward);

          // 添加项目经验
          currentExp = updatedProfile.experience + projectExpReward;
          currentLevel = updatedProfile.level;

          while (currentExp >= currentLevel * 100) {
            currentExp -= currentLevel * 100;
            currentLevel++;
            leveledUp = true;
          }

          updatedProfile = updatedProfile.copyWith(
            level: currentLevel,
            experience: currentExp,
          );

          // 播放项目完成音效
          await _audioService.playProjectComplete();
        }
      } catch (e) {
        print('添加项目工时失败：$e');
      }
    }

    // 4. 播放升级音效
    if (leveledUp) {
      await _audioService.playLevelUp();
    }

    // 5. 返回结果
    return WorkSessionResult(
      profile: updatedProfile,
      goldEarned: goldEarned + projectGoldReward,
      expEarned: expEarned + projectExpReward,
      hasCombo: hasCombo,
      comboBonus: hasCombo ? EconomyService.comboBonus : 0,
      leveledUp: leveledUp,
      newLevel: leveledUp ? currentLevel : null,
      project: updatedProject,
      projectCompleted: projectCompleted,
      projectGoldReward: projectGoldReward,
      projectExpReward: projectExpReward,
    );
  }

  /// 购买商店物品
  /// [profile] 冒险者资料
  /// [itemPrice] 物品价格
  /// 返回更新后的资料
  Future<AdventurerProfile> purchaseItem(
    AdventurerProfile profile,
    int itemPrice,
  ) async {
    try {
      final updated = EconomyService.purchaseItem(profile, itemPrice);
      await _audioService.playPurchase();
      return updated;
    } catch (e) {
      await _audioService.playError();
      rethrow;
    }
  }

  /// 解锁成就
  Future<void> unlockAchievement() async {
    await _audioService.playAchievement();
  }
}

/// 工作会话结果
class WorkSessionResult {
  final AdventurerProfile profile;
  final int goldEarned;
  final int expEarned;
  final bool hasCombo;
  final int comboBonus;
  final bool leveledUp;
  final int? newLevel;
  final Project? project;
  final bool projectCompleted;
  final int projectGoldReward;
  final int projectExpReward;

  WorkSessionResult({
    required this.profile,
    required this.goldEarned,
    required this.expEarned,
    required this.hasCombo,
    required this.comboBonus,
    required this.leveledUp,
    this.newLevel,
    this.project,
    required this.projectCompleted,
    required this.projectGoldReward,
    required this.projectExpReward,
  });

  /// 总金币（包括项目奖励）
  int get totalGold => goldEarned;

  /// 总经验（包括项目奖励）
  int get totalExp => expEarned;

  /// 是否有特殊事件（连击、升级、项目完成）
  bool get hasSpecialEvent => hasCombo || leveledUp || projectCompleted;

  /// 获取奖励摘要文本
  String getSummary() {
    final parts = <String>[];

    parts.add('获得 $goldEarned 金币');
    parts.add('获得 $expEarned 经验');

    if (hasCombo) {
      parts.add('🔥 连击奖励 +$comboBonus 金币');
    }

    if (leveledUp) {
      parts.add('⬆️ 升级到 Lv.$newLevel');
    }

    if (projectCompleted) {
      parts.add('🎉 项目完成！额外获得 $projectGoldReward 金币和 $projectExpReward 经验');
    }

    return parts.join('\n');
  }
}
