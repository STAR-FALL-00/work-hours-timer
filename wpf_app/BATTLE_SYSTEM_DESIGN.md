# 动态战斗系统设计文档

## 🎯 核心需求

创建一个完整的动态战斗系统，让骑士和史莱姆在血条上方的区域内进行真实的战斗互动。

---

## 📐 布局设计

### 窗口尺寸
- 宽度：300px
- 高度：140px

### 区域划分
```
┌─────────────────────────────────────┐
│                                     │ 
│     [战斗区域 - 280px × 96px]        │ ← 角色移动和战斗
│                                     │
├─────────────────────────────────────┤
│  [血条区域 - 280px × 32px]          │ ← Boss 血条
└─────────────────────────────────────┘
```

### 坐标系统
- X轴：0 (左边界) ~ 280 (右边界)
- 骑士初始位置：X = 20
- 史莱姆初始位置：X = 260
- 战斗距离：当两者距离 < 100px 时触发战斗

---

## 🎮 战斗系统状态机

### 状态定义
```csharp
enum BattleState
{
    Idle,           // 待机：双方休息
    Approaching,    // 接近：骑士追击史莱姆
    Fighting,       // 战斗：近距离交战
    Retreating,     // 撤退：史莱姆逃跑
    Cooldown        // 冷却：战斗后休息
}
```

### 状态转换
```
Idle (10-30秒)
  ↓
Approaching (史莱姆随机移动，骑士追击)
  ↓
Fighting (5回合战斗)
  ↓
Retreating (史莱姆逃跑)
  ↓
Cooldown (10-20秒)
  ↓
Idle
```

---

## 🏃 移动系统

### 史莱姆移动
**动画**: Jump Start (9帧) 表示移动

**移动逻辑**:
```csharp
// 随机选择目标位置
targetX = Random(50, 230);

// 平滑移动
while (currentX != targetX)
{
    currentX += direction * speed;
    PlayAnimation(JumpStart);
}

// 到达后待机
PlayAnimation(Idle);
```

**移动参数**:
- 速度：2-5 px/frame
- 移动范围：50px ~ 230px
- 停留时间：2-5秒

### 骑士移动
**动画**: Run (10帧)

**追击逻辑**:
```csharp
// 计算距离
distance = Abs(slimeX - heroX);

if (distance > 100)
{
    // 距离远，跑步追击
    heroX += direction * runSpeed;
    PlayAnimation(Run);
}
else
{
    // 距离近，进入战斗
    EnterFightingState();
}
```

**移动参数**:
- 跑步速度：3 px/frame
- 战斗距离：< 100px
- 追击范围：20px ~ 260px

---

## ⚔️ 战斗系统

### 战斗回合
每次战斗 5 回合，每回合随机选择动作。

### 骑士动作
| 动作 | 动画 | 帧数 | 概率 | 效果 |
|------|------|------|------|------|
| 普通攻击 | Attack1 | 6 | 40% | 史莱姆播放 Hurt |
| 重击 | Attack2 | 6 | 30% | 史莱姆播放 Hurt |
| 格挡 | Block | 5 | 15% | 被冲撞时后退 |
| 翻滚 | Roll | 9 | 15% | 闪避冲撞 |

### 史莱姆动作
| 动作 | 动画 | 帧数 | 概率 | 效果 |
|------|------|------|------|------|
| 受击 | Hurt | 11 | 70% | 响应骑士攻击 |
| 冲撞 | Jump Start | 9 | 30% | 向骑士冲撞 |

### 战斗逻辑
```csharp
for (int round = 0; round < 5; round++)
{
    // 随机选择动作
    var action = Random();
    
    if (action < 0.7) // 70% 骑士攻击
    {
        // 骑士攻击
        if (Random() < 0.6)
            HeroAttack1();
        else
            HeroAttack2();
        
        // 史莱姆受击
        SlimeHurt();
    }
    else // 30% 史莱姆反击
    {
        // 史莱姆冲撞
        SlimeCharge();
        
        // 骑士反应
        if (Random() < 0.5)
            HeroBlock(); // 格挡并后退
        else
            HeroRoll();  // 翻滚闪避
    }
    
    await Delay(1000); // 每回合间隔1秒
}
```

---

## 🎬 动画与位移

### 格挡后退
```csharp
void HeroBlock()
{
    PlayAnimation(Block); // 5帧
    
    // 后退 30px
    for (int i = 0; i < 30; i++)
    {
        heroX -= 1;
        await Delay(20);
    }
    
    // 跑回来
    PlayAnimation(Run);
    while (heroX < originalX)
    {
        heroX += 2;
        await Delay(20);
    }
}
```

### 翻滚闪避
```csharp
void HeroRoll()
{
    PlayAnimation(Roll); // 9帧
    
    // 翻滚 50px
    for (int i = 0; i < 50; i++)
    {
        heroX -= 1;
        await Delay(15);
    }
    
    // 跑回来
    PlayAnimation(Run);
    while (heroX < originalX)
    {
        heroX += 2;
        await Delay(20);
    }
}
```

