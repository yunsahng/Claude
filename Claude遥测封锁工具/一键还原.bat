@echo off
chcp 65001 >nul 2>&1
title Claude Desktop 遥测还原

echo ============================================
echo   Claude Desktop 遥测还原工具
echo ============================================
echo.

:: 检查管理员权限
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] 需要管理员权限，正在请求提升...
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

echo [1/2] 删除封锁条目...
echo.

set "HOSTS=%SystemRoot%\System32\drivers\etc\hosts"
set "TEMP_FILE=%TEMP%\hosts_clean.tmp"

:: 创建临时文件，跳过标记行
(
    for /f "usebackq delims=" %%a in ("%HOSTS%") do (
        echo %%a | findstr /C:"Claude Desktop telemetry block" >nul
        if errorlevel 1 (
            echo %%a
        )
    )
) > "%TEMP_FILE%"

:: 替换原文件
copy /y "%TEMP_FILE%" "%HOSTS%" >nul
del "%TEMP_FILE%" >nul

echo [OK] 封锁条目已删除
echo.

echo [2/2] 刷新DNS缓存...
ipconfig /flushdns
echo.

echo ============================================
echo   还原完成！Claude Desktop 遥测已恢复上传。
echo ============================================
echo.
pause
