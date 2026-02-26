# 需求文档

## 简介

本项目旨在使用 Flutter 框架完全重构现有的基于 Electron 的桌面工时计时器应用，以实现真正的跨平台支持（Android、iOS、Windows、Mac、Linux）。重构将保留所有现有功能，同时提供响应式 UI 设计，适配不同设备屏幕尺寸，并确保数据格式兼容性，使用户能够从 Electron 版本无缝迁移。

## 术语表

- **Flutter_App**: 使用 Flutter 框架开发的跨平台工时计时器应用
- **Work_Record**: 工作记录实体，包含开始时间、午休时间、结束时间等信息
- **Timer_Display**: 实时计时显示组件，展示当前工作时长
- **Statistics_Module**: 统计模块，计算总工时、剩余工时、加班时长
- **Record_List**: 工作记录列表视图
- **Data_Storage**: 本地数据持久化层（使用 sqflite 或 hive）
- **Export_Service**: 数据导出服务，支持导出工作记录
- **Import_Service**: 数据导入服务，支持从 Electron 版本导入数据
- **Validation_Service**: 数据验证服务，确保工作记录的有效性
- **Calculator_Service**: 工时计算服务，处理工时相关计算逻辑
- **Period_Analyzer**: 时段分析器，分析特定时间段的工作数据
- **Aggregation_Analyzer**: 聚合分析器，提供汇总统计功能
- **State_Manager**: 状态管理器（Provider 或 Riverpod）
- **Responsive_UI**: 响应式用户界面，自适应不同屏幕尺寸
- **Desktop_Platform**: 桌面平台（Windows、Mac、Linux）
- **Mobile_Platform**: 移动平台（Android、iOS）
- **Legacy_Data**: 来自 Electron 版本的现有数据
- **Build_Artifact**: 构建产物（APK、EXE、DMG 等）

## 需求

### 需求 1: Flutter 项目初始化

**用户故事:** 作为开发者，我希望创建 Flutter 项目结构，以便开始跨平台应用开发。

#### 验收标准

1. THE Flutter_App SHALL 支持 Android、iOS、Windows、Mac、Linux 平台
2. THE Flutter_App SHALL 使用 Dart 语言开发
3. THE Flutter_App SHALL 包含清晰的分层架构（Core、Analysis、Storage、Export、UI）
4. THE Flutter_App SHALL 使用 Provider 或 Riverpod 作为状态管理方案
5. THE Flutter_App SHALL 配置 sqflite 或 hive 作为本地存储解决方案

### 需求 2: 核心业务逻辑迁移

**用户故事:** 作为开发者，我希望将现有 TypeScript 业务逻辑迁移到 Dart，以便在 Flutter 中复用核心功能。

#### 验收标准

1. THE Flutter_App SHALL 实现 Work_Record 实体类，包含所有必要字段（id、startTime、lunchBreakStart、lunchBreakEnd、endTime、notes）
2. THE Validation_Service SHALL 验证工作记录的时间逻辑（开始时间 < 午休开始 < 午休结束 < 结束时间）
3. THE Calculator_Service SHALL 计算工作时长，排除午休时间
4. THE Calculator_Service SHALL 计算剩余工时（基于标准工作时长 8 小时）
5. THE Calculator_Service SHALL 计算加班时长（超过标准工作时长的部分）
6. THE Period_Analyzer SHALL 分析指定时间段内的工作记录
7. THE Aggregation_Analyzer SHALL 提供日、周、月维度的统计汇总

### 需求 3: 工时记录功能

**用户故事:** 作为用户，我希望记录每日工作时间，以便追踪我的工作时长。

#### 验收标准

1. WHEN 用户点击"开始工作"按钮，THE Flutter_App SHALL 创建新的 Work_Record 并记录开始时间
2. WHEN 用户点击"午休"按钮，THE Flutter_App SHALL 记录午休开始时间
3. WHEN 用户点击"结束午休"按钮，THE Flutter_App SHALL 记录午休结束时间
4. WHEN 用户点击"下班"按钮，THE Flutter_App SHALL 记录结束时间并完成当前 Work_Record
5. IF 用户尝试创建无效的时间记录，THEN THE Validation_Service SHALL 返回错误信息并阻止保存
6. THE Flutter_App SHALL 允许用户为工作记录添加备注

### 需求 4: 实时计时显示

**用户故事:** 作为用户，我希望看到实时的工作计时，以便了解当前已工作时长。

#### 验收标准

1. WHILE 工作记录处于进行中状态，THE Timer_Display SHALL 每秒更新显示当前工作时长
2. THE Timer_Display SHALL 以易读格式显示时间（HH:MM:SS）
3. WHEN 用户进入午休状态，THE Timer_Display SHALL 暂停计时
4. WHEN 用户结束午休，THE Timer_Display SHALL 恢复计时
5. THE Timer_Display SHALL 在桌面和移动端都清晰可见

