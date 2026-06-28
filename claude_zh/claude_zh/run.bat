@echo off
title Claude 汉化工具
cd /d "%~dp0"
chcp 65001 >nul

echo ===========================================
echo   Claude 界面汉化工具（便携版）
echo ===========================================
echo.

:: Check node
where node >nul 2>nul
if errorlevel 1 (
    echo [错误] 需要 Node.js，请先安装 https://nodejs.org
    pause
    exit /b 1
)

:: Find Claude
for /f "delims=" %%d in ('dir /b /o-N "C:\Program Files\WindowsApps\Claude_*" 2^>nul') do (
    if exist "C:\Program Files\WindowsApps\%%d\app\resources\en-US.json" (
        set "CDIR=C:\Program Files\WindowsApps\%%d\app\resources"
        goto :found
    )
)
if exist "%LOCALAPPDATA%\Programs\Claude\resources\en-US.json" set "CDIR=%LOCALAPPDATA%\Programs\Claude\resources" & goto :found
if exist "%ProgramFiles%\Claude\resources\en-US.json" set "CDIR=%ProgramFiles%\Claude\resources" & goto :found
echo [错误] 未找到 Claude 安装
pause
exit /b 1

:found
echo [1/2] 生成汉化文件...
node translate.js "%CDIR%" "%TEMP%\claude_zh"
if errorlevel 1 (
    echo [错误] 生成失败
    pause
    exit /b 1
)

echo [2/2] 写入汉化文件...
echo %CDIR% | findstr /i "WindowsApp" >nul && goto :elev || goto :direct

:direct
copy /Y "%TEMP%\claude_zh\zh-CN.json" "%CDIR%\zh-CN.json" >nul
copy /Y "%TEMP%\claude_zh\i18n_zh-CN.json" "%CDIR%\ion-dist\i18n\zh-CN.json" >nul
copy /Y "%TEMP%\claude_zh\dynamic_zh-CN.json" "%CDIR%\ion-dist\i18n\dynamic\zh-CN.json" >nul
goto :done

:elev
echo 请求管理员权限...
set "SRC=%TEMP:\=\\%\\claude_zh"
set "DST=%CDIR:\=\\%"
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "Start-Process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command ""Copy-Item -Path \"%SRC%\\zh-CN.json\" -Destination \"%DST%\\zh-CN.json\" -Force; Copy-Item -Path \"%SRC%\\i18n_zh-CN.json\" -Destination \"%DST%\\ion-dist\\i18n\\zh-CN.json\" -Force; Copy-Item -Path \"%SRC%\\dynamic_zh-CN.json\" -Destination \"%DST%\\ion-dist\\i18n\\dynamic\\zh-CN.json\" -Force; Write-Host 写入成功""' -Verb RunAs -Wait"

:done
rmdir /s /q "%TEMP%\claude_zh" 2>nul
echo.
echo 汉化完成！请重启 Claude 以生效。
echo.
echo 将此文件夹复制到其他电脑即可重复使用。
pause
