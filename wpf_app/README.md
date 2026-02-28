# Work Hours Timer v3.0 - WPF Edition

## 🎯 项目简介

基于 WPF/.NET 8 的工时计时器，专为 Windows 10/11 优化。

**核心特性**:
- 🪟 双窗口架构：侧边栏 + 桌面挂件
- ✨ 原生特效：Mica/Acrylic 磨砂背景
- 🎮 游戏化：像素风格动画，BOSS 战斗模式
- 💰 经济系统：金币、经验、商店、道具
- 📊 数据统计：工时图表、收益计算

---

## 🛠️ 开发环境要求

### 必需
- **Visual Studio 2022** (Community/Professional/Enterprise)
- **.NET 8 SDK** (已包含在 VS 2022 中)
- **Windows 10 1809+** 或 **Windows 11**

### 推荐
- **Git** (版本控制)
- **Windows Terminal** (更好的命令行体验)

---

## 🚀 快速开始

### 1. 克隆项目
```bash
git clone <repository-url>
cd timer/wpf_app
```

### 2. 打开解决方案
```bash
# 使用 Visual Studio 打开
start WorkHoursTimer.sln

# 或使用命令行构建
dotnet build
```

### 3. 运行应用
```bash
dotnet run --project WorkHoursTimer
```

---

## 📦 NuGet 依赖

在 Visual Studio 中，打开 **工具 > NuGet 包管理器 > 管理解决方案的 NuGet 程序包**，安装以下包：

```xml
<PackageReference Include="WPF-UI" Version="3.0.0" />
<PackageReference Include="CommunityToolkit.Mvvm" Version="8.2.2" />
<PackageReference Include="XamlAnimatedGif" Version="2.2.0" />
<PackageReference Include="System.Text.Json" Version="8.0.0" />
```

---

## 🏗️ 项目结构

```
WorkHoursTimer/
├── App.xaml                    # 应用程序入口
├── MainWindow.xaml             # 主窗口（侧边栏）
├── WidgetWindow.xaml           # 挂件窗口
├── Models/                     # 数据模型
├── ViewModels/                 # MVVM 视图模型
├── Views/                      # 用户控件
├── Services/                   # 业务逻辑
├── Helpers/                    # 工具类
└── Resources/                  # 资源文件
```

---

## 🎨 设计规范

### 颜色
- **主色调**: `#1A1A2E` (深空蓝)
- **强调色**: `#FFD700` (金币色)
- **危险色**: `#FF4757` (BOSS 血条)

### 字体
- **英文/数字**: Poppins
- **中文**: MiSans
- **像素**: Zpix

---

## 📝 开发指南

### MVVM 模式
使用 `CommunityToolkit.Mvvm` 简化 MVVM 开发：

```csharp
using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;

public partial class TimerViewModel : ObservableObject
{
    [ObservableProperty]
    private int _elapsedSeconds;

    [RelayCommand]
    private void StartTimer()
    {
        // 启动计时器逻辑
    }
}
```

### 窗口特效
使用 WPF-UI 实现 Mica 背景：

```xml
<ui:FluentWindow 
    xmlns:ui="http://schemas.lepo.co/wpfui/2022/xaml"
    WindowBackdropType="Mica"
    ExtendsContentIntoTitleBar="True">
    <!-- 内容 -->
</ui:FluentWindow>
```

---

## 🐛 调试技巧

### 查看输出日志
在 Visual Studio 中：**视图 > 输出**

### 断点调试
在代码行左侧点击设置断点，按 F5 启动调试

### 实时 XAML 编辑
启用 **调试 > 选项 > XAML 热重载**

---

## 📚 学习资源

- [WPF 官方教程](https://learn.microsoft.com/dotnet/desktop/wpf/)
- [WPF-UI 文档](https://wpfui.lepo.co/)
- [MVVM Toolkit](https://learn.microsoft.com/windows/communitytoolkit/mvvm/)

---

## 🤝 贡献指南

1. Fork 项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

---

## 📄 许可证

MIT License - 详见 [LICENSE](../LICENSE) 文件