### 需求 5: 今日统计功能

**用户故事:** 作为用户，我希望查看今日工作统计，以便了解总工时、剩余工时和加班情况。

#### 验收标准

1. THE Statistics_Module SHALL 显示今日总工时
2. THE Statistics_Module SHALL 显示今日剩余工时（基于 8 小时标准）
3. THE Statistics_Module SHALL 显示今日加班时长（如果超过 8 小时）
4. WHEN 工作记录更新，THE Statistics_Module SHALL 实时更新统计数据
5. THE Statistics_Module SHALL 以直观的方式展示数据（数字 + 进度条或图表）

### 需求 6: 工作记录列表

**用户故事:** 作为用户，我希望查看历史工作记录，以便回顾过往的工作时间。

#### 验收标准

1. THE Record_List SHALL 显示所有历史工作记录，按日期降序排列
2. THE Record_List SHALL 显示每条记录的日期、总工时、加班时长
3. WHEN 用户点击某条记录，THE Flutter_App SHALL 显示该记录的详细信息
4. THE Record_List SHALL 支持按日期范围筛选
5. THE Record_List SHALL 支持搜索功能（按日期或备注）
6. THE Record_List SHALL 支持编辑和删除操作

### 需求 7: 数据持久化

**用户故事:** 作为用户，我希望我的工作记录被安全保存，以便下次打开应用时能够查看。

#### 验收标准

1. THE Data_Storage SHALL 在本地数据库中持久化所有工作记录
2. WHEN 用户创建或更新工作记录，THE Data_Storage SHALL 立即保存到本地数据库
3. WHEN 应用启动，THE Data_Storage SHALL 加载所有历史记录
4. THE Data_Storage SHALL 确保数据完整性和一致性
5. IF 数据库操作失败，THEN THE Data_Storage SHALL 返回错误信息并保持数据不变

### 需求 8: 数据导出功能

**用户故事:** 作为用户，我希望导出我的工作记录，以便备份或在其他地方使用。

#### 验收标准

1. THE Export_Service SHALL 支持导出所有工作记录为 JSON 格式
2. THE Export_Service SHALL 支持导出指定日期范围的工作记录
3. WHEN 用户触发导出，THE Export_Service SHALL 生成包含所有必要字段的 JSON 文件
4. THE Export_Service SHALL 在移动端保存文件到下载目录或共享文件
5. THE Export_Service SHALL 在桌面端允许用户选择保存位置
6. THE Export_Service SHALL 提供导出成功或失败的反馈

### 需求 9: 数据导入功能

**用户故事:** 作为用户，我希望导入之前的工作记录，以便从 Electron 版本迁移数据。

#### 验收标准

1. THE Import_Service SHALL 支持导入 JSON 格式的工作记录
2. THE Import_Service SHALL 验证导入数据的格式和有效性
3. THE Import_Service SHALL 兼容 Electron 版本导出的数据格式
4. IF 导入数据包含无效记录，THEN THE Import_Service SHALL 跳过无效记录并报告错误
5. WHEN 导入完成，THE Import_Service SHALL 显示导入成功的记录数量
6. THE Import_Service SHALL 避免重复导入相同的记录（基于 id 或时间戳）

### 需求 10: 响应式 UI 设计

**用户故事:** 作为用户，我希望应用在不同设备上都有良好的显示效果，以便在手机和电脑上都能舒适使用。

#### 验收标准

1. THE Responsive_UI SHALL 在移动端（屏幕宽度 < 600px）使用单列布局
2. THE Responsive_UI SHALL 在平板端（屏幕宽度 600-1024px）使用优化的双列布局
3. THE Responsive_UI SHALL 在桌面端（屏幕宽度 > 1024px）使用多列布局
4. THE Responsive_UI SHALL 根据屏幕尺寸调整字体大小和按钮尺寸
5. THE Responsive_UI SHALL 在移动端提供底部导航栏
6. THE Responsive_UI SHALL 在桌面端提供侧边导航栏或顶部导航栏
7. THE Responsive_UI SHALL 确保所有交互元素在触摸屏和鼠标操作下都易于使用

### 需求 11: 跨平台构建支持

**用户故事:** 作为开发者，我希望能够为不同平台构建安装包，以便分发应用。

#### 验收标准

1. THE Flutter_App SHALL 支持构建 Windows 桌面安装程序（.exe 或 .msi）
2. THE Flutter_App SHALL 支持构建 Android APK 文件
3. WHERE iOS 平台支持可用，THE Flutter_App SHALL 支持构建 iOS IPA 文件
4. WHERE Mac 平台支持可用，THE Flutter_App SHALL 支持构建 Mac DMG 或 PKG 文件
5. WHERE Linux 平台支持可用，THE Flutter_App SHALL 支持构建 Linux AppImage 或 DEB 文件
6. THE Build_Artifact SHALL 在桌面平台小于 50MB
7. THE Build_Artifact SHALL 在移动平台小于 20MB
8. THE Flutter_App SHALL 包含构建脚本和文档，说明如何为各平台构建

