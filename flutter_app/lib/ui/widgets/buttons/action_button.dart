import 'package:flutter/material.dart';
import 'package:work_hours_timer/ui/theme/app_colors.dart';
import 'package:work_hours_timer/ui/theme/app_text_styles.dart';
import 'package:work_hours_timer/ui/theme/modern_hud_theme.dart';

/// 操作按钮 - 带动效的主要操作按钮
/// 支持渐变背景、图标、加载状态
class ActionButton extends StatefulWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final ActionButtonType type;
  final bool isLoading;
  final double? width;
  final double? height;

  const ActionButton({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
    this.type = ActionButtonType.primary,
    this.isLoading = false,
    this.width,
    this.height,
  });

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    return GestureDetector(
      onTapDown: isEnabled ? (_) => _controller.forward() : null,
      onTapUp: isEnabled ? (_) => _controller.reverse() : null,
      onTapCancel: isEnabled ? () => _controller.reverse() : null,
      onTap: widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.width,
          height: widget.height ?? 56,
          decoration: BoxDecoration(
            gradient: _getGradient(isEnabled),
            borderRadius: ModernHudTheme.cardBorderRadius,
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: _getColor().withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onPressed,
              borderRadius: ModernHudTheme.cardBorderRadius,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: ModernHudTheme.spacingL,
                  vertical: ModernHudTheme.spacingM,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.isLoading)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    else if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: ModernHudTheme.spacingS),
                    ],
                    Text(
                      widget.text,
                      style: AppTextStyles.buttonLarge(brightness),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  LinearGradient _getGradient(bool isEnabled) {
    if (!isEnabled) {
      return LinearGradient(
        colors: [
          AppColors.textTertiary,
          AppColors.textTertiary.withValues(alpha: 0.8),
        ],
      );
    }

    switch (widget.type) {
      case ActionButtonType.primary:
        return AppColors.getPrimaryGradient();
      case ActionButtonType.combat:
        return AppColors.getCombatGradient();
      case ActionButtonType.rest:
        return AppColors.getRestGradient();
      case ActionButtonType.gold:
        return AppColors.goldGradient;
    }
  }

  Color _getColor() {
    switch (widget.type) {
      case ActionButtonType.primary:
        return AppColors.primaryLight;
      case ActionButtonType.combat:
        return AppColors.combat;
      case ActionButtonType.rest:
        return AppColors.rest;
      case ActionButtonType.gold:
        return AppColors.accent;
    }
  }
}

enum ActionButtonType {
  primary,
  combat,
  rest,
  gold,
}
