# Sprint 1: 框架与通信 (Week 1)

## 🎯 Sprint 目标

搭建 WPF 双窗口架构，实现基础通信和交互。

**交付标准**:
- ✅ 主窗口（侧边栏）可以停靠在屏幕右侧
- ✅ 挂件窗口可以置顶显示，支持拖拽
- ✅ 两个窗口可以互相通信
- ✅ 实现鼠标穿透功能

---

## 📅 Day 1: 项目初始化

### 任务清单
- [ ] 创建 WPF 解决方案
- [ ] 安装 NuGet 依赖
- [ ] 配置 WPF-UI 主题
- [ ] 创建基础项目结构
- [ ] 实现主窗口基础框架

### 详细步骤

#### 1.1 创建项目结构
```
WorkHoursTimer/
├── Models/
├── ViewModels/
├── Views/
├── Services/
├── Helpers/
└── Resources/
    ├── Styles/
    ├── Images/
    └── Audio/
```

#### 1.2 创建 MainWindow
**MainWindow.xaml**:
```xml
<ui:FluentWindow x:Class="WorkHoursTimer.MainWindow"
                 xmlns:ui="http://schemas.lepo.co/wpfui/2022/xaml"
                 Title="Work Hours Timer"
                 Width="340"
                 Height="800"
                 WindowBackdropType="Mica"
                 ExtendsContentIntoTitleBar="True"
                 WindowStartupLocation="Manual"
                 ResizeMode="NoResize"
                 Topmost="False">
    
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
                
                <ui:Button Content="创建挂件窗口"
                           Margin="0,32,0,0"
                           HorizontalAlignment="Center"
                           Click="CreateWidgetWindow_Click"/>
            </StackPanel>
        </Grid>
    </Grid>
</ui:FluentWindow>
```

**MainWindow.xaml.cs**:
```csharp
using System.Windows;
using Wpf.Ui.Controls;

namespace WorkHoursTimer
{
    public partial class MainWindow : FluentWindow
    {
        private WidgetWindow? _widgetWindow;

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

        private void CreateWidgetWindow_Click(object sender, RoutedEventArgs e)
        {
            if (_widgetWindow == null || !_widgetWindow.IsLoaded)
            {
                _widgetWindow = new WidgetWindow();
                _widgetWindow.Show();
            }
        }
    }
}
```

### 验收标准
- [x] 项目可以编译通过
- [x] 主窗口显示在屏幕右侧
- [x] Mica 背景效果正常（Win11）或 Acrylic（Win10）

---

## 📅 Day 2: 挂件窗口基础

### 任务清单
- [ ] 创建 WidgetWindow
- [ ] 实现透明背景
- [ ] 实现窗口置顶
- [ ] 实现拖拽功能

### 详细步骤

#### 2.1 创建 WidgetWindow.xaml
```xml
<Window x:Class="WorkHoursTimer.WidgetWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Widget"
        Width="240"
        Height="120"
        WindowStyle="None"
        AllowsTransparency="True"
        Background="Transparent"
        Topmost="True"
        ShowInTaskbar="False"
        ResizeMode="NoResize"
        MouseLeftButtonDown="Window_MouseLeftButtonDown">
    
    <Border Background="#80000000"
            BorderBrush="#FFD700"
            BorderThickness="2"
            CornerRadius="12"
            Padding="16">
        <StackPanel>
            <TextBlock Text="👾 像素挂件"
                       FontSize="18"
                       FontWeight="Bold"
                       Foreground="White"
                       HorizontalAlignment="Center"/>
            
            <TextBlock Text="可拖拽"
                       FontSize="12"
                       Foreground="#A0A0B0"
                       HorizontalAlignment="Center"
                       Margin="0,8,0,0"/>
        </StackPanel>
    </Border>
</Window>
```

#### 2.2 创建 WidgetWindow.xaml.cs
```csharp
using System.Windows;
using System.Windows.Input;

namespace WorkHoursTimer
{
    public partial class WidgetWindow : Window
    {
        public WidgetWindow()
        {
            InitializeComponent();
            PositionToBottomRight();
        }

        private void PositionToBottomRight()
        {
            var workArea = SystemParameters.WorkArea;
            this.Left = workArea.Right - this.Width - 20;
            this.Top = workArea.Bottom - this.Height - 20;
        }

        private void Window_MouseLeftButtonDown(object sender, MouseButtonEventArgs e)
        {
            // 允许拖拽窗口
            if (e.ButtonState == MouseButtonState.Pressed)
            {
                this.DragMove();
            }
        }
    }
}
```

### 验收标准
- [x] 挂件窗口显示在右下角
- [x] 窗口背景透明
- [x] 可以拖拽移动
- [x] 始终置顶显示

---

## 📅 Day 3: 鼠标穿透功能

### 任务清单
- [ ] 创建 Win32Helper 类
- [ ] 实现鼠标穿透 API 封装
- [ ] 实现智能穿透逻辑

### 详细步骤

#### 3.1 创建 Helpers/Win32Helper.cs
```csharp
using System;
using System.Runtime.InteropServices;
using System.Windows;
using System.Windows.Interop;

namespace WorkHoursTimer.Helpers
{
    public static class Win32Helper
    {
        [DllImport("user32.dll")]
        private static extern int GetWindowLong(IntPtr hwnd, int index);

        [DllImport("user32.dll")]
        private static extern int SetWindowLong(IntPtr hwnd, int index, int newStyle);

        private const int GWL_EXSTYLE = -20;
        private const int WS_EX_TRANSPARENT = 0x00000020;

        /// <summary>
        /// 设置窗口鼠标穿透
        /// </summary>
        public static void SetClickThrough(Window window, bool enable)
        {
            var hwnd = new WindowInteropHelper(window).Handle;
            var extendedStyle = GetWindowLong(hwnd, GWL_EXSTYLE);

            if (enable)
            {
                SetWindowLong(hwnd, GWL_EXSTYLE, extendedStyle | WS_EX_TRANSPARENT);
            }
            else
            {
                SetWindowLong(hwnd, GWL_EXSTYLE, extendedStyle & ~WS_EX_TRANSPARENT);
            }
        }
    }
}
```

