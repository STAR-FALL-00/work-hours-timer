@echo off
chcp 65001 >nul
echo ========================================
echo 工时计时器 - 便携版打包脚本
echo ========================================
echo.

REM 检查Release构建是否存在
if not exist "build\windows\x64\runner\Release\work_hours_timer.exe" (
    echo 错误：找不到Release构建文件！
    echo 请先运行 build-release.bat 构建应用
    echo.
    pause
    exit /b 1
)

REM 创建输出目录
set OUTPUT_DIR=portable_package
if exist "%OUTPUT_DIR%" (
    echo 清理旧的打包文件...
    rmdir /s /q "%OUTPUT_DIR%"
)
mkdir "%OUTPUT_DIR%"

echo.
echo 正在复制文件...
xcopy "build\windows\x64\runner\Release\*" "%OUTPUT_DIR%\" /E /I /Y >nul

echo.
echo 创建使用说明...
(
echo 工时计时器 v1.0.0 - 便携版
echo ========================================
echo.
echo 使用方法：
echo 1. 双击 work_hours_timer.exe 启动应用
echo 2. 首次启动会自动创建数据目录
echo.
echo 功能说明：
echo - 标准模式：简洁的工时记录
echo - 游戏模式：带成就系统的趣味计时
echo - 统计分析：工作时长图表展示
echo - 数据导出：支持导出工作记录
echo.
echo 数据存储位置：
echo %%APPDATA%%\com.workhours\work_hours_timer\
echo.
echo 系统要求：
echo - Windows 10 或更高版本
echo - 64位系统
echo.
echo 技术支持：
echo 如遇到问题，请检查是否有杀毒软件阻止运行
echo.
echo ========================================
echo 版权所有 © 2024 Work Hours Timer
) > "%OUTPUT_DIR%\使用说明.txt"

echo.
echo 创建压缩包...
powershell -Command "Compress-Archive -Path '%OUTPUT_DIR%\*' -DestinationPath '工时计时器-v1.0.0-便携版.zip' -Force"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo 打包成功！
    echo ========================================
    echo.
    echo 输出文件：
    echo - 文件夹：%OUTPUT_DIR%\
    echo - 压缩包：工时计时器-v1.0.0-便携版.zip
    echo.
    echo 文件大小：
    for %%F in ("工时计时器-v1.0.0-便携版.zip") do echo   %%~zF 字节 ^(约 %%~zF / 1048576 MB^)
    echo.
    echo 可以直接分发压缩包，用户解压后即可使用
    echo.
) else (
    echo.
    echo ========================================
    echo 打包失败！
    echo ========================================
    echo.
)

pause
