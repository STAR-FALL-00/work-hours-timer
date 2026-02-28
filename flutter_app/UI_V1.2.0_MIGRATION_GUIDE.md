# v1.1.0 → v1.2.0 迁移指南

> **目标读者**: 需要将现有代码迁移到 v1.2.0 的开发者  
> **预计时间**: 30-60分钟

---

## 📋 迁移概览

v1.2.0 引入了全新的 Modern HUD 设计系统，包括：
- 统一的配色方案
- 新的文本样式系统
- 7个核心UI组件
- 4个重构的页面

**好消息**: 旧版本文件已保留，可以逐步迁移！

---

## 🚀 快速开始

### 1. 更新依赖（已完成）
```yaml
# pubspec.yaml
dependencies:
  google_fonts: ^6.1.0
  flutter_animate: ^4.3.0
  percent_indicator: ^4.2.3
  animations: ^2.0.8
```

### 2. 导入新组件
```dart
// 在需要使用新UI的文件中添加
import 'package:work_hours_timer/ui/widgets/modern_hud_widgets.dart';
import 'package:work_hours_timer/ui/theme/app_colors.dart';
import 'package:work_hours_timer/ui/theme/app_text_styles.dart';
import 'package:work_hours_timer/ui/theme/modern_hud_theme.dart';
```

---

## 🔄 迁移步骤

### Step 1: 切换到新版主页

**文件**: `lib/main.dart`

**旧代码**:
```dart
import 'ui/screens/home_screen.dart';  // 或 home_screen_v1_1.dart

home: const HomeScreen(),
```

**新代码**:
```dart
import 'ui/screens/home_screen_v1_2.dart';

home: const HomeScreenV12(),
```

**测试**: 运行应用，确认主页显示正常

---

### Step 2: 更新导航链接

如果你的其他页面有导航到主页的链接，需要更新：

**旧代码**:
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const HomeScreen()),
);
```

**新代码**:
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const HomeScreenV12()),
);
```

---

### Step 3: 更新商店页面（可选）

**文件**: 导航到商店的地方

**旧代码**:
```dart
import 'ui/screens/shop_screen.dart';

Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const ShopScreen()),
);
```

**新代码**:
```dart
import 'ui/screens/shop_screen_v1_2.dart';

Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const ShopScreenV12()),
);
```

---

### Step 4: 更新项目管理页面（可选）

**文件**: 导航到项目管理的地方

**旧代码**:
```dart
import 'ui/screens/projects_screen.dart';

Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const ProjectsScreen()),
);
```

**新代码**:
```dart
import 'ui/screens/projects_screen_v1_2.dart';

Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const ProjectsScreenV12()),
);
```

---

### Step 5: 更新统计页面（可选）

**文件**: 导航到统计的地方

**旧代码**:
```dart
import 'ui/screens/statistics_screen.dart';

Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const StatisticsScreen()),
);
```

**新代码**:
```dart
import 'ui/screens/statistics_screen_v1_2.dart';

Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const StatisticsScreenV12()),
);
```

---

## 🎨 使用新组件

### 替换自定义卡片为 MissionCard

**旧代码**:
```dart
Card(
  child: Column(
    children: [
      Text('当前项目: ${project.name}'),
      LinearProgressIndicator(value: project.progress),
      Text('${project.actualHours}h / ${project.estimatedHours}h'),
      Text(_formatDuration(_elapsed)),
      ElevatedButton(
        onPressed: _startWork,
        child: Text('开始工作'),
      ),
    ],
  ),
)
```

**新代码**:
```dart
MissionCard(
  projectName: project.name,
  bossProgress: project.progress,
  bossProgressText: '${project.actualHours}h / ${project.estimatedHours}h',
  timerText: _formatDuration(_elapsed),
  isWorking: _status == WorkStatus.working,
  statusText: _getStatusText(),
  onProjectTap: _showProjectSelector,
)
```

---

### 替换资源显示为 ResourceCapsule

**旧代码**:
```dart
Row(
  children: [
    Icon(Icons.monetization_on, color: Colors.amber),
    Text('${profile.gold}'),
    SizedBox(width: 16),
    Icon(Icons.star, color: Colors.purple),
    Text('${profile.experience}/${profile.level * 100}'),
  ],
)
```

