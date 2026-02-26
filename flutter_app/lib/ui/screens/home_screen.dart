import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../core/models/work_record.dart';
import '../../providers/providers.dart';
import 'settings_screen.dart';
import 'statistics_screen.dart';
import 'achievements_screen.dart';

enum WorkStatus { idle, working, onBreak }

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  DateTime? _startTime;
  DateTime? _breakStartTime;
  Duration _totalBreakTime = Duration.zero;
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  WorkStatus _status = WorkStatus.idle;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startWork() {
    setState(() {
      _startTime = DateTime.now();
      _breakStartTime = null;
      _totalBreakTime = Duration.zero;
      _elapsed = Duration.zero;
      _status = WorkStatus.working;
    });

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

    final record = WorkRecord.fromDuration(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startTime: _startTime!,
      endTime: endTime,
      date: DateTime.now(),
      duration: workDuration,
    );

    final calculator = ref.read(calculatorServiceProvider);
    await calculator.addWorkRecord(record);

    setState(() {
      _startTime = null;
      _breakStartTime = null;
      _totalBreakTime = Duration.zero;
      _elapsed = Duration.zero;
      _status = WorkStatus.idle;
    });
    _timer?.cancel();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('工作记录已保存')),
      );
      ref.invalidate(dailyWorkHoursProvider);
      ref.invalidate(todayRecordsProvider);
    }
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
    final todayRecords = ref.watch(todayRecordsProvider);
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
              // 主计时器卡片 - 更大更突出
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getStatusColor().withValues(alpha: 0.15),
                      _getStatusColor().withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: _getStatusColor().withValues(alpha: 0.2),
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
                            color: _getStatusColor().withValues(alpha: 0.15),
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

                        // 控制按钮 - 更大更圆润
                        if (_status == WorkStatus.idle)
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _startWork,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                elevation: 4,
                                shadowColor:
                                    Colors.green.withValues(alpha: 0.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.play_arrow_rounded, size: 28),
                                  SizedBox(width: 12),
                                  Text('开始工作',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                        if (_status != WorkStatus.idle)
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
                                      elevation: 4,
                                      shadowColor:
                                          (_status == WorkStatus.working
                                                  ? Colors.orange
                                                  : Colors.green)
                                              .withValues(alpha: 0.5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          _status == WorkStatus.working
                                              ? Icons.pause_rounded
                                              : Icons.play_arrow_rounded,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _status == WorkStatus.working
                                              ? '休息'
                                              : '继续',
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600),
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
                                      elevation: 4,
                                      shadowColor:
                                          Colors.red.withValues(alpha: 0.5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.stop_rounded, size: 24),
                                        SizedBox(width: 8),
                                        Text('下班',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600)),
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
              const SizedBox(height: 24),

              // 今日统计 - 网格布局
              todayRecords.when(
                data: (records) {
                  final settings = ref.watch(workSettingsProvider);
                  final totalDuration = records.fold<Duration>(
                    Duration.zero,
                    (sum, record) => sum + record.duration,
                  );
                  final standardHours =
                      Duration(hours: settings.standardWorkHours);
                  final remaining = standardHours - totalDuration;
                  final overtime = totalDuration > standardHours
                      ? totalDuration - standardHours
                      : Duration.zero;

                  DateTime? expectedEndTime;
                  Duration? timeUntilEnd;
                  if (_startTime != null && _status != WorkStatus.idle) {
                    expectedEndTime =
                        settings.calculateExpectedEndTime(_startTime!);
                    if (expectedEndTime != null) {
                      timeUntilEnd = expectedEndTime.difference(DateTime.now());
                    }
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 12),
                        child: Text(
                          '今日统计',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              '已工作',
                              _formatDuration(totalDuration),
                              Icons.work_rounded,
                              Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              remaining.isNegative ? '已超时' : '剩余',
                              _formatDuration(remaining.isNegative
                                  ? Duration.zero
                                  : remaining),
                              remaining.isNegative
                                  ? Icons.warning_rounded
                                  : Icons.schedule_rounded,
                              remaining.isNegative ? Colors.red : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      if (timeUntilEnd != null && !timeUntilEnd.isNegative) ...[
                        const SizedBox(height: 12),
                        _buildStatCard(
                          '距离下班',
                          _formatDuration(timeUntilEnd),
                          Icons.home_rounded,
                          Colors.green,
                          fullWidth: true,
                        ),
                      ],
                      if (overtime > Duration.zero) ...[
                        const SizedBox(height: 12),
                        _buildStatCard(
                          '加班时长',
                          _formatDuration(overtime),
                          Icons.access_time_filled_rounded,
                          Colors.red,
                          fullWidth: true,
                        ),
                      ],
                      // 薪资统计
                      if (settings.monthlySalary != null) ...[
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 12),
                          child: Row(
                            children: [
                              Icon(Icons.monetization_on_rounded,
                                  size: 20, color: Colors.grey[700]),
                              const SizedBox(width: 8),
                              Text(
                                '今日收入',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '本月${settings.currentMonthWorkdays}个工作日',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue[700],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: _buildSalaryCard(
                                '日薪',
                                settings.dailySalary!,
                                Icons.calendar_today_rounded,
                                Colors.purple,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildSalaryCard(
                                '时薪',
                                settings.hourlySalary!,
                                Icons.access_time_rounded,
                                Colors.teal,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildEarningsCard(
                          '今日已赚',
                          totalDuration,
                          settings.hourlySalary!,
                          Colors.green,
                        ),
                      ],
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Text('错误: $error'),
              ),
              const SizedBox(height: 24),

              // 今日记录
              Card(
                elevation: 2,
                shadowColor: Colors.black.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.history_rounded,
                              size: 24, color: Colors.grey[700]),
                          const SizedBox(width: 10),
                          Text(
                            '今日记录',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      todayRecords.when(
                        data: (records) {
                          if (records.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Column(
                                  children: [
                                    Icon(Icons.inbox_rounded,
                                        size: 64, color: Colors.grey[300]),
                                    const SizedBox(height: 16),
                                    Text(
                                      '暂无记录',
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          return Column(
                            children: records.map((record) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.blue.withValues(alpha: 0.05),
                                      Colors.blue.withValues(alpha: 0.02)
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color:
                                          Colors.blue.withValues(alpha: 0.1)),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.blue.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                          Icons.access_time_rounded,
                                          color: Colors.blue,
                                          size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        '${_formatTime(record.startTime)} - ${_formatTime(record.endTime)}',
                                        style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        _formatDuration(record.duration),
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'monospace',
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        },
                        loading: () => const Center(
                            child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator())),
                        error: (error, stack) => Text('错误: $error'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color,
      {bool fullWidth = false}) {
    return Card(
      elevation: 2,
      shadowColor: color.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.1),
              color.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildSalaryCard(
    String label, double amount, IconData icon, Color color) {
  return Card(
    elevation: 2,
    shadowColor: color.withValues(alpha: 0.2),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.1),
            color.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '¥${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildEarningsCard(
    String label, Duration workedDuration, double hourlySalary, Color color) {
  final workedHours = workedDuration.inMinutes / 60.0;
  final earnings = workedHours * hourlySalary;

  return Card(
    elevation: 2,
    shadowColor: color.withValues(alpha: 0.2),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.1),
            color.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.account_balance_wallet_rounded,
                color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '¥${earnings.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${workedHours.toStringAsFixed(1)}h',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
