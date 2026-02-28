import 'package:flutter/material.dart';
import 'package:work_hours_timer/ui/theme/app_colors.dart';
import 'package:work_hours_timer/ui/theme/app_text_styles.dart';
import 'package:work_hours_timer/ui/theme/modern_hud_theme.dart';

/// KPI 指标卡片 - 用于统计页面
/// 显示关键指标：总输出、最高连击、战利品等
class KpiCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? accentColor;
  final String? subtitle;
  final VoidCallback? onTap;

  const KpiCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.accentColor,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final color = accentColor ?? AppColors.getPrimary(brightness);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shadowColor: AppColors.getShadow(brightness).withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: ModernHudTheme.cardBorderRadius,
        ),
        child: Container(
          padding: const EdgeInsets.all(ModernHudTheme.spacingM),
          decoration: BoxDecoration(
            borderRadius: ModernHudTheme.cardBorderRadius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.getCardBackground(brightness),
                color.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 图标
              Container(
                padding: const EdgeInsets.all(ModernHudTheme.spacingM),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),

              const SizedBox(height: ModernHudTheme.spacingM),

              // 数值
              Text(
                value,
                style: AppTextStyles.headline2(brightness).copyWith(
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: ModernHudTheme.spacingXS),

              // 标签
              Text(
                label,
                style: AppTextStyles.labelMedium(brightness),
                textAlign: TextAlign.center,
              ),

              // 副标题（可选）
              if (subtitle != null) ...[
                const SizedBox(height: ModernHudTheme.spacingXS),
                Text(
                  subtitle!,
                  style: AppTextStyles.labelSmall(brightness).copyWith(
                    color: AppColors.textTertiary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