**新代码**:
```dart
Row(
  children: [
    Expanded(
      child: ResourceCapsule(
        type: ResourceType.gold,
        current: profile.gold,
      ),
    ),
    SizedBox(width: ModernHudTheme.spacingS),
    Expanded(
      child: ResourceCapsule(
        type: ResourceType.exp,
        current: profile.experience,
        max: profile.level * 100,
      ),
    ),
  ],
)
```

---

### 替换按钮为 ActionButton

**旧代码**:
```dart
ElevatedButton(
  onPressed: _startWork,
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blue,
    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
  ),
  child: Row(
    children: [
      Icon(Icons.play_arrow),
      SizedBox(width: 8),
      Text('开始工作'),
    ],
  ),
)
```

**新代码**:
```dart
ActionButton(
  text: '开始工作',
  icon: Icons.play_arrow_rounded,
  type: ActionButtonType.primary,
  onPressed: _startWork,
)
```

---

### 添加飘字动画

**旧代码**:
```dart
// 结束工作后直接显示对话框
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('工作完成'),
    content: Text('获得 $gold 金币，$exp 经验'),
  ),
);
```

**新代码**:
```dart
// 先显示飘字动画
FloatingTextManager.showGold(context, amount: gold);
Future.delayed(Duration(milliseconds: 300), () {
  FloatingTextManager.showExp(context, amount: exp);
});

// 延迟显示对话框
Future.delayed(Duration(milliseconds: 1500), () {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('工作完成'),
      content: Text('获得 $gold 金币，$exp 经验'),
    ),
  );
});
```

---

## 🎨 使用新配色

### 替换硬编码颜色

**旧代码**:
```dart
Container(
  color: Colors.blue,
  child: Text(
    'Hello',
    style: TextStyle(fontSize: 16, color: Colors.black),
  ),
)
```

**新代码**:
```dart
final brightness = Theme.of(context).brightness;

Container(
  color: AppColors.getPrimary(brightness),
  child: Text(
    'Hello',
    style: AppTextStyles.bodyMedium(brightness),
  ),
)
```

---

### 使用渐变背景

**旧代码**:
```dart
Container(
  decoration: BoxDecoration(
    color: Colors.blue,
    borderRadius: BorderRadius.circular(12),
  ),
)
```

**新代码**:
```dart
Container(
  decoration: BoxDecoration(
    gradient: AppColors.getPrimaryGradient(),
    borderRadius: ModernHudTheme.buttonBorderRadius,
  ),
)
```

---

## 📏 使用新间距系统

### 替换硬编码间距

**旧代码**:
```dart
Padding(
  padding: EdgeInsets.all(16),
  child: Column(
    children: [
      Text('Title'),
      SizedBox(height: 24),
      Text('Content'),
    ],
  ),
)
```

**新代码**:
```dart
Padding(
  padding: EdgeInsets.all(ModernHudTheme.spacingL),
  child: Column(
    children: [
      Text('Title'),
      SizedBox(height: ModernHudTheme.spacingL),
      Text('Content'),
    ],
  ),
)
```

---

## 🔤 使用新文本样式

### 替换自定义文本样式

**旧代码**:
```dart
Text(
  '标题',
  style: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  ),
)
```

**新代码**:
```dart
final brightness = Theme.of(context).brightness;

Text(
  '标题',
  style: AppTextStyles.headline3(brightness),
)
```

---

## ⚠️ 常见问题

### Q1: 旧版本页面还能用吗？
**A**: 可以！旧版本文件已保留：
- `home_screen.dart` / `home_screen_v1_1.dart`
- `shop_screen.dart`
- `projects_screen.dart`
- `statistics_screen.dart`

你可以继续使用它们，或者逐步迁移。

---

### Q2: 必须全部迁移吗？
**A**: 不必须！你可以：
1. 只迁移主页（最小改动）
2. 逐个页面迁移
3. 混合使用新旧页面

建议优先迁移主页，因为它是用户最常用的页面。

---

### Q3: 如何回退到旧版本？
**A**: 很简单，只需修改 `main.dart`:
```dart
// 回退到 v1.1.0
import 'ui/screens/home_screen_v1_1.dart';
home: const HomeScreenV11(),

// 或回退到 v1.0
import 'ui/screens/home_screen.dart';
home: const HomeScreen(),
```

