@echo off
chcp 65001 >nul
echo ========================================
echo Work Hours Timer v3.0 - Release Build
echo ========================================
echo.

REM 检查 .NET SDK
echo [1/4] 检查 .NET SDK...
dotnet --version >nul 2>&1
if errorlevel 1 (
    echo ❌ 未找到 .NET SDK，请先安装 .NET 8.0 SDK
    echo 下载地址: https://dotnet.microsoft.com/download
    pause
    exit /b 1
)
echo ✅ .NET SDK 已安装
echo.

REM 清理旧的构建
echo [2/4] 清理旧的构建文件...
cd WorkHoursTimer
if exist "bin\Release" rmdir /s /q "bin\Release"
if exist "obj\Release" rmdir /s /q "obj\Release"
echo ✅ 清理完成
echo.

REM 构建 Release 版本
echo [3/4] 构建 Release 版本...
dotnet publish -c Release -r win-x64 --self-contained false -p:PublishSingleFile=false -p:IncludeNativeLibrariesForSelfExtract=true
if errorlevel 1 (
    echo ❌ 构建失败
    cd ..
    pause
    exit /b 1
)
echo ✅ 构建成功
echo.

REM 创建发布目录
echo [4/4] 准备发布文件...
cd ..
if not exist "release" mkdir "release"
if exist "release\WorkHoursTimer" rmdir /s /q "release\WorkHoursTimer"
mkdir "release\WorkHoursTimer"

REM 复制文件
xcopy "WorkHoursTimer\bin\Release\net8.0-windows\win-x64\publish\*" "release\WorkHoursTimer\" /E /I /Y >nul

echo ✅ 发布文件已准备完成
echo.
echo ========================================
echo 发布文件位置: release\WorkHoursTimer\
echo 主程序: WorkHoursTimer.exe
echo ========================================
echo.
echo 下一步: 运行 package-release.bat 创建安装包
pause
