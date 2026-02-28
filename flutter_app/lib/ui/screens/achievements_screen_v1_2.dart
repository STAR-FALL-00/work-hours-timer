import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../core/models/adventurer_profile.dart';
import '../widgets/modern_hud_widgets.dart';
import '../widgets/cards/achievement_card.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/modern_hud_theme.dart';

/// v1.2.0 Modern HUD 风格成就页面
class AchievementsScreenV12 extends ConsumerWidget {
  const AchievementsScreenV12({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(adventurerProfileProvider);
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      backgroundColor: AppColors.getBackground(brightness),
      appBar: AppBar(
        elevation: 0,
        title: Text(
          '成就系统',
          style: AppTextStyles.headline3(brightness),
        ),
        backgroundColor: AppColors.getPrimary(brightness),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(ModernHudTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 成就统计卡片
            _buildStatsCard(profile, brightness),

            const SizedBox(height: ModernHudTheme.spacingL),

            // 分类标题
            _buildSectionTitle('全部成就', brightness),

            const SizedBox(height: ModernHudTheme.spacingM),

            // 成就列表
            _buildAchievementsList(profile, brightness),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(AdventurerProfile profile, Brightness brightness) {
    final unlockedCount = profile.achievements.length;
    final totalCount = Achievement.all.length;
    final progress = totalCount > 0 ? unlockedCount / totalCount : 0.0;

    return Container(
      padding: const EdgeInsets.all(ModernHudTheme.spacingL),
      decoration: BoxDecoration(
        gradient: AppColors.getPrimaryGradient(),
        borderRadius: ModernHudTheme.cardBorderRadius,
        boxShadow: [
          BoxShadow(
            color: AppColors.getPrimary(brightness).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 标题行
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(ModernHudTheme.spacingS),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.emoji_events_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: ModernHudTheme.spacingM),
                  Text(
                    '成就进度',
                    style: AppTextStyles.headline4(brightness).copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Text(
                '$unlockedCount / $totalCount',
                style: AppTextStyles.timerSmall(brightness).copyWith(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ],
          ),

          const SizedBox(height: ModernHudTheme.spacingL),

          // 进度条
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 20,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.accent,
              ),
            ),
          ),

          const SizedBox(height: ModernHudTheme.spacingM),

          // 进度文字
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '已解锁 ${(progress * 100).toStringAsFixed(0)}%',
                style: AppTextStyles.labelLarge(brightness).copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              if (unlockedCount < totalCount)
                Text(
                  '还差 ${totalCount - unlockedCount} 个',
                  style: AppTextStyles.labelLarge(brightness).copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, Brightness brightness) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.getPrimary(brightness),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: ModernHudTheme.spacingS),
        Text(
          title,
          style: AppTextStyles.headline4(brightness),
        ),
      ],
    );
  }

  Widget _buildAchievementsList(
      AdventurerProfile profile, Brightness brightness) {
    return Column(
      children: Achievement.all.map((achievement) {
        final isUnlocked = profile.achievements.contains(achievement.id);
        final progressData = _getProgressData(achievement, profile);

        return AchievementCard(
          icon: achievement.icon,
          name: achievement.name,
          description: achievement.description,
          isUnlocked: isUnlocked,
          progressText: progressData['text'],
          progressValue: progressData['value'],
        );
      }).toList(),
    );
  }

  Map<String, dynamic> _getProgressData(
    Achievement achievement,
    AdventurerProfile profile,
  ) {
    String? progressText;
    double? progressValue;

    // 根据成就类型计算进度
    switch (achievement.id) {
      case 'work_8_hours':
        // 需要从今日记录计算，这里暂时不显示进度
        break;

      case 'level_5':
        if (profile.level < 5) {
          progressValue = profile.level / 5.0;
          progressText = 'Lv.${profile.level} / Lv.5';
        }
        break;

      case 'level_10':
        if (profile.level < 10) {
          progressValue = profile.level / 10.0;
          progressText = 'Lv.${profile.level} / Lv.10';
        }
        break;

      case 'level_20':
        if (profile.level < 20) {
          progressValue = profile.level / 20.0;
          progressText = 'Lv.${profile.level} / Lv.20';
        }
        break;

      case 'consecutive_7':
        if (profile.consecutiveWorkDays < 7) {
          progressValue = profile.consecutiveWorkDays / 7.0;
          progressText = '${profile.consecutiveWorkDays} / 7 天';
        }
        break;

      case 'consecutive_30':
        if (profile.consecutiveWorkDays < 30) {
          progressValue = profile.consecutiveWorkDays / 30.0;
          progressText = '${profile.consecutiveWorkDays} / 30 天';
        }
        break;

      case 'gold_1000':
        if (profile.totalGold < 1000) {
          progressValue = profile.totalGold / 1000.0;
          progressText = '${profile.totalGold} / 1000 💰';
        }
        break;

      case 'gold_10000':
        if (profile.totalGold < 10000) {
          progressValue = profile.totalGold / 10000.0;
          progressText = '${profile.totalGold} / 10000 💰';
        }
        break;

      case 'work_100_hours':
        if (profile.totalWorkHours < 100) {
          progressValue = profile.totalWorkHours / 100.0;
          progressText = '${profile.totalWorkHours.toStringAsFixed(1)} / 100h';
        }
        break;

      case 'work_1000_hours':
        if (profile.totalWorkHours < 1000) {
          progressValue = profile.totalWorkHours / 1000.0;
          progressText = '${profile.totalWorkHours.toStringAsFixed(1)} / 1000h';
        }
        break;
    }

    return {
      'text': progressText,
      'value': progressValue,
    };
  }
}
