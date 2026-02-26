# Flutter 跨平台重构 - 设计文档

## 概述 (Overview)

本设计文档描述了将现有的 Electron/TypeScript 工时计算器应用重构为 Flutter 跨平台应用的技术方案。Flutter 应用将支持 Windows、Android 以及其他平台（可选），并保持与原有 Electron 应用的数据兼容性。

### 设计目标

1. **跨平台支持**: 使用 Flutter 框架实现一次编写，多平台运行（Windows、Android、iOS、macOS、Linux）
2. **功能完整性**: 保留原有 Electron 应用的所有核心功能
3. **数据兼容性**: 能够导入和使用 Electron 应用生成的数据
4. **用户体验优化**: 针对不同平台提供原生化的用户体验
5. **可维护性**: 采用清晰的架构模式，便于后续维护和扩展

### 技术栈

- **框架**: Flutter 3.x
- **语言**: Dart 3.x
- **状态管理**: Riverpod 2.x
- **本地存储**: Hive 2.x (NoSQL 数据库)
- **依赖注入**: Riverpod Provider
- **测试**: flutter_test, mockito

## 架构设计 (Architecture)

### 整体架构

采用分层架构 (Layered Architecture) 结合 Clean Architecture 原则：

```
┌─────────────────────────────────────────────────────────────┐
│                      Presentation Layer                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Screens    │  │   Widgets    │  │  ViewModels  │      │
│  │              │  │              │  │  (Notifiers) │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                      Business Logic Layer                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  Calculator  │  │   Analyzer   │  │  Validator   │      │
│  │   Service    │  │   Service    │  │   Service    │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                         Data Layer                           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ Repositories │  │    Models    │  │   Adapters   │      │
│  │              │  │              │  │   (Hive)     │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                      Platform Layer                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ File System  │  │  Platform    │  │   Native     │      │
│  │   Access     │  │  Detection   │  │   Features   │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

### 架构层次说明

#### 1. Presentation Layer (表现层)

负责 UI 渲染和用户交互：

- **Screens**: 完整的页面组件（主页、记录列表、设置等）
- **Widgets**: 可复用的 UI 组件（计时器卡片、统计卡片等）
- **ViewModels (Notifiers)**: 使用 Riverpod 的 StateNotifier 管理 UI 状态

#### 2. Business Logic Layer (业务逻辑层)

包含核心业务逻辑，与 UI 和数据存储解耦：

- **CalculatorService**: 工时计算、记录管理
- **AnalyzerService**: 时段分析、聚合统计
- **ValidationService**: 数据验证

#### 3. Data Layer (数据层)

处理数据持久化和数据模型：

- **Repositories**: 数据访问接口实现
- **Models**: 数据模型类（WorkRecord、Report 等）
- **Adapters**: Hive 类型适配器

#### 4. Platform Layer (平台层)

处理平台特定功能：

- **File System Access**: 跨平台文件操作
- **Platform Detection**: 平台识别和适配
- **Native Features**: 平台特定功能（通知、后台任务等）

### 状态管理架构

使用 Riverpod 实现状态管理：

```dart
// Provider 层次结构
┌─────────────────────────────────────┐
│      Global Providers               │
│  - repositoryProvider               │
│  - calculatorServiceProvider        │
│  - analyzerServiceProvider          │
└─────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────┐
│      Feature Providers              │
│  - timerStateProvider               │
│  - recordListProvider               │
│  - statisticsProvider               │
│  - settingsProvider                 │
└─────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────┐
│      UI State Notifiers             │
│  - TimerNotifier                    │
│  - RecordListNotifier               │
│  - StatisticsNotifier               │
└─────────────────────────────────────┘
```

## 组件和接口设计 (Components and Interfaces)

### Core 层组件

#### 1. WorkRecord 模型

```dart
/// 工作记录数据模型
@HiveType(typeId: 0)
class WorkRecord extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final DateTime startTime;
  
  @HiveField(2)
  final DateTime endTime;
  
  @HiveField(3)
  final DateTime date;
  
  @HiveField(4)
  final Duration duration;
  
  WorkRecord({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.date,
    required this.duration,
  });
  
  /// 从 JSON 创建（用于导入 Electron 数据）
  factory WorkRecord.fromJson(Map<String, dynamic> json);
  
  /// 转换为 JSON（用于导出）
  Map<String, dynamic> toJson();
  
  /// 计算工作时长
  static Duration calculateDuration(DateTime start, DateTime end);
}
```

#### 2. ValidationService

```dart
/// 验证服务
class ValidationService {
  /// 验证工作记录
  ValidationResult validateWorkRecord(DateTime startTime, DateTime endTime);
  
