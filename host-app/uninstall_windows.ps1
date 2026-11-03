$ErrorActionPreference = "Stop"

$install_dir = Split-Path -Parent $MyInvocation.MyCommand.Path
$startup_link = Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs\Startup\OLED Language Indicator.lnk"

Get-Process -Name "OledLanguageIndicator" -ErrorAction SilentlyContinue | Stop-Process -Force
Remove-Item -Path $startup_link -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1
Remove-Item -Path $install_dir -Recurse -Force
Write-Host "OLED Language Indicator was uninstalled and auto-start was removed."
