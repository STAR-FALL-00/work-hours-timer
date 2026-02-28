import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import 'core/models/work_record.dart';
import 'core/models/work_settings.dart';
import 'core/models/adventurer_profile.dart';
import 'core/models/app_settings.dart';
import 'core/models/project.dart';
import 'core/models/shop_item.dart';
import 'core/models/inventory.dart';
import 'core/models/item.dart';
import 'core/services/audio_service.dart';
import 'core/services/floating_window_service.dart';
import 'core/services/dark_mode_service.dart';
import 'ui/theme/extended_themes.dart';
import 'ui/screens/home_screen_v1_2.dart' as home_v12;
import 'providers/providers.dart';
// v3.0 多窗口支持
import 'main_window.dart';
import 'widget_window.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  // v3.0 多窗口支持：根据参数判断启动哪个窗口
  if (args.isNotEmpty) {
    final windowConfig = jsonDecode(args.first);
    final windowType = windowConfig['type'];

    if (windowType == 'widget') {
      // 挂件窗口：不初始化 Hive，避免文件锁冲突
      print('🪟 启动挂件窗口（不初始化数据库）');
      runApp(const WidgetWindowApp());
      return;
    }
  }

  // 主窗口：正常初始化所有服务
  print('🪟 启动主窗口（完整初始化）');

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(WorkRecordAdapter());
  Hive.registerAdapter(WorkSettingsAdapter());
  Hive.registerAdapter(AdventurerProfileAdapter());
  Hive.registerAdapter(AppSettingsAdapter());
  // v1.1.0 新增适配器
  Hive.registerAdapter(ProjectAdapter());
  Hive.registerAdapter(ShopItemAdapter());
  Hive.registerAdapter(InventoryAdapter());
  // v1.3.0 新增适配器
  Hive.registerAdapter(ItemAdapter());
  Hive.registerAdapter(ItemInstanceAdapter());
  Hive.registerAdapter(ItemTypeAdapter());
  Hive.registerAdapter(ItemEffectTypeAdapter());

  // Initialize providers (repository)
  await initializeProviders();

  // v1.1.0 初始化音效服务
  await AudioService().init();

  // v1.3.0 初始化新服务
  await FloatingWindowService().init();
  await DarkModeService().init();
  await ThemeManager().init();

  // 默认启动主窗口（v3.0 测试）
  runApp(const MainWindowApp());
}

// 保留 MyApp 类供将来使用
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: '工时计时器',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const home_v12.HomeScreenV12(),
    );
  }
}
