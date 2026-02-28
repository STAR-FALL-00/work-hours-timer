# 🐛 战斗系统调试指南

**日期**: 2026-02-28  
**目的**: 帮助查看战斗系统日志和调试

---

## 📋 问题诊断

### 症状
- 点击"开始工作"后等待很久没有看到战斗动画

### 可能原因
1. **初始延迟太长**: 原设计是 10-30 秒随机延迟
2. **日志未显示**: 需要查看 Debug 输出窗口
3. **战斗系统未启动**: 需要确认消息传递

---

## 🔧 已做的改进

### 1. 缩短延迟时间
```csharp
// 改进前：10-30 秒
DelayedAction(GetRandomDelay(10000, 30000), ...);

// 改进后：3-5 秒（首次战斗）
DelayedAction(GetRandomDelay(3000, 5000), ...);

// 改进后：5-10 秒（后续战斗）
DelayedAction(GetRandomDelay(5000, 10000), ...);
```

### 2. 添加详细日志
```csharp
Log("🎮 战斗系统启动 - X 秒后开始第一次战斗");
Log("⏰ 延迟结束，开始接近阶段");
Log("🎯 接近阶段 - Boss跳跃到: X");
Log("  Boss 开始跳跃: X → Y");
Log("  跳跃完成 - 位置: X");
Log("⚔️ 战斗开始！");
Log("  回合X: ...");
Log("🏃 Boss 撤退！");
Log("💤 冷却阶段");
Log("⏰ 待机 X 秒后开始下一轮");
```

---

## 🧪 测试步骤

### 方法 1: 使用 Visual Studio（推荐）

1. **关闭当前运行的应用**
   - 右键点击托盘图标 → 退出
   - 或直接关闭所有窗口

2. **用 Visual Studio 打开项目**
   ```bash
   # 双击打开
   wpf_app/WorkHoursTimer.sln
   ```

3. **启动调试**
   - 按 F5 或点击"开始调试"
   - 应用会启动

4. **打开输出窗口**
   - 菜单: 视图 → 输出
   - 或按 Ctrl+Alt+O
   - 确保选择"调试"输出

5. **触发战斗**
   - 点击主窗口"开始工作"按钮
   - 观察输出窗口的日志

6. **查看日志**
   ```
   [BattleSystem] 🎮 战斗系统启动 - 4 秒后开始第一次战斗
   [BattleSystem] ⏰ 延迟结束，开始接近阶段
   [BattleSystem] 🎯 接近阶段 - Boss跳跃到: 125
   [BattleSystem]   Boss 开始跳跃: 184 → 125
   [BattleSystem]   跳跃完成 - 位置: 125
   ...
   ```

### 方法 2: 使用 DebugView（无需 VS）

1. **下载 DebugView**
   - https://learn.microsoft.com/en-us/sysinternals/downloads/debugview
   - 解压并运行 Dbgview.exe

2. **配置 DebugView**
   - Capture → Capture Win32
   - Capture → Capture Global Win32

3. **关闭并重新运行应用**
   ```bash
   cd wpf_app/WorkHoursTimer
   dotnet run
   ```

4. **在 DebugView 中查看日志**
   - 搜索 "[BattleSystem]"
   - 查看战斗系统的所有日志

### 方法 3: 添加文件日志（最简单）

如果上面两种方法都不方便，可以添加文件日志：

1. **修改 BattleSystemService.cs**
   ```csharp
   private void Log(string message)
   {
       var logMessage = $"[BattleSystem] {message}";
       System.Diagnostics.Debug.WriteLine(logMessage);
       
       // 添加文件日志
       try
       {
           var logFile = Path.Combine(
               Environment.GetFolderPath(Environment.SpecialFolder.Desktop),
               "battle_log.txt"
           );
           File.AppendAllText(logFile, $"{DateTime.Now:HH:mm:ss} {logMessage}\n");
       }
       catch { }
   }
   ```

2. **重新编译运行**
   - 关闭应用
   - `dotnet build`
   - `dotnet run`

3. **查看桌面上的 battle_log.txt**

---

## 🎯 预期日志流程

### 完整的战斗循环日志

```
00:00:00 [BattleSystem] 🎮 战斗系统启动 - 4 秒后开始第一次战斗
00:00:04 [BattleSystem] ⏰ 延迟结束，开始接近阶段
00:00:04 [BattleSystem] 🎯 接近阶段 - Boss跳跃到: 125
00:00:04 [BattleSystem]   Boss 开始跳跃: 184 → 125
00:00:05 [BattleSystem]   跳跃完成 - 位置: 125
00:00:08 [BattleSystem] ⚔️ 战斗开始！
00:00:09 [BattleSystem]   回合1: 勇者普通攻击
00:00:10 [BattleSystem]   回合2: 勇者重击
00:00:11 [BattleSystem]   回合3: Boss 冲撞
00:00:11 [BattleSystem]     勇者格挡
00:00:12 [BattleSystem]   回合4: 勇者普通攻击
00:00:13 [BattleSystem]   回合5: 勇者重击
00:00:13 [BattleSystem] 🏃 Boss 撤退！
00:00:14 [BattleSystem] 💤 冷却阶段
00:00:15 [BattleSystem] ⏰ 待机 7 秒后开始下一轮
00:00:22 [BattleSystem] ⏰ 待机结束，开始下一轮战斗
00:00:22 [BattleSystem] 🎯 接近阶段 - Boss跳跃到: 156
...
```

