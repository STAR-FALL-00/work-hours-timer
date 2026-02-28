import 'package:window_manager/window_manager.dart';
import 'package:flutter/material.dart';

/// 悬浮窗服务
///
/// 功能：
/// - 管理窗口大小和位置
/// - 始终置顶
/// - 窗口状态切换
/// - 位置记忆
class FloatingWindowService {
  static final FloatingWindowService _instance =
      FloatingWindowService._internal();
  factory FloatingWindowService() => _instance;
  FloatingWindowService._internal();

  // 悬浮窗尺寸
  static const Size floatingSize = Size(280, 200);

  // 完整窗口尺寸
  static const Size fullSize = Size(1200, 800);

  // 最小窗口尺寸
  static const Size minSize = Size(800, 600);

  /// 初始化窗口管理器
  Future<void> init() async {
    await windowManager.ensureInitialized();

    // 设置窗口选项
    const windowOptions = WindowOptions(
      size: fullSize,
      minimumSize: minSize,
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  /// 切换到悬浮窗模式
  Future<void> switchToFloatingMode() async {
    try {
      // 保存当前位置
      final position = await windowManager.getPosition();
      await _savePosition(position);

      // 设置窗口大小
      await windowManager.setSize(floatingSize);

      // 设置始终置顶
      await windowManager.setAlwaysOnTop(true);

      // 设置无边框（可选）
      // await windowManager.setTitleBarStyle(TitleBarStyle.hidden);

      // 移动到右下角
      await _moveToBottomRight();

      print('✅ 已切换到悬浮窗模式');
    } catch (e) {
      print('❌ 切换到悬浮窗模式失败: $e');
    }
  }

  /// 切换到完整模式
  Future<void> switchToFullMode() async {
    try {
      // 取消始终置顶
      await windowManager.setAlwaysOnTop(false);

      // 恢复窗口大小
      await windowManager.setSize(fullSize);

      // 恢复标题栏
      await windowManager.setTitleBarStyle(TitleBarStyle.normal);

      // 恢复保存的位置或居中
      final savedPosition = await _loadPosition();
      if (savedPosition != null) {
        await windowManager.setPosition(savedPosition);
      } else {
        await windowManager.center();
      }

      print('✅ 已切换到完整模式');
    } catch (e) {
      print('❌ 切换到完整模式失败: $e');
    }
  }

  /// 移动窗口到右下角
  Future<void> _moveToBottomRight() async {
    try {
      final screenSize = await windowManager.getSize();
      final position = Offset(
        screenSize.width - floatingSize.width - 20,
        screenSize.height - floatingSize.height - 60,
      );
      await windowManager.setPosition(position);
    } catch (e) {
      print('❌ 移动窗口失败: $e');
    }
  }

  /// 保存窗口位置
  Future<void> _savePosition(Offset position) async {
    // TODO: 使用 SharedPreferences 或 Hive 保存位置
    print('💾 保存窗口位置: $position');
  }

  /// 加载窗口位置
  Future<Offset?> _loadPosition() async {
    // TODO: 从 SharedPreferences 或 Hive 加载位置
    return null;
  }

  /// 设置窗口透明度
  Future<void> setOpacity(double opacity) async {
    try {
      await windowManager.setOpacity(opacity);
    } catch (e) {
      print('❌ 设置透明度失败: $e');
    }
  }

  /// 获取当前窗口大小
  Future<Size> getSize() async {
    return await windowManager.getSize();
  }

  /// 获取当前窗口位置
  Future<Offset> getPosition() async {
    return await windowManager.getPosition();
  }

  /// 检查是否为悬浮窗模式
  Future<bool> isFloatingMode() async {
    final size = await getSize();
    return size.width <= floatingSize.width + 10 &&
        size.height <= floatingSize.height + 10;
  }

  /// 设置始终置顶
  Future<void> setAlwaysOnTop(bool alwaysOnTop) async {
    try {
      await windowManager.setAlwaysOnTop(alwaysOnTop);
    } catch (e) {
      print('❌ 设置始终置顶失败: $e');
    }
  }

  /// 最小化窗口
  Future<void> minimize() async {
    await windowManager.minimize();
  }

  /// 最大化窗口
  Future<void> maximize() async {
    await windowManager.maximize();
  }

  /// 恢复窗口
  Future<void> restore() async {
    await windowManager.restore();
  }

  /// 显示窗口
  Future<void> show() async {
    await windowManager.show();
  }

  /// 隐藏窗口
  Future<void> hide() async {
    await windowManager.hide();
  }

  /// 聚焦窗口
  Future<void> focus() async {
    await windowManager.focus();
  }
}
