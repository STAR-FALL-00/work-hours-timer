@echo off
chcp 65001 >nul
echo ========================================
echo 工作目录清理脚本
echo ========================================
echo.
echo 此脚本将清理以下内容：
echo - 临时文件和目录
echo - 重复的文档
echo - 旧的构建产物
echo - 不需要的脚本
echo.
echo 保留的内容：
echo - Flutter 应用源代码
echo - 最终的打包文件（安装程序和便携版）
echo - 核心文档
echo.
pause
echo.

REM 创建备份目录
if not exist "backup_before_cleanup" (
    mkdir "backup_before_cleanup"
    echo 已创建备份目录
)

echo.
echo 开始清理...
echo.

REM ========================================
REM 清理项目根目录的临时文件
REM ========================================
echo [1/5] 清理根目录临时文件...

REM 删除旧的 Node.js 相关文件（已迁移到 Flutter）
if exist "dist" rmdir /s /q "dist" 2>nul && echo   ✓ 删除 dist
if exist "dist-gui" rmdir /s /q "dist-gui" 2>nul && echo   ✓ 删除 dist-gui
if exist "installer-files" rmdir /s /q "installer-files" 2>nul && echo   ✓ 删除 installer-files
if exist "node_modules" rmdir /s /q "node_modules" 2>nul && echo   ✓ 删除 node_modules
if exist "gui" rmdir /s /q "gui" 2>nul && echo   ✓ 删除 gui
if exist "src" rmdir /s /q "src" 2>nul && echo   ✓ 删除 src

REM 删除旧的安装包目录
if exist "工时计时器-安装包" rmdir /s /q "工时计时器-安装包" 2>nul && echo   ✓ 删除 工时计时器-安装包

REM 删除重复的说明文档
del /q "安装程序使用说明.md" 2>nul && echo   ✓ 删除 安装程序使用说明.md
del /q "打包说明.md" 2>nul && echo   ✓ 删除 打包说明.md
del /q "打包完成说明.md" 2>nul && echo   ✓ 删除 打包完成说明.md
del /q "分发指南.md" 2>nul && echo   ✓ 删除 分发指南.md
del /q "开始使用.txt" 2>nul && echo   ✓ 删除 开始使用.txt
del /q "快速创建安装程序.txt" 2>nul && echo   ✓ 删除 快速创建安装程序.txt
del /q "如何创建安装程序.txt" 2>nul && echo   ✓ 删除 如何创建安装程序.txt
del /q "如何创建专业安装程序.md" 2>nul && echo   ✓ 删除 如何创建专业安装程序.md
del /q "使用指南-简化版.md" 2>nul && echo   ✓ 删除 使用指南-简化版.md
del /q "最终说明-创建安装程序.md" 2>nul && echo   ✓ 删除 最终说明-创建安装程序.md
del /q "README-安装程序.txt" 2>nul && echo   ✓ 删除 README-安装程序.txt

REM 删除旧的 Node.js 相关文件
del /q "build-installer.js" 2>nul && echo   ✓ 删除 build-installer.js
del /q "cli.js" 2>nul && echo   ✓ 删除 cli.js
del /q "create-real-icon.js" 2>nul && echo   ✓ 删除 create-real-icon.js
del /q "create-simple-icons.js" 2>nul && echo   ✓ 删除 create-simple-icons.js
del /q "demo.js" 2>nul && echo   ✓ 删除 demo.js
del /q "demo.ts" 2>nul && echo   ✓ 删除 demo.ts
del /q "diagnose.js" 2>nul && echo   ✓ 删除 diagnose.js
del /q "example.js" 2>nul && echo   ✓ 删除 example.js
del /q "simple-pack.js" 2>nul && echo   ✓ 删除 simple-pack.js
del /q "test-build.js" 2>nul && echo   ✓ 删除 test-build.js
del /q "package.json" 2>nul && echo   ✓ 删除 package.json
del /q "package-lock.json" 2>nul && echo   ✓ 删除 package-lock.json
del /q "package-gui.json" 2>nul && echo   ✓ 删除 package-gui.json
del /q "tsconfig.json" 2>nul && echo   ✓ 删除 tsconfig.json
del /q "vitest.config.ts" 2>nul && echo   ✓ 删除 vitest.config.ts