---

## 🔍 常见问题排查

### 问题 1: 没有任何日志输出

**可能原因**:
- 战斗系统未启动
- 消息传递失败

**检查**:
1. 确认点击了"开始工作"按钮
2. 确认挂件窗口已显示
3. 检查 WidgetViewModel 是否正确订阅消息

**解决**:
```csharp
// 在 WidgetViewModel.OnMessageReceived 添加日志
case "TIMER_STARTED":
    System.Diagnostics.Debug.WriteLine("收到 TIMER_STARTED 消息");
    IsWorking = true;
    StatusText = "▶️ 开始工作";
    _battleSystem.Start();
    break;
```

### 问题 2: 只有启动日志，没有后续日志

**可能原因**:
- DelayedAction 未执行
- Task.Delay 失败

**检查**:
```csharp
// 在 DelayedAction 添加日志
private void DelayedAction(int milliseconds, Action action)
{
    Log($"⏱️ 设置延迟: {milliseconds}ms");
    System.Threading.Tasks.Task.Delay(milliseconds).ContinueWith(_ =>
    {
        Log($"⏱️ 延迟结束，执行回调");
        System.Windows.Application.Current?.Dispatcher.Invoke(action);
    });
}
```

### 问题 3: 有日志但看不到动画

**可能原因**:
- UI 绑定问题
- Transform 未生效

**检查**:
1. 确认 BossX, BossY 属性正在变化
2. 确认 XAML 绑定正确
3. 确认 NegateConverter 工作正常

**解决**:
```csharp
// 在 ViewModel 添加日志
private void OnBossPositionChanged(object? sender, Position2DChangedEventArgs e)
{
    BossX = e.X;
    BossY = e.Y;
    System.Diagnostics.Debug.WriteLine($"Boss 位置: ({e.X:F0}, {e.Y:F0})");
}
```

---

## 📊 性能监控

### 帧率检查
```csharp
private int _frameCount = 0;
private DateTime _lastFpsCheck = DateTime.Now;

private void OnMovementTick(object? sender, EventArgs e)
{
    _frameCount++;
    var now = DateTime.Now;
    if ((now - _lastFpsCheck).TotalSeconds >= 1.0)
    {
        Log($"📊 FPS: {_frameCount}");
        _frameCount = 0;
        _lastFpsCheck = now;
    }
    
    // ... 原有代码
}
```

---

## 🚀 快速测试命令

### 关闭应用并重新编译运行
```bash
# 1. 关闭应用（手动）

# 2. 清理并重新编译
cd wpf_app/WorkHoursTimer
dotnet clean
dotnet build

# 3. 运行
dotnet run
```

### 使用 Visual Studio
```
1. 关闭应用
2. 在 VS 中按 Ctrl+Shift+B 编译
3. 按 F5 启动调试
4. 查看输出窗口
```

---

## 📝 当前配置

### 延迟时间
- **首次战斗**: 3-5 秒
- **后续战斗**: 5-10 秒
- **跳跃时长**: 0.5 秒（30 帧）

### 日志级别
- ✅ 系统启动/停止
- ✅ 状态切换
- ✅ 跳跃开始/结束
- ✅ 战斗回合
- ✅ 延迟设置

---

## 💡 建议

1. **首次测试**: 使用 Visual Studio 调试，可以看到完整日志
2. **日常使用**: 可以将延迟改回 10-30 秒，避免太频繁
3. **性能优化**: 如果卡顿，可以降低帧率或减少日志输出

---

## 🎉 成功标志

如果看到以下日志，说明战斗系统正常工作：

```
✅ 🎮 战斗系统启动
✅ ⏰ 延迟结束，开始接近阶段
✅ 🎯 接近阶段 - Boss跳跃到: X
✅   Boss 开始跳跃: X → Y
✅   跳跃完成 - 位置: X
✅ ⚔️ 战斗开始！
✅   回合X: ...
✅ 🏃 Boss 撤退！
✅ 💤 冷却阶段
✅ ⏰ 待机 X 秒后开始下一轮
```

---

**提示**: 如果还是看不到日志或动画，请提供具体的错误信息或现象描述，我会进一步协助排查！
