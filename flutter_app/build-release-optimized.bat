@echo off
chcp 65001 >nul
echo ========================================
echo 工时计时器 - 优化构建
echo ========================================
echo.
echo 此脚本将使用优化参数构建应用：
echo - 分离调试信息
echo - 代码混淆
echo - 树摇优化
echo.
echo 预期效果：
echo - 减小约 2-3 MB
echo - 提高安全性（代码混淆）
echo.
pause
echo.

REM 设置 Flutter 路径
set FLUTTER_PATH=E:\flutter_windows_3.41.2-stable\flutter\bin

echo 步骤 1: 清理旧的构建文件...
"%FLUTTER_PATH%\flutter.bat" clean

echo.
echo 步骤 2: 获取依赖...
"%FLUTTER_PATH%\flutter.bat" pub get

echo.
echo 步骤 3: 构建优化版本...
echo.
echo 使用参数：
echo   --release              : Release 模式
echo   --split-debug-info     : 分离调试信息
echo   --obfuscate            : 代码混淆
echo   --tree-shake-icons     : 移除未使用的图标
echo.

REM 创建调试信息目录
if not exist "debug-info" mkdir "debug-info"

"%FLUTTER_PATH%\flutter.bat" build windows --release --split-debug-info=debug-info --obfuscate --tree-shake-icons

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo 构建成功！
    echo ========================================
    echo.
    echo Release 文件位置:
    echo build\windows\x64\runner\Release\
    echo.
    echo 调试信息已保存到:
    echo debug-info\
    echo.
    echo 注意：
    echo - 调试信息文件夹可以删除（仅用于崩溃分析）
    echo - 代码已混淆，反编译难度增加
    echo.
    
    REM 显示文件大小
    echo 文件大小：
    for %%F in ("build\windows\x64\runner\Release\flutter_windows.dll") do echo   flutter_windows.dll: %%~zF 字节
    for %%F in ("build\windows\x64\runner\Release\data\app.so") do echo   app.so: %%~zF 字节
    echo.
) else (
    echo.
    echo ========================================
    echo 构建失败！错误代码: %ERRORLEVEL%
    echo ========================================
    echo.
)

pause
