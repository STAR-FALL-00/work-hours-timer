# UI v1.2.0 快速参考

> **快速上手指南** - 5分钟了解如何使用新版 UI 组件

---

## 📦 导入组件

```dart
// 一次性导入所有组件
import 'package:work_hours_timer/ui/widgets/modern_hud_widgets.dart';
import 'package:work_hours_timer/ui/theme/app_colors.dart';
import 'package:work_hours_timer/ui/theme/app_text_styles.dart';
import 'package:work_hours_timer/ui/theme/modern_hud_theme.dart';
```

---

## 🎨 使用配色

```dart
// 获取主色调（自动适配亮色/暗色模式）
final brightness = Theme.of(context).brightness;
final primaryColor = AppColors.getPrimary(brightness);

// 使用预定义颜色
Container(
  color: AppColors.accent,        // 金币色
  child: Text(
    'Hello',
    style: AppTextStyles.headline3(brightness),
  ),
)

// 使用渐变
Container(
  decoration: BoxDecoration(
    gradient: AppColors.getPrimaryGradient(),
  ),
)
```

---

## 🔤 使用文本样式

```dart
final brightness = Theme.of(context).brightness;

// 标题
Text('标题', style: AppTextStyles.headline3(brightness))

// 正文
Text('正文', style: AppTextStyles.bodyMedium(brightness))

// 计时器数字
Text('00:00:00', style: AppTextStyles.timerLarge(brightness))

// 金币数字
Text('1000', style: AppTextStyles.goldAmount(brightness))
```

---

## 🃏 使用卡片组件

### MissionCard - 任务卡片
```dart
MissionCard(
  projectName: '重构登录页',           // 项目名称（可选）
  bossProgress: 0.6,                  // BOSS血条进度（可选）
  bossProgressText: '6.0h / 10.0h',   // 进度文字（可选）
  timerText: '01:23:45',              // 计时器文字
  isWorking: true,                    // 是否工作中
  statusText: '🟢 战斗中',            // 状态文字
  predictedGold: 83,                  // 预计金币（可选）
  predictedExp: 138,                  // 预计经验（可选）
  comboHint: '🔥 连击奖励已激活！',   // 连击提示（可选）
  onProjectTap: () {                  // 点击项目名称回调（可选）
    // 显示项目选择器
  },
)
```

### ResourceCapsule - 资源胶囊
```dart
// 金币胶囊
ResourceCapsule(
  type: ResourceType.gold,
  current: 1234,
)

// 经验值胶囊（带进度条）
ResourceCapsule(
  type: ResourceType.exp,
  current: 450,
  max: 1000,
)
```

### QuestTile - 项目列表项
```dart
QuestTile(
  projectName: '重构登录页',
  progress: 0.6,
  progressText: '6.0h',
  monsterIcon: '🐉',
  onTap: () {
    // 查看详情
  },
  onStart: () {
    // 快速开始
  },
  onMore: () {
    // 更多操作
  },
)
```

### KpiCard - KPI指标卡片
```dart
KpiCard(
  icon: Icons.access_time,
  label: '总工时',
  value: '48h',
  subtitle: '本周',              // 可选
  accentColor: AppColors.primaryLight,
)
```

### ItemCard - 商品卡片
```dart
ItemCard(
  emoji: '🎨',
  name: '深海主题',
  price: 500,
  isOwned: true,                 // 是否已拥有
  isEquipped: false,             // 是否装备中
  count: 3,                      // 数量（消耗品）
  onTap: () {
    // 查看详情
  },
)
```

---

## 🔘 使用按钮

### ActionButton - 操作按钮
```dart
// 主要按钮（渐变背景）
ActionButton(
  text: '开始工作',
  icon: Icons.play_arrow_rounded,
  type: ActionButtonType.primary,
  onPressed: () {
    // 开始工作
  },
)

// 战斗按钮（红色）
ActionButton(
  text: '结束战斗',
  icon: Icons.stop_rounded,
  type: ActionButtonType.combat,
  onPressed: () {
    // 结束工作
  },
)

// 休息按钮（绿色）
ActionButton(
  text: '暂停',
  icon: Icons.pause_rounded,
  type: ActionButtonType.rest,
  onPressed: () {
    // 暂停
  },
)

// 金币按钮（金色）
ActionButton(
  text: '购买',
  icon: Icons.shopping_cart,
  type: ActionButtonType.gold,
  onPressed: () {
    // 购买
  },
)
```

---

## ✨ 使用飘字动画

