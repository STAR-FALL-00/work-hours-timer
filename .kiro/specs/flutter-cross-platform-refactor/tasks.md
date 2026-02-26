# 实施计划: Flutter 跨平台重构

## 概述

本实施计划将现有的 Electron/TypeScript 工时计算器应用重构为 Flutter 跨平台应用。实施将按照分层架构进行，从底层数据模型和存储开始，逐步构建业务逻辑层、分析层、导出层，最后实现 UI 层和跨平台适配。

## 任务列表

- [-] 1. 项目初始化和环境配置
  - 创建 Flutter 项目，配置支持 Windows、Android、iOS、macOS、Linux 平台
  - 配置 pubspec.yaml，添加依赖：riverpod、hive、hive_flutter、json_annotation、json_serializable、build_runner
  - 创建项目目录结构：lib/core、lib/analysis、lib/storage、lib/export、lib/ui
  - 配置 Hive 数据库初始化代码
  - _需求: 1.1, 1.2, 1.3, 1.4, 1.5_

- [ ] 2. Core 层 - 数据模型实现
  - [ ] 2.1 实现 WorkRecord 数据模型
    - 创建 lib/core/models/work_record.dart
    - 实现 WorkRecord 类，包含 id、startTime、endTime、date、duration 字段
    - 添加 @HiveType 和 @HiveField 注解
    - 实现 fromJson 和 toJson 方法（兼容 Electron 版本数据格式）
    - 实现 calculateDuration 静态方法
    - _需求: 2.1, 12.1, 12.2_
  
  - [ ]* 2.2 为 WorkRecord 编写单元测试
    - 测试 fromJson/toJson 往返一致性
    - 测试 calculateDuration 计算正确性
    - 测试边界情况（跨午夜、零时长等）
    - _需求: 2.1_
  
  - [ ] 2.3 实现 DailyWorkHours 模型
    - 创建 lib/core/models/daily_work_hours.dart
    - 实现 DailyWorkHours 类，包含 date、totalHours、workedHours、remainingHours、overtimeHours、standardHours 字段
    - _需求: 2.4, 2.5_
  
  - [ ] 2.4 实现 Report 系列模型
    - 创建 lib/core/models/reports.dart
    - 实现 DailyReport、WeeklyReport、MonthlyReport、YearlyReport 类
    - 为每个 Report 类添加 toJson 和 fromJson 方法
    - _需求: 2.6, 2.7_

- [ ] 3. Core 层 - 验证服务实现
  - [ ] 3.1 实现 ValidationService
    - 创建 lib/core/services/validation_service.dart
    - 实现 validateWorkRecord 方法，验证 startTime < endTime
    - 实现 validateDateRange 方法
    - 实现 ValidationResult 类
    - _需求: 2.2, 3.5_
  
  - [ ]* 3.2 为 ValidationService 编写单元测试
    - 测试有效时间记录验证
    - 测试无效时间记录验证（开始时间晚于结束时间）
    - 测试边界情况
    - _需求: 2.2, 3.5_

- [ ] 4. Storage 层 - 数据持久化实现
  - [ ] 4.1 实现 RecordRepository 接口
    - 创建 lib/storage/record_repository.dart
    - 定义 RecordRepository 抽象类
    - 定义 save、findByDate、findByDateRange、findAll、delete、update 方法
    - _需求: 7.1, 7.2_
  
  - [ ] 4.2 实现 HiveRecordRepository
    - 创建 lib/storage/hive_record_repository.dart
    - 实现 init 方法，初始化 Hive 数据库
    - 实现所有 RecordRepository 接口方法
    - 实现 _isSameDay 辅助方法
    - _需求: 7.1, 7.2, 7.3, 7.4_
  
  - [ ]* 4.3 为 HiveRecordRepository 编写集成测试
    - 测试保存和查询工作记录
    - 测试按日期范围查询
    - 测试更新和删除操作
    - 测试数据持久化（重启后数据仍存在）
    - _需求: 7.1, 7.2, 7.3_
  
  - [ ] 4.4 生成 Hive 适配器
    - 运行 build_runner 生成 WorkRecord 的 Hive 适配器
    - 验证生成的代码无错误
    - _需求: 7.1_

- [ ] 5. Checkpoint - 确保数据层测试通过
  - 确保所有测试通过，如有问题请询问用户