  /// 验证日期范围
  ValidationResult validateDateRange(DateTime start, DateTime end);
}

/// 验证结果
class ValidationResult {
  final bool isValid;
  final List<String> errors;
  
  ValidationResult({required this.isValid, required this.errors});
}
```

#### 3. CalculatorService

```dart
/// 工时计算服务
class CalculatorService {
  final RecordRepository _repository;
  final ValidationService _validationService;
  
  CalculatorService(this._repository, this._validationService);
  
  /// 添加工作记录
  Future<Result<void, ValidationError>> addWorkRecord(WorkRecord record);
  
  /// 获取每日工作时长统计
  Future<DailyWorkHours> getDailyWorkHours(DateTime date);
  
  /// 获取工作记录（支持单日期和日期范围）
  Future<List<WorkRecord>> getWorkRecords({
    DateTime? date,
    DateTimeRange? dateRange,
  });
  
  /// 删除工作记录
  Future<void> deleteWorkRecord(String id);
  
  /// 更新工作记录
  Future<Result<void, ValidationError>> updateWorkRecord(WorkRecord record);
}
```

### Analysis 层组件

#### 1. PeriodAnalyzer

```dart
/// 时段分析器
class PeriodAnalyzer {
  /// 分析工作记录的时段统计
  PeriodStatistics analyzePeriods(List<WorkRecord> records);
  
  /// 将工作记录的时长分配到各时段
  PeriodAllocation _allocateRecordToPeriods(WorkRecord record);
}

/// 时段统计
class PeriodStatistics {
  final PeriodData morning;
  final PeriodData noon;
  final PeriodData afternoon;
  
  PeriodStatistics({
    required this.morning,
    required this.noon,
    required this.afternoon,
  });
}

/// 时段数据
class PeriodData {
  final Duration totalDuration;
  final Duration averageDuration;
  final int recordCount;
  final TimeOfDay? averageStartTime; // 仅上午时段有此字段
  
  PeriodData({
    required this.totalDuration,
    required this.averageDuration,
    required this.recordCount,
    this.averageStartTime,
  });
}
```

#### 2. AggregationAnalyzer

```dart
/// 聚合统计分析器
class AggregationAnalyzer {
  final CalculatorService _calculatorService;
  final PeriodAnalyzer _periodAnalyzer;
  
  AggregationAnalyzer(this._calculatorService, this._periodAnalyzer);
  
  /// 生成日报告
  Future<DailyReport> generateDailyReport(DateTime date);
  
  /// 生成周报告
  Future<WeeklyReport> generateWeeklyReport(DateTime weekStart);
  
  /// 生成月报告
  Future<MonthlyReport> generateMonthlyReport(int year, int month);
  
  /// 生成年报告
  Future<YearlyReport> generateYearlyReport(int year);
}
```

### Storage 层组件

#### 1. RecordRepository

```dart
/// 工作记录存储库接口
abstract class RecordRepository {
  /// 保存工作记录
  Future<void> save(WorkRecord record);
  
  /// 按日期查询工作记录
  Future<List<WorkRecord>> findByDate(DateTime date);
  
  /// 按日期范围查询工作记录
  Future<List<WorkRecord>> findByDateRange(DateTime start, DateTime end);
  
  /// 查询所有工作记录
  Future<List<WorkRecord>> findAll();
  
  /// 删除工作记录
  Future<void> delete(String id);
  
  /// 更新工作记录
  Future<void> update(WorkRecord record);
}
```

#### 2. HiveRecordRepository

```dart
/// Hive 实现的工作记录存储库
class HiveRecordRepository implements RecordRepository {
  late Box<WorkRecord> _recordBox;
  
  /// 初始化 Hive 数据库
  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(WorkRecordAdapter());
    _recordBox = await Hive.openBox<WorkRecord>('work_records');
  }
  
  @override
  Future<void> save(WorkRecord record) async {
    await _recordBox.put(record.id, record);
  }
  
  @override
  Future<List<WorkRecord>> findByDate(DateTime date) async {
    return _recordBox.values
        .where((record) => _isSameDay(record.date, date))
        .toList();
  }
  
  @override
  Future<List<WorkRecord>> findByDateRange(DateTime start, DateTime end) async {
    return _recordBox.values
        .where((record) => 
            record.date.isAfter(start.subtract(Duration(days: 1))) &&
            record.date.isBefore(end.add(Duration(days: 1))))
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }
  
  @override
  Future<List<WorkRecord>> findAll() async {
    return _recordBox.values.toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }
  
  @override
  Future<void> delete(String id) async {
    await _recordBox.delete(id);
  }
  
  @override
  Future<void> update(WorkRecord record) async {
    await _recordBox.put(record.id, record);
  }
  
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
}
```

### Export 层组件

#### 1. ReportExporter

```dart
/// 报告导出器
class ReportExporter {
  final DataSerializer _serializer;
  
