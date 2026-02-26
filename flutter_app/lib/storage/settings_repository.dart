import 'package:hive_flutter/hive_flutter.dart';
import '../core/models/work_settings.dart';

class SettingsRepository {
  static const String _boxName = 'work_settings';
  static const String _settingsKey = 'settings';

  Box<WorkSettings>? _box;

  Future<void> init() async {
    _box = await Hive.openBox<WorkSettings>(_boxName);
  }

  WorkSettings getSettings() {
    if (_box == null) {
      throw Exception('SettingsRepository not initialized');
    }
    return _box!.get(_settingsKey) ?? WorkSettings();
  }

  Future<void> saveSettings(WorkSettings settings) async {
    if (_box == null) {
      throw Exception('SettingsRepository not initialized');
    }
    await _box!.put(_settingsKey, settings);
  }
}