REM 删除旧的批处理脚本
del /q "copy-to-english-path.bat" 2>nul && echo   ✓ 删除 copy-to-english-path.bat
del /q "create-icon.bat" 2>nul && echo   ✓ 删除 create-icon.bat
del /q "创建安装程序.bat" 2>nul && echo   ✓ 删除 创建安装程序.bat
del /q "flutter-cmd.bat" 2>nul && echo   ✓ 删除 flutter-cmd.bat
del /q "kill-processes.bat" 2>nul && echo   ✓ 删除 kill-processes.bat
del /q "make-installer.bat" 2>nul && echo   ✓ 删除 make-installer.bat
del /q "make-setup.bat" 2>nul && echo   ✓ 删除 make-setup.bat
del /q "rebuild-and-test.bat" 2>nul && echo   ✓ 删除 rebuild-and-test.bat
del /q "run-flutter-app.bat" 2>nul && echo   ✓ 删除 run-flutter-app.bat
del /q "start-timer.bat" 2>nul && echo   ✓ 删除 start-timer.bat
del /q "test-app.bat" 2>nul && echo   ✓ 删除 test-app.bat

REM 删除旧的安装程序配置
del /q "create-setup.iss" 2>nul && echo   ✓ 删除 create-setup.iss
del /q "installer.nsi" 2>nul && echo   ✓ 删除 installer.nsi
del /q "installer-simple.nsi" 2>nul && echo   ✓ 删除 installer-simple.nsi

REM 删除示例文件
del /q "daily-report-example.json" 2>nul && echo   ✓ 删除 daily-report-example.json
del /q "weekly-report-example.json" 2>nul && echo   ✓ 删除 weekly-report-example.json
del /q "copy-exclude.txt" 2>nul && echo   ✓ 删除 copy-exclude.txt

REM 删除旧的安装程序
del /q "WorkHoursTimer-Setup.exe" 2>nul && echo   ✓ 删除 WorkHoursTimer-Setup.exe

REM ========================================
REM 清理 flutter_app 目录的临时文件
REM ========================================
echo.
echo [2/5] 清理 flutter_app 临时文件...

REM 删除构建临时目录
if exist "flutter_app\build" rmdir /s /q "flutter_app\build" 2>nul && echo   ✓ 删除 build
if exist "flutter_app\.dart_tool" rmdir /s /q "flutter_app\.dart_tool" 2>nul && echo   ✓ 删除 .dart_tool
if exist "flutter_app\portable_package" rmdir /s /q "flutter_app\portable_package" 2>nul && echo   ✓ 删除 portable_package