---

### Q4: 新组件支持暗色模式吗？
**A**: 支持！所有组件都通过 `brightness` 参数自动适配：
```dart
final brightness = Theme.of(context).brightness;
AppColors.getPrimary(brightness)  // 自动选择亮色/暗色
```

---

### Q5: 如何自定义组件样式？
**A**: 组件提供了丰富的参数：
```dart
ActionButton(
  text: '自定义按钮',
  icon: Icons.star,
  type: ActionButtonType.primary,
  onPressed: () {},
  // 可以通过 type 参数选择不同样式
)
```

如果需要完全自定义，可以参考组件源码创建自己的版本。

---

### Q6: 性能会受影响吗？
**A**: 不会！新组件：
- 使用 const 构造函数
- 优化了重建逻辑
- 动画性能良好
- 内存占用合理

---

## 🧪 测试清单

迁移完成后，请测试以下功能：

### 主页
- [ ] 页面正常显示
- [ ] 开始工作功能
- [ ] 暂停/继续功能
- [ ] 结束工作功能
- [ ] 项目选择功能
- [ ] 飘字动画显示
- [ ] 奖励对话框显示

### 商店（如果迁移）
- [ ] 商品列表显示
- [ ] 分类切换功能
- [ ] 购买流程
- [ ] 飘字动画

### 项目管理（如果迁移）
- [ ] 项目列表显示
- [ ] 创建项目功能
- [ ] 项目详情查看
- [ ] 快速开始功能
- [ ] 归档/删除功能

### 统计（如果迁移）
- [ ] 周期切换功能
- [ ] KPI指标显示
- [ ] 图表显示
- [ ] 热力图显示

---

## 📚 参考资料

### 快速参考
- `UI_V1.2.0_QUICK_REFERENCE.md` - 5分钟快速上手

### 详细文档
- `UI_COMPONENTS_SHOWCASE.md` - 完整组件文档
- `UI_REDESIGN_PLAN_v1.2.0.md` - 设计规范
- `UI_V1.2.0_TESTING_GUIDE.md` - 测试指南

### 示例代码
- `lib/ui/screens/home_screen_v1_2.dart` - 主页示例
- `lib/ui/screens/shop_screen_v1_2.dart` - 商店示例
- `lib/ui/screens/projects_screen_v1_2.dart` - 项目管理示例
- `lib/ui/screens/statistics_screen_v1_2.dart` - 统计示例

---

## 💡 最佳实践

### 1. 渐进式迁移
```
第1天: 迁移主页
第2天: 测试主页功能
第3天: 迁移商店页面
第4天: 测试商店功能
...
```

### 2. 保留备份
```dart
// 在迁移前，先复制一份旧代码
// 例如: home_screen_backup.dart
```

### 3. 分支开发
```bash
git checkout -b ui-v1.2.0-migration
# 在分支上进行迁移
# 测试通过后再合并到主分支
```

### 4. 用户反馈
- 先在测试环境部署
- 收集用户反馈
- 根据反馈调整
- 正式发布

---

## 🎯 迁移检查表

### 准备阶段
- [ ] 阅读迁移指南
- [ ] 查看快速参考
- [ ] 创建开发分支
- [ ] 备份现有代码

### 迁移阶段
- [ ] 更新 main.dart
- [ ] 迁移主页
- [ ] 迁移商店（可选）
- [ ] 迁移项目管理（可选）
- [ ] 迁移统计（可选）
- [ ] 更新导航链接

### 测试阶段
- [ ] 功能测试
- [ ] 视觉测试
- [ ] 性能测试
- [ ] 用户测试

### 发布阶段
- [ ] 代码审查
- [ ] 合并到主分支
- [ ] 打包发布
- [ ] 监控反馈

---

## 🆘 需要帮助？

### 遇到问题？
1. 查看 `UI_V1.2.0_TESTING_GUIDE.md`
2. 查看组件源码
3. 参考示例页面
4. 提交 Issue

### 反馈渠道
- GitHub Issues
- 团队讨论
- 代码审查

---

**创建日期**: 2026-02-26  
**版本**: v1.2.0  
**维护者**: 开发团队

---

🚀 **祝迁移顺利！** 🚀
