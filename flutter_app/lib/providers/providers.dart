import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/hive_record_repository.dart';
import '../storage/record_repository.dart';
import '../storage/adventurer_repository.dart';
import '../storage/settings_repository.dart';
import '../storage/project_repository.dart';
import '../storage/shop_repository.dart';
import '../core/services/validation_service.dart';
import '../core/services/calculator_service.dart';
import '../core/services/project_service.dart';
import '../core/services/audio_service.dart';
import '../core/services/work_session_manager.dart';
import '../core/models/daily_work_hours.dart';
import '../core/models/work_record.dart';
import '../core/models/work_settings.dart';
import '../core/models/adventurer_profile.dart';
import '../core/models/app_settings.dart';
import '../core/models/project.dart';
import '../core/models/inventory.dart';

// 全局 repository 实例
final _repositoryInstance = HiveRecordRepository();
final _adventurerRepositoryInstance = AdventurerRepository();
final _settingsRepositoryInstance = SettingsRepository();
final _projectRepositoryInstance = ProjectRepository();
final _shopRepositoryInstance = ShopRepository();

// Repository Provider
final repositoryProvider = Provider<RecordRepository>((ref) {
  return _repositoryInstance;
});

final validationServiceProvider = Provider<ValidationService>((ref) {
  return ValidationService();
});

final calculatorServiceProvider = Provider<CalculatorService>((ref) {
  return CalculatorService(
    ref.watch(repositoryProvider),
    ref.watch(validationServiceProvider),
  );
});

// v1.1.0 新增服务 Providers
final projectServiceProvider = Provider<ProjectService>((ref) {
  return ProjectService(ref.watch(projectRepositoryProvider));
});

final audioServiceProvider = Provider<AudioService>((ref) {
  return AudioService();
});

final workSessionManagerProvider = Provider<WorkSessionManager>((ref) {
  return WorkSessionManager(
    projectService: ref.watch(projectServiceProvider),
    audioService: ref.watch(audioServiceProvider),
  );
});

final dailyWorkHoursProvider = FutureProvider.family<DailyWorkHours, DateTime>(
  (ref, date) async {
    final calculator = ref.watch(calculatorServiceProvider);
    return await calculator.getDailyWorkHours(date);
  },
);

// Today Records Provider
final todayRecordsProvider = FutureProvider<List<WorkRecord>>((ref) async {
  final calculator = ref.watch(calculatorServiceProvider);
  return await calculator.getWorkRecords(date: DateTime.now());
});

// Work Settings Provider
final workSettingsProvider =
    StateNotifierProvider<WorkSettingsNotifier, WorkSettings>((ref) {
  return WorkSettingsNotifier(_settingsRepositoryInstance);
});

class WorkSettingsNotifier extends StateNotifier<WorkSettings> {
  final SettingsRepository _repository;

  WorkSettingsNotifier(this._repository) : super(_repository.getSettings());

  Future<void> updateSettings(WorkSettings settings) async {
    await _repository.saveSettings(settings);
    state = settings;
  }

  void refresh() {
    state = _repository.getSettings();
  }
}

// Adventurer Repository Provider
final adventurerRepositoryProvider = Provider<AdventurerRepository>((ref) {
  return _adventurerRepositoryInstance;
});

// Adventurer Profile Provider
final adventurerProfileProvider =
    StateNotifierProvider<AdventurerProfileNotifier, AdventurerProfile>((ref) {
  return AdventurerProfileNotifier(ref.watch(adventurerRepositoryProvider));
});

class AdventurerProfileNotifier extends StateNotifier<AdventurerProfile> {
  final AdventurerRepository _repository;

  AdventurerProfileNotifier(this._repository) : super(_repository.getProfile());

  Future<void> addWorkExperience(int hours, int gold) async {
    final updated = await _repository.addWorkExperience(hours, gold);
    state = updated;

    // 检查并解锁成就
    await _repository.checkAndUnlockAchievements();
    // 重新加载以获取新成就
    state = _repository.getProfile();
  }

  Future<void> updateConsecutiveDays(int days) async {
    await _repository.updateConsecutiveDays(days);
    state = _repository.getProfile();
  }

  void refresh() {
    state = _repository.getProfile();
  }

  // 直接更新 profile（用于工作会话结算后）
  void updateProfile(AdventurerProfile profile) {
    state = profile;
  }
}

// App Settings Provider
final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettings>((ref) {
  return AppSettingsNotifier(ref.watch(adventurerRepositoryProvider));
});

