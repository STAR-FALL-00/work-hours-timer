# 工时计时器 - 完整打包指南

## 📦 打包方式对比

| 方式 | 文件大小 | 优点 | 缺点 | 适用场景 |
|------|---------|------|------|---------|
| 便携版（绿色版） | ~12 MB | 无需安装、即解即用 | 无开始菜单、需手动创建快捷方式 | 技术用户、U盘使用 |
| 安装程序 | ~30-40 MB | 专业、自动配置、易卸载 | 需要安装Inno Setup | 普通用户、正式分发 |

## 🚀 快速开始

### 方式 1：创建便携版（推荐，无需额外软件）

```batch
cd flutter_app
build-release.bat          # 构建Release版本
package-portable.bat       # 打包为便携版
```

输出：`工时计时器-v1.0.0-便携版.zip`（约12MB）

### 方式 2：创建安装程序（需要Inno Setup）

```batch
cd flutter_app
build-release.bat          # 构建Release版本
create-installer.bat       # 创建安装程序
```

输出：`installer_output\WorkHoursTimer-Setup-v1.0.0.exe`（约30-40MB）

## 📋 详细步骤

### 步骤 1：构建 Release 版本

1. 打开命令提示符或PowerShell
2. 进入项目目录：
   ```batch
   cd flutter_app
   ```

3. 运行构建脚本：
   ```batch
   build-release.bat
   ```

4. 等待构建完成（约30-60秒）

5. 验证构建成功：
   ```batch
   dir build\windows\x64\runner\Release\work_hours_timer.exe
   ```

### 步骤 2A：创建便携版（无需额外软件）

1. 运行打包脚本：
   ```batch
   package-portable.bat
   ```

2. 打包完成后会生成：
   - `portable_package\` - 文件夹（可直接使用）
   - `工时计时器-v1.0.0-便携版.zip` - 压缩包（用于分发）

3. 测试便携版：
   ```batch
   cd portable_package
   work_hours_timer.exe
   ```

### 步骤 2B：创建安装程序（需要Inno Setup）

1. 安装 Inno Setup（如果还没安装）：
   - 下载：https://jrsoftware.org/isdl.php
   - 安装到默认位置

2. 运行安装程序创建脚本：
   ```batch
   create-installer.bat
   ```

3. 安装程序生成在：
   ```
   installer_output\WorkHoursTimer-Setup-v1.0.0.exe
   ```

4. 测试安装程序：
   - 双击运行安装程序
   - 按照向导完成安装
   - 测试应用是否正常运行

## 📁 文件结构说明

### Release 构建目录
```
build\windows\x64\runner\Release\
├── work_hours_timer.exe          # 主程序（约90KB）
├── flutter_windows.dll           # Flutter引擎（约20MB）
└── data\                         # 资源文件
    ├── icudtl.dat               # Unicode数据
    ├── flutter_assets\          # 应用资源
    │   ├── fonts\
    │   ├── packages\
    │   └── ...
    └── app.so                   # 应用代码
