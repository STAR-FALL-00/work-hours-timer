import 'package:flutter/material.dart';
import 'dart:math' as math;

/// 工作状态
enum WorkStatus { idle, working, onBreak }

/// 跑步角色组件
///
/// 根据工作进度和状态显示不同的角色动画
class RunnerCharacter extends StatefulWidget {
  final double progress; // 0.0 - 1.0
  final WorkStatus status;
  final double trackWidth;

  const RunnerCharacter({
    super.key,
    required this.progress,
    required this.status,
    required this.trackWidth,
  });

  @override
  State<RunnerCharacter> createState() => _RunnerCharacterState();
}

class _RunnerCharacterState extends State<RunnerCharacter>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  int _frameIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..addListener(() {
        if (_animationController.value >= 1.0) {
          setState(() {
            _frameIndex = (_frameIndex + 1) % _getFrameCount();
          });
          _animationController.reset();
          if (widget.status == WorkStatus.working) {
            _animationController.forward();
          }
        }
      });

    if (widget.status == WorkStatus.working) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(RunnerCharacter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.status != widget.status) {
      if (widget.status == WorkStatus.working) {
        _animationController.forward();
      } else {
        _animationController.stop();
        setState(() {
          _frameIndex = 0;
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  int _getFrameCount() {
    switch (widget.status) {
      case WorkStatus.working:
        return 2; // 两帧走路动画
      case WorkStatus.onBreak:
        return 1;
      case WorkStatus.idle:
        return 1;
    }
  }

  String _getCharacterEmoji() {
    switch (widget.status) {
      case WorkStatus.working:
        // 交替显示跑步动画
        return _frameIndex == 0 ? '🏃‍♂️' : '🏃';
      case WorkStatus.onBreak:
        return '🚶‍♂️'; // 慢走
      case WorkStatus.idle:
        return '🧍‍♂️'; // 站立
    }
  }

  @override
  Widget build(BuildContext context) {
    // 计算角色位置（留出边距）
    final leftPosition = math.max(
      0,
      math.min(
        widget.trackWidth - 40,
        widget.progress * (widget.trackWidth - 40),
      ),
    );

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      left: leftPosition.toDouble(),
      top: 0,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        child: Text(
          _getCharacterEmoji(),
          style: const TextStyle(
            fontSize: 32,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}
