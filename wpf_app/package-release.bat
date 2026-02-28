@echo off
chcp 65001 >nul
echo ========================================
echo Work Hours Timer v3.0 - Package Release
echo ========================================
echo.

REM 检查发布文件是否存在
if not exist "release\WorkHoursTimer\WorkHoursTimer.exe" (
    echo ❌ 未找到发布文件，请先运行 build-release.bat
    pause
    exit /b 1
)

REM 创建 ZIP 包
echo [1/2] 创建便携版 ZIP 包...
cd release
if exist "WorkHoursTimer-v3.0-Portable.zip" del "WorkHoursTimer-v3.0-Portable.zip"

REM 使用 PowerShell 创建 ZIP
powershell -Command "Compress-Archive -Path 'WorkHoursTimer\*' -DestinationPath 'WorkHoursTimer-v3.0-Portable.zip' -CompressionLevel Optimal"

if errorlevel 1 (
    echo ❌ 创建 ZIP 包失败
    cd ..
    pause
    exit /b 1
)
echo ✅ ZIP 包创建成功
cd ..
echo.

REM 显示文件信息
echo [2/2] 获取文件信息...
for %%F in ("release\WorkHoursTimer-v3.0-Portable.zip") do (
    set size=%%~zF
    set /a sizeMB=!size! / 1048576
)
echo ✅ 打包完成
echo.
echo ========================================
echo 📦 发布包信息
echo ========================================
echo 文件名: WorkHoursTimer-v3.0-Portable.zip
echo 位置: release\
echo 大小: 约 %sizeMB% MB
echo ========================================
echo.
echo 🎉 打包完成！可以上传到 GitHub Release
echo.
pause
