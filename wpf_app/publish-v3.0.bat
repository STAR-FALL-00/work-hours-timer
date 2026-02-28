@echo off
chcp 65001 >nul
echo ========================================
echo Work Hours Timer v3.0.0 - 一键发布
echo ========================================
echo.
echo 此脚本将执行以下操作：
echo 1. 构建 Release 版本
echo 2. 创建 ZIP 包
echo 3. 提交代码到 Git
echo 4. 创建 Git Tag
echo 5. 推送到 GitHub
echo.
echo 按任意键继续，或 Ctrl+C 取消...
pause >nul
echo.

REM 步骤 1: 构建 Release
echo ========================================
echo [1/5] 构建 Release 版本...
echo ========================================
call build-release.bat
if errorlevel 1 (
    echo ❌ 构建失败，发布中止
    pause
    exit /b 1
)
echo.

REM 步骤 2: 打包
echo ========================================
echo [2/5] 创建 ZIP 包...
echo ========================================
call package-release.bat
if errorlevel 1 (
    echo ❌ 打包失败，发布中止
    pause
    exit /b 1
)
echo.

REM 步骤 3: Git 提交
echo ========================================
echo [3/5] 提交代码到 Git...
echo ========================================
cd ..
git add .
git commit -m "Release v3.0.0 - WPF 重构版本"
if errorlevel 1 (
    echo ⚠️ 没有需要提交的更改，继续...
)
echo ✅ 代码已提交
echo.

REM 步骤 4: 创建 Tag
echo ========================================
echo [4/5] 创建 Git Tag...
echo ========================================
git tag -a v3.0.0 -m "Work Hours Timer v3.0.0 - WPF Edition"
if errorlevel 1 (
    echo ⚠️ Tag 可能已存在，继续...
)
echo ✅ Tag 已创建
echo.

REM 步骤 5: 推送到 GitHub
echo ========================================
echo [5/5] 推送到 GitHub...
echo ========================================
echo 推送主分支...
git push origin main
if errorlevel 1 (
    echo ❌ 推送主分支失败
    cd wpf_app
    pause
    exit /b 1
)
echo.
echo 推送 Tag...
git push origin v3.0.0
if errorlevel 1 (
    echo ❌ 推送 Tag 失败
    cd wpf_app
    pause
    exit /b 1
)
echo ✅ 推送完成
echo.

cd wpf_app

REM 完成
echo ========================================
echo 🎉 发布准备完成！
echo ========================================
echo.
echo 📦 发布包位置: release\WorkHoursTimer-v3.0-Portable.zip
echo 🏷️ Git Tag: v3.0.0
echo 🌐 GitHub: 已推送
echo.
echo 下一步：
echo 1. 访问 GitHub 仓库
echo 2. 点击 "Releases" → "Create a new release"
echo 3. 选择 tag "v3.0.0"
echo 4. 上传 ZIP 文件
echo 5. 填写 Release 说明（参考 GITHUB_RELEASE_GUIDE_v3.0.md）
echo 6. 点击 "Publish release"
echo.
echo 详细步骤请查看: GITHUB_RELEASE_GUIDE_v3.0.md
echo ========================================
pause
