@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0play.ps1" -Software
if errorlevel 1 pause
