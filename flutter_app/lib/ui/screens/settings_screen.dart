import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _hoursController;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;
  late TextEditingController _salaryController;
  bool _useFixedSchedule = false;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(workSettingsProvider);
    _hoursController = TextEditingController(
      text: settings.standardWorkHours.toString(),
    );
    _startTimeController = TextEditingController(
      text: settings.startTime ?? '09:00',
    );
    _endTimeController = TextEditingController(
      text: settings.endTime ?? '18:00',
    );
    _salaryController = TextEditingController(
      text: settings.monthlySalary?.toStringAsFixed(0) ?? '',
    );
    _useFixedSchedule = settings.startTime != null && settings.endTime != null;
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    final hours = int.tryParse(_hoursController.text) ?? 8;
    final salary = double.tryParse(_salaryController.text);
    final settings = ref.read(workSettingsProvider);

    final newSettings = settings.copyWith(
      standardWorkHours: hours,
      startTime: _useFixedSchedule ? _startTimeController.text : null,
      endTime: _useFixedSchedule ? _endTimeController.text : null,
      monthlySalary: salary,
    );

    await ref.read(workSettingsProvider.notifier).updateSettings(newSettings);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('设置已保存')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appSettings = ref.watch(appSettingsProvider);
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        title:
            const Text('工作设置', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 游戏模式切换卡片
            Card(
              elevation: 2,
              shadowColor: Colors.purple.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade50, Colors.purple.shade100],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade700,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.gamepad,
                          color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '🎮 游戏模式',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            appSettings.isGameMode ? '⚔️ 冒险者工会界面' : '📊 标准工作界面',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Transform.scale(
                      scale: 1.1,
                      child: Switch(
                        value: appSettings.isGameMode,
                        onChanged: (value) async {
                          await ref.read(appSettingsProvider.notifier).setGameMode(value);
                          if (mounted) {
                            // 返回主页面以刷新界面
                            Navigator.of(context).pop();
                          }
                        },
                        activeColor: Colors.purple.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
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
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.schedule_rounded,
                              color: Colors.blue, size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          '标准工作时长',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _hoursController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        labelText: '每日工作小时数',
                        labelStyle: TextStyle(color: Colors.grey[600]),
                        suffixText: '小时',
                        suffixStyle: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Colors.blue, width: 2),
                        ),
                        helperText: '例如：8（表示8小时工作制）',
                        helperStyle: TextStyle(color: Colors.grey[500]),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
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
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.attach_money_rounded,
                              color: Colors.amber, size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          '薪资设置',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _salaryController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        labelText: '月薪',
                        labelStyle: TextStyle(color: Colors.grey[600]),
                        suffixText: '元',
                        suffixStyle: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500),
                        prefixIcon: const Icon(
                            Icons.account_balance_wallet_rounded,
                            color: Colors.amber),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Colors.amber, width: 2),
                        ),
                        helperText: '输入月薪后可查看日薪和时薪统计',
                        helperStyle: TextStyle(color: Colors.grey[500]),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.access_time_rounded,
                                  color: Colors.green, size: 24),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              '固定上下班时间',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Transform.scale(
                          scale: 1.1,
                          child: Switch(
                            value: _useFixedSchedule,
                            onChanged: (value) {
                              setState(() {
                                _useFixedSchedule = value;
                              });
                            },
                            activeColor: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _useFixedSchedule
                            ? Colors.green.withValues(alpha: 0.05)
                            : Colors.grey.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _useFixedSchedule
                              ? Colors.green.withValues(alpha: 0.2)
                              : Colors.grey.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _useFixedSchedule
                                ? Icons.check_circle_rounded
                                : Icons.info_rounded,
                            color: _useFixedSchedule
                                ? Colors.green
                                : Colors.grey[600],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _useFixedSchedule
                                  ? '使用固定的上下班时间计算'
                                  : '根据实际打卡时间 + 工作时长计算',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_useFixedSchedule) ...[
                      const SizedBox(height: 20),
                      TextField(
                        controller: _startTimeController,
                        style: const TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          labelText: '规定上班时间',
                          labelStyle: TextStyle(color: Colors.grey[600]),
                          hintText: '09:00',
                          prefixIcon: const Icon(Icons.wb_sunny_rounded,
                              color: Colors.orange),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Colors.green, width: 2),
                          ),
                          helperText: '格式：HH:mm（24小时制）',
                          helperStyle: TextStyle(color: Colors.grey[500]),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _endTimeController,
                        style: const TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          labelText: '规定下班时间',
                          labelStyle: TextStyle(color: Colors.grey[600]),
                          hintText: '18:00',
                          prefixIcon: const Icon(Icons.nightlight_rounded,
                              color: Colors.indigo),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Colors.green, width: 2),
                          ),
                          helperText: '格式：HH:mm（24小时制）',
                          helperStyle: TextStyle(color: Colors.grey[500]),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: Colors.blue.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save_rounded, size: 24),
                    SizedBox(width: 12),
                    Text(
                      '保存设置',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
}
