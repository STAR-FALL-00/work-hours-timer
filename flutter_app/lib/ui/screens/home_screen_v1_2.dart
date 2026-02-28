import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../core/models/work_record.dart';
import '../../providers/providers.dart';
import '../widgets/modern_hud_widgets.dart';
import '../widgets/timer/runner_track.dart';
import '../widgets/timer/runner_character.dart';
import '../widgets/timer/time_background.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/modern_hud_theme.dart';
import 'settings_screen_v1_2.dart';
import 'statistics_screen_v1_2.dart';
import 'achievements_screen_v1_2.dart';
import 'projects_screen_v1_2.dart';
import 'shop_screen_v1_2.dart';
import 'floating_window_screen.dart';

// WorkStatus 已在 runner_character.dart 中定义
export '../widgets/timer/runner_character.dart' show WorkStatus;

/// v1.2.0 Modern HUD 风格主页
/// 使用新的 UI 组件库，提供更现代化的用户体验
class HomeScreenV12 extends ConsumerStatefulWidget {
  const HomeScreenV12({super.key});

  @override
  ConsumerState<HomeScreenV12> createState() => _HomeScreenV12State();
}

class _HomeScreenV12State extends ConsumerState<HomeScreenV12> {
  DateTime? _startTime;
  DateTime? _breakStartTime;
  Duration _totalBreakTime = Duration.zero;
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  WorkStatus _status = WorkStatus.idle;
  int _breakCount = 0;
  bool _useRunnerMode = true; // 是否使用跑酷模式

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startWork() async {
    setState(() {
      _startTime = DateTime.now();
      _breakStartTime = null;
      _totalBreakTime = Duration.zero;
      _elapsed = Duration.zero;
      _status = WorkStatus.working;
      _breakCount = 0;
    });

    // 播放开始工作音效
    final audioService = ref.read(audioServiceProvider);
    await audioService.playStartWork();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_startTime != null) {
        setState(() {
          final now = DateTime.now();
          _elapsed = now.difference(_startTime!);

          // 减去休息时间
          if (_breakStartTime != null) {
            _elapsed -= now.difference(_breakStartTime!);
          }
          _elapsed -= _totalBreakTime;
        });
      }
    });
  }

  void _toggleBreak() {
    setState(() {
      if (_status == WorkStatus.working) {
        _breakStartTime = DateTime.now();
        _status = WorkStatus.onBreak;
        _breakCount++;
      } else if (_status == WorkStatus.onBreak) {
        if (_breakStartTime != null) {
          _totalBreakTime += DateTime.now().difference(_breakStartTime!);
          _breakStartTime = null;
        }
        _status = WorkStatus.working;
      }
    });
  }

  void _endWork() async {
    if (_startTime == null) return;

    final endTime = DateTime.now();

    if (_breakStartTime != null) {
      _totalBreakTime += endTime.difference(_breakStartTime!);
    }

    final totalDuration = endTime.difference(_startTime!);
    final workDuration = totalDuration - _totalBreakTime;

    final currentProjectId = ref.read(currentProjectIdProvider);
    final sessionManager = ref.read(workSessionManagerProvider);
    final profile = ref.read(adventurerProfileProvider);

    try {
      final result = await sessionManager.endWorkSession(
        duration: workDuration,
        profile: profile,
        projectId: currentProjectId,
        breakCount: _breakCount,
      );

      ref
          .read(adventurerProfileProvider.notifier)
          .updateProfile(result.profile);

      if (currentProjectId != null) {
        ref.read(allProjectsProvider.notifier).refresh();
      }

      final record = WorkRecord.fromDuration(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        startTime: _startTime!,
        endTime: endTime,
        date: DateTime.now(),
        duration: workDuration,
        projectId: currentProjectId,
        goldEarned: result.goldEarned,
        expEarned: result.expEarned,
      );

      final calculator = ref.read(calculatorServiceProvider);
      await calculator.addWorkRecord(record);

      setState(() {
        _startTime = null;
        _breakStartTime = null;
        _totalBreakTime = Duration.zero;
        _elapsed = Duration.zero;
        _status = WorkStatus.idle;
        _breakCount = 0;
      });
      _timer?.cancel();

      if (mounted) {
        // 显示飘字动画
        _showRewardAnimations(result.goldEarned, result.expEarned);

        // 延迟显示对话框
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            _showRewardDialog(result.getSummary(), result.hasSpecialEvent);
          }
        });

        ref.invalidate(dailyWorkHoursProvider);
        ref.invalidate(todayRecordsProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败：$e')),
        );
      }
    }
  }

  void _showRewardAnimations(int gold, int exp) {
    // 显示金币飘字
    FloatingTextManager.showGold(context, amount: gold);

    // 延迟显示经验值飘字
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        FloatingTextManager.showExp(context, amount: exp);
      }
    });
  }

  void _showRewardDialog(String summary, bool hasSpecialEvent) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              hasSpecialEvent ? Icons.celebration : Icons.check_circle,
              color: hasSpecialEvent ? Colors.amber : Colors.green,
            ),
            const SizedBox(width: 8),
            const Text('工作完成！'),
          ],
        ),
        content: Text(summary),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showProjectSelector() {
    final activeProjects = ref.read(activeProjectsProvider);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(ModernHudTheme.spacingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '选择项目',
              style: AppTextStyles.headline3(Theme.of(context).brightness),
            ),
            const SizedBox(height: ModernHudTheme.spacingM),
            ListTile(
              leading: const Icon(Icons.clear),
              title: const Text('无项目'),
              onTap: () {
                ref.read(currentProjectIdProvider.notifier).state = null;
                Navigator.pop(context);
              },
            ),
            ...activeProjects.map((project) {
              return ListTile(
                leading: const Icon(Icons.assignment),
                title: Text(project.name),
                subtitle: Text('进度: ${(project.progress * 100).toInt()}%'),
                onTap: () {
                  ref.read(currentProjectIdProvider.notifier).state =
                      project.id;
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _getStatusText() {
    switch (_status) {
      case WorkStatus.idle:
        return '☕ 营地休息';
      case WorkStatus.working:
        return '🟢 战斗中';
      case WorkStatus.onBreak:
        return '⏸️ 暂停休息';
    }
  }

  int _getPredictedGold() {
    return _elapsed.inMinutes;
  }

  int _getPredictedExp() {
    return (_elapsed.inMinutes / 60 * 100).toInt();
  }

  String? _getComboHint() {
    if (_status != WorkStatus.working) return null;
    if (_breakCount > 0) return null;

    final minutes = _elapsed.inMinutes;
    if (minutes >= 60) {
      return '🔥 连击奖励已激活！+50金币';
    } else if (minutes >= 45) {
      return '还差 ${60 - minutes} 分钟触发连击奖励';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(adventurerProfileProvider);
    final currentProject = ref.watch(currentProjectProvider);
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      backgroundColor: AppColors.getBackground(brightness),
      appBar: AppBar(
        elevation: 0,
        title: Text(
          '工时计时器',
          style: AppTextStyles.headline3(brightness),
        ),
        backgroundColor: AppColors.getPrimary(brightness),
        foregroundColor: Colors.white,
        actions: [
          // 计时器模式切换按钮
          IconButton(
            icon: Icon(_useRunnerMode ? Icons.timer : Icons.directions_run),
            onPressed: () {
              setState(() {
                _useRunnerMode = !_useRunnerMode;
              });
            },
            tooltip: _useRunnerMode ? '切换到传统模式' : '切换到跑酷模式',
          ),
          // 悬浮窗切换按钮
          IconButton(
            icon: const Icon(Icons.picture_in_picture_alt_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const FloatingWindowScreen()),
              );
            },
            tooltip: '悬浮窗模式',
          ),
          IconButton(
            icon: const Icon(Icons.shopping_bag),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ShopScreenV12()),
              );
            },
            tooltip: '商店',
          ),
          IconButton(
            icon: const Icon(Icons.work),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ProjectsScreenV12()),
              );
            },
            tooltip: '项目管理',
          ),
          IconButton(
            icon: const Icon(Icons.emoji_events_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AchievementsScreenV12()),
              );
            },
            tooltip: '成就',
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const StatisticsScreenV12()),
              );
            },
            tooltip: '统计',
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const SettingsScreenV12()),
              );
            },
            tooltip: '设置',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: TimeBackground(
        enabled: _useRunnerMode,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(ModernHudTheme.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 顶部状态栏：用户信息 + 资源胶囊
                _buildTopStatusBar(profile, brightness),

                const SizedBox(height: ModernHudTheme.spacingL),

                // 中央区域：跑酷模式或任务卡片
                if (_useRunnerMode)
                  _buildRunnerMode(currentProject, brightness)
                else
                  _buildTraditionalMode(currentProject, brightness),

                const SizedBox(height: ModernHudTheme.spacingL),

                // 底部操作栏
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopStatusBar(profile, Brightness brightness) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        children: [
          // 用户头像 + 等级
          Container(
            padding: const EdgeInsets.all(ModernHudTheme.spacingM),
            decoration: BoxDecoration(
              color: AppColors.getPrimary(brightness).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.getPrimary(brightness),
                  child: Text(
                    'Lv',
                    style: AppTextStyles.labelSmall(brightness).copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: ModernHudTheme.spacingS),
                Text(
                  '${profile.level}',
                  style: AppTextStyles.levelNumber(brightness),
                ),
              ],
            ),
          ),

          const SizedBox(width: ModernHudTheme.spacingM),

          // 资源胶囊：金币
          Expanded(
            child: ResourceCapsule(
              type: ResourceType.gold,
              current: profile.gold,
            ),
          ),

          const SizedBox(width: ModernHudTheme.spacingS),

          // 资源胶囊：经验值
          Expanded(
            child: ResourceCapsule(
              type: ResourceType.exp,
              current: profile.experience,
              max: profile.level * 100,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建跑酷模式
  Widget _buildRunnerMode(currentProject, Brightness brightness) {
    final settings = ref.watch(workSettingsProvider);
    final standardHours = Duration(hours: settings.standardWorkHours);

    return Column(
      children: [
        // 时间段提示
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: ModernHudTheme.spacingM,
            vertical: ModernHudTheme.spacingS,
          ),
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                TimeBackground.getTimePeriodInfo(),
                style: AppTextStyles.labelMedium(brightness),
              ),
              if (_status == WorkStatus.working) ...[
                const SizedBox(width: ModernHudTheme.spacingS),
                Text(
                  '• ${_getStatusText()}',
                  style: AppTextStyles.labelMedium(brightness).copyWith(
                    color: AppColors.success,
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: ModernHudTheme.spacingL),

        // 跑道组件
        RunnerTrack(
          elapsed: _elapsed,
          total: standardHours,
          status: _status,
          startTime: _startTime,
        ),

        const SizedBox(height: ModernHudTheme.spacingL),

        // 项目信息（如果有）
        if (currentProject != null)
          Container(
            padding: const EdgeInsets.all(ModernHudTheme.spacingM),
            decoration: BoxDecoration(
              color: AppColors.getCardBackground(brightness),
              borderRadius: ModernHudTheme.cardBorderRadius,
              border: Border.all(
                color: AppColors.getPrimary(brightness).withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.assignment, size: 20),
                const SizedBox(width: ModernHudTheme.spacingS),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentProject.name,
                        style: AppTextStyles.labelLarge(brightness),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '进度: ${currentProject.actualHours.toStringAsFixed(1)}h / ${currentProject.estimatedHours.toStringAsFixed(1)}h',
                        style: AppTextStyles.bodySmall(brightness),
                      ),
                    ],
                  ),
                ),
                if (_status == WorkStatus.idle)
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: _showProjectSelector,
                    tooltip: '选择项目',
                  ),
              ],
            ),
          ),

        // 预测奖励（工作中显示）
        if (_status != WorkStatus.idle) ...[
          const SizedBox(height: ModernHudTheme.spacingM),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(ModernHudTheme.spacingM),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.accent.withValues(alpha: 0.2),
                        AppColors.accent.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.monetization_on,
                          color: AppColors.accent, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '+${_getPredictedGold()}',
                        style: AppTextStyles.goldAmount(brightness),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: ModernHudTheme.spacingM),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(ModernHudTheme.spacingM),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.expBar.withValues(alpha: 0.2),
                        AppColors.expBar.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: AppColors.expBar, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '+${_getPredictedExp()}',
                        style: AppTextStyles.expAmount(brightness),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],

        // 连击提示
        if (_getComboHint() != null) ...[
          const SizedBox(height: ModernHudTheme.spacingM),
          Container(
            padding: const EdgeInsets.all(ModernHudTheme.spacingM),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.orange.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_fire_department,
                    color: Colors.orange, size: 20),
                const SizedBox(width: ModernHudTheme.spacingS),
                Expanded(
                  child: Text(
                    _getComboHint()!,
                    style: AppTextStyles.bodySmall(brightness),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// 构建传统模式
  Widget _buildTraditionalMode(currentProject, Brightness brightness) {
    return MissionCard(
      projectName: currentProject?.name,
      bossProgress: currentProject?.progress,
      bossProgressText: currentProject != null
          ? '${currentProject.actualHours.toStringAsFixed(1)}h / ${currentProject.estimatedHours.toStringAsFixed(1)}h'
          : null,
      timerText: _formatDuration(_elapsed),
      isWorking: _status == WorkStatus.working,
      statusText: _getStatusText(),
      predictedGold: _status != WorkStatus.idle ? _getPredictedGold() : null,
      predictedExp: _status != WorkStatus.idle ? _getPredictedExp() : null,
      comboHint: _getComboHint(),
      onProjectTap: _status == WorkStatus.idle ? _showProjectSelector : null,
    );
  }

  Widget _buildActionButtons() {
    if (_status == WorkStatus.idle) {
      // 空闲状态：只显示开始按钮
      return ActionButton(
        text: '开始工作',
        icon: Icons.play_arrow_rounded,
        type: ActionButtonType.primary,
        onPressed: _startWork,
      );
    } else {
      // 工作/休息状态：显示暂停和结束按钮
      return Row(
        children: [
          Expanded(
            flex: 3,
            child: ActionButton(
              text: _status == WorkStatus.working ? '暂停' : '继续',
              icon: _status == WorkStatus.working
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
              type: _status == WorkStatus.working
                  ? ActionButtonType.rest
                  : ActionButtonType.primary,
              onPressed: _toggleBreak,
            ),
          ),
          const SizedBox(width: ModernHudTheme.spacingM),
          Expanded(
            flex: 7,
            child: ActionButton(
              text: '结束战斗',
              icon: Icons.stop_rounded,
              type: ActionButtonType.combat,
              onPressed: _endWork,
            ),
          ),
        ],
      );
    }
  }
}
