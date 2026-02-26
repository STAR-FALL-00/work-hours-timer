@echo off
chcp 65001 >nul
echo ========================================
echo 发布到 GitHub
echo ========================================
echo.
echo 此脚本将帮助你发布项目到 GitHub
echo.
echo 前提条件：
echo 1. 已安装 Git
echo 2. 已创建 GitHub 账号
echo 3. 已在 GitHub 上创建仓库
echo.
pause
echo.

REM 检查 Git 是否安装
where git >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo 错误：未找到 Git！
    echo 请先安装 Git: https://git-scm.com/download/win
    echo.
    pause
    exit /b 1
)

echo Git 已安装 ✓
echo.

REM 检查是否已初始化 Git 仓库
if not exist ".git" (
    echo 步骤 1: 初始化 Git 仓库...
    git init
    echo.
) else (
    echo Git 仓库已存在 ✓
    echo.
)

REM 配置 Git 用户信息（如果还没配置）
echo 步骤 2: 配置 Git 用户信息...
echo.
set /p GIT_NAME="请输入你的名字: "
set /p GIT_EMAIL="请输入你的邮箱: "

git config user.name "%GIT_NAME%"
git config user.email "%GIT_EMAIL%"
echo.
echo Git 用户信息已配置 ✓
echo.

REM 添加所有文件
echo 步骤 3: 添加文件到 Git...
git add .
echo.
echo 文件已添加 ✓
echo.

REM 创建提交
echo 步骤 4: 创建提交...
git commit -m "Initial commit: 工时计时器 v1.0.0"
echo.
echo 提交已创建 ✓
echo.

REM 添加远程仓库
echo 步骤 5: 添加远程仓库...
echo.
set /p GITHUB_USERNAME="请输入你的 GitHub 用户名: "
set REPO_URL=https://github.com/%GITHUB_USERNAME%/work-hours-timer.git

echo.
echo 远程仓库 URL: %REPO_URL%
echo.
set /p CONFIRM="确认这个 URL 正确吗？(Y/N): "

if /i "%CONFIRM%" NEQ "Y" (
    echo 已取消
    pause
    exit /b 0
)

git remote add origin %REPO_URL%
echo.
echo 远程仓库已添加 ✓
echo.

REM 推送到 GitHub
echo 步骤 6: 推送到 GitHub...
echo.
echo 注意：首次推送需要输入 GitHub 用户名和密码
echo （或使用 Personal Access Token）
echo.
pause

git branch -M main
git push -u origin main

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo 推送成功！
    echo ========================================
    echo.
    echo 你的代码已上传到：
    echo https://github.com/%GITHUB_USERNAME%/work-hours-timer
    echo.
    echo 下一步：
    echo 1. 访问上面的 URL 查看你的仓库
    echo 2. 创建 Release（参考 GITHUB_RELEASE_GUIDE.md）
    echo 3. 上传安装文件
    echo.
) else (
    echo.
    echo ========================================
    echo 推送失败！
    echo ========================================
    echo.
    echo 可能的原因：
    echo 1. GitHub 仓库不存在
    echo 2. 用户名或密码错误
    echo 3. 网络连接问题
    echo.
    echo 请检查错误信息并重试
    echo.
)

pause
