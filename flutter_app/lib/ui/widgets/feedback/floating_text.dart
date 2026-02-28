import 'package:flutter/material.dart';
import 'package:work_hours_timer/ui/theme/app_text_styles.dart';

/// 飘字动画组件 - 金币/经验值飘字效果
/// 用于显示获得奖励时的视觉反馈
class FloatingText extends StatefulWidget {
  final String text;
  final FloatingTextType type;
  final Duration duration;
  final VoidCallback? onComplete;

  const FloatingText({
    super.key,
    required this.text,
    this.type = FloatingTextType.gold,
    this.duration = const Duration(seconds: 2),
    this.onComplete,
  });

  @override
  State<FloatingText> createState() => _FloatingTextState();
}

class _FloatingTextState extends State<FloatingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _positionAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    // 位置动画：向上移动
    _positionAnimation = Tween<double>(
      begin: 0,
      end: -100,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    // 透明度动画：渐隐
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
    ));

    // 缩放动画：先放大后缩小
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.5, end: 1.2),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.8),
        weight: 50,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // 开始动画
    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _positionAnimation.value),
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            ),
          ),
        );
      },
      child: Text(
        widget.text,
        style: _getTextStyle(),
      ),
    );
  }

  TextStyle _getTextStyle() {
    switch (widget.type) {
      case FloatingTextType.gold:
        return AppTextStyles.floatingGold();
      case FloatingTextType.exp:
        return AppTextStyles.floatingExp();
      case FloatingTextType.levelUp:
        return AppTextStyles.floatingLevelUp();
    }
  }
}

/// 飘字类型
enum FloatingTextType {
  gold, // 金币
  exp, // 经验值
  levelUp, // 升级
}

/// 飘字管理器 - 用于在屏幕上显示飘字
class FloatingTextManager {
  static OverlayEntry? _currentEntry;

  /// 显示飘字
  static void show(
    BuildContext context, {
    required String text,
    FloatingTextType type = FloatingTextType.gold,
    Duration duration = const Duration(seconds: 2),
    Offset? position,
  }) {
    // 移除之前的飘字
    _currentEntry?.remove();

    // 创建新的飘字
    _currentEntry = OverlayEntry(
      builder: (context) {
        final size = MediaQuery.of(context).size;
        final defaultPosition = Offset(
          size.width / 2,
          size.height / 2,
        );
        final actualPosition = position ?? defaultPosition;

        return Positioned(
          left: actualPosition.dx - 50, // 居中对齐
          top: actualPosition.dy,
          child: FloatingText(
            text: text,
            type: type,
            duration: duration,
            onComplete: () {
              _currentEntry?.remove();
              _currentEntry = null;
            },
          ),
        );
      },
    );

    // 添加到Overlay
    Overlay.of(context).insert(_currentEntry!);
  }

  /// 显示金币飘字
  static void showGold(
    BuildContext context, {
    required int amount,
    Offset? position,
  }) {
    show(
      context,
      text: '+$amount 💰',
      type: FloatingTextType.gold,
      position: position,
    );
  }

  /// 显示经验值飘字
  static void showExp(
    BuildContext context, {
    required int amount,
    Offset? position,
  }) {
    show(
      context,
      text: '+$amount ⭐',
      type: FloatingTextType.exp,
      position: position,
    );
  }

  /// 显示升级飘字
  static void showLevelUp(
    BuildContext context, {
    required int level,
    Offset? position,
  }) {
    show(
      context,
      text: 'LEVEL UP! $level',
      type: FloatingTextType.levelUp,
      duration: const Duration(seconds: 3),
      position: position,
    );
  }
}