REM 删除重复的文档
del /q "flutter_app\ACHIEVEMENTS_SYSTEM.md" 2>nul && echo   ✓ 删除 ACHIEVEMENTS_SYSTEM.md
del /q "flutter_app\DEBUG_STATS.md" 2>nul && echo   ✓ 删除 DEBUG_STATS.md
del /q "flutter_app\FILES_CREATED.md" 2>nul && echo   ✓ 删除 FILES_CREATED.md
del /q "flutter_app\FIX_FLUTTER_VERSION.md" 2>nul && echo   ✓ 删除 FIX_FLUTTER_VERSION.md
del /q "flutter_app\GAMIFICATION_DESIGN.md" 2>nul && echo   ✓ 删除 GAMIFICATION_DESIGN.md
del /q "flutter_app\GAMIFICATION_IMPLEMENTATION.md" 2>nul && echo   ✓ 删除 GAMIFICATION_IMPLEMENTATION.md
del /q "flutter_app\GAMIFICATION_STARTED.md" 2>nul && echo   ✓ 删除 GAMIFICATION_STARTED.md
del /q "flutter_app\GAMIFICATION_TODO.md" 2>nul && echo   ✓ 删除 GAMIFICATION_TODO.md
del /q "flutter_app\MONTHLY_STATS_DEBUG.md" 2>nul && echo   ✓ 删除 MONTHLY_STATS_DEBUG.md
del /q "flutter_app\NEW_FEATURES.md" 2>nul && echo   ✓ 删除 NEW_FEATURES.md
del /q "flutter_app\PROJECT_SUMMARY.md" 2>nul && echo   ✓ 删除 PROJECT_SUMMARY.md
del /q "flutter_app\QUICK_FIX_MONTHLY_STATS.md" 2>nul && echo   ✓ 删除 QUICK_FIX_MONTHLY_STATS.md
del /q "flutter_app\QUICK_FIX.md" 2>nul && echo   ✓ 删除 QUICK_FIX.md
del /q "flutter_app\RESTART_APP.md" 2>nul && echo   ✓ 删除 RESTART_APP.md
del /q "flutter_app\RESTART_INSTRUCTIONS.md" 2>nul && echo   ✓ 删除 RESTART_INSTRUCTIONS.md
del /q "flutter_app\SALARY_FEATURE.md" 2>nul && echo   ✓ 删除 SALARY_FEATURE.md
del /q "flutter_app\SETTINGS_PERSISTENCE_FIX.md" 2>nul && echo   ✓ 删除 SETTINGS_PERSISTENCE_FIX.md
del /q "flutter_app\SMART_SALARY_CALCULATION.md" 2>nul && echo   ✓ 删除 SMART_SALARY_CALCULATION.md
del /q "flutter_app\START_HERE.md" 2>nul && echo   ✓ 删除 START_HERE.md
del /q "flutter_app\STATS_FIX.md" 2>nul && echo   ✓ 删除 STATS_FIX.md
del /q "flutter_app\UI_IMPROVEMENTS.md" 2>nul && echo   ✓ 删除 UI_IMPROVEMENTS.md
del /q "flutter_app\UI_OPTIMIZATION_GAME_MODE.md" 2>nul && echo   ✓ 删除 UI_OPTIMIZATION_GAME_MODE.md
del /q "flutter_app\UPDATE_HOME_SCREEN.md" 2>nul && echo   ✓ 删除 UPDATE_HOME_SCREEN.md
del /q "flutter_app\打包说明.md" 2>nul && echo   ✓ 删除 打包说明.md

REM 删除临时脚本
del /q "flutter_app\build-release-utf8.bat" 2>nul && echo   ✓ 删除 build-release-utf8.bat
del /q "flutter_app\build-release.ps1" 2>nul && echo   ✓ 删除 build-release.ps1
del /q "flutter_app\clean-and-run.bat" 2>nul && echo   ✓ 删除 clean-and-run.bat
del /q "flutter_app\create-installer.bat" 2>nul && echo   ✓ 删除 create-installer.bat (已被 install-chinese-and-build.bat 替代)
del /q "flutter_app\run-app.bat" 2>nul && echo   ✓ 删除 run-app.bat
del /q "flutter_app\run-with-correct-flutter.bat" 2>nul && echo   ✓ 删除 run-with-correct-flutter.bat

REM 删除临时文件
del /q "flutter_app\temp_reload.txt" 2>nul && echo   ✓ 删除 temp_reload.txt
del /q "flutter_app\test_monthly_stats.dart" 2>nul && echo   ✓ 删除 test_monthly_stats.dart
del /q "flutter_app\ChineseSimplified.isl" 2>nul && echo   ✓ 删除 ChineseSimplified.isl (已安装到 Inno Setup)

REM ========================================
REM 清理根目录的旧文档
REM ========================================
echo.
echo [3/5] 清理根目录旧文档...

