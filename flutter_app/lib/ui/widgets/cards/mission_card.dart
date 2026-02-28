import 'package:flutter/material.dart';
import 'package:work_hours_timer/ui/theme/app_colors.dart';
import 'package:work_hours_timer/ui/theme/app_text_styles.dart';
import 'package:work_hours_timer/ui/theme/modern_hud_theme.dart';

/// 任务卡片 - 主页核心组件
/// 集中显示当前任务、BOSS血条、计时器、奖励预览
class MissionCard extends StatelessWidget {
  final String? projectName;
  final double? bossProgress; // 0.0 - 1.0
  final String? bossProgressText; // "12h / 20h"
  final String timerText; // "00:45:32"
  final bool isWorking;
  final String? statusText; // "🟢 战斗中" or "☕ 营地休息"
  final int? predictedGold;
  final int? predictedExp;
  final String? comboHint; // 连击提示
  final VoidCallback? onProjectTap;

  const MissionCard({
    super.key,
    this.projectName,
    this.bossProgress,
    this.bossProgressText,
    required this.timerText,
    this.isWorking = false,
    this.statusText,
    this.predictedGold,
    this.predictedExp,
    this.comboHint,
    this.onProjectTap,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Card(
      elevation: 4,
      shadowColor: AppColors.getShadow(brightness).withOpacity(0.15),
      shape: RoundedRectangleBorder(
        borderRadius: ModernHudTheme.cardBorderRadius,
      ),
      child: Container(
        padding: const EdgeInsets.all(ModernHudTheme.spacingL),
        decoration: BoxDecoration(
          borderRadius: ModernHudTheme.cardBorderRadius,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.getCardBackground(brightness),
              AppColors.getCardBackground(brightness).withOpacity(0.95),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题区
            _buildHeader(brightness),

            if (projectName != null) ...[
              const SizedBox(height: ModernHudTheme.spacingM),
              _buildProjectSection(brightness),
            ],

            const SizedBox(height: ModernHudTheme.spacingL),

            // 计时器
            _buildTimer(brightness),

            const SizedBox(height: ModernHudTheme.spacingS),

            // 状态指示
            if (statusText != null) _buildStatus(brightness),

            // 奖励预览
            if (isWorking &&
                (predictedGold != null || predictedExp != null)) ...[
              const SizedBox(height: ModernHudTheme.spacingM),
              _buildRewardPreview(brightness),
            ],

            // 连击提示
            if (comboHint != null) ...[
              const SizedBox(height: ModernHudTheme.spacingS),
              _buildComboHint(brightness),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Brightness brightness) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(ModernHudTheme.spacingS),
          decoration: BoxDecoration(
            color: AppColors.getPrimary(brightness).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.flag_rounded,
            color: AppColors.getPrimary(brightness),
            size: 20,
          ),
        ),
        const SizedBox(width: ModernHudTheme.spacingM),
        Text(
          '当前任务',
          style: AppTextStyles.headline4(brightness),
        ),
      ],
    );
  }

  Widget _buildProjectSection(Brightness brightness) {
    return GestureDetector(
      onTap: onProjectTap,
      child: Container(
        padding: const EdgeInsets.all(ModernHudTheme.spacingM),
        decoration: BoxDecoration(
          color: AppColors.getPrimary(brightness).withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.getPrimary(brightness).withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.assignment_rounded, size: 18),
                const SizedBox(width: ModernHudTheme.spacingS),
                Expanded(
                  child: Text(
                    projectName!,
                    style: AppTextStyles.headline5(brightness),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (onProjectTap != null)
                  Icon(
                    Icons.arrow_drop_down_rounded,
                    color: AppColors.textSecondary,
                  ),
              ],
            ),
            if (bossProgress != null && bossProgressText != null) ...[
              const SizedBox(height: ModernHudTheme.spacingM),
              _buildBossHealthBar(brightness),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBossHealthBar(Brightness brightness) {
    final color = AppColors.getBossHealthColor(bossProgress!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'HP',
              style: AppTextStyles.labelSmall(brightness).copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              bossProgressText!,
              style: AppTextStyles.labelSmall(brightness).copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: ModernHudTheme.spacingXS),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              // 背景
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              // 进度
              FractionallySizedBox(
                widthFactor: bossProgress!,
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color,
                        color.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.5),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimer(Brightness brightness) {
    return Center(
      child: Text(
        timerText,
        style: AppTextStyles.timerLarge(brightness).copyWith(
          shadows: [
            Shadow(
              color: AppColors.getPrimary(brightness).withOpacity(0.3),
              blurRadius: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatus(Brightness brightness) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: ModernHudTheme.spacingM,
          vertical: ModernHudTheme.spacingS,
        ),
        decoration: BoxDecoration(
          color: isWorking
              ? AppColors.combat.withOpacity(0.1)
              : AppColors.rest.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          statusText!,
          style: isWorking
              ? AppTextStyles.statusCombat(brightness)
              : AppTextStyles.statusRest(brightness),
        ),
      ),
    );
  }

  Widget _buildRewardPreview(Brightness brightness) {
    return Container(
      padding: const EdgeInsets.all(ModernHudTheme.spacingM),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.accent.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '预计奖励: ',
            style: AppTextStyles.labelMedium(brightness),
          ),
          if (predictedGold != null) ...[
            const SizedBox(width: ModernHudTheme.spacingS),
            Text(
              '+$predictedGold',
              style: AppTextStyles.goldAmount(brightness),
            ),
            const Text(' 💰'),
          ],
          if (predictedExp != null) ...[
            const SizedBox(width: ModernHudTheme.spacingM),
            Text(
              '+$predictedExp',
              style: AppTextStyles.expAmount(brightness),
            ),
            const Text(' ⭐'),
          ],
        ],
      ),
    );
  }

  Widget _buildComboHint(Brightness brightness) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ModernHudTheme.spacingM,
        vertical: ModernHudTheme.spacingS,
      ),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.bolt_rounded,
            color: AppColors.warning,
            size: 16,
          ),
          const SizedBox(width: ModernHudTheme.spacingS),
          Expanded(
            child: Text(
              comboHint!,
              style: AppTextStyles.labelSmall(brightness).copyWith(
                color: AppColors.warning,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
