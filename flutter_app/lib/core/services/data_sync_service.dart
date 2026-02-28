import 'package:hive/hive.dart';
import 'package:synchronized/synchronized.dart';
import 'window_communication_service.dart';

/// 数据同步服务
///
/// 策略：
/// - 主窗口：负责所有数据写入
/// - 挂件窗口：只读数据，通过消息获取更新
class DataSyncService {
  static final DataSyncService _instance = DataSyncService._internal();
  factory DataSyncService() => _instance;
  DataSyncService._internal();

  final _lock = Lock();
  bool _isMainWindow = true;

  /// 设置窗口类型
  void setWindowType(bool isMainWindow) {
    _isMainWindow = isMainWindow;
    print('📋 窗口类型: ${isMainWindow ? "主窗口" : "挂件窗口"}');
  }

  /// 写入数据（仅主窗口）
  Future<void> writeData(String boxName, String key, dynamic value) async {
    if (!_isMainWindow) {
      print('⚠️ 挂件窗口不能写入数据，请通过主窗口');
      return;
    }

    await _lock.synchronized(() async {
      try {
        final box = Hive.box(boxName);
        await box.put(key, value);
        print('✅ 数据已写入: $boxName.$key');

        // 通知挂件窗口数据已更新
        WindowCommunicationService().sendMessage('DATA_UPDATED', {
          'box': boxName,
          'key': key,
          'value': value,
        });
      } catch (e) {
        print('❌ 写入数据失败: $e');
      }
    });
  }

  /// 读取数据（所有窗口）
  T? readData<T>(String boxName, String key) {
    try {
      final box = Hive.box(boxName);
      return box.get(key) as T?;
    } catch (e) {
      print('❌ 读取数据失败: $e');
      return null;
    }
  }

  /// 请求数据（挂件窗口使用）
  Future<void> requestData(String boxName, String key) async {
    if (_isMainWindow) {
      print('⚠️ 主窗口不需要请求数据');
      return;
    }

    await WindowCommunicationService().sendMessage('REQUEST_DATA', {
      'box': boxName,
      'key': key,
    });
    print('📤 已请求数据: $boxName.$key');
  }

  /// 处理数据请求（主窗口使用）
  void handleDataRequest(String boxName, String key) {
    if (!_isMainWindow) return;

    final value = readData(boxName, key);
    WindowCommunicationService().sendMessage('DATA_RESPONSE', {
      'box': boxName,
      'key': key,
      'value': value,
    });
    print('📤 已响应数据请求: $boxName.$key');
  }
}
