# 🐉 添加 Boss 多帧动画指南

**当前状态**: Boss 显示为静态图片  
**目标**: 添加 Boss 的待机/攻击动画

---

## 📋 当前问题

从截图看到：
- ✅ 勇者动画正常（8帧待机动画流畅播放）
- ❌ Boss 显示为静态图片（只有 1 帧）
- ❌ Boss 图片可能太小或不清晰

---

## 🎯 解决方案

### 方案 1: 使用现有的 Slime Sprites.png（快速）

当前我们有一个 `Slime Sprites.png` 文件，这是一个精灵图集（sprite sheet），包含多个动画帧在一张图片中。

**问题**: 需要将精灵图集切割成单独的帧。

**工具推荐**:
1. **Aseprite** (付费，但最专业)
   - 打开 .aseprite 文件
   - 导出为序列帧（File → Export Sprite Sheet → Output: Separate Files）

2. **在线工具** (免费)
   - https://www.piskelapp.com/
   - https://ezgif.com/sprite-cutter
   - 上传 Slime Sprites.png
   - 设置帧大小（通常是 32x32 或 48x48）
   - 导出为单独的 PNG 文件

---

### 方案 2: 下载新的 Boss 素材（推荐）

从 README.txt 中提到的链接下载：
https://pixelfrog-assets.itch.io/kings-and-pigs

**步骤**:

1. **下载素材包**
   - 访问上述链接
   - 下载 Kings and Pigs 素材包
   - 解压到临时文件夹

2. **找到 Boss 动画**
   - 进入 `Sprites/02-King Pig` 文件夹
   - 找到以下动画序列：
     - `Idle` (待机)
     - `Attack` (攻击)
     - `Hit` (受击，可选)
     - `Dead` (死亡，可选)

3. **复制到项目**
   ```
   wpf_app/WorkHoursTimer/Assets/Images/Boss/KingPig/
   ├── Idle/
   │   ├── frame_0.png
   │   ├── frame_1.png
   │   └── ...
   └── Attack/
       ├── frame_0.png
       ├── frame_1.png
       └── ...
   ```

4. **添加到项目资源**
   
   编辑 `WorkHoursTimer.csproj`，添加：
   ```xml
   <!-- Boss Idle Frames -->
   <Resource Include="Assets\Images\Boss\KingPig\Idle\frame_0.png" />
   <Resource Include="Assets\Images\Boss\KingPig\Idle\frame_1.png" />
   <!-- ... 添加所有帧 -->
   
   <!-- Boss Attack Frames -->
   <Resource Include="Assets\Images\Boss\KingPig\Attack\frame_0.png" />
   <Resource Include="Assets\Images\Boss\KingPig\Attack\frame_1.png" />
   <!-- ... 添加所有帧 -->
   ```

5. **更新 ViewModel**
   
   编辑 `ViewModels/WidgetViewModel.cs`：
   ```csharp
   // 假设 Boss Idle 有 4 帧
   _bossIdleFrames = Enumerable.Range(0, 4)
       .Select(i => $"pack://application:,,,/Assets/Images/Boss/KingPig/Idle/frame_{i}.png")
       .ToArray();
   
   // 假设 Boss Attack 有 6 帧
   _bossAttackFrames = Enumerable.Range(0, 6)
       .Select(i => $"pack://application:,,,/Assets/Images/Boss/KingPig/Attack/frame_{i}.png")
       .ToArray();
   ```

6. **添加状态切换**
   
   在 `OnMessageReceived` 方法中添加：
   ```csharp
   case "TIMER_STARTED":
       IsWorking = true;
       HeroFrames = _heroAttackFrames;
       BossFrames = _bossAttackFrames;  // Boss 也切换到攻击状态
       break;
   
   case "TIMER_STOPPED":
   case "TIMER_PAUSED":
       IsWorking = false;
       HeroFrames = _heroIdleFrames;
       BossFrames = _bossIdleFrames;  // Boss 切换回待机状态
       break;
   ```

---

### 方案 3: 临时使用 Emoji（最快）

