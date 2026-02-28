# 🚀 下一步行动清单

**更新时间**: 2026-02-27  
**当前状态**: 技术栈切换决策完成，准备开始 WPF 开发

---

## ✅ 今天已完成

- [x] 技术栈切换决策（Flutter → WPF）
- [x] 创建 9 份完整技术文档
- [x] 制定 3-4 周开发计划
- [x] 风险识别和缓解措施
- [x] 更新项目 README

---

## 🎯 立即执行（今天剩余时间）

### 1. 安装 Visual Studio 2022 ⏰ 预计 30 分钟

```powershell
# 1. 下载 Visual Studio 2022
# 访问: https://visualstudio.microsoft.com/zh-hans/downloads/
# 选择: Community 版本（免费）

# 2. 安装时选择工作负载
# ✅ .NET 桌面开发
# ✅ .NET 8.0 运行时

# 3. 验证安装
dotnet --version
# 应显示: 8.0.x
```

**检查点**: ✅ `dotnet --version` 显示 8.0.x

---

### 2. 创建 WPF 项目 ⏰ 预计 10 分钟

```powershell
# 进入项目目录
cd E:\work\work\New-warm\timer

# 创建 WPF 项目
dotnet new wpf -n WorkHoursTimer -o wpf_app/WorkHoursTimer -f net8.0

# 创建解决方案
cd wpf_app
dotnet new sln -n WorkHoursTimer
dotnet sln add WorkHoursTimer/WorkHoursTimer.csproj

# 验证项目
cd WorkHoursTimer
dotnet build
```

**检查点**: ✅ 项目编译成功，无错误

---

### 3. 安装 NuGet 包 ⏰ 预计 5 分钟

```powershell
# 确保在 WorkHoursTimer 项目目录
cd E:\work\work\New-warm\timer\wpf_app\WorkHoursTimer

# 安装 WPF-UI（现代化 UI 库）
dotnet add package WPF-UI --version 3.0.5

# 安装 MVVM Toolkit（状态管理）
dotnet add package CommunityToolkit.Mvvm --version 8.2.2

# 安装 GIF 动画支持
dotnet add package XamlAnimatedGif --version 2.2.0

# 安装 JSON 支持（数据存储）
dotnet add package System.Text.Json --version 8.0.0

# 验证安装
dotnet restore
dotnet build
```

**检查点**: ✅ 所有包安装成功，项目编译通过

---

### 4. 配置 WPF-UI 主题 ⏰ 预计 15 分钟

#### 4.1 修改 App.xaml

打开 `WorkHoursTimer/App.xaml`，替换为：

```xml
<Application x:Class="WorkHoursTimer.App"
             xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
             xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
             xmlns:ui="http://schemas.lepo.co/wpfui/2022/xaml"
             StartupUri="MainWindow.xaml">
    <Application.Resources>
        <ResourceDictionary>
            <ResourceDictionary.MergedDictionaries>
                <!-- WPF-UI 主题 -->
                <ui:ThemesDictionary Theme="Dark" />
                <ui:ControlsDictionary />
            </ResourceDictionary.MergedDictionaries>
            
            <!-- 自定义颜色 -->
            <SolidColorBrush x:Key="PrimaryDeep" Color="#1A1A2E"/>
            <SolidColorBrush x:Key="AccentGold" Color="#FFD700"/>
            <SolidColorBrush x:Key="TextPrimary" Color="#FFFFFF"/>
            <SolidColorBrush x:Key="TextSecondary" Color="#A0A0B0"/>
            <SolidColorBrush x:Key="Danger" Color="#FF4757"/>
        </ResourceDictionary>
    </Application.Resources>
</Application>
```

#### 4.2 修改 MainWindow.xaml

打开 `WorkHoursTimer/MainWindow.xaml`，替换为：

```xml
<ui:FluentWindow x:Class="WorkHoursTimer.MainWindow"
                 xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
                 xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
                 xmlns:ui="http://schemas.lepo.co/wpfui/2022/xaml"
                 Title="Work Hours Timer"
                 Width="340"
                 Height="800"
                 WindowBackdropType="Mica"
                 ExtendsContentIntoTitleBar="True"
                 WindowStartupLocation="Manual"
                 ResizeMode="NoResize">
    
    <Grid Background="{DynamicResource ApplicationBackgroundBrush}">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
        </Grid.RowDefinitions>
        
        <!-- 标题栏 -->
        <ui:TitleBar Grid.Row="0" Title="Work Hours Timer"/>
        
        <!-- 内容区域 -->
        <Grid Grid.Row="1" Margin="16">
            <StackPanel VerticalAlignment="Center">
                <TextBlock Text="🚀 WPF v3.0"
                           FontSize="32"
                           FontWeight="Bold"
                           Foreground="{StaticResource AccentGold}"
                           HorizontalAlignment="Center"/>
                
                <TextBlock Text="Sprint 1 - Day 1"
                           FontSize="16"
                           Foreground="{StaticResource TextSecondary}"
                           HorizontalAlignment="Center"
                           Margin="0,8,0,0"/>
                
                <TextBlock Text="环境搭建完成！"
                           FontSize="14"
                           Foreground="{StaticResource TextPrimary}"
                           HorizontalAlignment="Center"
                           Margin="0,32,0,0"/>
            </StackPanel>
        </Grid>
    </Grid>
</ui:FluentWindow>
```

