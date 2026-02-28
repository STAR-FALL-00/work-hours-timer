# 🎮 挂件 UI 开发计划

**开始时间**: 2026-02-28  
**状态**: 准备开始  
**素材**: 已下载，使用占位符 + 金币 GIF

---

## 🎯 开发目标

创建两种挂件模式：
1. **勇者伐魔模式** (Boss Battle)
2. **跑酷猫咪模式** (Runner Cat)

---

## 📦 可用素材

### ✅ 可以直接使用
- `Assets/Images/Effects/SpinningCoin/SpinningCoin.gif` - 金币动画

### ⏳ 使用占位符（后期替换）
- 勇者: 🗡️ Emoji 或蓝色方块
- Boss: 👹 Emoji 或红色圆形
- 猫咪: 🐱 Emoji 或橙色椭圆

---

## 🎨 设计方案

### 勇者伐魔模式布局
```
┌─────────────────────────────────┐
│  🗡️ 勇者 Lv.5    ❤️❤️❤️    👹 Boss │
│  [==========]   HP: 75%          │
│                                   │
│  💰 1250 金币    ⭐ 350/500 经验  │
│  ⏱️ 02:30:45                     │
└─────────────────────────────────┘
```

### 跑酷猫咪模式布局
```
┌─────────────────────────────────┐
│           🐱                      │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│  ▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░░░░░░░░░  │
│  0h        4h        8h           │
│  ⏱️ 04:25:30  💰 425 金币        │
└─────────────────────────────────┘
```

---

## 🔧 技术实现

### 1. 安装 XamlAnimatedGif
```xml
<PackageReference Include="XamlAnimatedGif" Version="2.2.0" />
```

### 2. 移动金币 GIF
从 `Assets/Images/Effects/SpinningCoin/SpinningCoin.gif`  
到 `Assets/Images/UI/coin_spin.gif`

### 3. 添加到项目
- Build Action: Resource
- Copy to Output Directory: Do not copy

### 4. XAML 引用
```xml
<Image gif:AnimationBehavior.SourceUri="pack://application:,,,/Assets/Images/UI/coin_spin.gif"
       gif:AnimationBehavior.RepeatBehavior="Forever"
       RenderOptions.BitmapScalingMode="NearestNeighbor"
       Width="24" Height="24" />
```

---

## 📋 开发步骤

### Phase 1: 准备工作
1. ✅ 素材已下载
2. [ ] 安装 XamlAnimatedGif NuGet 包
3. [ ] 移动金币 GIF 到正确位置
4. [ ] 添加到项目资源

### Phase 2: 勇者伐魔模式
1. [ ] 创建布局（Grid）
2. [ ] 添加勇者占位符（Emoji）
3. [ ] 添加 Boss 占位符（Emoji）
4. [ ] 添加 HP 血条
5. [ ] 添加金币显示（使用真实 GIF）
6. [ ] 添加经验显示
7. [ ] 添加计时器显示

### Phase 3: 跑酷猫咪模式
1. [ ] 创建布局（Grid）
2. [ ] 添加猫咪占位符（Emoji）
3. [ ] 添加进度条
4. [ ] 添加里程碑标记
5. [ ] 添加计时器和金币显示

### Phase 4: 皮肤切换
1. [ ] 在 Settings 中添加皮肤选择
2. [ ] 实现切换逻辑
3. [ ] 保存用户选择

### Phase 5: 动画逻辑
1. [ ] 根据工作状态切换显示
2. [ ] 血条动画
3. [ ] 进度条动画
4. [ ] 金币数字滚动

---

## 🎯 预期效果

完成后：
- ✨ 挂件显示流畅的金币动画
- 🎮 根据工作状态自动切换显示
- 💎 保持像素风格
- 🌟 与主窗口完美搭配

---

## 📝 注意事项

1. **像素清晰度**
   - 必须设置 `RenderOptions.BitmapScalingMode="NearestNeighbor"`
   - 否则图像会模糊

2. **Pack URI 格式**
   - `pack://application:,,,/Assets/Images/UI/coin_spin.gif`
   - 注意三个逗号

3. **占位符策略**
   - 先用 Emoji 快速实现
   - 功能完成后替换真实 GIF
   - 不影响开发进度

---

## 🚀 下一步

在新的对话中：
1. 安装 XamlAnimatedGif
2. 整理金币 GIF
3. 重写 WidgetWindow.xaml
4. 实现勇者伐魔模式
5. 实现跑酷猫咪模式
6. 测试效果

---

**创建时间**: 2026-02-28  
**准备就绪**: ✅  
**开始开发**: 🚀

---

**让我们在新对话中继续！**