### FloatingText - 飘字动画
```dart
// 显示金币飘字
FloatingTextManager.showGold(
  context,
  amount: 100,
)

// 显示经验值飘字
FloatingTextManager.showExp(
  context,
  amount: 150,
)

// 显示升级飘字
FloatingTextManager.showLevelUp(
  context,
  level: 5,
)

// 自定义飘字
FloatingTextManager.show(
  context,
  text: '✨ 成就解锁！',
  type: FloatingTextType.levelUp,
)
```

---

## 📏 使用间距

```dart
// 使用预定义间距
SizedBox(height: ModernHudTheme.spacingM)  // 16px
SizedBox(width: ModernHudTheme.spacingL)   // 24px

// 所有间距选项
ModernHudTheme.spacingXS  // 4px
ModernHudTheme.spacingS   // 8px
ModernHudTheme.spacingM   // 16px
ModernHudTheme.spacingL   // 24px
ModernHudTheme.spacingXL  // 32px
```

---

## 🎯 使用圆角

```dart
// 使用预定义圆角
Container(
  decoration: BoxDecoration(
    borderRadius: ModernHudTheme.cardBorderRadius,  // 16px
  ),
)

// 所有圆角选项
ModernHudTheme.cardBorderRadius    // 16px
ModernHudTheme.buttonBorderRadius  // 12px
ModernHudTheme.chipBorderRadius    // 20px
```

---

## 🌈 常用颜色组合

### 主色调组合
```dart
Container(
  decoration: BoxDecoration(
    gradient: AppColors.getPrimaryGradient(),
    borderRadius: BorderRadius.circular(12),
  ),
  child: Text(
    '主要按钮',
    style: AppTextStyles.buttonMedium(brightness).copyWith(
      color: Colors.white,
    ),
  ),
)
```

### 金币组合
```dart
Row(
  children: [
    Icon(Icons.monetization_on, color: AppColors.accent),
    SizedBox(width: 4),
    Text('1000', style: AppTextStyles.goldAmount(brightness)),
  ],
)
```

### 经验值组合
```dart
Row(
  children: [
    Icon(Icons.star, color: AppColors.expBar),
    SizedBox(width: 4),
    Text('450/1000', style: AppTextStyles.expAmount(brightness)),
  ],
)
```

### 状态组合
```dart
// 成功状态
Container(
  color: AppColors.success.withValues(alpha: 0.1),
  child: Row(
    children: [
      Icon(Icons.check_circle, color: AppColors.success),
      Text('成功', style: AppTextStyles.statusSuccess(brightness)),
    ],
  ),
)

// 错误状态
Container(
  color: AppColors.error.withValues(alpha: 0.1),
  child: Row(
    children: [
      Icon(Icons.error, color: AppColors.error),
      Text('错误', style: AppTextStyles.statusError(brightness)),
    ],
  ),
)
```

---

## 📱 响应式布局

```dart
// 根据屏幕宽度调整列数
final screenWidth = MediaQuery.of(context).size.width;
final crossAxisCount = screenWidth > 600 ? 3 : 2;

GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: crossAxisCount,
    childAspectRatio: 0.75,
    crossAxisSpacing: ModernHudTheme.spacingM,
    mainAxisSpacing: ModernHudTheme.spacingM,
  ),
  itemBuilder: (context, index) {
    return ItemCard(...);
  },
)
```

---

## 🎭 亮色/暗色模式

```dart
// 获取当前亮度
final brightness = Theme.of(context).brightness;

// 使用自适应颜色
Container(
  color: AppColors.getBackground(brightness),
  child: Text(
    'Hello',
    style: AppTextStyles.bodyMedium(brightness),
  ),
)

// 自定义亮色/暗色
final color = brightness == Brightness.light
    ? AppColors.primaryLight
    : AppColors.primaryDark;
```

---

## 🔧 常用模式

### 卡片容器
```dart
Card(
  elevation: 2,
  shadowColor: AppColors.getShadow(brightness).withValues(alpha: 0.1),
  shape: RoundedRectangleBorder(
    borderRadius: ModernHudTheme.cardBorderRadius,
  ),
  child: Padding(
    padding: const EdgeInsets.all(ModernHudTheme.spacingL),
    child: Column(
      children: [
        // 内容
      ],
    ),
  ),
)
```