#### 4.3 修改 MainWindow.xaml.cs

打开 `WorkHoursTimer/MainWindow.xaml.cs`，替换为：

```csharp
using System.Windows;
using Wpf.Ui.Controls;

namespace WorkHoursTimer
{
    public partial class MainWindow : FluentWindow
    {
        public MainWindow()
        {
            InitializeComponent();
            PositionWindowToRight();
        }

        private void PositionWindowToRight()
        {
            var workArea = SystemParameters.WorkArea;
            this.Height = workArea.Height * 0.9;
            this.Top = workArea.Top + (workArea.Height - this.Height) / 2;
            this.Left = workArea.Right - this.Width;
        }
    }
}
```

**检查点**: ✅ 代码无编译错误

---

### 5. 运行测试 ⏰ 预计 5 分钟

```powershell
# 编译项目
dotnet build

# 运行项目
dotnet run
```

**预期结果**:
- ✅ 窗口出现在屏幕右侧
- ✅ 显示 "🚀 WPF v3.0" 文字
- ✅ 背景为 Mica 磨砂效果（Windows 11）或 Acrylic（Windows 10）
- ✅ 窗口高度为屏幕的 90%

**如果成功**: 🎉 恭喜！Day 1 基础框架完成！

---

## 📅 明天计划（2026-02-28 周五）

### Day 2: 挂件窗口

**目标**: 创建透明的桌面挂件窗口

**任务**:
1. 创建 `WidgetWindow.xaml`
2. 实现透明背景
3. 实现窗口置顶
4. 实现拖拽功能
5. 从主窗口创建挂件窗口

**参考文档**: `wpf_app/SPRINT1_DEVELOPMENT_PLAN.md` Day 2

**预计时间**: 2-3 小时

---

## 📚 参考文档

### 必读文档
1. `wpf_app/QUICK_START_GUIDE.md` - 快速启动指南
2. `wpf_app/SPRINT1_DEVELOPMENT_PLAN.md` - Sprint 1 详细计划
3. `V3.0_MIGRATION_ACTION_PLAN.md` - 完整行动计划

### 技术文档
4. `V3.0_TECH_STACK_MIGRATION.md` - 技术栈迁移说明
5. `V3.0_FLUTTER_VS_WPF_COMPARISON.md` - 技术对比分析

### 外部资源
- [WPF-UI 官方文档](https://wpfui.lepo.co/)
- [.NET 8 文档](https://learn.microsoft.com/dotnet/)
- [MVVM Toolkit](https://learn.microsoft.com/windows/communitytoolkit/mvvm/)

---

## ⚠️ 常见问题

### Q1: Mica 效果不显示？
**A**: Windows 10 不支持 Mica，改用 Acrylic：
```xml
WindowBackdropType="Acrylic"
```

### Q2: 编译错误 "找不到类型或命名空间"？
**A**: NuGet 包未正确安装，运行：
```powershell
dotnet restore
dotnet build
```

### Q3: 窗口位置不正确？
**A**: 多显示器环境可能有问题，检查 `SystemParameters.WorkArea`

---

## ✅ 完成检查清单

### 今天必须完成
- [ ] Visual Studio 2022 已安装
- [ ] WPF 项目已创建
- [ ] NuGet 包已安装
- [ ] WPF-UI 主题已配置
- [ ] 主窗口可以运行
- [ ] 窗口显示在右侧
- [ ] Mica/Acrylic 背景正常

### 可选完成
- [ ] 阅读 Sprint 1 完整计划
- [ ] 熟悉 WPF-UI 文档
- [ ] 准备明天的开发环境

---

## 🎯 本周目标

**Week 1 目标**: 实现双窗口架构和基础通信

- [ ] Day 1: 环境搭建，主窗口框架 ⏳ 进行中
- [ ] Day 2: 挂件窗口
- [ ] Day 3: 鼠标穿透
- [ ] Day 4-5: 窗口通信
- [ ] Day 6-7: 优化测试

**交付物**: 双窗口可以运行并通信

---

## 📞 需要帮助？

- 查看 `wpf_app/QUICK_START_GUIDE.md` 的常见问题部分
- 搜索 [WPF-UI Issues](https://github.com/lepoco/wpfui/issues)
- 查看 [Stack Overflow WPF 标签](https://stackoverflow.com/questions/tagged/wpf)

---

**准备好了吗？让我们开始 WPF v3.0 的开发之旅！** 🚀

**下一步**: 打开 PowerShell，执行第 1 步 "安装 Visual Studio 2022"
