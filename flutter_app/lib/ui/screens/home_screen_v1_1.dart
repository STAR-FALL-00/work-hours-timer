import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../core/models/work_record.dart';
import '../../providers/providers.dart';
import '../../core/services/economy_service.dart';
import '../widgets/boss_health_bar.dart';
import 'settings_screen.dart';
import 'statistics_screen.dart';
import 'achievements_screen.dart';
import 'projects_screen.dart';
import 'shop_screen.dart';

enum WorkStatus { idle, working, onBreak }

/// v1.1.0 增强版主页
/// 集成了金币显示、项目选择、BOSS血条等新功能
class HomeScreenV11 extends ConsumerStatefulWidget {
  const HomeScreenV11({super.key});

  @override
  ConsumerState<HomeScreenV11> createState() => _HomeScreenV11State();
}

class _HomeScreenV11State extends ConsumerState<HomeScreenV11> {
  DateTime? _startTime;
  DateTime? _breakStartTime;
  Duration _totalBreakTime = Duration.zero;
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  WorkStatus _status = WorkStatus.idle;
  int _breakCount = 0;

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
        // 开始休息
        _breakStartTime = DateTime.now();
        _status = WorkStatus.onBreak;
        _breakCount++;
      } else if (_status == WorkStatus.onBreak) {
        // 结束休息
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

    // 如果当前在休息，先结束休息
    if (_breakStartTime != null) {
      _totalBreakTime += endTime.difference(_breakStartTime!);
    }

    // 计算实际工作时长（排除休息时间）
    final totalDuration = endTime.difference(_startTime!);
    final workDuration = totalDuration - _totalBreakTime;

    // 获取当前选择的项目
    final currentProjectId = ref.read(currentProjectIdProvider);

    // 使用 WorkSessionManager 结算奖励
    final sessionManager = ref.read(workSessionManagerProvider);
    final profile = ref.read(adventurerProfileProvider);

    try {
      final result = await sessionManager.endWorkSession(
        duration: workDuration,
        profile: profile,
        projectId: currentProjectId,
        breakCount: _breakCount,
      );

      // 更新冒险者资料
      ref
          .read(adventurerProfileProvider.notifier)
          .updateProfile(result.profile);

      // 如果有项目，刷新项目列表
      if (currentProjectId != null) {
        ref.read(allProjectsProvider.notifier).refresh();
      }

      // 保存工作记录
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
        // 显示奖励摘要
        _showRewardDialog(result.getSummary(), result.hasSpecialEvent);

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

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _getStatusText() {
    switch (_status) {
      case WorkStatus.idle:
        return '未开始工作';
      case WorkStatus.working:
        return '正在工作中...';
      case WorkStatus.onBreak:
        return '休息中...';
    }
  }

  Color _getStatusColor() {
    switch (_status) {
      case WorkStatus.idle:
        return Colors.grey;
      case WorkStatus.working:
        return Colors.green;
      case WorkStatus.onBreak:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(adventurerProfileProvider);
    final currentProjectId = ref.watch(currentProjectIdProvider);
    final currentProject = ref.watch(currentProjectProvider);
    final activeProjects = ref.watch(activeProjectsProvider);
    final now = DateTime.now();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        title:
            const Text('工时计时器', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: colorScheme.inversePrimary,
        actions: [
          // 金币显示
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.monetization_on,
                    color: Colors.amber, size: 20),
                const SizedBox(width: 4),
                Text(
                  EconomyService.formatGold(profile.gold),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_bag),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ShopScreen()),
              );
            },
            tooltip: '商店',
          ),
          IconButton(
            icon: const Icon(Icons.work),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProjectsScreen()),
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
                    builder: (context) => const AchievementsScreen()),
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
                    builder: (context) => const StatisticsScreen()),
              );
            },
            tooltip: '统计',
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            tooltip: '设置',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 项目选择卡片
              if (activeProjects.isNotEmpty) ...[
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.psychology, color: Colors.blue),
                            const SizedBox(width: 8),
                            const Text(
                              '当前项目',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String?>(
                          value: currentProjectId,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          hint: const Text('选择项目（可选）'),
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('无项目'),
                            ),
                            ...activeProjects.map((project) {
                              return DropdownMenuItem<String?>(
                                value: project.id,
                                child: Text(project.name),
                              );
                            }),
                          ],
                          onChanged: _status == WorkStatus.idle
                              ? (value) {
                                  ref
                                      .read(currentProjectIdProvider.notifier)
                                      .state = value;
                                }
                              : null,
                        ),
                        if (currentProject != null) ...[
                          const SizedBox(height: 12),
                          MiniBossHealthBar(project: currentProject),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 主计时器卡片
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getStatusColor().withOpacity(0.15),
                      _getStatusColor().withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: _getStatusColor().withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        // 状态指示器
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: _getStatusColor().withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _getStatusColor(),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                _getStatusText(),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: _getStatusColor(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 大号计时器显示
                        Text(
                          _formatDuration(_elapsed),
                          style: TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                            color: _getStatusColor(),
                            letterSpacing: 4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${now.year}年${now.month}月${now.day}日 ${_formatTime(now)}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // 控制按钮
                        if (_status == WorkStatus.idle)
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _startWork,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 2,
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.play_arrow, size: 28),
                                  SizedBox(width: 8),
                                  Text(
                                    '开始工作',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: _toggleBreak,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          _status == WorkStatus.working
                                              ? Colors.orange
                                              : Colors.green,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 2,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          _status == WorkStatus.working
                                              ? Icons.pause
                                              : Icons.play_arrow,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _status == WorkStatus.working
                                              ? '休息'
                                              : '继续',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: SizedBox(
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: _endWork,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 2,
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.stop, size: 24),
                                        SizedBox(width: 8),
                                        Text(
                                          '下班',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 实时奖励预览
              if (_status != WorkStatus.idle) ...[
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '预计奖励',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildRewardItem(
                              Icons.monetization_on,
                              Colors.amber,
                              '${_elapsed.inMinutes} 金币',
                            ),
                            _buildRewardItem(
                              Icons.star,
                              Colors.blue,
                              '${(_elapsed.inMinutes / 60 * 100).toInt()} 经验',
                            ),
                            if (_elapsed.inMinutes >= 60 && _breakCount == 0)
                              _buildRewardItem(
                                Icons.local_fire_department,
                                Colors.orange,
                                '连击 +50',
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRewardItem(IconData icon, Color color, String text) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