### 需求 12: 数据格式兼容性

**用户故事:** 作为用户，我希望能够无缝从 Electron 版本迁移到 Flutter 版本，以便不丢失任何历史数据。

#### 验收标准

1. THE Flutter_App SHALL 使用与 Electron 版本兼容的数据模型
2. THE Import_Service SHALL 正确解析 Electron 版本导出的 JSON 数据
3. FOR ALL 有效的 Legacy_Data，导入后再导出 SHALL 产生等效的数据结构（往返属性）
4. THE Flutter_App SHALL 提供数据迁移指南文档
5. IF Legacy_Data 包含 Flutter_App 不支持的字段，THEN THE Import_Service SHALL 保留这些字段以避免数据丢失

### 需求 13: 性能要求

**用户故事:** 作为用户，我希望应用响应迅速，以便获得流畅的使用体验。

#### 验收标准

1. WHEN 应用启动，THE Flutter_App SHALL 在 3 秒内显示主界面
2. WHEN 用户执行操作（点击按钮、切换页面），THE Flutter_App SHALL 在 100 毫秒内响应
3. WHEN 加载工作记录列表，THE Flutter_App SHALL 在 500 毫秒内显示数据（假设记录数 < 1000）
4. THE Timer_Display SHALL 每秒更新时不产生可见的卡顿
5. THE Flutter_App SHALL 在低端移动设备上保持至少 30 FPS 的帧率

### 需求 14: 错误处理和用户反馈

**用户故事:** 作为用户，我希望在出现错误时得到清晰的提示，以便了解问题并采取行动。

#### 验收标准

1. IF 数据库操作失败，THEN THE Flutter_App SHALL 显示用户友好的错误消息
2. IF 网络操作失败（如果涉及），THEN THE Flutter_App SHALL 显示连接错误提示
3. IF 导入数据格式无效，THEN THE Import_Service SHALL 显示具体的验证错误信息
4. WHEN 用户执行成功的操作（保存、导出、导入），THE Flutter_App SHALL 显示成功提示
5. THE Flutter_App SHALL 记录错误日志以便调试
6. THE Flutter_App SHALL 提供用户反馈机制（如错误报告功能）

### 需求 15: 本地化支持

**用户故事:** 作为用户，我希望应用支持中文界面，以便更好地理解和使用。

#### 验收标准

1. THE Flutter_App SHALL 支持简体中文界面
2. THE Flutter_App SHALL 支持英文界面
3. THE Flutter_App SHALL 根据系统语言自动选择界面语言
4. THE Flutter_App SHALL 允许用户手动切换界面语言
5. THE Flutter_App SHALL 确保所有 UI 文本、错误消息、提示信息都已本地化

## 附加说明

### 架构迁移映射

现有 Electron 架构到 Flutter 架构的映射关系：

- **Core 层** → `lib/core/`
  - WorkRecord → `lib/core/models/work_record.dart`
  - ValidationService → `lib/core/services/validation_service.dart`
  - WorkHoursCalculator → `lib/core/services/calculator_service.dart`

- **Analysis 层** → `lib/analysis/`
  - PeriodAnalyzer → `lib/analysis/period_analyzer.dart`
  - AggregationAnalyzer → `lib/analysis/aggregation_analyzer.dart`

- **Storage 层** → `lib/storage/`
  - RecordRepository → `lib/storage/record_repository.dart`
  - StorageAdapter → `lib/storage/storage_adapter.dart`

- **Export 层** → `lib/export/`
  - ReportExporter → `lib/export/report_exporter.dart`
  - DataSerializer → `lib/export/data_serializer.dart`

- **GUI 层** → `lib/ui/`
  - Electron 界面 → Flutter Widgets

### 技术选型建议

- **状态管理**: 推荐使用 Riverpod（更现代、类型安全）
- **本地存储**: 推荐使用 Hive（轻量、快速
、跨平台）
- **路由管理**: 推荐使用 go_router
- **UI 组件库**: 使用 Material Design 3

### 优先级说明

1. **P0（必须）**: 需求 1-9（核心功能和数据迁移）
2. **P1（重要）**: 需求 10-13（用户体验和性能）
3. **P2（可选）**: 需求 14-15（增强功能）

### 测试要求

- 所有核心业务逻辑必须包含单元测试
- 关键功能必须包含集成测试
- 数据导入/导出必须包含往返测试（round-trip property test）
- UI 组件应包含 Widget 测试
