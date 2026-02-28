# WPF v3.0 快速启动指南

## 📋 第一步：环境准备

### 安装 Visual Studio 2022

1. 下载 [Visual Studio 2022](https://visualstudio.microsoft.com/zh-hans/downloads/)
2. 安装时选择以下工作负载：
   - ✅ .NET 桌面开发
   - ✅ .NET 8.0 运行时

### 验证安装
```powershell
dotnet --version
# 应显示: 8.0.x
```

---

## 🏗️ 第二步：创建项目

### 使用 Visual Studio GUI

1. 打开 Visual Studio 2022
2. 点击 **创建新项目**
3. 搜索 **WPF 应用程序**
4. 选择 **WPF 应用程序 (.NET)**
5. 配置项目：
   - **项目名称**: `WorkHoursTimer`
   - **位置**: `E:\work\work\New-warm\timer\wpf_app`
   - **框架**: `.NET 8.0 (长期支持)`
6. 点击 **创建**

### 使用命令行

```powershell
# 进入工作目录
cd E:\work\work\New-warm\timer

# 创建 WPF 项目
dotnet new wpf -n WorkHoursTimer -o wpf_app/WorkHoursTimer -f net8.0

# 创建解决方案
cd wpf_app
dotnet new sln -n WorkHoursTimer
dotnet sln add WorkHoursTimer/WorkHoursTimer.csproj
```

---

## 📦 第三步：安装 NuGet 包

### 方法 1：使用 Visual Studio

1. 右键点击项目 → **管理 NuGet 程序包**
2. 点击 **浏览** 标签
3. 搜索并安装以下包：
   - `WPF-UI` (版本 3.0.0+)
   - `CommunityToolkit.Mvvm` (版本 8.2.2+)
   - `XamlAnimatedGif` (版本 2.2.0+)

### 方法 2：使用命令行

```powershell
cd WorkHoursTimer

dotnet add package WPF-UI --version 3.0.5
dotnet add package CommunityToolkit.Mvvm --version 8.2.2
dotnet add package XamlAnimatedGif --version 2.2.0
dotnet add package System.Text.Json --version 8.0.0
```

---

## 🎨 第四步：配置 WPF-UI

### 修改 App.xaml

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
            <SolidColorBrush x:Key="Danger" Color="#FF4757"/>
        </ResourceDictionary>
    </Application.Resources>
</Application>
```

### 修改 MainWindow.xaml

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
    
    <Grid>
        <TextBlock Text="Hello WPF v3.0!"
                   FontSize="24"
                   FontWeight="Bold"
                   Foreground="{StaticResource AccentGold}"
                   HorizontalAlignment="Center"
                   VerticalAlignment="Center"/>
    </Grid>
</ui:FluentWindow>
```

### 修改 MainWindow.xaml.cs

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
            
            // 窗口停靠到右侧
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

---

## ▶️ 第五步：运行项目

### 使用 Visual Studio
按 **F5** 或点击 **启动** 按钮

### 使用命令行
```powershell
dotnet run
```

### 预期结果
- 窗口出现在屏幕右侧
- 显示 "Hello WPF v3.0!" 文字
- 背景为 Mica 磨砂效果（Windows 11）

---

## 🐛 常见问题

### 问题 1：Mica 效果不显示
**原因**: Windows 10 不支持 Mica，需要使用 Acrylic

**解决**:
```xml
WindowBackdropType="Acrylic"
```

### 问题 2：编译错误 "找不到类型或命名空间"
**原因**: NuGet 包未正确安装

**解决**:
```powershell
dotnet restore
dotnet build
```

### 问题 3：窗口位置不正确
**原因**: 多显示器环境

**解决**: 在 `PositionWindowToRight()` 中添加主屏幕检测

---

## 📚 下一步

1. ✅ 环境搭建完成
2. 📖 阅读 [项目结构文档](./PROJECT_STRUCTURE.md)
3. 🎨 查看 [UI 设计规范](./UI_DESIGN_SPEC.md)
4. 💻 开始 [Sprint 1 开发](./SPRINT1_TASKS.md)

---

## 🆘 获取帮助

- 查看 [WPF-UI 文档](https://wpfui.lepo.co/)
- 搜索 [Stack Overflow](https://stackoverflow.com/questions/tagged/wpf)
- 提交 [Issue](https://github.com/your-repo/issues)
