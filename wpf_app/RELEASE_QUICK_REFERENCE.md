# 🚀 v3.0.0 发布快速参考

## 一键发布（推荐）

```bash
cd wpf_app
./publish-v3.0.bat
```

这个脚本会自动完成：
- ✅ 构建 Release 版本
- ✅ 创建 ZIP 包
- ✅ Git 提交和 Tag
- ✅ 推送到 GitHub

然后手动在 GitHub 上创建 Release 并上传文件。

---

## 手动发布步骤

### 1. 构建和打包
```bash
cd wpf_app
./build-release.bat      # 构建
./package-release.bat    # 打包
```

### 2. Git 操作
```bash
cd ..
git add .
git commit -m "Release v3.0.0"
git tag -a v3.0.0 -m "Work Hours Timer v3.0.0"
git push origin main
git push origin v3.0.0
```

### 3. GitHub Release
1. 访问: https://github.com/your-username/work-hours-timer/releases/new
2. Tag: `v3.0.0`
3. Title: `Work Hours Timer v3.0.0 - WPF 重构版本 🎉`
4. 上传: `wpf_app/release/WorkHoursTimer-v3.0-Portable.zip`
5. 复制 Release 说明（见下方）
6. 点击 "Publish release"

---

## Release 说明模板

```markdown
# 🎉 Work Hours Timer v3.0.0 - WPF 重构版本

完全重构的版本，带来全新的桌面挂件体验！

## ✨ 主要特性
- 🎮 像素风格动画挂件
- ⚔️ 完整战斗系统
- ⏰ 基于时间的血条
- 🎨 现代化 UI

## 📦 下载
- **便携版**: WorkHoursTimer-v3.0-Portable.zip
- **系统要求**: Windows 10/11 + .NET 8.0

## 🚀 快速开始
1. 下载 ZIP 文件
2. 解压到任意目录
3. 运行 WorkHoursTimer.exe

查看完整更新日志: [CHANGELOG_v3.0.0.md](链接)
```

---

## 文件清单

发布包应包含：
- ✅ WorkHoursTimer.exe（主程序）
- ✅ *.dll（依赖库）
- ✅ Assets/（资源文件夹）
- ✅ runtimes/（运行时文件）

---

## 验证清单

发布前：
- [ ] 代码已提交
- [ ] 版本号正确
- [ ] 功能已测试
- [ ] ZIP 包已创建

发布后：
- [ ] Release 已创建
- [ ] 文件可下载
- [ ] 链接有效
- [ ] 文档已更新

---

## 常用命令

### 删除错误的 Tag
```bash
git tag -d v3.0.0                    # 删除本地
git push origin :refs/tags/v3.0.0   # 删除远程
```

### 修改最后一次提交
```bash
git commit --amend -m "新的提交信息"
git push origin main --force
```

### 查看 Tag 列表
```bash
git tag -l
```

---

## 问题排查

### 构建失败
- 检查 .NET SDK 是否安装
- 清理 bin 和 obj 文件夹
- 重新运行 build-release.bat

### 推送失败
- 检查 Git 配置
- 确认有推送权限
- 检查网络连接

### ZIP 包过大
- 检查是否包含不必要的文件
- 确认使用 Release 配置
- 考虑使用 PublishSingleFile

---

## 联系方式

- GitHub Issues: https://github.com/your-username/work-hours-timer/issues
- Email: your-email@example.com

---

**版本**: v3.0.0  
**日期**: 2026-02-28  
**平台**: Windows (WPF)
