import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'dart:convert';
import 'core/services/window_communication_service.dart';

/// 主窗口应用
///
/// 功能：
/// - 控制器、数据中心、交互中心
/// - 创建和管理挂件窗口
/// - 处理用户交互
class MainWindowApp extends StatelessWidget {
  const MainWindowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Work Hours Timer - Main',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4A90E2)),
          useMaterial3: true,
        ),
        home: const MainWindowScreen(),
      ),
    );
  }
}

/// 主窗口屏幕
class MainWindowScreen extends ConsumerStatefulWidget {
  const MainWindowScreen({super.key});

  @override
  ConsumerState<MainWindowScreen> createState() => _MainWindowScreenState();
}

class _MainWindowScreenState extends ConsumerState<MainWindowScreen> {
  WindowController? _widgetWindowController;
  String _receivedMessage = '等待消息...';

  @override
  void initState() {
    super.initState();
    // 初始化通信服务
    WindowCommunicationService().initialize();
    _setupMessageHandler();
  }

  /// 设置消息处理器
  void _setupMessageHandler() {
    WindowCommunicationService().setMessageHandler((type, data) {
      setState(() {
        _receivedMessage = '收到消息: $type - ${data.toString()}';
      });
      print('📥 主窗口收到消息: $type');
    });
  }

  /// 创建挂件窗口
  Future<void> _createWidgetWindow() async {
    try {
      final windowController = await DesktopMultiWindow.createWindow(
        jsonEncode({
          'type': 'widget',
          'width': 240,
          'height': 120,
        }),
      );

      setState(() {
        _widgetWindowController = windowController;
      });

      // 设置通信目标
      WindowCommunicationService().setTargetWindow(windowController.windowId);

      print('✅ 挂件窗口已创建: ID = ${windowController.windowId}');
    } catch (e) {
      print('❌ 创建挂件窗口失败: $e');
    }
  }

  /// 发送测试消息
  Future<void> _sendTestMessage() async {
    if (_widgetWindowController == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先创建挂件窗口')),
      );
      return;
    }

    await WindowCommunicationService().sendMessage('TEST', {
      'text': 'Hello from Main Window',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    print('📤 已发送测试消息');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('主窗口 (Main Window)'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 状态显示
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      '挂件窗口 ID: ${_widgetWindowController?.windowId ?? "未创建"}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _receivedMessage,
                      style: const TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 创建窗口按钮
              ElevatedButton.icon(
                onPressed: _widgetWindowController == null
                    ? _createWidgetWindow
                    : null,
                icon: const Icon(Icons.add_box),
                label: const Text('创建挂件窗口'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),

              const SizedBox(height: 16),

              // 发送消息按钮
              ElevatedButton.icon(
                onPressed:
                    _widgetWindowController != null ? _sendTestMessage : null,
                icon: const Icon(Icons.send),
                label: const Text('发送测试消息'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),

              const SizedBox(height: 32),

              // 说明文字
              const Text(
                'Sprint 1 - Day 1: 环境搭建\n'
                '测试双窗口通信功能',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
