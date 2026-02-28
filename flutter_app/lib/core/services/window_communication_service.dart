import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';

/// 窗口通信服务
///
/// 功能：
/// - 跨窗口消息传递
/// - 消息类型路由
/// - 双向通信支持
class WindowCommunicationService {
  static final WindowCommunicationService _instance =
      WindowCommunicationService._internal();
  factory WindowCommunicationService() => _instance;
  WindowCommunicationService._internal();

  int? _targetWindowId;
  Function(String type, Map<String, dynamic> data)? _messageHandler;

  /// 初始化通信服务
  void initialize() {
    DesktopMultiWindow.setMethodHandler(_handleMethodCall);
    print(' 窗口通信服务已初始化');
  }

  /// 设置目标窗口 ID
  void setTargetWindow(int windowId) {
    _targetWindowId = windowId;
    print(' 设置目标窗口: $windowId');
  }

  /// 设置消息处理器
  void setMessageHandler(
      Function(String type, Map<String, dynamic> data) handler) {
    _messageHandler = handler;
    print(' 消息处理器已设置');
  }

  /// 发送消息到目标窗口
  Future<void> sendMessage(String type, Map<String, dynamic> data) async {
    if (_targetWindowId == null) {
      print(' 未设置目标窗口，无法发送消息');
      return;
    }

    try {
      final message = jsonEncode({
        'type': type,
        'data': data,
      });

      await DesktopMultiWindow.invokeMethod(
        _targetWindowId!,
        'message',
        message,
      );

      print(' 消息已发送: $type -> 窗口 $_targetWindowId');
    } catch (e) {
      print(' 发送消息失败: $e');
    }
  }

  /// 处理接收到的消息
  Future<dynamic> _handleMethodCall(MethodCall call, int fromWindowId) async {
    if (call.method == 'message') {
      try {
        final messageJson = jsonDecode(call.arguments as String);
        final type = messageJson['type'] as String;
        final data = messageJson['data'] as Map<String, dynamic>;

        print(' 收到消息: $type <- 窗口 $fromWindowId');

        // 自动设置回复目标
        if (_targetWindowId == null) {
          _targetWindowId = fromWindowId;
          print(' 自动设置回复目标: $fromWindowId');
        }

        // 调用消息处理器
        _messageHandler?.call(type, data);
      } catch (e) {
        print(' 处理消息失败: $e');
      }
    }
  }
}
