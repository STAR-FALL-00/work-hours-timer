import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/models/work_record.dart';
import 'core/models/work_settings.dart';
import 'core/models/adventurer_profile.dart';
import 'core/models/app_settings.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/game_home_screen.dart';
import 'providers/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(WorkRecordAdapter());
  Hive.registerAdapter(WorkSettingsAdapter());
  Hive.registerAdapter(AdventurerProfileAdapter());
  Hive.registerAdapter(AppSettingsAdapter());

  // Initialize providers (repository)
  await initializeProviders();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appSettings = ref.watch(appSettingsProvider);
    
    return MaterialApp(
      title: '工时计时器',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: appSettings.isGameMode ? const GameHomeScreen() : const HomeScreen(),
    );
  }
}