  ReportExporter(this._serializer);
  
  /// 导出日报告
  String exportDailyReport(DailyReport report);
  
  /// 导出周报告
  String exportWeeklyReport(WeeklyReport report);
  
  /// 导出月报告
  String exportMonthlyReport(MonthlyReport report);
  
  /// 导出年报告
  String exportYearlyReport(YearlyReport report);
  
  /// 导入报告
  Report importReport(String data);
  
  /// 保存报告到文件
  Future<void> saveReportToFile(String data, String filename);
  
  /// 从文件读取报告
  Future<String> loadReportFromFile(String filepath);
}
```

#### 2. DataSerializer

```dart
/// 数据序列化器
class DataSerializer {
  /// 序列化报告为 JSON
  String serialize(Report report);
  
  /// 从 JSON 反序列化报告
  Report deserialize(String json);
  
  /// 序列化工作记录列表
  String serializeRecords(List<WorkRecord> records);
  
  /// 从 JSON 反序列化工作记录列表
  List<WorkRecord> deserializeRecords(String json);
}
```

### UI 层组件

#### 1. 主界面 (HomeScreen)

```dart
/// 主界面
class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('工时计算器')),
      body: Column(
        children: [
          TimerCard(),           // 计时器卡片
          StatisticsCard(),      // 统计卡片
          QuickActionsBar(),     // 快速操作栏
        ],
      ),
      bottomNavigationBar: AppBottomNavigation(),
    );
  }
}
```

#### 2. 计时器卡片 (TimerCard)

```dart
/// 计时器卡片
class TimerCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerStateProvider);
    
    return Card(
      child: Column(
        children: [
          // 当前时间显示
          CurrentTimeDisplay(),
          
          // 计时器状态显示
          if (timerState.isRunning)
            ElapsedTimeDisplay(startTime: timerState.startTime),
          
          // 操作按钮
          TimerControlButtons(),
        ],
      ),
    );
  }
}
```

#### 3. 统计卡片 (StatisticsCard)

```dart
/// 统计卡片
class StatisticsCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyStats = ref.watch(dailyStatisticsProvider);
    
    return Card(
      child: Column(
        children: [
          StatItem(
            label: '已工作',
            value: formatDuration(dailyStats.workedHours),
          ),
          StatItem(
            label: '剩余',
            value: formatDuration(dailyStats.remainingHours),
          ),
          StatItem(
            label: '加班',
            value: formatDuration(dailyStats.overtimeHours),
            highlight: dailyStats.overtimeHours > Duration.zero,
          ),
        ],
      ),
    );
  }
}
```

#### 4. 记录列表页面 (RecordListScreen)

```dart
/// 记录列表页面
class RecordListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(recordListProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('工作记录'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: records.when(
        data: (recordList) => ListView.builder(
          itemCount: recordList.length,
          itemBuilder: (context, index) {
            return RecordListItem(record: recordList[index]);
          },
        ),
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => ErrorDisplay(error: error),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRecordDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }
}
```

## 数据模型 (Data Models)

### 核心数据模型

#### 1. WorkRecord (工作记录)

```dart
@HiveType(typeId: 0)
class WorkRecord extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final DateTime startTime;
  
  @HiveField(2)
  final DateTime endTime;
  
  @HiveField(3)
  final DateTime date;
  
  @HiveField(4)
  final Duration duration;
  
  WorkRecord({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.date,
    required this.duration,
  });
}
```

#### 2. DailyWorkHours (每日工作时长)

```dart
class DailyWorkHours {
  final DateTime date;
  final Duration totalHours;
  final Duration workedHours;
  final Duration remainingHours;
  final Duration overtimeHours;
  final Duration standardHours; // 固定为 8 小时
  
  DailyWorkHours({
    required this.date,
    required this.totalHours,
    required this.workedHours,
    required this.remainingHours,
    required this.overtimeHours,
    required this.standardHours,
  });
}
```

#### 3. Report 类型

```dart
/// 日报告
class DailyReport {
  final DateTime date;
  final Duration totalHours;
  final Duration workedHours;
  final Duration remainingHours;
  final Duration overtimeHours;
  final PeriodStatistics periodBreakdown;
  