del /q "BUILD_GUIDE.md" 2>nul && echo   ✓ 删除 BUILD_GUIDE.md
del /q "FINAL_SUMMARY.md" 2>nul && echo   ✓ 删除 FINAL_SUMMARY.md
del /q "FLUTTER_INSTALLATION_GUIDE.md" 2>nul && echo   ✓ 删除 FLUTTER_INSTALLATION_GUIDE.md
del /q "FLUTTER_MIGRATION.md" 2>nul && echo   ✓ 删除 FLUTTER_MIGRATION.md
del /q "FLUTTER_PROJECT_SUMMARY.md" 2>nul && echo   ✓ 删除 FLUTTER_PROJECT_SUMMARY.md
del /q "GUI_USAGE.md" 2>nul && echo   ✓ 删除 GUI_USAGE.md
del /q "INSTALL_GUIDE.md" 2>nul && echo   ✓ 删除 INSTALL_GUIDE.md
del /q "PACKAGING_INSTRUCTIONS.md" 2>nul && echo   ✓ 删除 PACKAGING_INSTRUCTIONS.md
del /q "QUICK_START.md" 2>nul && echo   ✓ 删除 QUICK_START.md
del /q "README_FINAL.md" 2>nul && echo   ✓ 删除 README_FINAL.md
del /q "USAGE_GUIDE.md" 2>nul && echo   ✓ 删除 USAGE_GUIDE.md
del /q "VISUAL_STUDIO_SETUP.md" 2>nul && echo   ✓ 删除 VISUAL_STUDIO_SETUP.md
del /q "LICENSE.txt" 2>nul && echo   ✓ 删除 LICENSE.txt

REM ========================================
REM 整理保留的文档
REM ========================================
echo.
echo [4/5] 整理保留的文档...

REM 在 flutter_app 中保留的核心文档：
REM - README.md (项目说明)
REM - CURRENT_FEATURES.md (功能说明)
REM - FINAL_PROJECT_STATUS.md (项目状态)
REM - BUILD_AND_PACKAGE_GUIDE.md (构建打包指南)
REM - PACKAGING_COMPLETE_GUIDE.md (完整打包指南)
REM - INNO_SETUP_GUIDE.md (Inno Setup 指南)
REM - INSTALLER_SUCCESS.md (安装程序创建总结)
REM - PACKAGE_SUMMARY.md (便携版打包总结)
REM - QUICK_REFERENCE.md (快速参考)
REM - GAMIFICATION_COMPLETE_GUIDE.md (游戏化完整指南)
REM - GAMIFICATION_QUICK_START.md (游戏化快速开始)
REM - SALARY_QUICK_START.md (薪资功能快速开始)
REM - 用户使用手册.md (用户手册)

echo   ✓ 保留核心文档

REM ========================================
REM 显示清理结果
REM ========================================
echo.
echo [5/5] 清理完成！
echo.
echo ========================================
echo 清理结果
echo ========================================
echo.
echo 已删除：
echo   - 旧的 Node.js 项目文件
echo   - 临时构建目录
echo   - 重复的文档
echo   - 临时脚本
echo   - 示例文件
echo.
echo 保留的内容：
echo   - flutter_app\ (Flutter 应用源代码)
echo   - flutter_app\installer_output\ (安装程序)
echo   - flutter_app\工时计时器-v1.0.0-便携版.zip (便携版)
echo   - 核心文档和脚本
echo.
echo 保留的核心脚本：
echo   - flutter_app\build-release.bat (构建 Release)
echo   - flutter_app\package-portable.bat (创建便携版)
echo   - flutter_app\install-chinese-and-build.bat (创建安装程序)
echo.
echo 保留的核心文档：
echo   - README.md (项目说明)
echo   - PACKAGING_SUCCESS.md (打包成功总结)
echo   - flutter_app\INSTALLER_SUCCESS.md (安装程序总结)
echo   - flutter_app\QUICK_REFERENCE.md (快速参考)
echo   - flutter_app\用户使用手册.md (用户手册)
echo.
echo ========================================
echo.

pause
