# 工时计时器 Flutter 应用

## 项目状态

✅ Flutter 项目已创建
✅ 核心数据模型已实现
✅ 业务逻辑层已实现
✅ 数据持久化已配置
✅ 基础 UI 已创建
✅ 代码生成已完成

## 已实现功能

- ✅ 工作记录数据模型（WorkRecord）
- ✅ 数据验证服务（ValidationService）
- ✅ 工时计算服务（CalculatorService）
- ✅ Hive 本地存储
- ✅ Riverpod 状态管理
- ✅ 主界面（计时器 + 今日统计）

## 运行应用

### 前置条件

1. **启用 Windows 开发者模式**（必需）
   - 按 `Win + I` 打开设置
   - 导航到：更新和安全 → 开发者选项
   - 启用"开发人员模式"
   - 或运行命令：`start ms-settings:developers`

2. **Visual Studio 2022**（Windows 桌面开发）
   - 需要安装"使用 C++ 的桌面开发"工作负载

### 运行步骤

```bash
# 1. 进入项目目录
cd flutter_app

# 2. 获取依赖
flutter pub get

# 3. 运行应用（Windows 桌面）
flutter run -d windows

# 4. 或者构建 Release 版本
flutter build windows --release
```

## 项目结构

```
lib/
├── core/
│   ├── models/
│   │   ├── work_record.dart          # 工作记录模型
│   │   └── daily_work_hours.dart     # 每日工时统计模型
│   └── services/
│       ├── validation_service.dart   # 数据验证服务
│       └── calculator_service.dart   # 工时计算服务
├── storage/
│   ├── record_repository.dart        # 存储接口
│   └── hive_record_repository.dart   # Hive 实现
├── providers/
│   └── providers.dart                # Riverpod Providers
├── ui/
│   └── screens/
│       └── home_screen.dart          # 主界面
└── main.dart                         # 应用入口
```

## 使用说明

1. **开始工作**
   - 点击"开始工作"按钮
   - 计时器开始运行

2. **下班**
   - 点击"下班"按钮
   - 工作记录自动保存
   - 今日统计自动更新

3. **查看统计**
   - 已工作：今日总工作时长
   - 剩余：距离 8 小时标准工时的剩余时间
   - 加班：超过 8 小时的加班时长

## 技术栈

- **Flutter**: 3.41.2
- **Dart**: 3.11.0
- **状态管理**: Riverpod 2.6.1
- **本地存储**: Hive 2.2.3
- **JSON 序列化**: json_serializable 6.8.0

## 下一步开发

- [ ] 添加午休功能
- [ ] 工作记录列表页面
- [ ] 数据导出/导入功能
- [ ] 报告生成（日/周/月/年）
- [ ] 响应式 UI（适配移动端）
- [ ] 国际化支持
- [ ] Android APK 打包

## 故障排除

### 问题：无法运行应用

**解决方案**：
1. 确保已启用开发者模式
2. 确保 Visual Studio 2022 已安装
3. 运行 `flutter doctor` 检查环境

### 问题：依赖包版本冲突

**解决方案**：
```bash
flutter pub upgrade
flutter pub get
```

### 问题：代码生成失败

**解决方案**：
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## 许可证

MIT License
