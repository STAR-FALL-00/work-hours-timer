import 'package:hive_flutter/hive_flutter.dart';
import '../core/models/adventurer_profile.dart';
import '../core/models/app_settings.dart';

class AdventurerRepository {
  static const String _profileBoxName = 'adventurer_profile';
  static const String _settingsBoxName = 'app_settings';
  static const String _profileKey = 'profile';
  static const String _settingsKey = 'settings';

  Box<AdventurerProfile>? _profileBox;
  Box<AppSettings>? _settingsBox;

  Future<void> init() async {
    _profileBox = await Hive.openBox<AdventurerProfile>(_profileBoxName);
    _settingsBox = await Hive.openBox<AppSettings>(_settingsBoxName);
  }

  // 获取冒险者资料
  AdventurerProfile getProfile() {
    if (_profileBox == null) {
      throw Exception('AdventurerRepository not initialized');
    }
    return _profileBox!.get(_profileKey) ?? AdventurerProfile();
  }

  // 保存冒险者资料
  Future<void> saveProfile(AdventurerProfile profile) async {
    if (_profileBox == null) {
      throw Exception('AdventurerRepository not initialized');
    }
    await _profileBox!.put(_profileKey, profile);
  }

  // 获取应用设置
  AppSettings getSettings() {
    if (_settingsBox == null) {
      throw Exception('AdventurerRepository not initialized');
    }
    return _settingsBox!.get(_settingsKey) ?? AppSettings();
  }

  // 保存应用设置
  Future<void> saveSettings(AppSettings settings) async {
    if (_settingsBox == null) {
      throw Exception('AdventurerRepository not initialized');
    }
    await _settingsBox!.put(_settingsKey, settings);
  }

  // 更新工作经验
  Future<AdventurerProfile> addWorkExperience(int hours, int gold) async {
    final profile = getProfile();
    final updatedProfile = profile
        .addWorkExperience(hours)
        .addGold(gold);
    await saveProfile(updatedProfile);
    return updatedProfile;
  }

  // 更新连续工作天数
  Future<void> updateConsecutiveDays(int days) async {
    final profile = getProfile();
    final updatedProfile = profile.updateConsecutiveDays(days);
    await saveProfile(updatedProfile);
  }

  // 解锁成就
  Future<void> unlockAchievement(String achievementId) async {
    final profile = getProfile();
    final updatedProfile = profile.unlockAchievement(achievementId);
    await saveProfile(updatedProfile);
  }

  // 检查并解锁所有符合条件的成就
  Future<List<String>> checkAndUnlockAchievements() async {
    final profile = getProfile();
    final newAchievements = <String>[];

    for (final achievement in Achievement.all) {
      if (!profile.achievements.contains(achievement.id) &&
          achievement.condition(profile)) {
        await unlockAchievement(achievement.id);
        newAchievements.add(achievement.id);
      }
    }

    return newAchievements;
  }
}
