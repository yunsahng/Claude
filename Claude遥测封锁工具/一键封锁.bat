@echo off
chcp 65001 >nul 2>&1
title Claude Desktop 遥测封锁工具

echo ============================================
echo   Claude Desktop 遥测封锁工具
echo ============================================
echo.

:: 获取脚本所在目录
set "SCRIPT_DIR=%~dp0"

:: 检查管理员权限
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] 需要管理员权限，正在请求提升...
    echo.
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

echo [1/2] 执行封锁脚本...
echo.
python "%SCRIPT_DIR%block_claude_telemetry.py"
echo.

echo [2/2] 验证封锁效果...
echo.
python "%SCRIPT_DIR%verify_claude_block.py"
echo.

echo ============================================
echo   操作完成！
echo ============================================
echo.
echo 如果要还原，运行 restore.bat
echo.
pause