class AppSettingsNotifier extends StateNotifier<AppSettings> {
  final AdventurerRepository _repository;

  AppSettingsNotifier(this._repository) : super(_repository.getSettings());

  Future<void> toggleGameMode() async {
    final newSettings = state.copyWith(isGameMode: !state.isGameMode);
    await _repository.saveSettings(newSettings);
    state = newSettings;
  }

  Future<void> setGameMode(bool isGameMode) async {
    final newSettings = state.copyWith(isGameMode: isGameMode);
    await _repository.saveSettings(newSettings);
    state = newSettings;
  }
}

// 初始化函数
Future<void> initializeProviders() async {
  await _repositoryInstance.init();
  await _adventurerRepositoryInstance.init();
  await _settingsRepositoryInstance.init();
  await _projectRepositoryInstance.init();
  await _shopRepositoryInstance.init();
}

// Statistics Models
class WeeklyStats {
  final Duration totalHours;
  final Map<DateTime, Duration> dailyHours;

  WeeklyStats({required this.totalHours, required this.dailyHours});
}

class MonthlyStats {
  final Duration totalHours;
  final int workDays;
  final Map<int, Duration> weeklyHours;

  MonthlyStats(
      {required this.totalHours,
      required this.workDays,
      required this.weeklyHours});
}

class YearlyStats {
  final Duration totalHours;
  final int workDays;
  final Map<int, Duration> monthlyHours;

  YearlyStats(
      {required this.totalHours,
      required this.workDays,
      required this.monthlyHours});
}

// Weekly Stats Provider
final weeklyStatsProvider =
    FutureProvider.family<WeeklyStats, DateTime>((ref, weekStart) async {
  final calculator = ref.watch(calculatorServiceProvider);

  // Normalize to start of day (00:00:00)
  final normalizedStart =
      DateTime(weekStart.year, weekStart.month, weekStart.day);
  final weekEnd = normalizedStart
      .add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

  final records = await calculator.getWorkRecords(
    dateRange: DateTimeRange(start: normalizedStart, end: weekEnd),
  );

  final dailyHours = <DateTime, Duration>{};
  for (var record in records) {
    final date = DateTime(record.date.year, record.date.month, record.date.day);
    dailyHours[date] = (dailyHours[date] ?? Duration.zero) + record.duration;
  }

  final totalHours = dailyHours.values.fold<Duration>(
    Duration.zero,
    (sum, duration) => sum + duration,
  );

  return WeeklyStats(totalHours: totalHours, dailyHours: dailyHours);
});

// Monthly Stats Provider
final monthlyStatsProvider =
    FutureProvider.family<MonthlyStats, DateTime>((ref, month) async {
  final calculator = ref.watch(calculatorServiceProvider);
  final monthStart = DateTime(month.year, month.month, 1);
  // 计算月末：下个月的第一天减去一天
  final nextMonth = month.month == 12
      ? DateTime(month.year + 1, 1, 1)
      : DateTime(month.year, month.month + 1, 1);
  final monthEnd = nextMonth.subtract(const Duration(days: 1));
  final normalizedMonthEnd =
      DateTime(monthEnd.year, monthEnd.month, monthEnd.day, 23, 59, 59);

  final records = await calculator.getWorkRecords(
    dateRange: DateTimeRange(start: monthStart, end: normalizedMonthEnd),
  );

  final weeklyHours = <int, Duration>{};
  final workDays = <DateTime>{};

  for (var record in records) {
    workDays
        .add(DateTime(record.date.year, record.date.month, record.date.day));
    final weekOfMonth = ((record.date.day - 1) ~/ 7) + 1;
    weeklyHours[weekOfMonth] =
        (weeklyHours[weekOfMonth] ?? Duration.zero) + record.duration;
  }

  final totalHours = weeklyHours.values.fold<Duration>(
    Duration.zero,
    (sum, duration) => sum + duration,
  );

  return MonthlyStats(
    totalHours: totalHours,
    workDays: workDays.length,
    weeklyHours: weeklyHours,
  );
});

