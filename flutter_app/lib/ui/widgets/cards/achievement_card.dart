import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/modern_hud_theme.dart';

/// 成就卡片组件
/// Modern HUD 风格的成就展示卡片
class AchievementCard extends StatelessWidget {
  final String icon;
  final String name;
  final String description;
  final bool isUnlocked;
  final String? progressText;
  final double? progressValue;
  final VoidCallback? onTap;

  const AchievementCard({
    super.key,
    required this.icon,
    required this.name,
    required this.description,
    required this.isUnlocked,
    this.progressText,
    this.progressValue,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: ModernHudTheme.spacingM),
        padding: const EdgeInsets.all(ModernHudTheme.spacingL),
        decoration: BoxDecoration(
          color: isUnlocked
              ? AppColors.getCardBackground(brightness)
              : AppColors.getCardBackground(brightness).withValues(alpha: 0.5),
          borderRadius: ModernHudTheme.cardBorderRadius,
          border: Border.all(
            color: isUnlocked
                ? AppColors.accent
                : AppColors.border.withValues(alpha: 0.3),
            width: isUnlocked ? 2 : 1,
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color:
                        AppColors.getShadow(brightness).withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            // 图标
            _buildIcon(brightness),
            const SizedBox(width: ModernHudTheme.spacingL),

            // 信息
            Expanded(
              child: _buildInfo(brightness),
            ),

            // 状态标记
            if (isUnlocked) _buildCheckMark(),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(Brightness brightness) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        gradient: isUnlocked
            ? AppColors.goldGradient
            : LinearGradient(
                colors: [
                  AppColors.textTertiary.withValues(alpha: 0.3),
                  AppColors.textTertiary.withValues(alpha: 0.1),
                ],
              ),
        shape: BoxShape.circle,
        boxShadow: isUnlocked
            ? [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          isUnlocked ? icon : '🔒',
          style: const TextStyle(fontSize: 32),
        ),
      ),
    );
  }

  Widget _buildInfo(Brightness brightness) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 成就名称
        Text(
          name,
          style: AppTextStyles.headline5(brightness).copyWith(
            color: isUnlocked
                ? AppColors.getTextPrimary(brightness)
                : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: ModernHudTheme.spacingXS),

        // 成就描述
        Text(
          description,
          style: AppTextStyles.bodySmall(brightness).copyWith(
            color:
                isUnlocked ? AppColors.textSecondary : AppColors.textTertiary,
          ),
        ),

        // 进度条（未解锁时显示）
        if (!isUnlocked && progressValue != null) ...[
          const SizedBox(height: ModernHudTheme.spacingM),
          _buildProgress(brightness),
        ],
      ],
    );
  }

  Widget _buildProgress(Brightness brightness) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (progressText != null)
          Text(
            progressText!,
            style: AppTextStyles.labelSmall(brightness).copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        const SizedBox(height: ModernHudTheme.spacingXS),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progressValue!.clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: AppColors.border.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.getPrimary(brightness),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckMark() {
    return Container(
      padding: const EdgeInsets.all(ModernHudTheme.spacingS),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.check_circle_rounded,
        color: AppColors.accent,
        size: 28,
      ),
    );
  }
}
