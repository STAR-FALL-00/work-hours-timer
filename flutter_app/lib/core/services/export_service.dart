import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/work_record.dart';

/// 导出服务
///
/// 功能：
/// - JSON 导出
/// - CSV 导出
/// - Excel 导出（待实现）
/// - PDF 导出（待实现）
/// - 自定义导出范围
class ExportService {
  static final ExportService _instance = ExportService._internal();
  factory ExportService() => _instance;
  ExportService._internal();

  /// 导出为 JSON
  Future<File> exportToJson({
    required List<WorkRecord> records,
    DateTime? startDate,
    DateTime? endDate,
    String? fileName,
  }) async {
    // 筛选日期范围
    final filteredRecords = _filterByDateRange(records, startDate, endDate);

    // 生成 JSON
    final jsonData = {
      'exportDate': DateTime.now().toIso8601String(),
      'recordCount': filteredRecords.length,
      'dateRange': {
        'start': startDate?.toIso8601String(),
        'end': endDate?.toIso8601String(),
      },
      'records': filteredRecords.map((r) => r.toJson()).toList(),
    };

    // 保存文件
    final file = await _saveToFile(
      jsonData.toString(),
      fileName ?? 'work_records_${_getDateString()}.json',
    );

    return file;
  }

  /// 导出为 CSV
  Future<File> exportToCsv({
    required List<WorkRecord> records,
    DateTime? startDate,
    DateTime? endDate,
    String? fileName,
  }) async {
    // 筛选日期范围
    final filteredRecords = _filterByDateRange(records, startDate, endDate);

    // 生成 CSV
    final buffer = StringBuffer();

    // 表头
    buffer.writeln('日期,开始时间,结束时间,工作时长(小时),项目ID,金币,经验值');

    // 数据行
    for (final record in filteredRecords) {
      final date = DateFormat('yyyy-MM-dd').format(record.date);
      final startTime = DateFormat('HH:mm:ss').format(record.startTime);
      final endTime = record.endTime != null
          ? DateFormat('HH:mm:ss').format(record.endTime!)
          : '';
      final hours = record.duration.inMinutes / 60.0;

      buffer.writeln('$date,$startTime,$endTime,${hours.toStringAsFixed(2)},'
          '${record.projectId ?? ""},'
          '${record.goldEarned ?? 0},'
          '${record.expEarned ?? 0}');
    }

    // 保存文件
    final file = await _saveToFile(
      buffer.toString(),
      fileName ?? 'work_records_${_getDateString()}.csv',
    );

    return file;
  }

  /// 导出为 Markdown
  Future<File> exportToMarkdown({
    required List<WorkRecord> records,
    DateTime? startDate,
    DateTime? endDate,
    String? fileName,
  }) async {
    // 筛选日期范围
    final filteredRecords = _filterByDateRange(records, startDate, endDate);

    // 生成 Markdown
    final buffer = StringBuffer();

    // 标题
    buffer.writeln('# 工作记录导出报告\n');
    buffer.writeln(
        '**导出日期**: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}\n');
    buffer.writeln('**记录数量**: ${filteredRecords.length}\n');

    if (startDate != null || endDate != null) {
      buffer.writeln(
          '**日期范围**: ${startDate != null ? DateFormat('yyyy-MM-dd').format(startDate) : '开始'} ~ ${endDate != null ? DateFormat('yyyy-MM-dd').format(endDate) : '结束'}\n');
    }

    buffer.writeln('---\n');

    // 统计信息
    final totalHours = filteredRecords.fold<double>(
        0, (sum, r) => sum + r.duration.inMinutes / 60.0);
    final totalGold =
        filteredRecords.fold<int>(0, (sum, r) => sum + (r.goldEarned ?? 0));
    final totalExp =
        filteredRecords.fold<int>(0, (sum, r) => sum + (r.expEarned ?? 0));

    buffer.writeln('## 📊 统计摘要\n');
    buffer.writeln('- **总工作时长**: ${totalHours.toStringAsFixed(2)} 小时');
    buffer.writeln('- **总金币**: $totalGold 💰');
    buffer.writeln('- **总经验值**: $totalExp ⭐');
    buffer.writeln(
        '- **平均每日工时**: ${(totalHours / (filteredRecords.length > 0 ? filteredRecords.length : 1)).toStringAsFixed(2)} 小时\n');

    buffer.writeln('---\n');

    // 详细记录表格
    buffer.writeln('## 📝 详细记录\n');
    buffer.writeln('| 日期 | 开始时间 | 结束时间 | 工作时长 | 金币 | 经验值 |');
    buffer.writeln('|------|----------|----------|----------|------|--------|');

    for (final record in filteredRecords) {
      final date = DateFormat('yyyy-MM-dd').format(record.date);
      final startTime = DateFormat('HH:mm').format(record.startTime);
      final endTime = record.endTime != null
          ? DateFormat('HH:mm').format(record.endTime!)
          : '-';
      final hours = (record.duration.inMinutes / 60.0).toStringAsFixed(2);

      buffer.writeln(
          '| $date | $startTime | $endTime | ${hours}h | ${record.goldEarned ?? 0} | ${record.expEarned ?? 0} |');
    }

    // 保存文件
    final file = await _saveToFile(
      buffer.toString(),
      fileName ?? 'work_records_${_getDateString()}.md',
    );

    return file;
  }