- [ ] 6. Core 层 - 计算服务实现
  - [ ] 6.1 实现 CalculatorService
    - 创建 lib/core/services/calculator_service.dart
    - 实现 addWorkRecord 方法，包含验证逻辑
    - 实现 getDailyWorkHours 方法，计算每日工时统计
    - 实现 getWorkRecords 方法，支持单日期和日期范围查询
    - 实现 deleteWorkRecord 和 updateWorkRecord 方法
    - _需求: 2.3, 2.4, 2.5, 3.1, 3.2, 3.3, 3.4, 6.3, 6.6_
  
  - [ ]* 6.2 为 CalculatorService 编写单元测试
    - 测试添加有效工作记录
    - 测试添加无效工作记录（应返回验证错误）
    - 测试每日工时计算（总工时、剩余工时、加班时长）
    - 测试查询和删除操作
    - _需求: 2.3, 2.4, 2.5, 3.5_

- [ ] 7. Analysis 层 - 时段分析实现
  - [ ] 7.1 实现 PeriodAnalyzer
    - 创建 lib/analysis/period_analyzer.dart
    - 实现 PeriodStatistics、PeriodData 类
    - 实现 analyzePeriods 方法，分析上午、中午、下午时段统计
    - 实现 _allocateRecordToPeriods 辅助方法
    - _需求: 2.6_
  
  - [ ]* 7.2 为 PeriodAnalyzer 编写单元测试
    - 测试单条记录的时段分配
    - 测试多条记录的时段统计
    - 测试跨时段记录的处理
    - _需求: 2.6_

- [ ] 8. Analysis 层 - 聚合分析实现
  - [ ] 8.1 实现 AggregationAnalyzer
    - 创建 lib/analysis/aggregation_analyzer.dart
    - 实现 generateDailyReport 方法
    - 实现 generateWeeklyReport 方法
    - 实现 generateMonthlyReport 方法
    - 实现 generateYearlyReport 方法
    - _需求: 2.7, 5.1, 5.2, 5.3_
  
  - [ ]* 8.2 为 AggregationAnalyzer 编写单元测试
    - 测试日报告生成
    - 测试周报告生成（包含多天数据）
    - 测试月报告生成
    - 测试年报告生成
    - _需求: 2.7_

- [ ] 9. Export 层 - 数据导出导入实现
  - [ ] 9.1 实现 DataSerializer
    - 创建 lib/export/data_serializer.dart
    - 实现 serialize 和 deserialize 方法（处理 Report 对象）
    - 实现 serializeRecords 和 deserializeRecords 方法
    - _需求: 8.3, 9.2, 12.2_
  
  - [ ] 9.2 实现 ReportExporter
    - 创建 lib/export/report_exporter.dart
    - 实现 exportDailyReport、exportWeeklyReport、exportMonthlyReport、exportYearlyReport 方法
    - 实现 importReport 方法
    - 实现 saveReportToFile 和 loadReportFromFile 方法（使用 path_provider 和 file_picker）
    - _需求: 8.1, 8.2, 8.3, 8.4, 8.5, 9.1, 9.2, 9.3_
  
  - [ ]* 9.3 为导出导入功能编写往返测试
    - **属性: 数据往返一致性**
    - **验证: 需求 12.3**
    - 测试导出后再导入，数据应保持一致
    - 测试 Electron 版本数据格式的导入兼容性
    - _需求: 8.3, 9.2, 12.2, 12.3, 12.5_

- [ ] 10. Checkpoint - 确保业务逻辑层测试通过
  - 确保所有测试通过，如有问题请询问用户

- [ ] 11. UI 层 - 状态管理配置
  - [ ] 11.1 配置 Riverpod Providers
    - 创建 lib/providers/repository_provider.dart
    - 创建 lib/providers/service_providers.dart
    - 定义 repositoryProvider、calculatorServiceProvider、analyzerServiceProvider、validationServiceProvider
    - _需求: 1.4_
  
  - [ ] 11.2 实现 TimerState 和 TimerNotifier
    - 创建 lib/ui/state/timer_state.dart
    - 实现 TimerState 类（包含 isRunning、startTime、currentDuration）
    - 实现 TimerNotifier 类，管理计时器状态
    - 实现 startWork、pauseWork、resumeWork、endWork 方法
    - _需求: 3.1, 3.2, 3.3, 3.4, 4.1, 4.2, 4.3, 4.4_
  
  - [ ] 11.3 实现 RecordListNotifier
    - 创建 lib/ui/state/record_list_state.dart
    - 实现 RecordListNotifier，管理工作记录列表状态
    - 实现加载、筛选、搜索功能
    - _需求: 6.1, 6.2, 6.4, 6.5_
  
  - [ ] 11.4 实现 StatisticsNotifier
    - 创建 lib/ui/state/statistics_state.dart
    - 实现 StatisticsNotifier，管理统计数据状态
    - 实现实时更新逻辑
    - _需求: 5.1, 5.2, 5.3, 5.4_