### 史莱姆逃跑
```csharp
void SlimeRetreat()
{
    PlayAnimation(JumpStart);
    
    // 快速逃到右边
    while (slimeX < 260)
    {
        slimeX += 5;
        await Delay(30);
    }
    
    PlayAnimation(Idle);
}
```

---

## ⏱️ 时间控制

### 事件循环
```csharp
while (IsWorking)
{
    // 1. 待机阶段 (10-30秒)
    await IdlePhase(Random(10000, 30000));
    
    // 2. 接近阶段 (史莱姆移动，骑士追击)
    await ApproachingPhase();
    
    // 3. 战斗阶段 (5回合)
    await FightingPhase();
    
    // 4. 撤退阶段 (史莱姆逃跑)
    await RetreatingPhase();
    
    // 5. 冷却阶段 (10-20秒)
    await CooldownPhase(Random(10000, 20000));
}
```

### 时间参数
- 待机时间：10-30秒（随机）
- 战斗回合：5回合
- 每回合间隔：1秒
- 冷却时间：10-20秒（随机）
- 完整循环：约 30-60秒

---

## 🔧 技术实现

### 需要的新属性
```csharp
// 位置属性
[ObservableProperty]
private double _heroX = 20;

[ObservableProperty]
private double _slimeX = 260;

// 状态属性
[ObservableProperty]
private BattleState _currentState = BattleState.Idle;

// 镜像属性（角色朝向）
[ObservableProperty]
private bool _heroFlipped = false;

[ObservableProperty]
private bool _slimeFlipped = true;
```

### XAML 绑定
```xml
<!-- 骑士 -->
<controls:PixelActor 
    FramePaths="{Binding HeroFrames}"
    Width="96" Height="96"
    RenderTransformOrigin="0.5,0.5">
    <controls:PixelActor.RenderTransform>
        <TransformGroup>
            <ScaleTransform ScaleX="{Binding HeroFlipped, Converter={StaticResource BoolToScaleConverter}}"/>
            <TranslateTransform X="{Binding HeroX}"/>
        </TransformGroup>
    </controls:PixelActor.RenderTransform>
</controls:PixelActor>

<!-- 史莱姆 -->
<controls:PixelActor 
    FramePaths="{Binding SlimeFrames}"
    Width="96" Height="96"
    RenderTransformOrigin="0.5,0.5">
    <controls:PixelActor.RenderTransform>
        <TransformGroup>
            <ScaleTransform ScaleX="{Binding SlimeFlipped, Converter={StaticResource BoolToScaleConverter}}"/>
            <TranslateTransform X="{Binding SlimeX}"/>
        </TransformGroup>
    </controls:PixelActor.RenderTransform>
</controls:PixelActor>
```

### 移动动画
使用 `DispatcherTimer` 实现平滑移动：
```csharp
private DispatcherTimer _movementTimer;

void StartMovement()
{
    _movementTimer = new DispatcherTimer
    {
        Interval = TimeSpan.FromMilliseconds(16) // 60 FPS
    };
    _movementTimer.Tick += UpdatePositions;
    _movementTimer.Start();
}

void UpdatePositions(object sender, EventArgs e)
{
    // 更新位置
    HeroX += heroVelocityX;
    SlimeX += slimeVelocityX;
    
    // 检查状态转换
    CheckStateTransition();
}
```

---

## 📦 需要添加的资源

### 骑士动画
- ✅ Idle (8帧) - 已有
- ✅ Attack1 (6帧) - 已有
- ⚪ Attack2 (6帧) - 需添加
- ✅ Run (10帧) - 已有
- ⚪ Block (5帧) - 需添加
- ⚪ Roll (9帧) - 需添加

### 史莱姆动画
- ✅ Idle (7帧) - 已有
- ✅ Hurt (11帧) - 已有
- ✅ Jump Start (9帧) - 已切割，需添加

---

## 🎯 实现步骤

### 阶段 1：基础移动（30分钟）
1. 添加位置属性和绑定
2. 实现史莱姆随机移动
3. 实现骑士追击逻辑
4. 测试移动效果

### 阶段 2：战斗系统（45分钟）
1. 添加所需动画资源
2. 实现战斗状态机
3. 实现战斗回合逻辑
4. 添加格挡和翻滚位移
5. 测试战斗效果

### 阶段 3：完整循环（15分钟）
1. 实现事件循环
2. 添加时间控制
3. 优化动画切换
4. 完整测试

---

## 🚀 你的决定？

这是一个相当复杂的系统，需要约 1.5-2 小时完成。

**选项**:

1. **完整实现** - 按照上述设计完整实现
   - 时间：1.5-2小时
   - 效果：最佳，完全符合你的设想

2. **简化版本** - 先实现核心功能
   - 阶段1：移动系统（30分钟）
   - 测试后再决定是否继续

3. **分步实现** - 我先实现阶段1，你测试后再继续
   - 更灵活，可以随时调整

你想要哪个选项？我建议选择选项3（分步实现），这样可以边做边调整，确保效果符合你的预期。
