@echo off
chcp 65001 >nul
echo ========================================
echo 测试工作时间设置功能
echo ========================================
echo.
echo 启动应用...
echo 请点击"工作时间设置"按钮测试
echo.
echo 如果崩溃，请查看控制台输出的错误信息
echo ========================================
echo.

cd WorkHoursTimer\bin\Debug\net8.0-windows
WorkHoursTimer.exe

pause
