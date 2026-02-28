import 'package:flutter/material.dart';

/// 时间背景组件
///
/// 根据当前时间显示不同的背景颜色
/// - 早晨 (6-9点): 清晨蓝
/// - 上午 (9-12点): 明亮黄
/// - 下午 (12-18点): 温暖橙
/// - 傍晚 (18-21点): 夕阳紫
/// - 夜晚 (21-6点): 深蓝黑
class TimeBackground extends StatelessWidget {
  final Widget child;
  final bool enabled;

  const TimeBackground({
    super.key,
    required this.child,
    this.enabled = true,
  });

  /// 获取当前时间段的背景颜色
  Color _getBackgroundColor() {
    if (!enabled) {
      return Colors.transparent;
    }

    final hour = DateTime.now().hour;

    if (hour >= 6 && hour < 9) {
      // 早晨：清晨蓝
      return const Color(0xFF87CEEB).withValues(alpha: 0.1);
    } else if (hour >= 9 && hour < 12) {
      // 上午：明亮黄
      return const Color(0xFFFFD700).withValues(alpha: 0.1);
    } else if (hour >= 12 && hour < 18) {
      // 下午：温暖橙
      return const Color(0xFFFFA500).withValues(alpha: 0.1);
    } else if (hour >= 18 && hour < 21) {
      // 傍晚：夕阳紫
      return const Color(0xFF9370DB).withValues(alpha: 0.1);
    } else {
      // 夜晚：深蓝黑
      return const Color(0xFF191970).withValues(alpha: 0.1);
    }
  }

  /// 获取时间段名称
  String _getTimePeriodName() {
    final hour = DateTime.now().hour;

    if (hour >= 6 && hour < 9) return '早晨';
    if (hour >= 9 && hour < 12) return '上午';
    if (hour >= 12 && hour < 18) return '下午';
    if (hour >= 18 && hour < 21) return '傍晚';
    return '夜晚';
  }

  /// 获取时间段图标
  String _getTimePeriodIcon() {
    final hour = DateTime.now().hour;

    if (hour >= 6 && hour < 9) return '🌅'; // 早晨
    if (hour >= 9 && hour < 12) return '☀️'; // 上午
    if (hour >= 12 && hour < 18) return '🌤️'; // 下午
    if (hour >= 18 && hour < 21) return '🌆'; // 傍晚
    return '🌙'; // 夜晚
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(seconds: 2),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
      ),
      child: child,
    );
  }

  /// 获取时间段信息（用于显示）
  static String getTimePeriodInfo() {
    final hour = DateTime.now().hour;
    String icon, name;

    if (hour >= 6 && hour < 9) {
      icon = '🌅';
      name = '早晨';
    } else if (hour >= 9 && hour < 12) {
      icon = '☀️';
      name = '上午';
    } else if (hour >= 12 && hour < 18) {
      icon = '🌤️';
      name = '下午';
    } else if (hour >= 18 && hour < 21) {
      icon = '🌆';
      name = '傍晚';
    } else {
      icon = '🌙';
      name = '夜晚';
    }

    return '$icon $name';
  }
}