- [ ] 12. UI 层 - 基础组件实现
  - [ ] 12.1 实现 TimerCard 组件
    - 创建 lib/ui/widgets/timer_card.dart
    - 实现 CurrentTimeDisplay 组件
    - 实现 ElapsedTimeDisplay 组件（每秒更新）
    - 实现 TimerControlButtons 组件（开始、午休、结束午休、下班按钮）
    - _需求: 3.1, 3.2, 3.3, 3.4, 4.1, 4.2, 4.3, 4.4, 4.5_
  
  - [ ] 12.2 实现 StatisticsCard 组件
    - 创建 lib/ui/widgets/statistics_card.dart
    - 实现 StatItem 组件
    - 显示今日总工时、剩余工时、加班时长
    - 添加进度条或图表可视化
    - _需求: 5.1, 5.2, 5.3, 5.4, 5.5_
  
  - [ ] 12.3 实现 RecordListItem 组件
    - 创建 lib/ui/widgets/record_list_item.dart
    - 显示工作记录的日期、总工时、加班时长
    - 实现点击展开详情功能
    - 实现编辑和删除操作
    - _需求: 6.2, 6.3, 6.6_

- [ ] 13. UI 层 - 主要页面实现
  - [ ] 13.1 实现 HomeScreen
    - 创建 lib/ui/screens/home_screen.dart
    - 集成 TimerCard、StatisticsCard、QuickActionsBar
    - 实现底部导航栏（移动端）或侧边导航栏（桌面端）
    - _需求: 3.1, 3.2, 3.3, 3.4, 3.6, 4.1, 4.2, 4.3, 4.4, 5.1, 5.2, 5.3_
  
  - [ ] 13.2 实现 RecordListScreen
    - 创建 lib/ui/screens/record_list_screen.dart
    - 集成 RecordListItem 组件
    - 实现筛选对话框（按日期范围）
    - 实现搜索功能
    - 实现添加记录对话框
    - _需求: 6.1, 6.2, 6.3, 6.4, 6.5, 6.6_
  
  - [ ] 13.3 实现 ReportsScreen
    - 创建 lib/ui/screens/reports_screen.dart
    - 实现报告类型选择（日、周、月、年）
    - 实现日期选择器
    - 显示报告内容
    - 实现导出按钮
    - _需求: 8.1, 8.2, 8.6_
  
  - [ ] 13.4 实现 SettingsScreen
    - 创建 lib/ui/screens/settings_screen.dart
    - 实现语言切换功能
    - 实现数据导入/导出功能
    - 实现关于页面
    - _需求: 9.1, 9.6, 15.3, 15.4_

- [ ] 14. UI 层 - 响应式设计实现
  - [ ] 14.1 实现响应式布局工具
    - 创建 lib/ui/utils/responsive.dart
    - 实现屏幕尺寸检测（isMobile、isTablet、isDesktop）
    - 实现响应式值计算（根据屏幕尺寸返回不同值）
    - _需求: 10.1, 10.2, 10.3_
  
  - [ ] 14.2 适配移动端布局
    - 调整 HomeScreen 为单列布局
    - 实现底部导航栏
    - 调整字体和按钮尺寸
    - 确保触摸目标至少 48x48 dp
    - _需求: 10.1, 10.4, 10.5, 10.7_
  
  - [ ] 14.3 适配桌面端布局
    - 调整 HomeScreen 为多列布局
    - 实现侧边导航栏
    - 优化鼠标交互
    - _需求: 10.3, 10.4, 10.6, 10.7_
  
  - [ ] 14.4 适配平板端布局
    - 实现双列布局
    - 优化触摸和鼠标混合交互
    - _需求: 10.2, 10.4, 10.7_

- [ ] 15. Checkpoint - 确保 UI 功能完整
  - 确保所有测试通过，如有问题请询问用户

