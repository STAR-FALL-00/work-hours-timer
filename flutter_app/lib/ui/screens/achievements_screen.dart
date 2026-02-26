import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../core/models/adventurer_profile.dart';
import '../../ui/theme/game_theme.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(adventurerProfileProvider);
    final appSettings = ref.watch(appSettingsProvider);
    final isGameMode = appSettings.isGameMode;

    return Scaffold(
      backgroundColor: isGameMode ? GameTheme.darkBrown : Colors.grey[50],
      appBar: AppBar(
        title: Text(
          isGameMode ? '🏆 荣誉殿堂' : '🏆 成就系统',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isGameMode ? GameTheme.primaryGold : null,
          ),
        ),
        backgroundColor: isGameMode 
            ? GameTheme.darkBrown 
            : Theme.of(context).colorScheme.inversePrimary,
        iconTheme: IconThemeData(
          color: isGameMode ? GameTheme.primaryGold : null,
        ),
      ),
      body: Container(
        decoration: isGameMode
            ? BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [GameTheme.darkBrown, GameTheme.lightBrown],
                ),
              )
            : null,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 成就统计卡片
                _buildStatsCard(profile, isGameMode),
                const SizedBox(height: 20),
                
                // 成就列表
                _buildAchievementsList(profile, isGameMode),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard(AdventurerProfile profile, bool isGameMode) {
    final unlockedCount = profile.achievements.length;
    final totalCount = Achievement.all.length;
    final progress = totalCount > 0 ? unlockedCount / totalCount : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: isGameMode
          ? GameTheme.parchmentDecoration
          : BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '成就进度',
                style: isGameMode
                    ? GameTheme.questTitleStyle
                    : const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
              ),
              Text(
                '$unlockedCount / $totalCount',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  color: isGameMode ? GameTheme.primaryGold : Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 20,
              backgroundColor: isGameMode 
                  ? GameTheme.darkParchment 
                  : Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                isGameMode ? GameTheme.primaryGold : Colors.blue,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '已解锁 ${(progress * 100).toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 14,
              color: isGameMode ? GameTheme.lightBrown : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsList(AdventurerProfile profile, bool isGameMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '全部成就',
          style: isGameMode
              ? GameTheme.questTitleStyle.copyWith(
                  color: GameTheme.primaryGold,
                )
              : const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
        ),
        const SizedBox(height: 12),
        ...Achievement.all.map((achievement) {
          final isUnlocked = profile.achievements.contains(achievement.id);
          return _buildAchievementCard(
            achievement,
            isUnlocked,
            profile,
            isGameMode,
          );
        }).toList(),
      ],
    );
  }

  Widget _buildAchievementCard(
    Achievement achievement,
    bool isUnlocked,
    AdventurerProfile profile,
    bool isGameMode,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: isGameMode
          ? BoxDecoration(
              color: isUnlocked ? GameTheme.parchment : GameTheme.darkParchment,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isUnlocked ? GameTheme.primaryGold : GameTheme.darkBrown,
                width: isUnlocked ? 2 : 1,
              ),
              boxShadow: isUnlocked
                  ? [
                      BoxShadow(
                        color: GameTheme.primaryGold.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            )
          : BoxDecoration(
              color: isUnlocked ? Colors.blue.shade50 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isUnlocked ? Colors.blue : Colors.grey.shade300,
                width: isUnlocked ? 2 : 1,
              ),
            ),
      child: Row(
        children: [
          // 图标
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? (isGameMode ? GameTheme.primaryGold : Colors.blue)
                  : Colors.grey,
              shape: BoxShape.circle,
              boxShadow: isUnlocked
                  ? [
                      BoxShadow(
                        color: (isGameMode 
                            ? GameTheme.primaryGold 
                            : Colors.blue
                        ).withValues(alpha: 0.4),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                isUnlocked ? achievement.icon : '🔒',
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // 信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isUnlocked
                        ? (isGameMode ? GameTheme.darkBrown : Colors.black87)
                        : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: isUnlocked
                        ? (isGameMode ? GameTheme.lightBrown : Colors.grey.shade700)
                        : Colors.grey.shade500,
                  ),
                ),
                if (!isUnlocked) ...[
                  const SizedBox(height: 8),
                  _buildProgress(achievement, profile, isGameMode),
                ],
              ],
            ),
          ),
          
          // 状态标记
          if (isUnlocked)
            Icon(
              Icons.check_circle,
              color: isGameMode ? GameTheme.primaryGold : Colors.blue,
              size: 28,
            ),
        ],
      ),
    );
  }

  Widget _buildProgress(
    Achievement achievement,
    AdventurerProfile profile,
    bool isGameMode,
  ) {
    String progressText = '';
    double? progressValue;

    // 根据成就类型显示进度
    if (achievement.id == 'work_8_hours') {
      // 需要从今日记录计算
      progressText = '今日工作时长进度';
    } else if (achievement.id == 'level_5') {
      progressValue = profile.level / 5.0;
      progressText = 'Lv.${profile.level} / Lv.5';
    } else if (achievement.id == 'level_10') {
      progressValue = profile.level / 10.0;
      progressText = 'Lv.${profile.level} / Lv.10';
    } else if (achievement.id == 'consecutive_7') {
      progressValue = profile.consecutiveWorkDays / 7.0;
      progressText = '${profile.consecutiveWorkDays} / 7 天';
    } else if (achievement.id == 'gold_1000') {
      progressValue = profile.totalGold / 1000.0;
      progressText = '${profile.totalGold} / 1000 金币';
    } else if (achievement.id == 'gold_10000') {
      progressValue = profile.totalGold / 10000.0;
      progressText = '${profile.totalGold} / 10000 金币';
    } else if (achievement.id == 'work_100_hours') {
      progressValue = profile.totalWorkHours / 100.0;
      progressText = '${profile.totalWorkHours} / 100 小时';
    } else if (achievement.id == 'work_1000_hours') {
      progressValue = profile.totalWorkHours / 1000.0;
      progressText = '${profile.totalWorkHours} / 1000 小时';
    }

    if (progressValue != null && progressValue > 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            progressText,
            style: TextStyle(
              fontSize: 12,
              color: isGameMode ? GameTheme.lightBrown : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progressValue.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: isGameMode 
                  ? GameTheme.darkParchment 
                  : Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(
                isGameMode ? GameTheme.primaryGold : Colors.blue,
              ),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}
