import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// 暗色模式服务
///
/// 功能：
/// - 暗色模式切换
/// - 自动切换（跟随系统）
/// - 定时切换
/// - 护眼模式
/// - 亮度调节
class DarkModeService {
  static final DarkModeService _instance = DarkModeService._internal();
  factory DarkModeService() => _instance;
  DarkModeService._internal();

  // 当前模式
  ThemeMode _currentMode = ThemeMode.system;

  // 是否启用自动切换
  bool _autoSwitch = false;

  // 定时切换时间
  TimeOfDay? _darkModeStartTime;
  TimeOfDay? _darkModeEndTime;

  // 护眼模式
  bool _eyeCareMode = false;

  // 亮度
  double _brightness = 1.0;

  /// 获取当前模式
  ThemeMode get currentMode => _currentMode;

  /// 是否为暗色模式
  bool get isDarkMode {
    if (_currentMode == ThemeMode.dark) return true;
    if (_currentMode == ThemeMode.light) return false;

    // 跟随系统
    final brightness =
        SchedulerBinding.instance.platformDispatcher.platformBrightness;
    return brightness == Brightness.dark;
  }

  /// 设置主题模式
  Future<void> setThemeMode(ThemeMode mode) async {
    _currentMode = mode;
    // TODO: 保存到本地存储
    print('✅ 主题模式已设置: $mode');
  }

  /// 切换暗色模式
  Future<void> toggleDarkMode() async {
    if (_currentMode == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      await setThemeMode(ThemeMode.dark);
    }
  }

  /// 启用/禁用自动切换
  Future<void> setAutoSwitch(bool enabled) async {
    _autoSwitch = enabled;
    if (enabled) {
      await setThemeMode(ThemeMode.system);
    }
    // TODO: 保存到本地存储
    print('✅ 自动切换已${enabled ? "启用" : "禁用"}');
  }

  /// 设置定时切换时间
  Future<void> setScheduledSwitch({
    required TimeOfDay startTime,
    required TimeOfDay endTime,
  }) async {
    _darkModeStartTime = startTime;
    _darkModeEndTime = endTime;

    // 检查当前时间是否在暗色模式时间范围内
    _checkScheduledMode();

    // TODO: 保存到本地存储
    print('✅ 定时切换已设置: $startTime - $endTime');
  }

  /// 检查定时模式
  void _checkScheduledMode() {
    if (_darkModeStartTime == null || _darkModeEndTime == null) return;

    final now = TimeOfDay.now();
    final shouldBeDark = _isInTimeRange(
      now,
      _darkModeStartTime!,
      _darkModeEndTime!,
    );

    if (shouldBeDark && _currentMode != ThemeMode.dark) {
      setThemeMode(ThemeMode.dark);
    } else if (!shouldBeDark && _currentMode != ThemeMode.light) {
      setThemeMode(ThemeMode.light);
    }
  }

  /// 判断时间是否在范围内
  bool _isInTimeRange(TimeOfDay current, TimeOfDay start, TimeOfDay end) {
    final currentMinutes = current.hour * 60 + current.minute;
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;

    if (startMinutes <= endMinutes) {
      // 正常范围（如 08:00 - 20:00）
      return currentMinutes >= startMinutes && currentMinutes < endMinutes;
    } else {
      // 跨越午夜（如 20:00 - 08:00）
      return currentMinutes >= startMinutes || currentMinutes < endMinutes;
    }
  }

  /// 启用/禁用护眼模式
  Future<void> setEyeCareMode(bool enabled) async {
    _eyeCareMode = enabled;
    // TODO: 保存到本地存储
    print('✅ 护眼模式已${enabled ? "启用" : "禁用"}');
  }

  /// 设置亮度
  Future<void> setBrightness(double brightness) async {
    _brightness = brightness.clamp(0.0, 1.0);
    // TODO: 保存到本地存储
    print('✅ 亮度已设置: ${(_brightness * 100).toInt()}%');
  }

  /// 获取护眼模式状态
  bool get isEyeCareModeEnabled => _eyeCareMode;

  /// 获取亮度
  double get brightness => _brightness;

  /// 获取自动切换状态
  bool get isAutoSwitchEnabled => _autoSwitch;

  /// 获取定时切换时间
  TimeOfDay? get darkModeStartTime => _darkModeStartTime;
  TimeOfDay? get darkModeEndTime => _darkModeEndTime;

  /// 初始化
  Future<void> init() async {
    // TODO: 从本地存储加载设置
    print('✅ 暗色模式服务已初始化');
  }

  /// 获取推荐的暗色模式时间
  static Map<String, TimeOfDay> getRecommendedTimes() {
    return {
      'start': const TimeOfDay(hour: 20, minute: 0), // 晚上8点
      'end': const TimeOfDay(hour: 7, minute: 0), // 早上7点
    };
  }
}

/// 暗色模式配置
class DarkModeConfig {
  final ThemeMode mode;
  final bool autoSwitch;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final bool eyeCareMode;
  final double brightness;

  DarkModeConfig({
    this.mode = ThemeMode.system,
    this.autoSwitch = false,
    this.startTime,
    this.endTime,
    this.eyeCareMode = false,
    this.brightness = 1.0,
  });

  DarkModeConfig copyWith({
    ThemeMode? mode,
    bool? autoSwitch,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    bool? eyeCareMode,
    double? brightness,
  }) {
    return DarkModeConfig(
      mode: mode ?? this.mode,
      autoSwitch: autoSwitch ?? this.autoSwitch,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      eyeCareMode: eyeCareMode ?? this.eyeCareMode,
      brightness: brightness ?? this.brightness,
    );
  }
}

/// 护眼模式颜色过滤器
class EyeCareFilter {
  /// 获取护眼模式颜色矩阵
  static ColorFilter getColorFilter({double intensity = 0.3}) {
    // 减少蓝光，增加暖色调
    return ColorFilter.matrix([
      1.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      1.0 - intensity * 0.1,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      1.0 - intensity * 0.3,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      1.0,
      0.0,
    ]);
  }

  /// 应用护眼模式到颜色
  static Color applyToColor(Color color, {double intensity = 0.3}) {
    final r = color.red;
    final g = (color.green * (1.0 - intensity * 0.1)).round();
    final b = (color.blue * (1.0 - intensity * 0.3)).round();

    return Color.fromARGB(
      color.alpha,
      r.clamp(0, 255),
      g.clamp(0, 255),
      b.clamp(0, 255),
    );
  }
}
