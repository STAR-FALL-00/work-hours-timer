import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'dart:convert';

/// 窗口管理服务
///
/// 功能：
/// - 创建和管理多个窗口
/// - 窗口生命周期管理
/// - 窗口配置管理
class WindowManagerService {
  static final WindowManagerService _instance =
      WindowManagerService._internal();
  factory WindowManagerService() => _instance;
  WindowManagerService._internal();

  final Map<String, int> _windows = {};

  /// 创建挂件窗口
  Future<WindowController> createWidgetWindow({
    double width = 240,
    double height = 120,
  }) async {
    final windowController = await DesktopMultiWindow.createWindow(
      jsonEncode({
        'type': 'widget',
        'width': width,
        'height': height,
      }),
    );

    _windows['widget'] = windowController.windowId;
    return windowController;
  }

  /// 获取窗口 ID
  int? getWindowId(String type) {
    return _windows[type];
  }

  /// 关闭窗口
  Future<void> closeWindow(String type) async {
    final windowId = _windows[type];
    if (windowId != null) {
      // TODO: 实现窗口关闭逻辑
      _windows.remove(type);
    }
  }

  /// 显示窗口
  Future<void> showWindow(int windowId) async {
    await DesktopMultiWindow.invokeMethod(windowId, 'show');
  }

  /// 隐藏窗口
  Future<void> hideWindow(int windowId) async {
    await DesktopMultiWindow.invokeMethod(windowId, 'hide');
  }
}
