@echo off
echo ========================================
echo 战斗系统测试脚本
echo ========================================
echo.

echo [1/3] 清理旧的构建...
cd WorkHoursTimer
dotnet clean >nul 2>&1

echo [2/3] 重新编译...
dotnet build
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ❌ 编译失败！请检查错误信息。
    pause
    exit /b 1
)

echo.
echo [3/3] 启动应用...
echo.
echo ========================================
echo 📋 测试步骤:
echo ========================================
echo 1. 点击主窗口的"开始工作"按钮
echo 2. 等待 3-5 秒
echo 3. 观察挂件窗口中的角色动画
echo.
echo 💡 如何查看日志:
echo ========================================
echo 方法1: 使用 Visual Studio
echo   - 用 VS 打开 WorkHoursTimer.sln
echo   - 按 F5 启动调试
echo   - 查看"输出"窗口 (Ctrl+Alt+O)
echo.
echo 方法2: 使用 DebugView
echo   - 下载并运行 DebugView.exe
echo   - 启用 Capture Win32
echo   - 搜索 "[BattleSystem]" 或 "[WidgetViewModel]"
echo.
echo ========================================
echo.

dotnet run

cd ..
