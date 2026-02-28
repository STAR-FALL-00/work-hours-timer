import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/providers.dart';
import '../widgets/modern_hud_widgets.dart';
import '../widgets/work_heatmap.dart';
import '../widgets/dialogs/export_dialog.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/modern_hud_theme.dart';

/// v1.2.0 Modern HUD 风格统计页面
/// 使用 KpiCard 组件展示关键指标
class StatisticsScreenV12 extends ConsumerStatefulWidget {
  const StatisticsScreenV12({super.key});

  @override
  ConsumerState<StatisticsScreenV12> createState() =>
      _StatisticsScreenV12State();
}

class _StatisticsScreenV12State extends ConsumerState<StatisticsScreenV12> {
  String _selectedPeriod = 'week';

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      backgroundColor: AppColors.getBackground(brightness),
      appBar: AppBar(
        elevation: 0,
        title: Text(
          '工时统计',
          style: AppTextStyles.headline3(brightness),
        ),
        backgroundColor: AppColors.getPrimary(brightness),
        foregroundColor: Colors.white,
        actions: [
          // 导出按钮
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            onPressed: () => _showExportDialog(context),
            tooltip: '导出数据',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // 周期选择器
          _buildPeriodSelector(brightness),

          // 内容区域
          Expanded(
            child: _buildContent(brightness),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(Brightness brightness) {
    final periods = [
      {'id': 'week', 'name': '本周', 'icon': Icons.view_week},
      {'id': 'month', 'name': '本月', 'icon': Icons.calendar_month},
      {'id': 'year', 'name': '本年', 'icon': Icons.calendar_today},
      {'id': 'heatmap', 'name': '热力图', 'icon': Icons.grid_on},
    ];

    return Container(
      padding: const EdgeInsets.all(ModernHudTheme.spacingM),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(brightness),
        boxShadow: [
          BoxShadow(
            color: AppColors.getShadow(brightness).withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: periods.map((period) {
          final isSelected = _selectedPeriod == period['id'];
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _buildPeriodChip(
                period['name'] as String,
                period['icon'] as IconData,
                isSelected,
                () => setState(() => _selectedPeriod = period['id'] as String),
                brightness,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPeriodChip(
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
    Brightness brightness,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          vertical: ModernHudTheme.spacingS,
        ),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.getPrimaryGradient() : null,
          color: isSelected
              ? null
              : AppColors.getPrimary(brightness).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : AppColors.getPrimary(brightness).withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color:
                  isSelected ? Colors.white : AppColors.getPrimary(brightness),
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.labelSmall(brightness).copyWith(
                color: isSelected
                    ? Colors.white
                    : AppColors.getPrimary(brightness),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(Brightness brightness) {
    switch (_selectedPeriod) {
      case 'week':
        return _buildWeeklyStats(brightness);
      case 'month':
        return _buildMonthlyStats(brightness);
      case 'year':
        return _buildYearlyStats(brightness);
      case 'heatmap':
        return _buildHeatmapView(brightness);
      default:
        return _buildWeeklyStats(brightness);
    }
  }

  Widget _buildWeeklyStats(Brightness brightness) {
    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));

    return ref.watch(weeklyStatsProvider(weekStart)).when(
          data: (stats) => SingleChildScrollView(
            padding: const EdgeInsets.all(ModernHudTheme.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // KPI 指标行
                Row(
                  children: [
                    Expanded(
                      child: KpiCard(
                        icon: Icons.access_time,
                        label: '总工时',
                        value: _formatHours(stats.totalHours),
                        accentColor: AppColors.primaryLight,
                      ),
                    ),
                    const SizedBox(width: ModernHudTheme.spacingM),
                    Expanded(
                      child: KpiCard(
                        icon: Icons.event_available,
                        label: '工作天数',
                        value: '${stats.dailyHours.length}',
                        subtitle: '天',
                        accentColor: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: ModernHudTheme.spacingM),
                    Expanded(
                      child: KpiCard(
                        icon: Icons.trending_up,
                        label: '日均工时',
                        value: _formatAverage(
                            stats.totalHours, stats.dailyHours.length),
                        accentColor: AppColors.accent,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: ModernHudTheme.spacingL),

                // 趋势图
                _buildWeeklyChart(stats.dailyHours, brightness),
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildErrorState(brightness),
        );
  }

  Widget _buildMonthlyStats(Brightness brightness) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);

    return ref.watch(monthlyStatsProvider(monthStart)).when(
          data: (stats) => SingleChildScrollView(
            padding: const EdgeInsets.all(ModernHudTheme.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // KPI 指标行
                Row(
                  children: [
                    Expanded(
                      child: KpiCard(
                        icon: Icons.calendar_month,
                        label: '总工时',
                        value: _formatHours(stats.totalHours),
                        accentColor: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: ModernHudTheme.spacingM),
                    Expanded(
                      child: KpiCard(
                        icon: Icons.event,
                        label: '工作天数',
                        value: '${stats.workDays}',
                        subtitle: '天',
                        accentColor: AppColors.accent,
                      ),
                    ),
                    const SizedBox(width: ModernHudTheme.spacingM),
                    Expanded(
                      child: KpiCard(
                        icon: Icons.show_chart,
                        label: '周均工时',
                        value: _formatAverage(
                            stats.totalHours, stats.weeklyHours.length),
                        accentColor: AppColors.info,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: ModernHudTheme.spacingL),

                // 周统计图
                _buildMonthlyChart(stats.weeklyHours, brightness),
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildErrorState(brightness),
        );
  }

  Widget _buildYearlyStats(Brightness brightness) {
    final now = DateTime.now();

    return ref.watch(yearlyStatsProvider(now.year)).when(
          data: (stats) => SingleChildScrollView(
            padding: const EdgeInsets.all(ModernHudTheme.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // KPI 指标行
                Row(
                  children: [
                    Expanded(
                      child: KpiCard(
                        icon: Icons.calendar_today,
                        label: '全年总工时',
                        value: _formatHours(stats.totalHours),
                        accentColor: AppColors.expBar,
                      ),
                    ),
                    const SizedBox(width: ModernHudTheme.spacingM),
                    Expanded(
                      child: KpiCard(
                        icon: Icons.event_available,
                        label: '工作天数',
                        value: '${stats.workDays}',
                        subtitle: '天',
                        accentColor: AppColors.rest,
                      ),
                    ),
                    const SizedBox(width: ModernHudTheme.spacingM),
                    Expanded(
                      child: KpiCard(
                        icon: Icons.analytics,
                        label: '月均工时',
                        value: _formatAverage(
                            stats.totalHours, stats.monthlyHours.length),
                        accentColor: AppColors.combat,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: ModernHudTheme.spacingL),

                // 月统计图
                _buildYearlyChart(stats.monthlyHours, brightness),
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildErrorState(brightness),
        );
  }

  Widget _buildHeatmapView(Brightness brightness) {
    return ref.watch(heatmapDataProvider).when(
          data: (heatmapData) => SingleChildScrollView(
            padding: const EdgeInsets.all(ModernHudTheme.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // KPI 指标行
                Row(
                  children: [
                    Expanded(
                      child: KpiCard(
                        icon: Icons.calendar_view_month,
                        label: '过去一年',
                        value: _formatHours(
                          heatmapData.values.fold<Duration>(
                            Duration.zero,
                            (sum, duration) => sum + duration,
                          ),
                        ),
                        accentColor: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: ModernHudTheme.spacingM),
                    Expanded(
                      child: KpiCard(
                        icon: Icons.event_available,
                        label: '工作天数',
                        value: '${heatmapData.length}',
                        subtitle: '天',
                        accentColor: AppColors.info,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: ModernHudTheme.spacingL),

                // 热力图
                Card(
                  elevation: 2,
                  shadowColor:
                      AppColors.getShadow(brightness).withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: ModernHudTheme.cardBorderRadius,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(ModernHudTheme.spacingL),
                    child: WorkHeatmap(workData: heatmapData),
                  ),
                ),

                const SizedBox(height: ModernHudTheme.spacingM),

                // 说明卡片
                _buildInfoCard(brightness),
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildErrorState(brightness),
        );
  }

  Widget _buildWeeklyChart(
      Map<DateTime, Duration> dailyHours, Brightness brightness) {
    if (dailyHours.isEmpty) {
      return _buildEmptyChart(brightness);
    }

    final spots = dailyHours.entries.map((entry) {
      return FlSpot(
        entry.key.weekday.toDouble(),
        entry.value.inHours.toDouble(),
      );
    }).toList();

    return Card(
      elevation: 2,
      shadowColor: AppColors.getShadow(brightness).withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: ModernHudTheme.cardBorderRadius,
      ),
      child: Padding(
        padding: const EdgeInsets.all(ModernHudTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(ModernHudTheme.spacingS),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.show_chart_rounded,
                    color: AppColors.primaryLight,
                    size: 20,
                  ),
                ),
                const SizedBox(width: ModernHudTheme.spacingM),
                Text(
                  '每日工时趋势',
                  style: AppTextStyles.headline5(brightness),
                ),
              ],
            ),
            const SizedBox(height: ModernHudTheme.spacingL),
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 2,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: AppColors.border.withValues(alpha: 0.5),
                        strokeWidth: 1,
                      );
                    },
                  ),
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
                              style: AppTextStyles.labelSmall(brightness),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}h',
                            style: AppTextStyles.labelSmall(brightness),
                          );
                        },
                        reservedSize: 40,
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: AppColors.border.withValues(alpha: 0.5),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: AppColors.primaryLight,
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: AppColors.primaryLight,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.primaryLight.withValues(alpha: 0.3),
                            AppColors.primaryLight.withValues(alpha: 0.05),
                          ],
                        ),
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

  Widget _buildMonthlyChart(
      Map<int, Duration> weeklyHours, Brightness brightness) {
    if (weeklyHours.isEmpty) {
      return _buildEmptyChart(brightness);
    }

    final barGroups = weeklyHours.entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value.inHours.toDouble(),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                AppColors.success,
                AppColors.restLight,
              ],
            ),
            width: 20,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(4),
            ),
          ),
        ],
      );
    }).toList();

    return Card(
      elevation: 2,
      shadowColor: AppColors.getShadow(brightness).withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: ModernHudTheme.cardBorderRadius,
      ),
      child: Padding(
        padding: const EdgeInsets.all(ModernHudTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(ModernHudTheme.spacingS),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.bar_chart_rounded,
                    color: AppColors.success,
                    size: 20,
                  ),
                ),
                const SizedBox(width: ModernHudTheme.spacingM),
                Text(
                  '每周工时统计',
                  style: AppTextStyles.headline5(brightness),
                ),
              ],
            ),
            const SizedBox(height: ModernHudTheme.spacingL),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: AppColors.border.withValues(alpha: 0.5),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '第${value.toInt()}周',
                            style: AppTextStyles.labelSmall(brightness),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}h',
                            style: AppTextStyles.labelSmall(brightness),
                          );
                        },
                        reservedSize: 40,
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: AppColors.border.withValues(alpha: 0.5),
                    ),
                  ),
                  barGroups: barGroups,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYearlyChart(
      Map<int, Duration> monthlyHours, Brightness brightness) {
    if (monthlyHours.isEmpty) {
      return _buildEmptyChart(brightness);
    }

    final barGroups = monthlyHours.entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value.inHours.toDouble(),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                AppColors.expBar,
                AppColors.expBarLight,
              ],
            ),
            width: 16,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(4),
            ),
          ),
        ],
      );
    }).toList();

    return Card(
      elevation: 2,
      shadowColor: AppColors.getShadow(brightness).withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: ModernHudTheme.cardBorderRadius,
      ),
      child: Padding(
        padding: const EdgeInsets.all(ModernHudTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(ModernHudTheme.spacingS),
                  decoration: BoxDecoration(
                    color: AppColors.expBar.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.bar_chart_rounded,
                    color: AppColors.expBar,
                    size: 20,
                  ),
                ),
                const SizedBox(width: ModernHudTheme.spacingM),
                Text(
                  '每月工时统计',
                  style: AppTextStyles.headline5(brightness),
                ),
              ],
            ),
            const SizedBox(height: ModernHudTheme.spacingL),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: AppColors.border.withValues(alpha: 0.5),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}月',
                            style: AppTextStyles.labelSmall(brightness),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}h',
                            style: AppTextStyles.labelSmall(brightness),
                          );
                        },
                        reservedSize: 40,
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: AppColors.border.withValues(alpha: 0.5),
                    ),
                  ),
                  barGroups: barGroups,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyChart(Brightness brightness) {
    return Card(
      elevation: 2,
      shadowColor: AppColors.getShadow(brightness).withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: ModernHudTheme.cardBorderRadius,
      ),
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.show_chart_rounded,
                size: 64,
                color: AppColors.textTertiary,
              ),
              const SizedBox(height: ModernHudTheme.spacingM),
              Text(
                '暂无数据',
                style: AppTextStyles.headline5(brightness).copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(Brightness brightness) {
    return Card(
      elevation: 2,
      shadowColor: AppColors.getShadow(brightness).withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: ModernHudTheme.cardBorderRadius,
      ),
      child: Padding(
        padding: const EdgeInsets.all(ModernHudTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(ModernHudTheme.spacingS),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.info,
                    size: 20,
                  ),
                ),
                const SizedBox(width: ModernHudTheme.spacingM),
                Text(
                  '使用说明',
                  style: AppTextStyles.headline5(brightness),
                ),
              ],
            ),
            const SizedBox(height: ModernHudTheme.spacingM),
            Text(
              '• 点击任意日期查看当天的详细工作时长\n'
              '• 颜色越深表示当天工作时间越长\n'
              '• 灰色表示当天没有工作记录',
              style: AppTextStyles.bodyMedium(brightness).copyWith(
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(Brightness brightness) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: ModernHudTheme.spacingM),
          Text(
            '加载失败',
            style: AppTextStyles.headline4(brightness).copyWith(
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  String _formatHours(Duration duration) {
    final hours = duration.inHours;
    if (hours >= 100) {
      return '${hours}h';
    }
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h${minutes}m';
  }

  String _formatAverage(Duration total, int count) {
    if (count == 0) return '0h';
    final avgMinutes = total.inMinutes / count;
    final hours = (avgMinutes / 60).floor();
    final minutes = (avgMinutes % 60).round();
    return '${hours}h${minutes}m';
  }

  void _showExportDialog(BuildContext context) async {
    final calculator = ref.read(calculatorServiceProvider);
    final records = await calculator.getWorkRecords();

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => ExportDialog(records: records),
      );
    }
  }
}
