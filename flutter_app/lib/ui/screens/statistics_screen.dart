import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/providers.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}小时${minutes}分钟';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        title:
            const Text('工时统计', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.tab,
          labelStyle:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          unselectedLabelStyle:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
          tabs: const [
            Tab(text: '本周'),
            Tab(text: '本月'),
            Tab(text: '本年'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWeeklyStats(),
          _buildMonthlyStats(),
          _buildYearlyStats(),
        ],
      ),
    );
  }

  Widget _buildWeeklyStats() {
    final now = DateTime.now();
    // Calculate Monday of current week and normalize to midnight
    final weekStart = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));

    return ref.watch(weeklyStatsProvider(weekStart)).when(
          data: (stats) => SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCard(
                  '本周总工时',
                  stats.totalHours,
                  Icons.access_time,
                  Colors.blue,
                ),
                const SizedBox(height: 16),
                _buildWeeklyChart(stats.dailyHours),
                const SizedBox(height: 16),
                _buildDailyList(stats.dailyHours),
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('错误: $error')),
        );
  }

  Widget _buildMonthlyStats() {
    final now = DateTime.now();
    // 标准化为当月第一天
    final monthStart = DateTime(now.year, now.month, 1);

    return ref.watch(monthlyStatsProvider(monthStart)).when(
          data: (stats) => SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        '本月总工时',
                        stats.totalHours,
                        Icons.calendar_month,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSummaryCard(
                        '工作天数',
                        Duration(hours: stats.workDays),
                        Icons.event_available,
                        Colors.orange,
                        suffix: '天',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildMonthlyChart(stats.weeklyHours),
                const SizedBox(height: 16),
                _buildWeeklyList(stats.weeklyHours),
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('错误: $error')),
        );
  }

  Widget _buildYearlyStats() {
    final now = DateTime.now();

    return ref.watch(yearlyStatsProvider(now.year)).when(
          data: (stats) => SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        '全年总工时',
                        stats.totalHours,
                        Icons.calendar_today,
                        Colors.purple,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSummaryCard(
                        '工作天数',
                        Duration(hours: stats.workDays),
                        Icons.event,
                        Colors.teal,
                        suffix: '天',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildYearlyChart(stats.monthlyHours),
                const SizedBox(height: 16),
                _buildMonthlyList(stats.monthlyHours),
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('错误: $error')),
        );
  }

  Widget _buildSummaryCard(
    String title,
    Duration duration,
    IconData icon,
    Color color, {
    String? suffix,
  }) {
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
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              suffix != null
                  ? '${duration.inHours}$suffix'
                  : _formatDuration(duration),
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

  Widget _buildWeeklyChart(Map<DateTime, Duration> dailyHours) {
    if (dailyHours.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.show_chart_rounded,
                    size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  '暂无数据',
                  style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final spots = dailyHours.entries.map((entry) {
      return FlSpot(
        entry.key.weekday.toDouble(),
        entry.value.inHours.toDouble(),
      );
    }).toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.show_chart_rounded,
                      color: Colors.blue, size: 20),
                ),
                const SizedBox(width: 10),
                const Text(
                  '每日工时趋势',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = [
                            '',
                            '周一',
                            '周二',
                            '周三',
                            '周四',
                            '周五',
                            '周六',
                            '周日'
                          ];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              days[value.toInt()],
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}h',
                              style: const TextStyle(fontSize: 11));
                        },
                        reservedSize: 40,
                      ),
                    ),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(
                      show: true, border: Border.all(color: Colors.grey[300]!)),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 4,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyChart(Map<int, Duration> weeklyHours) {
    if (weeklyHours.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: Text('暂无数据')),
        ),
      );
    }

    final barGroups = weeklyHours.entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value.inHours.toDouble(),
            color: Colors.green,
            width: 20,
          ),
        ],
      );
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '每周工时统计',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('第${value.toInt()}周');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}h');
                        },
                        reservedSize: 40,
                      ),
                    ),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  barGroups: barGroups,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYearlyChart(Map<int, Duration> monthlyHours) {
    if (monthlyHours.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: Text('暂无数据')),
        ),
      );
    }

    final barGroups = monthlyHours.entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value.inHours.toDouble(),
            color: Colors.purple,
            width: 16,
          ),
        ],
      );
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '每月工时统计',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}月');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}h');
                        },
                        reservedSize: 40,
                      ),
                    ),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  barGroups: barGroups,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyList(Map<DateTime, Duration> dailyHours) {
    if (dailyHours.isEmpty) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '详细数据',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...dailyHours.entries.map((entry) {
              return ListTile(
                leading: Icon(Icons.calendar_today, color: Colors.blue),
                title: Text('${entry.key.month}月${entry.key.day}日'),
                trailing: Text(
                  _formatDuration(entry.value),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyList(Map<int, Duration> weeklyHours) {
    if (weeklyHours.isEmpty) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '详细数据',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...weeklyHours.entries.map((entry) {
              return ListTile(
                leading: Icon(Icons.date_range, color: Colors.green),
                title: Text('第${entry.key}周'),
                trailing: Text(
                  _formatDuration(entry.value),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyList(Map<int, Duration> monthlyHours) {
    if (monthlyHours.isEmpty) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '详细数据',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...monthlyHours.entries.map((entry) {
              return ListTile(
                leading: Icon(Icons.calendar_month, color: Colors.purple),
                title: Text('${entry.key}月'),
                trailing: Text(
                  _formatDuration(entry.value),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