- [ ] 16. 本地化实现
  - [ ] 16.1 配置 Flutter 国际化
    - 在 pubspec.yaml 中添加 flutter_localizations 依赖
    - 配置 MaterialApp 的 localizationsDelegates 和 supportedLocales
    - _需求: 15.1, 15.2_
  
  - [ ] 16.2 创建本地化资源文件
    - 创建 lib/l10n/app_zh.arb（简体中文）
    - 创建 lib/l10n/app_en.arb（英文）
    - 翻译所有 UI 文本、错误消息、提示信息
    - _需求: 15.1, 15.2, 15.5_
  
  - [ ] 16.3 实现语言切换功能
    - 在 SettingsScreen 中实现语言选择
    - 实现语言偏好持久化
    - 实现动态语言切换（无需重启应用）
    - _需求: 15.3, 15.4_
  
  - [ ] 16.4 生成本地化代码
    - 运行 flutter gen-l10n 生成本地化代码
    - 在代码中使用 AppLocalizations
    - _需求: 15.5_

- [ ] 17. 错误处理和用户反馈
  - [ ] 17.1 实现全局错误处理
    - 创建 lib/core/error/error_handler.dart
    - 实现 ErrorHandler 类，捕获和记录错误
    - 实现用户友好的错误消息转换
    - _需求: 14.1, 14.2, 14.3, 14.5_
  
  - [ ] 17.2 实现 SnackBar 反馈机制
    - 创建 lib/ui/utils/feedback.dart
    - 实现 showSuccessMessage、showErrorMessage、showInfoMessage 方法
    - 在所有用户操作后显示反馈
    - _需求: 14.4, 14.6_
  
  - [ ] 17.3 实现错误日志记录
    - 集成 logger 包
    - 在关键操作中添加日志记录
    - 实现日志查看功能（开发者模式）
    - _需求: 14.5_

- [ ] 18. 跨平台适配
  - [ ] 18.1 Windows 平台适配
    - 配置 windows/runner 目录
    - 测试 Windows 桌面应用功能
    - 优化窗口大小和最小尺寸
    - _需求: 1.1, 11.1_
  
  - [ ] 18.2 Android 平台适配
    - 配置 android/app/build.gradle
    - 设置应用图标和启动画面
    - 配置权限（文件访问）
    - 测试 Android 应用功能
    - _需求: 1.1, 11.2_
  
  - [ ] 18.3 iOS 平台适配（可选）
    - 配置 ios/Runner 目录
    - 设置应用图标和启动画面
    - 配置权限（文件访问）
    - 测试 iOS 应用功能
    - _需求: 1.1, 11.3_
  
  - [ ] 18.4 macOS 平台适配（可选）
    - 配置 macos/Runner 目录
    - 测试 macOS 应用功能
    - _需求: 1.1, 11.4_
  
  - [ ] 18.5 Linux 平台适配（可选）
    - 配置 linux/runner 目录
    - 测试 Linux 应用功能
    - _需求: 1.1, 11.5_

- [ ] 19. 数据迁移和兼容性测试
  - [ ] 19.1 创建数据迁移指南
    - 创建 docs/migration_guide.md
    - 说明如何从 Electron 版本导出数据
    - 说明如何在 Flutter 版本中导入数据
    - _需求: 12.4_
  
  - [ ]* 19.2 测试 Electron 数据导入
    - 准备 Electron 版本导出的测试数据
    - 测试导入功能
    - 验证导入后数据的正确性
    - 测试往返属性（导入后再导出）
    - _需求: 12.1, 12.2, 12.3, 12.5_
  
  - [ ] 19.3 处理不兼容字段
    - 识别 Electron 版本中 Flutter 不支持的字段
    - 实现字段保留逻辑（避免数据丢失）
    - _需求: 12.5_

- [ ] 20. 性能优化
  - [ ] 20.1 优化应用启动时间
    - 实现延迟加载（lazy loading）
    - 优化数据库初始化
    - 测试启动时间（目标 < 3 秒）
    - _需求: 13.1_
  
  - [ ] 20.2 优化 UI 响应性能
    - 使用 Isolate 处理耗时操作
    - 优化列表渲染（使用 ListView.builder）
    - 测试操作响应时间（目标 < 100 毫秒）
    - _需求: 13.2_
  
  - [ ] 20.3 优化数据加载性能
    - 实现分页加载（如果记录数 > 1000）
    - 添加加载指示器
    - 测试数据加载时间（目标 < 500 毫秒）
    - _需求: 13.3_
  
  - [ ] 20.4 优化计时器性能
    - 确保计时器更新不影响 UI 流畅度
    - 测试帧率（目标 >= 30 FPS）
    - _需求: 13.4, 13.5_

