import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/services/export_service.dart';
import '../../../core/models/work_record.dart';

/// 导出对话框
class ExportDialog extends StatefulWidget {
  final List<WorkRecord> records;

  const ExportDialog({
    super.key,
    required this.records,
  });

  @override
  State<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  ExportFormat _selectedFormat = ExportFormat.json;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('导出数据'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 格式选择
            const Text('导出格式', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildFormatSelector(),

            const SizedBox(height: 16),

            // 日期范围
            const Text('日期范围（可选）',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildDateRangeSelector(),

            const SizedBox(height: 16),

            // 说明
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 20, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '文件将保存到文档/exports目录',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isExporting ? null : () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _isExporting ? null : _handleExport,
          child: _isExporting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('导出'),
        ),
      ],
    );
  }

  Widget _buildFormatSelector() {
    return Wrap(
      spacing: 8,
      children: [
        _buildFormatChip('JSON', ExportFormat.json, Icons.code),
        _buildFormatChip('CSV', ExportFormat.csv, Icons.table_chart),
        _buildFormatChip('Markdown', ExportFormat.markdown, Icons.description),
      ],
    );
  }

  Widget _buildFormatChip(String label, ExportFormat format, IconData icon) {
    final isSelected = _selectedFormat == format;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFormat = format;
        });
      },
    );
  }

  Widget _buildDateRangeSelector() {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.calendar_today),
          title: Text(
            _startDate != null
                ? '开始: ${DateFormat('yyyy-MM-dd').format(_startDate!)}'
                : '选择开始日期',
          ),
          onTap: () => _selectDate(true),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.event),
          title: Text(
            _endDate != null
                ? '结束: ${DateFormat('yyyy-MM-dd').format(_endDate!)}'
                : '选择结束日期',
          ),
          onTap: () => _selectDate(false),
        ),
        if (_startDate != null || _endDate != null)
          TextButton(
            onPressed: () {
              setState(() {
                _startDate = null;
                _endDate = null;
              });
            },
            child: const Text('清除日期范围'),
          ),
      ],
    );
  }

  Future<void> _selectDate(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        if (isStart) {
          _startDate = date;
        } else {
          _endDate = date;
        }
      });
    }
  }

  Future<void> _handleExport() async {
    setState(() {
      _isExporting = true;
    });

    try {
      final exportService = ExportService();
      late final file;

      switch (_selectedFormat) {
        case ExportFormat.json:
          file = await exportService.exportToJson(
            records: widget.records,
            startDate: _startDate,
            endDate: _endDate,
          );
          break;
        case ExportFormat.csv:
          file = await exportService.exportToCsv(
            records: widget.records,
            startDate: _startDate,
            endDate: _endDate,
          );
          break;
        case ExportFormat.markdown:
          file = await exportService.exportToMarkdown(
            records: widget.records,
            startDate: _startDate,
            endDate: _endDate,
          );
          break;
        default:
          throw Exception('不支持的格式');
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('导出成功！\n文件: ${file.path}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }
}
