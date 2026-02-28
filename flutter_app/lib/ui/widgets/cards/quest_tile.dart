import 'package:flutter/material.dart';
import 'package:work_hours_timer/ui/theme/app_colors.dart';
import 'package:work_hours_timer/ui/theme/app_text_styles.dart';
import 'package:work_hours_timer/ui/theme/modern_hud_theme.dart';

/// 项目列表项 - 悬赏令风格
/// 显示项目名称、BOSS图标、HP血条、快速操作
class QuestTile extends StatelessWidget {
  final String projectName;
  final double progress; // 0.0 - 1.0
  final String progressText; // "24h"
  final String? monsterIcon; // 怪兽图标，如 "🐉"
  final VoidCallback? onStart; // 快速开始
  final VoidCallback? onTap; // 点击查看详情
  final VoidCallback? onMore; // 更多操作

  const QuestTile({
    super.key,
    required this.projectName,
    required this.progress,
    required this.progressText,
    this.monsterIcon,
    this.onStart,
    this.onTap,
    this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final bossColor = AppColors.getBossHealthColor(1 - progress);

    return Card(
      margin: const EdgeInsets.only(bottom: ModernHudTheme.spacingM),
      elevation: 2,
      shadowColor: AppColors.getShadow(brightness).withOpacity(0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: ModernHudTheme.cardBorderRadius,
        child: Padding(
          padding: const EdgeInsets.all(ModernHudTheme.spacingM),
          child: Row(
            children: [
              // 怪兽图标
              _buildMonsterIcon(brightness, bossColor),

              const SizedBox(width: ModernHudTheme.spacingM),

              // 项目信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 项目名称
                    Text(
                      projectName,
                      style: AppTextStyles.headline5(brightness),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: ModernHudTheme.spacingS),

                    // HP血条
                    _buildHealthBar(brightness, bossColor),

                    const SizedBox(height: ModernHudTheme.spacingXS),

                    // 累计工时
                    Text(
                      '累计工时: $progressText',
                      style: AppTextStyles.labelSmall(brightness),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: ModernHudTheme.spacingM),

              // 操作按钮
              _buildActions(brightness),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonsterIcon(Brightness brightness, Color bossColor) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            bossColor.withOpacity(0.2),
            bossColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: bossColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          monsterIcon ?? _getDefaultMonsterIcon(progress),
          style: const TextStyle(fontSize: 32),
        ),
      ),
    );
  }

  Widget _buildHealthBar(Brightness brightness, Color bossColor) {
    return Row(
      children: [
        Text(
          'HP:',
          style: AppTextStyles.labelSmall(brightness).copyWith(
            color: bossColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: ModernHudTheme.spacingS),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                // 背景
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: bossColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                // 进度
                FractionallySizedBox(
                  widthFactor: 1 - progress, // 剩余血量
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: bossColor,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: bossColor.withOpacity(0.5),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: ModernHudTheme.spacingS),
        Text(
          '${((1 - progress) * 100).toInt()}%',
          style: AppTextStyles.labelSmall(brightness).copyWith(
            color: bossColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildActions(Brightness brightness) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 快速开始按钮
        if (onStart != null)
          IconButton(
            onPressed: onStart,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.combat.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: AppColors.combat,
                size: 20,
              ),
            ),
            tooltip: '开始战斗',
          ),

        // 更多操作按钮
        if (onMore != null)
          IconButton(
            onPressed: onMore,
            icon: Icon(
              Icons.more_vert_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
            tooltip: '更多操作',
          ),
      ],
    );
  }

  String _getDefaultMonsterIcon(double progress) {
    // 根据进度返回不同的怪兽图标
    if (progress < 0.3) {
      return '🐉'; // 龙 - 刚开始
    } else if (progress < 0.7) {
      return '🦁'; // 狮子 - 进行中
    } else {
      return '🐺'; // 狼 - 快完成
    }
  }
}