- [ ] 21. Checkpoint - 确保性能达标
  - 确保所有测试通过，如有问题请询问用户

- [ ] 22. 构建和打包
  - [ ] 22.1 创建构建脚本
    - 创建 scripts/build_windows.bat
    - 创建 scripts/build_android.sh
    - 创建 scripts/build_ios.sh（可选）
    - 创建 scripts/build_macos.sh（可选）
    - 创建 scripts/build_linux.sh（可选）
    - _需求: 11.8_
  
  - [ ] 22.2 构建 Windows 安装包
    - 使用 flutter build windows --release
    - 使用 Inno Setup 或 NSIS 创建安装程序
    - 测试安装包大小（目标 < 50MB）
    - _需求: 11.1, 11.6_
  
  - [ ] 22.3 构建 Android APK
    - 使用 flutter build apk --release
    - 签名 APK
    - 测试 APK 大小（目标 < 20MB）
    - _需求: 11.2, 11.7_
  
  - [ ] 22.4 构建 iOS IPA（可选）
    - 使用 flutter build ios --release
    - 创建 IPA 文件
    - 测试 IPA 大小（目标 < 20MB）
    - _需求: 11.3, 11.7_
  
  - [ ] 22.5 构建 macOS DMG（可选）
    - 使用 flutter build macos --release
    - 创建 DMG 安装包
    - 测试安装包大小（目标 < 50MB）
    - _需求: 11.4, 11.6_
  
  - [ ] 22.6 构建 Linux 安装包（可选）
    - 使用 flutter build linux --release
    - 创建 AppImage 或 DEB 包
    - 测试安装包大小（目标 < 50MB）
    - _需求: 11.5, 11.6_

- [ ] 23. 文档和发布准备
  - [ ] 23.1 创建用户文档
    - 创建 docs/user_guide.md
    - 说明应用的主要功能和使用方法
    - 添加截图和示例
    - _需求: 12.4_
  
  - [ ] 23.2 创建开发者文档
    - 创建 docs/developer_guide.md
    - 说明项目结构和架构
    - 说明如何构建和调试
    - _需求: 11.8_
  
  - [ ] 23.3 更新 README
    - 更新项目简介
    - 添加安装说明
    - 添加功能列表
    - 添加截图
    - _需求: 11.8_
  
  - [ ] 23.4 准备发布说明
    - 创建 CHANGELOG.md
    - 列出新功能和改进
    - 列出已知问题
    - _需求: 12.4_

- [ ] 24. 最终测试和验收
  - [ ]* 24.1 执行端到端测试
    - 测试完整的工作流程（开始工作 → 午休 → 结束工作 → 查看统计 → 导出数据）
    - 测试数据迁移流程（从 Electron 导入数据）
    - 测试跨平台功能（Windows、Android）
    - _需求: 所有需求_
  
  - [ ]* 24.2 执行性能测试
    - 测试启动时间
    - 测试操作响应时间
    - 测试数据加载时间
    - 测试帧率
    - _需求: 13.1, 13.2, 13.3, 13.4, 13.5_
  
  - [ ]* 24.3 执行兼容性测试
    - 测试不同屏幕尺寸的显示效果
    - 测试不同系统语言的本地化
    - 测试 Electron 数据导入兼容性
    - _需求: 10.1, 10.2, 10.3, 12.1, 12.2, 12.3, 15.1, 15.2_

- [ ] 25. 最终 Checkpoint - 项目完成验收
  - 确保所有测试通过，所有功能正常工作，准备发布

## 注意事项

- 标记 `*` 的任务为可选任务，可以跳过以加快 MVP 开发
- 每个任务都引用了具体的需求编号，便于追溯
- Checkpoint 任务确保增量验证
- 属性测试验证通用正确性属性
- 单元测试验证具体示例和边界情况
- 建议按顺序执行任务，因为后续任务依赖前面的实现

## 技术栈总结

- Flutter 3.x + Dart 3.x
- Riverpod 2.x（状态管理）
- Hive 2.x（本地存储）
- json_serializable（JSON 序列化）
- flutter_localizations（国际化）
- path_provider + file_picker（文件操作）
- logger（日志记录）
