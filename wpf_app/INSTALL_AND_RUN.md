# WPF v3.0 安装和运行指南

## 🎯 当前状态

✅ 项目结构已创建  
✅ 基础代码已完成  
⏳ 需要安装 .NET 8 SDK  
⏳ 需要安装依赖包

---

## 📦 第一步：安装 .NET 8 SDK

### 方法 1：使用 winget (推荐)

```powershell
# 打开 PowerShell 或 Windows Terminal
winget install Microsoft.DotNet.SDK.8
```

### 方法 2：手动下载

1. 访问：https://dotnet.microsoft.com/download/dotnet/8.0
2. 下载 ".NET 8.0 SDK" (Windows x64)
3. 运行安装程序
4. 重启 PowerShell

### 验证安装

```powershell
dotnet --version
# 应显示: 8.0.x
```

---

## 🚀 第二步：构建和运行项目

### 进入项目目录

```powershell
cd E:\work\work\New-warm\timer\wpf_app
```

### 恢复依赖包

```powershell
dotnet restore WorkHoursTimer.sln
```

### 构建项目

```powershell
dotnet build WorkHoursTimer.sln
```

### 运行项目

```powershell
dotnet run --project WorkHoursTimer\WorkHoursTimer.csproj
```

---

## ✅ 预期结果

运行成功后，你应该看到：

1. **主窗口**
   - 出现在屏幕右侧
   - 显示 "🚀 WPF v3.0"
   - 有 Mica/Acrylic 磨砂背景（Windows 11/10）
   - 有一个"创建挂件窗口"按钮

2. **点击按钮后**
   - 挂件窗口出现在右下角
   - 显示 "👾 像素挂件"
   - 可以拖拽移动
   - 始终置顶

---

## 🐛 常见问题

### Q1: 找不到 dotnet 命令？
**A**: 需要安装 .NET 8 SDK，参考第一步

### Q2: 编译错误 "找不到 WPF-UI"？
**A**: 运行 `dotnet restore` 恢复依赖包

### Q3: Mica 效果不显示？
**A**: Windows 10 不支持 Mica，会自动降级为 Acrylic

### Q4: 窗口位置不正确？
**A**: 多显示器环境可能有问题，这是已知问题，后续会修复

---

## 📝 项目结构

```
wpf_app/
├── WorkHoursTimer.sln              # 解决方案文件
├── WorkHoursTimer/                 # 主项目
│   ├── App.xaml                    # 应用程序入口
│   ├── App.xaml.cs
│   ├── MainWindow.xaml             # 主窗口
│   ├── MainWindow.xaml.cs
│   ├── WidgetWindow.xaml           # 挂件窗口
│   ├── WidgetWindow.xaml.cs
│   └── WorkHoursTimer.csproj       # 项目文件
└── INSTALL_AND_RUN.md              # 本文档
```

---

## 🎯 下一步

完成 Day 1 后，继续：

1. **Day 2**: 实现鼠标穿透功能
2. **Day 3**: 实现窗口间通信
3. **Day 4-5**: 实现业务逻辑

参考文档：
- `SPRINT1_DEVELOPMENT_PLAN.md` - Sprint 1 详细计划
- `V3.0_TASK_LIST.md` - 完整任务列表

---

## 🆘 需要帮助？

- 查看 `QUICK_START_GUIDE.md`
- 查看 `V3.0_PRD.md`
- 查看 `V3.0_DESIGN_SPEC.md`

---

**祝开发顺利！** 🚀
