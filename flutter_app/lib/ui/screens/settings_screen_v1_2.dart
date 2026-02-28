import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../providers/service_providers.dart';
import '../../core/services/theme_service.dart';
import '../widgets/modern_hud_widgets.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/modern_hud_theme.dart';
import 'theme_manager_screen.dart';
import 'decoration_manager_screen.dart';
import 'item_inventory_screen.dart';

/// v1.2.0 Modern HUD 风格设置页面
class SettingsScreenV12 extends ConsumerStatefulWidget {
  const SettingsScreenV12({super.key});

  @override
  ConsumerState<SettingsScreenV12> createState() => _SettingsScreenV12State();
}

class _SettingsScreenV12State extends ConsumerState<SettingsScreenV12> {
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
      // 显示成功飘字
      FloatingTextManager.show(
        context,
        text: '✓ 设置已保存',
        type: FloatingTextType.levelUp,
      );

      // 延迟返回
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appSettings = ref.watch(appSettingsProvider);
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      backgroundColor: AppColors.getBackground(brightness),
      appBar: AppBar(
        elevation: 0,
        title: Text(
          '设置',
          style: AppTextStyles.headline3(brightness),
        ),
        backgroundColor: AppColors.getPrimary(brightness),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(ModernHudTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 游戏模式切换
            _buildGameModeCard(appSettings, brightness),

            // 主题管理
            _buildThemeManagementCard(brightness),

            // 装饰品管理
            _buildDecorationManagementCard(brightness),

            // 道具背包
            _buildItemInventoryCard(brightness),

            // 暗色模式设置
            _buildDarkModeCard(brightness),

            // 标准工作时长
            _buildWorkHoursCard(brightness),

            // 薪资设置
            _buildSalaryCard(brightness),

            // 固定上下班时间
            _buildScheduleCard(brightness),

            const SizedBox(height: ModernHudTheme.spacingL),

            // 保存按钮
            _buildSaveButton(brightness),
          ],
        ),
      ),
    );
  }

  Widget _buildGameModeCard(appSettings, Brightness brightness) {
    return Container(
      margin: const EdgeInsets.only(bottom: ModernHudTheme.spacingL),
      padding: const EdgeInsets.all(ModernHudTheme.spacingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.expBar.withValues(alpha: 0.2),
            AppColors.expBar.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: ModernHudTheme.cardBorderRadius,
        border: Border.all(
          color: AppColors.expBar.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.expBar.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(ModernHudTheme.spacingM),
            decoration: BoxDecoration(
              color: AppColors.expBar,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.gamepad_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: ModernHudTheme.spacingL),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🎮 游戏模式',
                  style: AppTextStyles.headline5(brightness).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  appSettings.isGameMode ? '⚔️ 冒险者工会界面' : '📊 标准工作界面',
                  style: AppTextStyles.bodySmall(brightness).copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 1.2,
            child: Switch(
              value: appSettings.isGameMode,
              onChanged: (value) async {
                await ref.read(appSettingsProvider.notifier).setGameMode(value);
                if (mounted) {
                  // 显示切换提示
                  FloatingTextManager.show(
                    context,
                    text: value ? '🎮 游戏模式' : '📊 标准模式',
                    type: FloatingTextType.levelUp,
                  );
                  // 返回主页面以刷新界面
                  Future.delayed(const Duration(milliseconds: 800), () {
                    if (mounted) {
                      Navigator.of(context).pop();
                    }
                  });
                }
              },
              activeTrackColor: AppColors.expBar.withValues(alpha: 0.5),
              activeColor: AppColors.expBar,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkHoursCard(Brightness brightness) {
    return SettingCard(
      icon: Icons.schedule_rounded,
      iconColor: AppColors.primaryLight,
      title: '标准工作时长',
      subtitle: '设置每日标准工作小时数',
      child: TextField(
        controller: _hoursController,
        keyboardType: TextInputType.number,
        style: AppTextStyles.bodyMedium(brightness),
        decoration: InputDecoration(
          labelText: '每日工作小时数',
          labelStyle: AppTextStyles.labelLarge(brightness),
          suffixText: '小时',
          suffixStyle: AppTextStyles.labelMedium(brightness),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppColors.border.withValues(alpha: 0.5),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppColors.getPrimary(brightness),
              width: 2,
            ),
          ),
          helperText: '例如：8（表示8小时工作制）',
          helperStyle: AppTextStyles.bodySmall(brightness).copyWith(
            color: AppColors.textTertiary,
          ),
          filled: true,
          fillColor: AppColors.getBackground(brightness),
        ),
      ),
    );
  }

  Widget _buildSalaryCard(Brightness brightness) {
    return SettingCard(
      icon: Icons.attach_money_rounded,
      iconColor: AppColors.accent,
      title: '薪资设置',
      subtitle: '输入月薪后可查看日薪和时薪统计',
      child: TextField(
        controller: _salaryController,
        keyboardType: TextInputType.number,
        style: AppTextStyles.bodyMedium(brightness),
        decoration: InputDecoration(
          labelText: '月薪',
          labelStyle: AppTextStyles.labelLarge(brightness),
          suffixText: '元',
          suffixStyle: AppTextStyles.labelMedium(brightness),
          prefixIcon: const Icon(
            Icons.account_balance_wallet_rounded,
            color: AppColors.accent,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppColors.border.withValues(alpha: 0.5),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.accent,
              width: 2,
            ),
          ),
          helperText: '可选项，用于统计分析',
          helperStyle: AppTextStyles.bodySmall(brightness).copyWith(
            color: AppColors.textTertiary,
          ),
          filled: true,
          fillColor: AppColors.getBackground(brightness),
        ),
      ),
    );
  }

  Widget _buildScheduleCard(Brightness brightness) {
    return SettingCard(
      icon: Icons.access_time_rounded,
      iconColor: AppColors.rest,
      title: '固定上下班时间',
      subtitle: '设置规定的上下班时间',
      child: Column(
        children: [
          // 开关
          SettingSwitchTile(
            title: _useFixedSchedule ? '使用固定时间' : '使用灵活时间',
            subtitle: _useFixedSchedule ? '根据规定的上下班时间计算' : '根据实际打卡时间 + 工作时长计算',
            value: _useFixedSchedule,
            onChanged: (value) {
              setState(() {
                _useFixedSchedule = value;
              });
            },
            activeColor: AppColors.rest,
          ),

          // 时间输入（仅在开启时显示）
          if (_useFixedSchedule) ...[
            const SizedBox(height: ModernHudTheme.spacingL),
            TextField(
              controller: _startTimeController,
              style: AppTextStyles.bodyMedium(brightness),
              decoration: InputDecoration(
                labelText: '规定上班时间',
                labelStyle: AppTextStyles.labelLarge(brightness),
                hintText: '09:00',
                prefixIcon: const Icon(
                  Icons.wb_sunny_rounded,
                  color: Colors.orange,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.border.withValues(alpha: 0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.rest,
                    width: 2,
                  ),
                ),
                helperText: '格式：HH:mm（24小时制）',
                helperStyle: AppTextStyles.bodySmall(brightness).copyWith(
                  color: AppColors.textTertiary,
                ),
                filled: true,
                fillColor: AppColors.getBackground(brightness),
              ),
            ),
            const SizedBox(height: ModernHudTheme.spacingM),
            TextField(
              controller: _endTimeController,
              style: AppTextStyles.bodyMedium(brightness),
              decoration: InputDecoration(
                labelText: '规定下班时间',
                labelStyle: AppTextStyles.labelLarge(brightness),
                hintText: '18:00',
                prefixIcon: const Icon(
                  Icons.nightlight_rounded,
                  color: Colors.indigo,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.border.withValues(alpha: 0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.rest,
                    width: 2,
                  ),
                ),
                helperText: '格式：HH:mm（24小时制）',
                helperStyle: AppTextStyles.bodySmall(brightness).copyWith(
                  color: AppColors.textTertiary,
                ),
                filled: true,
                fillColor: AppColors.getBackground(brightness),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSaveButton(Brightness brightness) {
    return ActionButton(
      text: '保存设置',
      icon: Icons.save_rounded,
      type: ActionButtonType.primary,
      onPressed: _saveSettings,
    );
  }

  Widget _buildThemeManagementCard(Brightness brightness) {
    final inventory = ref.watch(inventoryProvider);
    final themeService = ThemeService();
    final activeThemeName = themeService.getThemeName(inventory.activeTheme);
    final activeThemeIcon = themeService.getThemeIcon(inventory.activeTheme);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ThemeManagerScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: ModernHudTheme.spacingL),
        padding: const EdgeInsets.all(ModernHudTheme.spacingM),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.accent.withValues(alpha: 0.1),
              AppColors.accent.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: ModernHudTheme.cardBorderRadius,
          border: Border.all(
            color: AppColors.accent.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: ModernHudTheme.cardShadow(brightness),
        ),
        child: Row(
          children: [
            // 图标
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.accent,
                    AppColors.accent.withValues(alpha: 0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.palette_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: ModernHudTheme.spacingM),
            // 文本
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '主题管理',
                    style: AppTextStyles.headline5(brightness),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        activeThemeIcon,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '当前：$activeThemeName',
                        style: AppTextStyles.bodySmall(brightness),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // 箭头
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.textTertiary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDecorationManagementCard(Brightness brightness) {
    final inventory = ref.watch(inventoryProvider);
    final activeCount = inventory.activeDecorations.length;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DecorationManagerScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: ModernHudTheme.spacingL),
        padding: const EdgeInsets.all(ModernHudTheme.spacingM),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.success.withValues(alpha: 0.1),
              AppColors.success.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: ModernHudTheme.cardBorderRadius,
          border: Border.all(
            color: AppColors.success.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: ModernHudTheme.cardShadow(brightness),
        ),
        child: Row(
          children: [
            // 图标
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.success,
                    AppColors.success.withValues(alpha: 0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.emoji_objects_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: ModernHudTheme.spacingM),
            // 文本
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '装饰品管理',
                    style: AppTextStyles.headline5(brightness),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activeCount > 0 ? '已激活 $activeCount 个装饰品' : '暂无激活的装饰品',
                    style: AppTextStyles.bodySmall(brightness),
                  ),
                ],
              ),
            ),
            // 箭头
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.textTertiary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemInventoryCard(Brightness brightness) {
    final itemService = ref.watch(itemServiceProvider);
    final activeEffects = itemService.getActiveEffects();
    final itemCount = activeEffects.length;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ItemInventoryScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: ModernHudTheme.spacingL),
        padding: const EdgeInsets.all(ModernHudTheme.spacingM),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.info.withValues(alpha: 0.1),
              AppColors.info.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: ModernHudTheme.cardBorderRadius,
          border: Border.all(
            color: AppColors.info.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: ModernHudTheme.cardShadow(brightness),
        ),
        child: Row(
          children: [
            // 图标
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.info,
                    AppColors.info.withValues(alpha: 0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.inventory_2_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: ModernHudTheme.spacingM),
            // 文本
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '道具背包',
                    style: AppTextStyles.headline5(brightness),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    itemCount > 0 ? '激活 $itemCount 个道具' : '暂无激活道具',
                    style: AppTextStyles.bodySmall(brightness),
                  ),
                ],
              ),
            ),
            // 箭头
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.textTertiary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDarkModeCard(Brightness brightness) {
    final darkModeService = ref.watch(darkModeServiceProvider);
    final isDarkMode = darkModeService.isDarkMode;
    final isAutoSwitch = darkModeService.isAutoSwitchEnabled;

    return Container(
      margin: const EdgeInsets.only(bottom: ModernHudTheme.spacingL),
      padding: const EdgeInsets.all(ModernHudTheme.spacingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            (isDarkMode ? Colors.indigo : Colors.amber).withValues(alpha: 0.2),
            (isDarkMode ? Colors.indigo : Colors.amber).withValues(alpha: 0.1),
          ],
        ),
        borderRadius: ModernHudTheme.cardBorderRadius,
        border: Border.all(
          color: (isDarkMode ? Colors.indigo : Colors.amber)
              .withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDarkMode ? Colors.indigo : Colors.amber)
                .withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(ModernHudTheme.spacingM),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.indigo : Colors.amber,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isDarkMode
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: ModernHudTheme.spacingL),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '暗色模式',
                      style: AppTextStyles.headline5(brightness).copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isAutoSwitch
                          ? '🌓 自动切换'
                          : (isDarkMode ? '🌙 深色主题' : '☀️ 浅色主题'),
                      style: AppTextStyles.bodySmall(brightness).copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Transform.scale(
                scale: 1.2,
                child: Switch(
                  value: isDarkMode,
                  onChanged: (value) {
                    darkModeService.toggleDarkMode();
                    setState(() {});
                  },
                  activeTrackColor: Colors.indigo.withValues(alpha: 0.5),
                  activeThumbColor: Colors.indigo,
                ),
              ),
            ],
          ),
          const SizedBox(height: ModernHudTheme.spacingL),
          // 自动切换选项
          SettingSwitchTile(
            title: '自动切换',
            subtitle: '根据系统设置自动切换主题',
            value: isAutoSwitch,
            onChanged: (value) {
              darkModeService.setAutoSwitch(value);
              setState(() {});
            },
            activeColor: isDarkMode ? Colors.indigo : Colors.amber,
          ),
          const SizedBox(height: ModernHudTheme.spacingM),
          // 护眼模式选项
          SettingSwitchTile(
            title: '护眼模式',
            subtitle: '降低蓝光，保护眼睛',
            value: darkModeService.isEyeCareModeEnabled,
            onChanged: (value) {
              darkModeService.setEyeCareMode(value);
              setState(() {});
            },
            activeColor: Colors.green,
          ),
        ],
      ),
    );
  }
}