  /// 导出统计报告
  Future<File> exportStatisticsReport({
    required List<WorkRecord> records,
    DateTime? startDate,
    DateTime? endDate,
    String? fileName,
  }) async {
    // 筛选日期范围
    final filteredRecords = _filterByDateRange(records, startDate, endDate);

    // 按日期分组
    final Map<String, List<WorkRecord>> recordsByDate = {};
    for (final record in filteredRecords) {
      final dateKey = DateFormat('yyyy-MM-dd').format(record.date);
      recordsByDate.putIfAbsent(dateKey, () => []).add(record);
    }

    // 生成报告
    final buffer = StringBuffer();

    buffer.writeln('# 📊 工作统计报告\n');
    buffer.writeln(
        '**生成日期**: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}\n');
    buffer.writeln('---\n');

    // 总体统计
    final totalHours = filteredRecords.fold<double>(
        0, (sum, r) => sum + r.duration.inMinutes / 60.0);
    final totalGold =
        filteredRecords.fold<int>(0, (sum, r) => sum + (r.goldEarned ?? 0));
    final totalExp =
        filteredRecords.fold<int>(0, (sum, r) => sum + (r.expEarned ?? 0));

    buffer.writeln('## 总体统计\n');
    buffer.writeln('- 📅 统计天数: ${recordsByDate.length} 天');
    buffer.writeln('- ⏰ 总工作时长: ${totalHours.toStringAsFixed(2)} 小时');
    buffer.writeln('- 💰 总金币: $totalGold');
    buffer.writeln('- ⭐ 总经验值: $totalExp');
    buffer.writeln(
        '- 📈 平均每日工时: ${(totalHours / (recordsByDate.length > 0 ? recordsByDate.length : 1)).toStringAsFixed(2)} 小时\n');

    // 每日统计
    buffer.writeln('## 每日统计\n');
    buffer.writeln('| 日期 | 工作时长 | 金币 | 经验值 | 工作次数 |');
    buffer.writeln('|------|----------|------|--------|----------|');

    final sortedDates = recordsByDate.keys.toList()..sort();
    for (final date in sortedDates) {
      final dayRecords = recordsByDate[date]!;
      final dayHours = dayRecords.fold<double>(
          0, (sum, r) => sum + r.duration.inMinutes / 60.0);
      final dayGold =
          dayRecords.fold<int>(0, (sum, r) => sum + (r.goldEarned ?? 0));
      final dayExp =
          dayRecords.fold<int>(0, (sum, r) => sum + (r.expEarned ?? 0));

      buffer.writeln(
          '| $date | ${dayHours.toStringAsFixed(2)}h | $dayGold | $dayExp | ${dayRecords.length} |');
    }

    // 保存文件
    final file = await _saveToFile(
      buffer.toString(),
      fileName ?? 'statistics_report_${_getDateString()}.md',
    );

    return file;
  }

  /// 筛选日期范围
  List<WorkRecord> _filterByDateRange(
    List<WorkRecord> records,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    return records.where((record) {
      if (startDate != null && record.date.isBefore(startDate)) {
        return false;
      }
      if (endDate != null && record.date.isAfter(endDate)) {
        return false;
      }
      return true;
    }).toList();
  }

  /// 保存到文件
  Future<File> _saveToFile(String content, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final exportDir = Directory('${directory.path}/exports');

    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }

    final file = File('${exportDir.path}/$fileName');
    await file.writeAsString(content);

    return file;
  }

  /// 获取日期字符串
  String _getDateString() {
    return DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
  }

  /// 获取导出目录
  Future<Directory> getExportDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final exportDir = Directory('${directory.path}/exports');

    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }

    return exportDir;
  }

  /// 获取所有导出文件
  Future<List<File>> getExportedFiles() async {
    final exportDir = await getExportDirectory();
    final files = exportDir.listSync().whereType<File>().toList();

    // 按修改时间排序（最新的在前）
    files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

    return files;
  }

  /// 删除导出文件
  Future<void> deleteExportFile(File file) async {
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// 清理旧的导出文件（保留最近N个）
  Future<void> cleanupOldExports({int keepCount = 10}) async {
    final files = await getExportedFiles();

    if (files.length > keepCount) {
      for (var i = keepCount; i < files.length; i++) {
        await files[i].delete();
      }
    }
  }
}

/// 导出配置
class ExportConfig {
  final ExportFormat format;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? fileName;
  final bool includeStatistics;
  final bool includeCharts;

  ExportConfig({
    required this.format,
    this.startDate,
    this.endDate,
    this.fileName,
    this.includeStatistics = true,
    this.includeCharts = false,
  });
}

/// 导出格式
enum ExportFormat {
  json,
  csv,
  markdown,
  excel,
  pdf,
}

/// 导出结果
class ExportResult {
  final bool success;
  final String? filePath;
  final String? errorMessage;
  final int recordCount;

  ExportResult({
    required this.success,
    this.filePath,
    this.errorMessage,
    this.recordCount = 0,
  });
}
