# 史莱姆动画资源完整清单

## ✅ 切割完成状态

所有史莱姆动画已成功切割为单帧！

---

## 👾 史莱姆（Slime Enemy）可用动画

### 1. Idle（待机）
- **帧数**: 7 帧
- **路径**: `Slime Enemy/Idle/Frames/frame_0.png` ~ `frame_6.png`
- **用途**: 待机、休息
- **状态**: ✅ 已集成到项目

### 2. Hurt（受击）
- **帧数**: 11 帧
- **路径**: `Slime Enemy/Hurt/Frames/frame_0.png` ~ `frame_10.png`
- **用途**: 被攻击时的反应
- **状态**: ✅ 已集成到项目

### 3. Death（死亡）
- **帧数**: 14 帧
- **路径**: `Slime Enemy/Death/Frames/frame_0.png` ~ `frame_13.png`
- **用途**: 死亡动画（血量为0时）
- **状态**: ✅ 已集成到项目

### 4. Jump（跳跃）- 新切割！
跳跃动画分为 5 个阶段，共 22 帧：

#### 4.1 Jump Start（起跳准备）
- **帧数**: 9 帧
- **路径**: `Slime Enemy/Jump/Frames/Start/frame_0.png` ~ `frame_8.png`
- **用途**: 跳跃前的蓄力动作
- **状态**: ✅ 已切割，未集成

#### 4.2 Jump Up（向上跳）
- **帧数**: 1 帧
- **路径**: `Slime Enemy/Jump/Frames/Up/frame_0.png`
- **用途**: 跳跃上升阶段
- **状态**: ✅ 已切割，未集成

#### 4.3 Jump ToFall（跳跃到下落）
- **帧数**: 5 帧
- **路径**: `Slime Enemy/Jump/Frames/ToFall/frame_0.png` ~ `frame_4.png`
- **用途**: 从上升到下落的过渡
- **状态**: ✅ 已切割，未集成

#### 4.4 Jump Down（下落）
- **帧数**: 1 帧
- **路径**: `Slime Enemy/Jump/Frames/Down/frame_0.png`
- **用途**: 下落阶段
- **状态**: ✅ 已切割，未集成

#### 4.5 Jump Land（落地）
- **帧数**: 6 帧
- **路径**: `Slime Enemy/Jump/Frames/Land/frame_0.png` ~ `frame_5.png`
- **用途**: 落地缓冲动作
- **状态**: ✅ 已切割，未集成

---

## 🎨 动画组合方案

### 方案 1：基础战斗（当前使用）
```
Boss 动画：
- Idle（待机）- 停止工作时
- Hurt（受击）- 工作时
- Death（死亡）- 工作时
```
**问题**: Death 动画在工作时播放显得奇怪

### 方案 2：受击+跳跃（推荐）
```
Boss 动画：
- Idle（待机）- 停止工作时
- Hurt（受击）- 工作时
- Jump Start（起跳）- 工作时
```
**优点**: 更有活力，跳跃动作更自然

### 方案 3：完整跳跃循环
```
Boss 动画：
- Idle（待机）- 停止工作时
- Jump Start → Up → ToFall → Down → Land（完整跳跃）- 工作时
- Hurt（受击）- 工作时
```
**优点**: 最丰富，但需要顺序播放跳跃阶段

### 方案 4：简化跳跃
```
Boss 动画：
- Idle（待机）- 停止工作时
- Hurt（受击）- 工作时
- Jump Start + Land（简化跳跃）- 工作时
```
**优点**: 跳跃感明显，帧数适中

### 方案 5：弹跳效果
```
Boss 动画：
- Idle（待机）- 停止工作时
- Hurt（受击）- 工作时
- Jump Up + Down（弹跳）- 工作时
```
**优点**: 轻快可爱，帧数少

---

## 💡 推荐实现方案

### 推荐：方案 2（受击+起跳）

**理由**:
1. Jump Start 有 9 帧，动作丰富
2. 起跳动作符合"被攻击后弹起"的逻辑
3. 不需要复杂的顺序播放
4. 与 Hurt 动画配合自然

**实现**:
```csharp
// Boss 动画定义
_bossIdleFrames = ... // 7 帧 Idle
_bossAttackFrames = ... // 11 帧 Hurt
_bossJumpFrames = Enumerable.Range(0, 9)
    .Select(i => $"pack://application:,,,/Assets/Images/Boss/Slime Enemy/Jump/Frames/Start/frame_{i}.png")
    .ToArray();

// 随机切换
var choice = random.Next(2);
if (choice == 0)
    BossFrames = _bossAttackFrames;  // Hurt
else
    BossFrames = _bossJumpFrames;    // Jump Start
```

