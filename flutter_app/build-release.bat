@echo off
chcp 65001 >nul
echo 正在构建 Release 版本...
echo.

REM 设置 Flutter 路径
set FLUTTER_PATH=E:\flutter_windows_3.41.2-stable\flutter\bin

REM 构建 Release 版本
echo 步骤 1: 清理旧的构建文件...
"%FLUTTER_PATH%\flutter.bat" clean

echo.
echo 步骤 2: 获取依赖...
"%FLUTTER_PATH%\flutter.bat" pub get

echo.
echo 步骤 3: 构建 Windows Release 版本...
"%FLUTTER_PATH%\flutter.bat" build windows --release

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo 构建成功！
    echo ========================================
    echo.
    echo Release 文件位置:
    echo build\windows\x64\runner\Release\
    echo.
    echo 主程序: work_hours_timer.exe
    echo.
) else (
    echo.
    echo ========================================
    echo 构建失败！错误代码: %ERRORLEVEL%
    echo ========================================
    echo.
)

pause
