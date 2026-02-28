import 'package:flutter/material.dart';
import 'runner_character.dart';
import 'milestone.dart';
import '../../theme/app_colors.dart';
import '../../theme/modern_hud_theme.dart';

/// 跑道组件
///
/// 显示工作进度的横版跑道，包含：
/// - 起点和终点标记
/// - 进度条
/// - 跑步角色
/// - 里程碑标记
class RunnerTrack extends StatefulWidget {
  final Duration elapsed;
  final Duration total;
  final WorkStatus status;
  final DateTime? startTime;

  const RunnerTrack({
    super.key,
    required this.elapsed,
    required this.total,
    required this.status,
    this.startTime,
  });

  @override
  State<RunnerTrack> createState() => _RunnerTrackState();
}

class _RunnerTrackState extends State<RunnerTrack> {
  MilestoneData? _reachedMilestone;
  final Set<MilestoneType> _shownTips = {};

  @override
  void didUpdateWidget(RunnerTrack oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 检查是否到达新的里程碑
    if (widget.startTime != null && widget.status == WorkStatus.working) {
      _checkMilestones();
    }
  }

  void _checkMilestones() {
    final startTime = widget.startTime;
    if (startTime == null) return;

    final currentTime = TimeOfDay.fromDateTime(startTime.add(widget.elapsed));

    for (final milestone in MilestoneData.defaults) {
      // 检查是否刚到达这个里程碑
      if (!_shownTips.contains(milestone.type)) {
        final milestoneMinutes =
            milestone.time.hour * 60 + milestone.time.minute;
        final currentMinutes = currentTime.hour * 60 + currentTime.minute;

        // 允许5分钟的误差范围
        if ((currentMinutes - milestoneMinutes).abs() <= 5) {
          setState(() {
            _reachedMilestone = milestone;
            _shownTips.add(milestone.type);
          });
          break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final progress = widget.total.inSeconds > 0
        ? (widget.elapsed.inSeconds / widget.total.inSeconds).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ModernHudTheme.spacingL,
        vertical: ModernHudTheme.spacingM,
      ),
      child: Column(
        children: [
          // 里程碑提示气泡
          if (_reachedMilestone != null)
            Padding(
              padding: const EdgeInsets.only(bottom: ModernHudTheme.spacingM),
              child: MilestoneTip(
                milestone: _reachedMilestone!,
                onDismiss: () {
                  setState(() {
                    _reachedMilestone = null;
                  });
                },
              ),
            ),

          // 跑道主体
          SizedBox(
            height: 80, // 增加高度以容纳里程碑
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // 背景跑道
                    Positioned(
                      top: 20,
                      left: 0,
                      right: 0,
                      child: _buildTrackBackground(brightness),
                    ),
                    // 进度填充
                    Positioned(
                      top: 20,
                      left: 0,
                      right: 0,
                      child: _buildProgressFill(brightness, progress),
                    ),
                    // 起点标记
                    Positioned(
                      top: 10,
                      left: -20,
                      child: _buildStartMarker(),
                    ),
                    // 终点标记
                    Positioned(
                      top: 10,
                      right: -20,
                      child: _buildEndMarker(),
                    ),
                    // 里程碑标记
                    if (widget.startTime != null)
                      ..._buildMilestones(
                        constraints.maxWidth,
                        TimeOfDay.fromDateTime(widget.startTime!),
                      ),
                    // 跑步角色
                    Positioned(
                      top: 20,
                      left: 0,
                      right: 0,
                      child: RunnerCharacter(
                        progress: progress,
                        status: widget.status,
                        trackWidth: constraints.maxWidth,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: ModernHudTheme.spacingM),

          // 时间信息
          _buildTimeInfo(brightness),
        ],
      ),
    );
  }

  /// 构建里程碑标记列表
  List<Widget> _buildMilestones(double trackWidth, TimeOfDay startTime) {
    return MilestoneData.defaults.map((milestone) {
      final position = milestone.getPosition(
        startTime: startTime,
        totalDuration: widget.total,
      );

      // 只显示在合理范围内的里程碑（0.1 - 0.9）
      if (position < 0.1 || position > 0.9) {
        return const SizedBox.shrink();
      }

      final isReached = milestone.isReached(widget.elapsed, startTime);

      return MilestoneMarker(
        milestone: milestone,
        position: position,
        trackWidth: trackWidth,
        isReached: isReached,
        onTap: () {
          // 点击里程碑显示提示
          if (isReached) {
            setState(() {
              _reachedMilestone = milestone;
            });
          }
        },
      );
    }).toList();
  }

  /// 构建跑道背景
  Widget _buildTrackBackground(Brightness brightness) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color:
            brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[200],
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: brightness == Brightness.dark
              ? Colors.grey[700]!
              : Colors.grey[400]!,
          width: 2,
        ),
      ),
    );
  }

  /// 构建进度填充
  Widget _buildProgressFill(Brightness brightness, double progress) {
    return SizedBox(
      height: 60,
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.success,
                AppColors.success.withValues(alpha: 0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppColors.success.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建起点标记
  Widget _buildStartMarker() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Text(
        '🏠',
        style: TextStyle(fontSize: 24),
      ),
    );
  }

  /// 构建终点标记
  Widget _buildEndMarker() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Text(
        '🏡',
        style: TextStyle(fontSize: 24),
      ),
    );
  }

  /// 构建时间信息
  Widget _buildTimeInfo(Brightness brightness) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '已工作: ${_formatDuration(widget.elapsed)}',
          style: TextStyle(
            fontSize: 14,
            color: brightness == Brightness.dark
                ? Colors.grey[400]
                : Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          '目标: ${_formatDuration(widget.total)}',
          style: TextStyle(
            fontSize: 14,
            color: brightness == Brightness.dark
                ? Colors.grey[400]
                : Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// 格式化时长
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }
}
