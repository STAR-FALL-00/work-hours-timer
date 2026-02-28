import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:intl/intl.dart';

/// 工作热力图组件
///
/// 类似 GitHub Contribution Graph，显示过去一年的工作情况
/// 颜色深浅根据当日工作时长决定
class WorkHeatmap extends StatelessWidget {
  /// 日期到工作时长的映射 (DateTime -> Duration)
  final Map<DateTime, Duration> workData;

  /// 是否显示月份标签
  final bool showMonthLabel;

  /// 是否显示周标签
  final bool showWeekLabel;

  const WorkHeatmap({
    super.key,
    required this.workData,
    this.showMonthLabel = true,
    this.showWeekLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    // 将 Duration 转换为小时数的 Map
    final Map<DateTime, int> heatmapData = {};

    for (var entry in workData.entries) {
      // 标准化日期到午夜
      final normalizedDate = DateTime(
        entry.key.year,
        entry.key.month,
        entry.key.day,
      );
      heatmapData[normalizedDate] = entry.value.inHours;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.grid_on_rounded,
                    color: Colors.green,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  '工作热力图',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                _buildLegend(),
              ],
            ),
            const SizedBox(height: 20),

            // 热力图
            HeatMapCalendar(
              defaultColor: Colors.grey[200]!,
              flexible: true,
              datasets: heatmapData,
              colorMode: ColorMode.color,
              showColorTip: false,
              size: 30,
              fontSize: 10,
              borderRadius: 4,
              margin: const EdgeInsets.all(2),
              textColor: Colors.black54,
              colorsets: _getColorSets(),
              onClick: (value) {
                // 点击事件可以显示详细信息
                _showDayDetails(context, value);
              },
            ),

            const SizedBox(height: 12),

            // 说明文字
            Text(
              '过去一年的工作记录',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建图例
  Widget _buildLegend() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '少',
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
        ),
        const SizedBox(width: 4),
        _buildLegendBox(Colors.grey[200]!),
        _buildLegendBox(Colors.green[200]!),
        _buildLegendBox(Colors.green[400]!),
        _buildLegendBox(Colors.green[600]!),
        _buildLegendBox(Colors.green[800]!),
        const SizedBox(width: 4),
        Text(
          '多',
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildLegendBox(Color color) {
    return Container(
      width: 12,
      height: 12,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  /// 获取颜色集合
  /// 根据工作时长映射到不同的绿色深度
  Map<int, Color> _getColorSets() {
    return {
      1: Colors.green[200]!, // 1-2 小时
      3: Colors.green[400]!, // 3-4 小时
      5: Colors.green[600]!, // 5-6 小时
      7: Colors.green[800]!, // 7+ 小时
    };
  }

  /// 显示某天的详细信息
  void _showDayDetails(BuildContext context, DateTime date) {
    // 标准化日期
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final duration = workData[normalizedDate];

    if (duration == null || duration.inMinutes == 0) {
      return; // 没有数据，不显示
    }

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final dateStr = DateFormat('yyyy年MM月dd日 EEEE', 'zh_CN').format(date);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.event, color: Colors.green, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('工作详情'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dateStr,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.access_time, color: Colors.green, size: 32),
                  const SizedBox(width: 12),
                  Text(
                    '$hours小时$minutes分钟',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}