```

### 便携版目录
```
portable_package\
├── work_hours_timer.exe          # 主程序
├── flutter_windows.dll           # Flutter引擎
├── data\                         # 资源文件
└── 使用说明.txt                  # 使用说明
```

### 安装程序输出
```
installer_output\
└── WorkHoursTimer-Setup-v1.0.0.exe  # 安装程序
```

## 🎯 分发建议

### 便携版分发

1. 上传 `工时计时器-v1.0.0-便携版.zip` 到：
   - 网盘（百度网盘、阿里云盘等）
   - GitHub Releases
   - 自己的网站

2. 提供使用说明：
   ```
   工时计时器 v1.0.0 - 便携版
   
   使用方法：
   1. 解压 ZIP 文件到任意目录
   2. 双击 work_hours_timer.exe 启动
   3. 首次启动会自动创建数据目录
   
   系统要求：
   - Windows 10 或更高版本（64位）
   ```

### 安装程序分发

1. 上传 `WorkHoursTimer-Setup-v1.0.0.exe` 到分发平台

2. 提供安装说明：
   ```
   工时计时器 v1.0.0 - 安装版
   
   安装方法：
   1. 双击运行安装程序
   2. 按照向导完成安装
   3. 从开始菜单启动应用
   
   系统要求：
   - Windows 10 或更高版本（64位）
   ```

## ⚠️ 注意事项

### 1. 路径问题

- ✅ 当前项目路径包含中文，但已成功构建
- ⚠️ 如果遇到编码问题，建议移动到纯英文路径
- ✅ 构建产物可以正常使用

### 2. 杀毒软件

- 首次运行可能被杀毒软件拦截
- 建议添加到白名单
- 或进行代码签名（需要证书）

### 3. Windows SmartScreen

- 未签名的程序会显示警告
- 用户需要点击"更多信息" → "仍要运行"
- 解决方案：购买代码签名证书

### 4. 数据存储

- 应用数据存储在：`%APPDATA%\com.workhours\work_hours_timer\`
- 卸载时不会删除用户数据
- 用户可手动删除该目录清除所有数据

## 🔧 自定义配置

### 修改应用名称

编辑 `pubspec.yaml`：
```yaml
name: work_hours_timer
description: 工时记录和统计工具
version: 1.0.0+1
```

### 修改安装程序配置

编辑 `installer.iss`：
```iss
#define MyAppName "工时计时器"
#define MyAppVersion "1.0.0"
```

### 添加应用图标

1. 准备图标文件（.ico格式）
2. 放置在项目目录
3. 修改 `windows\runner\Runner.rc` 引用图标

## 📊 性能优化

### 减小文件大小

1. 移除未使用的资源
2. 优化图片资源
3. 使用 `--split-debug-info` 分离调试信息

### 提升启动速度

1. 使用 `--tree-shake-icons` 移除未使用的图标
2. 优化初始化代码
3. 延迟加载非必需功能

## 🐛 故障排除

### 问题 1：构建失败

```
Error: Unable to find git in your PATH.
```

解决方案：安装 Git 或使用 Flutter SDK 内置的 Git

### 问题 2：打包失败

```
错误：找不到Release构建文件！
```

解决方案：先运行 `build-release.bat` 构建应用

### 问题 3：应用无法启动

可能原因：
- 缺少 Visual C++ 运行库
- 系统不兼容（需要 Windows 10+）
- 被杀毒软件阻止

解决方案：
- 安装 Visual C++ Redistributable
- 升级系统
- 添加到杀毒软件白名单

## 📚 相关文档

- [BUILD_AND_PACKAGE_GUIDE.md](BUILD_AND_PACKAGE_GUIDE.md) - 详细构建指南
- [INNO_SETUP_GUIDE.md](INNO_SETUP_GUIDE.md) - Inno Setup 使用指南
- [CURRENT_FEATURES.md](CURRENT_FEATURES.md) - 功能说明

## ✅ 打包检查清单

构建前：
- [ ] 更新版本号（pubspec.yaml）
- [ ] 测试所有功能正常
- [ ] 更新 CHANGELOG
- [ ] 准备发布说明

构建：
- [ ] 运行 `flutter clean`
- [ ] 运行 `flutter pub get`
- [ ] 运行 `build-release.bat`
- [ ] 验证构建成功

打包：
- [ ] 创建便携版（`package-portable.bat`）
- [ ] 或创建安装程序（`create-installer.bat`）
- [ ] 测试打包文件

测试：
- [ ] 在干净的系统上测试安装
- [ ] 测试所有功能
- [ ] 测试卸载（如果是安装程序）

发布：
- [ ] 上传到分发平台
- [ ] 发布更新说明
- [ ] 通知用户

## 🎉 完成！

现在你已经掌握了完整的打包流程：

1. ✅ Release 构建已完成
2. ✅ 便携版已创建：`工时计时器-v1.0.0-便携版.zip`
3. ⏳ 安装程序（可选）：需要安装 Inno Setup

你可以：
- 直接分发便携版 ZIP 文件
- 或安装 Inno Setup 后创建专业的安装程序

---

**提示：** 对于大多数用户，便携版已经足够使用。如果需要更专业的分发方式，再考虑创建安装程序。