如果暂时没有合适的素材，可以先用 Emoji 占位：

编辑 `WidgetViewModel.cs`：
```csharp
// 临时使用单帧（当前的 Slime 图片）
_bossIdleFrames = new[] { 
    "pack://application:,,,/Assets/Images/Boss/Animated Slime Enemy/Slime Sprites.png" 
};
```

---

## 🔍 调试当前问题

### 检查 Boss 图片是否加载

1. **查看调试输出**
   - 在 Visual Studio 中运行（F5）
   - 打开输出窗口（Ctrl + Alt + O）
   - 创建挂件
   - 查找 Boss 相关的日志：
     ```
     🎬 开始加载 1 帧动画
     📷 尝试加载: pack://application:,,,/Assets/Images/Boss/...
     ✅ 加载成功 或 ❌ 加载失败
     ```

2. **检查图片路径**
   
   当前 ViewModel 中的路径：
   ```csharp
   _bossIdleFrames = new[] { 
       "pack://application:,,,/Assets/Images/Boss/Animated Slime Enemy/Slime Sprites.png" 
   };
   ```
   
   路径中有空格，可能导致问题。

3. **验证图片文件**
   ```powershell
   cd wpf_app/WorkHoursTimer
   Test-Path "Assets\Images\Boss\Animated Slime Enemy\Slime Sprites.png"
   # 应该返回 True
   ```

---

## 🚀 快速修复（推荐先做这个）

### 步骤 1: 确保 Boss 图片正确加载

编辑 `WidgetViewModel.cs`，确认路径正确：
```csharp
_bossIdleFrames = new[] { 
    "pack://application:,,,/Assets/Images/Boss/Animated Slime Enemy/Slime Sprites.png" 
};
```

### 步骤 2: 增加 Boss 图片大小

在 `WidgetWindow.xaml` 中，Boss 的 PixelActor 已经设置为 64x64，应该足够大了。

### 步骤 3: 检查项目资源配置

编辑 `WorkHoursTimer.csproj`，确认有这一行：
```xml
<Resource Include="Assets\Images\Boss\Animated Slime Enemy\Slime Sprites.png" />
```

如果没有，添加它。

### 步骤 4: 重新编译
```bash
cd wpf_app/WorkHoursTimer
dotnet clean
dotnet build
dotnet run
```

---

## 📊 预期效果

完成后，挂件应该显示：
- ✅ 勇者：64x64，8帧待机动画
- ✅ Boss：64x64，静态图片（或多帧动画）
- ✅ 图片清晰，像素完美渲染
- ✅ 开始工作时，勇者切换到攻击动画

---

## 🎨 进一步优化

### 1. 添加 Boss 受击效果
当 Boss 血量降低时，播放受击动画：
```csharp
private void UpdateProgress(int totalSeconds)
{
    var newHealth = Math.Max(0, 100 - (currentHours / targetHours * 100));
    
    // 如果血量降低，播放受击动画
    if (newHealth < BossHealth)
    {
        BossFrames = _bossHitFrames;
        // 200ms 后切换回待机/攻击动画
        Task.Delay(200).ContinueWith(_ => 
        {
            BossFrames = IsWorking ? _bossAttackFrames : _bossIdleFrames;
        });
    }
    
    BossHealth = newHealth;
}
```

### 2. 添加 Boss 死亡动画
当 Boss 血量为 0 时：
```csharp
if (BossHealth <= 0)
{
    BossFrames = _bossDeathFrames;
    // 播放胜利音效
    // 显示胜利特效
}
```

---

## 📝 总结

**当前状态**:
- ✅ 勇者动画完美运行
- ⚠️ Boss 显示为静态图片

**下一步**:
1. 先确认 Boss 图片能正确加载（查看调试输出）
2. 如果图片加载失败，检查路径和资源配置
3. 如果图片加载成功但太小，已经调整为 64x64
4. 长期：下载 King Pig 素材，添加多帧动画

---

**需要帮助？** 请提供：
1. Visual Studio 输出窗口的 Boss 加载日志
2. 或者截图显示当前 Boss 的显示效果
