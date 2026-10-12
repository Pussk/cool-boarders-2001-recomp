@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -STA -File "%~dp0graphics-menu.ps1"
if errorlevel 1 pause