#### 3.2 修改 WidgetWindow.xaml.cs
```csharp
using System.Windows;
using System.Windows.Input;
using WorkHoursTimer.Helpers;

namespace WorkHoursTimer
{
    public partial class WidgetWindow : Window
    {
        private bool _isClickThroughEnabled = false;

        public WidgetWindow()
        {
            InitializeComponent();
            PositionToBottomRight();
            
            // 窗口加载完成后启用穿透
            this.Loaded += (s, e) => EnableClickThrough();
            
            // 鼠标进入时禁用穿透（允许拖拽）
            this.MouseEnter += (s, e) => DisableClickThrough();
            
            // 鼠标离开时启用穿透
            this.MouseLeave += (s, e) => EnableClickThrough();
        }

        private void EnableClickThrough()
        {
            if (!_isClickThroughEnabled)
            {
                Win32Helper.SetClickThrough(this, true);
                _isClickThroughEnabled = true;
            }
        }

        private void DisableClickThrough()
        {
            if (_isClickThroughEnabled)
            {
                Win32Helper.SetClickThrough(this, false);
                _isClickThroughEnabled = false;
            }
        }

        // ... 其他代码保持不变
    }
}
```

### 验收标准
- [x] 鼠标不在挂件上时，可以点击穿透到桌面
- [x] 鼠标移到挂件上时，可以拖拽移动
- [x] 鼠标离开后，自动恢复穿透

---

## 📅 Day 4-5: 窗口通信

### 任务清单
- [ ] 创建 WindowMessenger 服务
- [ ] 实现事件总线
- [ ] 主窗口发送消息到挂件
- [ ] 挂件窗口接收并显示消息

### 详细步骤

#### 4.1 创建 Services/WindowMessenger.cs
```csharp
using System;

namespace WorkHoursTimer.Services
{
    public class WindowMessenger
    {
        private static WindowMessenger? _instance;
        public static WindowMessenger Instance => _instance ??= new WindowMessenger();

        public event EventHandler<MessageEventArgs>? MessageReceived;

        public void SendMessage(string type, object data)
        {
            MessageReceived?.Invoke(this, new MessageEventArgs
            {
                Type = type,
                Data = data,
                Timestamp = DateTime.Now
            });
        }
    }

    public class MessageEventArgs : EventArgs
    {
        public string Type { get; set; } = string.Empty;
        public object? Data { get; set; }
        public DateTime Timestamp { get; set; }
    }
}
```

#### 4.2 修改 MainWindow - 发送消息
```csharp
private void CreateWidgetWindow_Click(object sender, RoutedEventArgs e)
{
    if (_widgetWindow == null || !_widgetWindow.IsLoaded)
    {
        _widgetWindow = new WidgetWindow();
        _widgetWindow.Show();
    }
    
    // 发送测试消息
    WindowMessenger.Instance.SendMessage("TEST", new
    {
        Text = "Hello from Main Window!",
        Timestamp = DateTime.Now
    });
}
```

#### 4.3 修改 WidgetWindow - 接收消息
```csharp
public WidgetWindow()
{
    InitializeComponent();
    PositionToBottomRight();
    
    // 订阅消息
    WindowMessenger.Instance.MessageReceived += OnMessageReceived;
}

private void OnMessageReceived(object? sender, MessageEventArgs e)
{
    if (e.Type == "TEST")
    {
        // 更新 UI（需要在 UI 线程）
        Dispatcher.Invoke(() =>
        {
            // 显示接收到的消息
            MessageBox.Show($"收到消息: {e.Data}");
        });
    }
}
```

### 验收标准
- [x] 点击主窗口按钮，挂件窗口收到消息
- [x] 消息传递无延迟
- [x] 支持多种消息类型

---

## 📅 Day 6-7: 优化与测试

### 任务清单
- [ ] 性能优化
- [ ] 内存占用测试
- [ ] 多显示器支持
- [ ] 异常处理
- [ ] 编写单元测试

### 优化项目
1. **内存优化**: 确保静默运行 < 50MB
2. **窗口动画**: 添加滑入/滑出动画
3. **自动隐藏**: 实现侧边栏自动隐藏逻辑
4. **配置保存**: 保存窗口位置到 JSON

---

## ✅ Sprint 1 完成标准

### 功能清单
- [x] 主窗口可以停靠在屏幕右侧
- [x] 挂件窗口可以置顶、拖拽
- [x] 鼠标穿透功能正常
- [x] 窗口间通信正常
- [x] Mica/Acrylic 背景效果

### 性能指标
- [x] 启动时间 < 2 秒
- [x] 内存占用 < 50MB
- [x] CPU 占用 < 1%（静默时）

### 交付物
- [x] 可运行的 WPF 应用
- [x] 完整的代码注释
- [x] Sprint 1 完成报告

---

## 📚 参考代码示例

完整的示例代码已提供在各个 Day 的详细步骤中。

---

## 🆘 遇到问题？

- 查看 [常见问题](./FAQ.md)
- 搜索 [WPF-UI Issues](https://github.com/lepoco/wpfui/issues)
- 提交项目 Issue
