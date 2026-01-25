@echo off
REM Batch wrapper for dotfiles CLI
REM This allows running 'dot' from Command Prompt
REM 
REM Usage: dot <command> [arguments]

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0dot.ps1" %*
