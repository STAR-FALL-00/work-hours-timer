import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// 里程碑类型
enum MilestoneType {
  lunch, // 午休
  tea, // 下午茶
  finish, // 下班
}

/// 里程碑数据
class MilestoneData {
  final MilestoneType type;
  final String emoji;
  final String label;
  final TimeOfDay time;
  final Color color;

  const MilestoneData({
    required this.type,
    required this.emoji,
    required this.label,
    required this.time,
    required this.color,
  });

  /// 预定义的里程碑
  static const List<MilestoneData> defaults = [
    MilestoneData(
      type: MilestoneType.lunch,
      emoji: '🍱',
      label: '午休',
      time: TimeOfDay(hour: 12, minute: 0),
      color: Colors.orange,
    ),
    MilestoneData(
      type: MilestoneType.tea,
      emoji: '☕',
      label: '下午茶',
      time: TimeOfDay(hour: 15, minute: 0),
      color: Colors.brown,
    ),
    MilestoneData(
      type: MilestoneType.finish,
      emoji: '🏡',
      label: '下班',
      time: TimeOfDay(hour: 18, minute: 0),
      color: AppColors.success,
    ),
  ];

  /// 计算里程碑在跑道上的位置（0.0 - 1.0）
  double getPosition({
    required TimeOfDay startTime,
    required Duration totalDuration,
  }) {
    // 计算从开始时间到里程碑时间的分钟数
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final milestoneMinutes = time.hour * 60 + time.minute;

    int diffMinutes = milestoneMinutes - startMinutes;

    // 处理跨天的情况
    if (diffMinutes < 0) {
      diffMinutes += 24 * 60;
    }

    // 计算位置比例
    final position = diffMinutes / totalDuration.inMinutes;

    // 限制在 0.0 - 1.0 范围内
    return position.clamp(0.0, 1.0);
  }

  /// 检查是否已到达里程碑
  bool isReached(Duration elapsed, TimeOfDay startTime) {
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final milestoneMinutes = time.hour * 60 + time.minute;
    final currentMinutes = startMinutes + elapsed.inMinutes;

    return currentMinutes >= milestoneMinutes;
  }

  /// 获取提示消息
  String getTipMessage() {
    switch (type) {
      case MilestoneType.lunch:
        return '该吃午饭啦！🍱';
      case MilestoneType.tea:
        return '喝杯咖啡休息一下~☕';
      case MilestoneType.finish:
        return '可以下班啦！🎉';
    }
  }
}

/// 里程碑标记组件
class MilestoneMarker extends StatelessWidget {
  final MilestoneData milestone;
  final double position; // 0.0 - 1.0
  final double trackWidth;
  final bool isReached;
  final VoidCallback? onTap;

  const MilestoneMarker({
    super.key,
    required this.milestone,
    required this.position,
    required this.trackWidth,
    required this.isReached,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final leftPosition = (trackWidth * position).clamp(0.0, trackWidth - 40);

    return Positioned(
      left: leftPosition,
      top: -15,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标记图标
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isReached
                    ? milestone.color.withValues(alpha: 0.2)
                    : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: milestone.color,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  milestone.emoji,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),

            const SizedBox(height: 4),

            // 标签
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: milestone.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: milestone.color.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                milestone.label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: brightness == Brightness.dark
                      ? milestone.color.withValues(alpha: 0.9)
                      : milestone.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 里程碑提示气泡
class MilestoneTip extends StatefulWidget {
  final MilestoneData milestone;
  final VoidCallback? onDismiss;

  const MilestoneTip({
    super.key,
    required this.milestone,
    this.onDismiss,
  });

  @override
  State<MilestoneTip> createState() => _MilestoneTipState();
}

class _MilestoneTipState extends State<MilestoneTip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    // 3秒后自动消失
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() async {
    await _controller.reverse();
    if (mounted) {
      widget.onDismiss?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: widget.milestone.color.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.milestone.color.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.milestone.emoji,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 8),
              Text(
                widget.milestone.getTipMessage(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _dismiss,
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
