# 工时计时器 (Work Hours Timer)

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.41.2-blue.svg)
![Platform](https://img.shields.io/badge/platform-Windows-lightgrey.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Version](https://img.shields.io/badge/version-1.0.0-orange.svg)

一款简洁高效的工时记录工具，支持标准模式和游戏化模式，让工作记录变得有趣！

[下载安装程序](https://github.com/YOUR_USERNAME/work-hours-timer/releases) | [使用文档](flutter_app/用户使用手册.md) | [报告问题](https://github.com/YOUR_USERNAME/work-hours-timer/issues)

</div>

---

## ✨ 功能特性

### 🎯 双模式设计

#### 标准模式
- ⏱️ 简洁的工时记录界面
- 📊 清晰的统计数据展示
- 📈 月度工作时长图表
- 💰 薪资计算功能

#### 游戏模式
- 🎮 趣味化的工作体验
- 🏆 成就系统（30+ 成就）
- ⭐ 经验值和等级系统
- 🎯 每日任务挑战

### 📊 核心功能

- ✅ **工时记录** - 一键开始/结束工作，自动计算时长
- ✅ **午休管理** - 支持午休暂停，准确计算工作时间
- ✅ **数据统计** - 日/周/月统计，可视化图表展示
- ✅ **数据导出** - 支持导出工作记录为 JSON 格式
- ✅ **数据导入** - 支持从文件导入历史记录
- ✅ **薪资计算** - 自动计算工资，支持加班费
- ✅ **本地存储** - 数据安全存储在本地

---

## 📥 下载安装

### 安装程序（推荐）

**适合：** 普通用户

- 📦 [下载安装程序 (10.53 MB)](https://github.com/YOUR_USERNAME/work-hours-timer/releases/latest/download/WorkHoursTimer-Setup-v1.0.0.exe)
- 双击运行，按照向导完成安装
- 自动创建开始菜单快捷方式

### 便携版

**适合：** 技术用户、快速测试

- 📦 [下载便携版 (11.84 MB)](https://github.com/YOUR_USERNAME/work-hours-timer/releases/latest/download/工时计时器-v1.0.0-便携版.zip)
- 解压到任意目录
- 双击 `work_hours_timer.exe` 启动

### 系统要求

- Windows 10 或更高版本
- 64 位系统
- 约 30 MB 磁盘空间

---

## 🚀 快速开始

### 1. 安装应用

下载并安装应用（见上方下载链接）

### 2. 首次使用

1. 启动应用
2. 选择模式（标准模式或游戏模式）
3. 点击"开始工作"按钮
4. 开始记录你的工作时间！

### 3. 基本操作

- **开始工作** - 点击"开始工作"按钮
- **午休** - 点击"午休"按钮暂停计时
- **下班** - 点击"下班"按钮结束并保存记录
- **查看统计** - 切换到"统计"标签查看数据

---

## 📸 应用截图

### 标准模式
![标准模式](screenshots/standard-mode.png)

### 游戏模式
![游戏模式](screenshots/game-mode.png)

### 统计界面
![统计界面](screenshots/statistics.png)

---

## 🎮 游戏化功能

### 成就系统

解锁 30+ 个成就，包括：

- 🌟 **新手上路** - 完成第一天工作
- 🔥 **连续打卡** - 连续工作 7 天
- ⏰ **早起鸟** - 早上 8 点前开始工作
- 🌙 **夜猫子** - 晚上 10 点后还在工作
- 💪 **工作狂** - 单日工作超过 10 小时
- 🎯 **完美一周** - 一周工作满 40 小时

### 等级系统

- 通过工作获得经验值
- 升级解锁新称号
- 从"实习生"到"传奇大师"

### 每日任务

- 每日随机任务
- 完成任务获得额外奖励
- 保持工作动力

---

## 🛠️ 开发者指南

### 环境要求

- Flutter 3.41.2 或更高版本
- Dart 3.x
- Visual Studio 2022（Windows 开发）

### 克隆项目

```bash
git clone https://github.com/YOUR_USERNAME/work-hours-timer.git
cd work-hours-timer/flutter_app
```

### 安装依赖

```bash
flutter pub get
```

### 运行应用

```bash
flutter run -d windows
```

### 构建 Release 版本

```bash
# 使用提供的脚本
build-release.bat

# 或手动构建
flutter build windows --release
```

### 创建安装程序

```bash
# 需要先安装 Inno Setup
install-chinese-and-build.bat
```

---

## 📁 项目结构

```
work-hours-timer/
├── flutter_app/                    # Flutter 应用
│   ├── lib/                        # 源代码
│   │   ├── models/                 # 数据模型
│   │   ├── providers/              # 状态管理
│   │   ├── screens/                # 界面
│   │   ├── services/               # 业务逻辑
│   │   └── widgets/                # 组件
│   ├── windows/                    # Windows 平台配置
│   ├── installer_output/           # 安装程序输出
│   ├── build-release.bat           # 构建脚本
│   ├── package-portable.bat        # 便携版打包
│   └── install-chinese-and-build.bat # 安装程序创建
├── README.md                       # 本文档
└── LICENSE                         # 许可证
```

---

## 📚 文档

- [用户使用手册](flutter_app/用户使用手册.md) - 详细的使用说明
- [功能说明](flutter_app/CURRENT_FEATURES.md) - 完整功能列表
- [游戏化指南](flutter_app/GAMIFICATION_COMPLETE_GUIDE.md) - 游戏化功能详解
- [构建指南](flutter_app/BUILD_AND_PACKAGE_GUIDE.md) - 开发者构建指南
- [打包指南](flutter_app/PACKAGING_COMPLETE_GUIDE.md) - 打包发布指南

---

## 🤝 贡献

欢迎贡献代码、报告问题或提出建议！

### 如何贡献

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

### 报告问题

如果发现 Bug 或有功能建议，请[创建 Issue](https://github.com/YOUR_USERNAME/work-hours-timer/issues)。

---

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

---

## 🙏 致谢

- [Flutter](https://flutter.dev/) - 跨平台 UI 框架
- [Riverpod](https://riverpod.dev/) - 状态管理
- [fl_chart](https://pub.dev/packages/fl_chart) - 图表库
- [path_provider](https://pub.dev/packages/path_provider) - 文件存储
- [Inno Setup](https://jrsoftware.org/isinfo.php) - 安装程序制作

---

## 📞 联系方式

- 项目主页：[https://github.com/YOUR_USERNAME/work-hours-timer](https://github.com/YOUR_USERNAME/work-hours-timer)
- 问题反馈：[Issues](https://github.com/YOUR_USERNAME/work-hours-timer/issues)

---

## ⭐ Star History

如果这个项目对你有帮助，请给个 Star ⭐️

[![Star History Chart](https://api.star-history.com/svg?repos=YOUR_USERNAME/work-hours-timer&type=Date)](https://star-history.com/#YOUR_USERNAME/work-hours-timer&Date)

---

<div align="center">

**用心记录，高效工作** ❤️

Made with ❤️ using Flutter

</div>
