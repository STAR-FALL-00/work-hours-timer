@echo off
echo ========================================
echo Work Hours Timer v3.0 - Build and Run
echo ========================================
echo.

REM 检查 .NET SDK
echo [1/4] 检查 .NET SDK...
dotnet --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ 未找到 .NET SDK
    echo.
    echo 请先安装 .NET 8 SDK:
    echo 1. 运行: winget install Microsoft.DotNet.SDK.8
    echo 2. 或访问: https://dotnet.microsoft.com/download/dotnet/8.0
    echo.
    pause
    exit /b 1
)
echo ✅ .NET SDK 已安装
echo.

REM 恢复依赖
echo [2/4] 恢复依赖包...
dotnet restore WorkHoursTimer.sln
if %errorlevel% neq 0 (
    echo ❌ 恢复依赖失败
    pause
    exit /b 1
)
echo ✅ 依赖包已恢复
echo.

REM 构建项目
echo [3/4] 构建项目...
dotnet build WorkHoursTimer.sln --configuration Debug
if %errorlevel% neq 0 (
    echo ❌ 构建失败
    pause
    exit /b 1
)
echo ✅ 构建成功
echo.

REM 运行项目
echo [4/4] 启动应用...
echo.
echo ========================================
echo 应用正在启动...
echo 主窗口应该出现在屏幕右侧
echo 点击"创建挂件窗口"按钮测试功能
echo ========================================
echo.
dotnet run --project WorkHoursTimer\WorkHoursTimer.csproj

pause
