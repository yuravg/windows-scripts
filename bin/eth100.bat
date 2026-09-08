@echo off
rem
rem Set Ethernet adapter link speed to 100 Mbps.
rem Non-interactive - call from an already-elevated shell/script.
rem Optional %1: adapter name (see "Get-NetAdapter"); default: auto-detect.
rem
if "%~1"=="" (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%HOME%\projects\windows-scripts\templates\eth_set_speed.ps1" -Speed 100
) else (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%HOME%\projects\windows-scripts\templates\eth_set_speed.ps1" -Speed 100 -AdapterName "%~1"
)
exit /b %ERRORLEVEL%
