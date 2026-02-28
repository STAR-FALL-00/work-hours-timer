import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/modern_hud_theme.dart';

/// 设置卡片组件
/// Modern HUD 风格的设置项卡片
class SettingCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget child;

  const SettingCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Container(
      margin: const EdgeInsets.only(bottom: ModernHudTheme.spacingL),
      padding: const EdgeInsets.all(ModernHudTheme.spacingL),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(brightness),
        borderRadius: ModernHudTheme.cardBorderRadius,
        boxShadow: [
          BoxShadow(
            color: AppColors.getShadow(brightness).withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(ModernHudTheme.spacingS),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: ModernHudTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.headline5(brightness),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: AppTextStyles.bodySmall(brightness).copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: ModernHudTheme.spacingL),

          // 内容
          child,
        ],
      ),
    );
  }
}

/// 设置开关项
class SettingSwitchTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? activeColor;

  const SettingSwitchTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Container(
      padding: const EdgeInsets.all(ModernHudTheme.spacingM),
      decoration: BoxDecoration(
        color: value
            ? (activeColor ?? AppColors.getPrimary(brightness))
                .withValues(alpha: 0.1)
            : AppColors.border.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value
              ? (activeColor ?? AppColors.getPrimary(brightness))
                  .withValues(alpha: 0.3)
              : AppColors.border.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            value ? Icons.check_circle_rounded : Icons.info_rounded,
            color: value
                ? (activeColor ?? AppColors.getPrimary(brightness))
                : AppColors.textSecondary,
            size: 20,
          ),
          const SizedBox(width: ModernHudTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelLarge(brightness).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: AppTextStyles.bodySmall(brightness).copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Transform.scale(
            scale: 1.1,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeTrackColor:
                  (activeColor ?? AppColors.getPrimary(brightness))
                      .withValues(alpha: 0.5),
              activeColor: activeColor ?? AppColors.getPrimary(brightness),
            ),
          ),
        ],
      ),
    );
  }
}
