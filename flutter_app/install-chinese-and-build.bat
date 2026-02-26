@echo off
chcp 65001 >nul
echo ========================================
echo 工时计时器 - 安装中文语言包并创建安装程序
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

REM 设置Inno Setup路径
set INNO_SETUP_PATH=E:\software\Inno Setup 6
set ISCC_PATH=%INNO_SETUP_PATH%\ISCC.exe

REM 检查Inno Setup是否安装
if not exist "%ISCC_PATH%" (
    echo 错误：找不到 Inno Setup！
    echo 路径：%ISCC_PATH%
    echo.
    pause
    exit /b 1
)

echo 步骤 1: 复制中文语言文件到 Inno Setup 目录...
if exist "ChineseSimplified.isl" (
    copy /Y "ChineseSimplified.isl" "%INNO_SETUP_PATH%\Languages\" >nul
    if %ERRORLEVEL% EQU 0 (
        echo ✓ 中文语言文件已复制
    ) else (
        echo ✗ 复制失败，可能需要管理员权限
        echo   请手动复制 ChineseSimplified.isl 到：
        echo   %INNO_SETUP_PATH%\Languages\
        echo.
        pause
        exit /b 1
    )
) else (
    echo ✗ 找不到 ChineseSimplified.isl 文件
    pause
    exit /b 1
)

echo.
echo 步骤 2: 创建输出目录...
if not exist "installer_output" (
    mkdir "installer_output"
)

echo.
echo 步骤 3: 编译安装程序...
echo.
"%ISCC_PATH%" "installer.iss"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo 安装程序创建成功！
    echo ========================================
    echo.
    echo 输出位置：
    for %%F in ("installer_output\WorkHoursTimer-Setup-v*.exe") do (
        echo   %%~nxF
        echo   大小：%%~zF 字节 (约 %%~zF / 1048576 MB)
        echo   路径：%%~fF
    )
    echo.
    echo 可以分发此安装程序给用户使用
    echo.
) else (
    echo.
    echo ========================================
    echo 安装程序创建失败！
    echo ========================================
    echo.
    echo 请检查上方的错误信息
    echo.
)

pause