---

## 🦸 勇者动画建议（配合史莱姆）

### 推荐组合：战斗+移动
```
勇者动画：
- Idle（待机）- 停止工作时
- Attack1（普通攻击）- 工作时
- Attack2（连击）- 工作时
- Roll（翻滚）- 工作时
```

**配合效果**:
- 勇者攻击 → 史莱姆受击
- 勇者翻滚 → 史莱姆起跳（闪避）
- 勇者连击 → 史莱姆受击

---

## 📊 完整动画统计

| 角色 | 动画类型 | 帧数 | 状态 |
|------|---------|------|------|
| 勇者 | Idle | 8 | ✅ 已集成 |
| 勇者 | Attack1 | 6 | ✅ 已集成 |
| 勇者 | Attack2 | 6 | ⚪ 未集成 |
| 勇者 | Attack3 | 8 | ⚪ 未集成 |
| 勇者 | Run | 10 | ✅ 已集成 |
| 勇者 | Roll | 9 | ⚪ 未集成 |
| 勇者 | Jump | 3 | ⚪ 未集成 |
| 勇者 | Death | 10 | ⚪ 未集成 |
| **史莱姆** | **Idle** | **7** | **✅ 已集成** |
| **史莱姆** | **Hurt** | **11** | **✅ 已集成** |
| **史莱姆** | **Death** | **14** | **✅ 已集成** |
| **史莱姆** | **Jump Start** | **9** | **✅ 已切割** |
| **史莱姆** | **Jump Up** | **1** | **✅ 已切割** |
| **史莱姆** | **Jump ToFall** | **5** | **✅ 已切割** |
| **史莱姆** | **Jump Down** | **1** | **✅ 已切割** |
| **史莱姆** | **Jump Land** | **6** | **✅ 已切割** |

---

## 🎯 下一步行动

### 选项 A：快速修复（推荐）
1. 将 Boss Death 替换为 Jump Start
2. 添加 Jump Start 帧到项目资源
3. 测试效果

### 选项 B：完整优化
1. 添加勇者 Attack2 和 Roll
2. 添加史莱姆 Jump Start
3. 重新设计动画切换逻辑
4. 测试完整效果

### 选项 C：实验性方案
1. 实现完整跳跃循环（Start → Up → ToFall → Down → Land）
2. 需要顺序播放机制
3. 更复杂但效果最好

---

## 🔧 实现指南

### 1. 添加 Jump Start 到项目

编辑 `WorkHoursTimer.csproj`，添加：
```xml
<!-- Boss Slime Jump Start Frames (9 frames) -->
<Resource Include="Assets\Images\Boss\Slime Enemy\Jump\Frames\Start\frame_0.png" />
<Resource Include="Assets\Images\Boss\Slime Enemy\Jump\Frames\Start\frame_1.png" />
<Resource Include="Assets\Images\Boss\Slime Enemy\Jump\Frames\Start\frame_2.png" />
<Resource Include="Assets\Images\Boss\Slime Enemy\Jump\Frames\Start\frame_3.png" />
<Resource Include="Assets\Images\Boss\Slime Enemy\Jump\Frames\Start\frame_4.png" />
<Resource Include="Assets\Images\Boss\Slime Enemy\Jump\Frames\Start\frame_5.png" />
<Resource Include="Assets\Images\Boss\Slime Enemy\Jump\Frames\Start\frame_6.png" />
<Resource Include="Assets\Images\Boss\Slime Enemy\Jump\Frames\Start\frame_7.png" />
<Resource Include="Assets\Images\Boss\Slime Enemy\Jump\Frames\Start\frame_8.png" />
```

### 2. 修改 ViewModel

编辑 `WidgetViewModel.cs`：
```csharp
// 将 Death 改为 Jump Start
_bossJumpFrames = Enumerable.Range(0, 9)
    .Select(i => $"pack://application:,,,/Assets/Images/Boss/Slime Enemy/Jump/Frames/Start/frame_{i}.png")
    .ToArray();
```

### 3. 编译测试
```bash
dotnet build wpf_app/WorkHoursTimer.sln
```

---

## 📝 你的选择？

请告诉我你想要：
1. **快速修复**：立即替换 Death 为 Jump Start
2. **完整优化**：添加更多动画（Attack2, Roll, Jump Start）
3. **自定义**：你指定想要的动画组合
4. **先看效果**：我可以创建一个动画预览工具

我会根据你的选择立即实现！