### 渐变按钮
```dart
Container(
  decoration: BoxDecoration(
    gradient: AppColors.getPrimaryGradient(),
    borderRadius: ModernHudTheme.buttonBorderRadius,
  ),
  child: Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: () {},
      borderRadius: ModernHudTheme.buttonBorderRadius,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: ModernHudTheme.spacingL,
          vertical: ModernHudTheme.spacingM,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.play_arrow, color: Colors.white),
            SizedBox(width: ModernHudTheme.spacingS),
            Text('开始', style: AppTextStyles.buttonMedium(brightness)),
          ],
        ),
      ),
    ),
  ),
)
```

### 芯片选择器
```dart
Container(
  padding: const EdgeInsets.symmetric(
    horizontal: ModernHudTheme.spacingM,
    vertical: ModernHudTheme.spacingS,
  ),
  decoration: BoxDecoration(
    gradient: isSelected ? AppColors.getPrimaryGradient() : null,
    color: isSelected ? null : AppColors.getPrimary(brightness).withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: isSelected ? Colors.transparent : AppColors.getPrimary(brightness).withValues(alpha: 0.3),
      width: 1.5,
    ),
  ),
  child: Row(
    children: [
      Icon(Icons.star, color: isSelected ? Colors.white : AppColors.getPrimary(brightness)),
      SizedBox(width: ModernHudTheme.spacingS),
      Text('选项', style: AppTextStyles.labelLarge(brightness).copyWith(
        color: isSelected ? Colors.white : AppColors.getPrimary(brightness),
      )),
    ],
  ),
)
```

---

## 📚 完整示例

### 创建一个新页面
```dart
import 'package:flutter/material.dart';
import 'package:work_hours_timer/ui/widgets/modern_hud_widgets.dart';
import 'package:work_hours_timer/ui/theme/app_colors.dart';
import 'package:work_hours_timer/ui/theme/app_text_styles.dart';
import 'package:work_hours_timer/ui/theme/modern_hud_theme.dart';

class MyNewScreen extends StatelessWidget {
  const MyNewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      backgroundColor: AppColors.getBackground(brightness),
      appBar: AppBar(
        title: Text(
          '我的页面',
          style: AppTextStyles.headline3(brightness),
        ),
        backgroundColor: AppColors.getPrimary(brightness),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(ModernHudTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // KPI 指标行
            Row(
              children: [
                Expanded(
                  child: KpiCard(
                    icon: Icons.access_time,
                    label: '总工时',
                    value: '48h',
                    accentColor: AppColors.primaryLight,
                  ),
                ),
                const SizedBox(width: ModernHudTheme.spacingM),
                Expanded(
                  child: KpiCard(
                    icon: Icons.event,
                    label: '工作天数',
                    value: '5',
                    subtitle: '天',
                    accentColor: AppColors.success,
                  ),
                ),
              ],
            ),

            const SizedBox(height: ModernHudTheme.spacingL),

            // 操作按钮
            ActionButton(
              text: '开始工作',
              icon: Icons.play_arrow_rounded,
              type: ActionButtonType.primary,
              onPressed: () {
                // 显示飘字
                FloatingTextManager.showGold(context, amount: 100);
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 🎯 最佳实践

### 1. 始终使用 brightness 参数
```dart
// ✅ 好
final brightness = Theme.of(context).brightness;
Text('Hello', style: AppTextStyles.bodyMedium(brightness))

// ❌ 不好
Text('Hello', style: TextStyle(fontSize: 14))
```

### 2. 使用预定义间距
```dart
// ✅ 好
SizedBox(height: ModernHudTheme.spacingM)

// ❌ 不好
SizedBox(height: 16)
```

### 3. 使用预定义颜色
```dart
// ✅ 好
Container(color: AppColors.accent)

// ❌ 不好
Container(color: Color(0xFFF59E0B))
```

### 4. 使用组件而不是重复代码
```dart
// ✅ 好
KpiCard(icon: Icons.star, label: '等级', value: '5')

// ❌ 不好
Card(
  child: Column(
    children: [
      Icon(Icons.star),
      Text('等级'),
      Text('5'),
    ],
  ),
)
```

---

## 🔗 相关文档

- **完整组件文档**: `UI_COMPONENTS_SHOWCASE.md`
- **设计规范**: `UI_REDESIGN_PLAN_v1.2.0.md`
- **测试指南**: `UI_V1.2.0_TESTING_GUIDE.md`
- **完整总结**: `UI_REDESIGN_V1.2.0_COMPLETE.md`

---

**创建日期**: 2026-02-26  
**版本**: v1.2.0  
**维护者**: 开发团队