  DailyReport({
    required this.date,
    required this.totalHours,
    required this.workedHours,
    required this.remainingHours,
    required this.overtimeHours,
    required this.periodBreakdown,
  });
  
  Map<String, dynamic> toJson();
  factory DailyReport.fromJson(Map<String, dynamic> json);
}

/// 周报告
class WeeklyReport {
  final DateTime weekStart;
  final DateTime weekEnd;
  final Duration totalHours;
  final Duration averageDailyHours;
  final Duration totalOvertime;
  final PeriodStatistics periodAverages;
  final int workDays;
  
  WeeklyReport({
    required this.weekStart,
    required this.weekEnd,
    required this.totalHours,
    required this.averageDailyHours,
    required this.totalOvertime,
    required this.periodAverages,
    required this.workDays,
  });
  
  Map<String, dynamic> toJson();
  factory WeeklyReport.fromJson(Map<String, dynamic> json);
}

/// 月报告
class MonthlyReport {
  final int year;
  final int month;
  final Duration totalHours;
  final Duration averageDailyHours;
  final Duration totalOvertime;
  final PeriodStatistics periodAverages;
  final int workDays;
  
  MonthlyReport({
    required this.year,
    required this.month,
    required this.totalHours,
    required this.averageDailyHours,
    required this.totalOvertime,
    required this.periodAverages,
    required this.workDays,
  });
  
  Map<String, dynamic> toJson();
  factory MonthlyReport.fromJson(Map<String, dynamic> json);
}

/// 年报告
class YearlyReport {
  final int year;
  final Duration totalHours;
  final Duration averageDailyHours;
  final Duration totalOvertime;
  final PeriodStatistics periodAverages;
  final int workDays;
  final List<MonthlyReport> monthlyBreakdown;
  
  YearlyReport({
    required this.year,
    required this.totalHours,
    required this.averageDailyHours,
    required this.totalOvertime,
    required this.periodAverages,
    required this.workDays,
    required this.monthlyBreakdown,
  });
  
  Map<String, dynamic> toJson();
  factory YearlyReport.fromJson(Map<String, dynamic> json);
}
```

### Hive 数据库 Schema

```dart
// Box 定义
const String WORK_RECORDS_BOX = 'work_records';
const String SETTINGS_BOX = 'settings';

// Type IDs
const int WORK_RECORD_TYPE_ID = 0;
const int SETTINGS_TYPE_ID = 1;

// 数据库初始化
Future<void> initDatabase() async {
  await Hive.initFlutter();
  
  // 注册适配器
  Hive.registerAdapter(WorkRecordAdapter());
  Hive.registerAdapter(SettingsAdapter());
  
  // 打开 boxes
  await Hive.openBox<WorkRecord>(WORK_RECORDS_BOX);
  await Hive.openBox<Settings>(SETTINGS_BOX);
}
```

### JSON 序列化/反序列化

使用 `json_serializable` 包自动生成序列化代码：

```dart
import 'package:json_annotation/json_annotation.dart';

part 'work_record.g.dart';

@JsonSerializable()
class WorkRecord {
  final String id;
  
  @JsonKey(name: 'start_time')
  final DateTime startTime;
  
  @JsonKey(name: 'end_time')
  final DateTime endTime;
  
  final DateTime date;
  
  @JsonKey(fromJson: _durationFromJson, toJson: _durationToJson)
  final Duration duration;
  
  WorkRecord({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.date,
    required this.duration,
  });
  
  factory WorkRecord.fromJson(Map<String, dynamic> json) =>
      _$WorkRecordFromJson(json);
  
  Map<String, dynamic> toJson() => _$WorkRecordToJson(this);
  
  static Duration _durationFromJson(Map<String, dynamic> json) {
    return Duration(
      hours: json['hours'] as int,
      minutes: json['minutes'] as int,
      seconds: json['seconds'] as int,
    );
  }
  
  static Map<String, dynamic> _durationToJson(Duration duration) {
    return {
      'hours': duration.inHours,
      'minutes': duration.inMinutes.remainder(60),
      'seconds': duration.inSeconds.remainder(60),
    };
  }
}
```

## 正确性属性 (Correctness Properties)

*属性是一个特征或行为，应该在系统的所有有效执行中保持为真——本质上是关于系统应该做什么的形式化陈述。属性作为人类可读规范和机器可验证正确性保证之间的桥梁。*

在编写正确性属性之前，我需要先进行验收标准测试的预备工作分析。

