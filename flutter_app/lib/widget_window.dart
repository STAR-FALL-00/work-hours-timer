import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/services/window_communication_service.dart';

/// 挂件窗口应用
///
/// 功能：
/// - 纯展示、状态反馈、陪伴
/// - 接收主窗口的消息
/// - 显示简单的状态信息
class WidgetWindowApp extends StatelessWidget {
  const WidgetWindowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Work Hours Timer - Widget',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF4A90E2)),
          useMaterial3: true,
        ),
        home: const WidgetWindowScreen(),
      ),
    );
  }
}

/// 挂件窗口屏幕
class WidgetWindowScreen extends ConsumerStatefulWidget {
  const WidgetWindowScreen({super.key});

  @override
  ConsumerState<WidgetWindowScreen> createState() => _WidgetWindowScreenState();
}

class _WidgetWindowScreenState extends ConsumerState<WidgetWindowScreen> {
  String _displayText = 'Hello from Widget';
  String _lastMessageTime = '';

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
      if (type == 'TEST') {
        setState(() {
          _displayText = data['text'] ?? 'No text';
          _lastMessageTime = DateTime.now().toString().substring(11, 19);
        });
        print('📥 挂件窗口收到消息: $type');
      }
    });
  }

  /// 发送回复消息
  Future<void> _sendReply() async {
    await WindowCommunicationService().sendMessage('REPLY', {
      'text': 'Hello from Widget Window',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    print('📤 挂件窗口已发送回复');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: 240,
        height: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF4A90E2),
              Color(0xFF357ABD),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 显示文字
            Text(
              _displayText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            if (_lastMessageTime.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                '时间: $_lastMessageTime',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],

            const SizedBox(height: 16),

            // 回复按钮
            ElevatedButton(
              onPressed: _sendReply,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Color(0xFF4A90E2),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('发送回复'),
            ),
          ],
        ),
      ),
    );
  }
}
