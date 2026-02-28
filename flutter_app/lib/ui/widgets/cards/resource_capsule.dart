import 'package:flutter/material.dart';
import 'package:work_hours_timer/ui/theme/app_colors.dart';
import 'package:work_hours_timer/ui/theme/app_text_styles.dart';
import 'package:work_hours_timer/ui/theme/modern_hud_theme.dart';

/// 资源胶囊组件 - 显示金币或经验值
/// 带进度条背景的胶囊式设计
class ResourceCapsule extends StatelessWidget {
  final ResourceType type;
  final int current;
  final int? max; // 如果有最大值，显示进度条
  final VoidCallback? onTap;

  const ResourceCapsule({
    super.key,
    required this.type,
    required this.current,
    this.max,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final hasProgress = max != null && max! > 0;
    final progress = hasProgress ? (current / max!).clamp(0.0, 1.0) : 0.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(
          horizontal: ModernHudTheme.spacingM,
          vertical: ModernHudTheme.spacingXS,
        ),
        decoration: BoxDecoration(
          color: _getBackgroundColor(brightness),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _getBorderColor().withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _getBorderColor().withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // 进度条背景
            if (hasProgress)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: progress,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _getBorderColor().withOpacity(0.2),
                              _getBorderColor().withOpacity(0.1),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // 内容
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getIcon(),
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: ModernHudTheme.spacingS),
                Text(
                  _formatNumber(current),
                  style: _getTextStyle(brightness),
                ),
                if (hasProgress) ...[
                  Text(
                    ' / ${_formatNumber(max!)}',
                    style: AppTextStyles.labelSmall(brightness).copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor(Brightness brightness) {
    return AppColors.getCardBackground(brightness);
  }

  Color _getBorderColor() {
    switch (type) {
      case ResourceType.gold:
        return AppColors.accent;
      case ResourceType.exp:
        return AppColors.expBar;
    }
  }

  String _getIcon() {
    switch (type) {
      case ResourceType.gold:
        return '💰';
      case ResourceType.exp:
        return '⭐';
    }
  }

  TextStyle _getTextStyle(Brightness brightness) {
    switch (type) {
      case ResourceType.gold:
        return AppTextStyles.goldAmount(brightness).copyWith(fontSize: 16);
      case ResourceType.exp:
        return AppTextStyles.expAmount(brightness).copyWith(fontSize: 16);
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}

enum ResourceType {
  gold,
  exp,
}