// Yearly Stats Provider
final yearlyStatsProvider =
    FutureProvider.family<YearlyStats, int>((ref, year) async {
  final calculator = ref.watch(calculatorServiceProvider);
  final yearStart = DateTime(year, 1, 1);
  final yearEnd = DateTime(year, 12, 31, 23, 59, 59);

  final records = await calculator.getWorkRecords(
    dateRange: DateTimeRange(start: yearStart, end: yearEnd),
  );

  final monthlyHours = <int, Duration>{};
  final workDays = <DateTime>{};

  for (var record in records) {
    workDays
        .add(DateTime(record.date.year, record.date.month, record.date.day));
    monthlyHours[record.date.month] =
        (monthlyHours[record.date.month] ?? Duration.zero) + record.duration;
  }

  final totalHours = monthlyHours.values.fold<Duration>(
    Duration.zero,
    (sum, duration) => sum + duration,
  );

  return YearlyStats(
    totalHours: totalHours,
    workDays: workDays.length,
    monthlyHours: monthlyHours,
  );
});

// ==================== v1.1.0 新增 Providers ====================

// Project Repository Provider
final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return _projectRepositoryInstance;
});

// Shop Repository Provider
final shopRepositoryProvider = Provider<ShopRepository>((ref) {
  return _shopRepositoryInstance;
});

// All Projects Provider
final allProjectsProvider =
    StateNotifierProvider<ProjectsNotifier, List<Project>>((ref) {
  return ProjectsNotifier(ref.watch(projectRepositoryProvider));
});

class ProjectsNotifier extends StateNotifier<List<Project>> {
  final ProjectRepository _repository;

  ProjectsNotifier(this._repository) : super(_repository.getAllProjects());

  void refresh() {
    state = _repository.getAllProjects();
  }

  Future<void> createProject(Project project) async {
    await _repository.createProject(project);
    refresh();
  }

  Future<void> updateProject(Project project) async {
    await _repository.updateProject(project);
    refresh();
  }

  Future<void> deleteProject(String id) async {
    await _repository.deleteProject(id);
    refresh();
  }

  Future<Project?> addHoursToProject(String projectId, double hours) async {
    final updated = await _repository.addHoursToProject(projectId, hours);
    refresh();
    return updated;
  }

  Future<void> archiveProject(String id) async {
    await _repository.archiveProject(id);
    refresh();
  }

  Future<void> reactivateProject(String id) async {
    await _repository.reactivateProject(id);
    refresh();
  }
}

// Active Projects Provider
final activeProjectsProvider = Provider<List<Project>>((ref) {
  final all = ref.watch(allProjectsProvider);
  return all.where((p) => p.status == 'active').toList();
});

// Inventory Provider
final inventoryProvider =
    StateNotifierProvider<InventoryNotifier, Inventory>((ref) {
  return InventoryNotifier(ref.watch(shopRepositoryProvider));
});

class InventoryNotifier extends StateNotifier<Inventory> {
  final ShopRepository _repository;

  InventoryNotifier(this._repository) : super(_repository.getInventory());

  void refresh() {
    state = _repository.getInventory();
  }

  Future<void> purchaseItem(String itemId, int price,
      {bool isConsumable = false}) async {
    // 检查金币是否足够（由调用方处理）
    await _repository.purchaseItem(itemId, isConsumable: isConsumable);
    refresh();
  }

  Future<void> useConsumable(String itemId) async {
    await _repository.useConsumable(itemId);
    refresh();
  }

  Future<void> activateTheme(String themeId) async {
    await _repository.activateTheme(themeId);
    refresh();
  }

  Future<void> toggleDecoration(String decorationId) async {
    await _repository.toggleDecoration(decorationId);
    refresh();
  }
}

// Current Project Provider (用于主页选择当前工作的项目)
final currentProjectIdProvider = StateProvider<String?>((ref) => null);

final currentProjectProvider = Provider<Project?>((ref) {
  final projectId = ref.watch(currentProjectIdProvider);
  if (projectId == null) return null;

  final projects = ref.watch(allProjectsProvider);
  try {
    return projects.firstWhere((p) => p.id == projectId);
  } catch (e) {
    return null;
  }
});

// Heatmap Data Provider (过去一年的每日工作数据)
final heatmapDataProvider =
    FutureProvider<Map<DateTime, Duration>>((ref) async {
  final calculator = ref.watch(calculatorServiceProvider);
  final now = DateTime.now();
  final oneYearAgo = DateTime(now.year - 1, now.month, now.day);

  final records = await calculator.getWorkRecords(
    dateRange: DateTimeRange(start: oneYearAgo, end: now),
  );

  final dailyHours = <DateTime, Duration>{};
  for (var record in records) {
    // 标准化日期到午夜
    final date = DateTime(record.date.year, record.date.month, record.date.day);
    dailyHours[date] = (dailyHours[date] ?? Duration.zero) + record.duration;
  }

  return dailyHours;
});
