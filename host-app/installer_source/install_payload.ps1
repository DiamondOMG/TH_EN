$ErrorActionPreference = "Stop"

$payload_dir = $PSScriptRoot
$install_dir = Join-Path $env:LOCALAPPDATA "Programs\OledLanguageIndicator"
$startup_dir = Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs\Startup"
$startup_link = Join-Path $startup_dir "OLED Language Indicator.lnk"
$exe_path = Join-Path $install_dir "OledLanguageIndicator.exe"

New-Item -ItemType Directory -Path $install_dir -Force | Out-Null
New-Item -ItemType Directory -Path $startup_dir -Force | Out-Null
Copy-Item -Path (Join-Path $payload_dir "OledLanguageIndicator.exe") -Destination $exe_path -Force
Copy-Item -Path (Join-Path $payload_dir "uninstall_windows.ps1") -Destination (Join-Path $install_dir "uninstall_windows.ps1") -Force

$wsh_shell = New-Object -ComObject WScript.Shell
$shortcut = $wsh_shell.CreateShortcut($startup_link)
$shortcut.TargetPath = $exe_path
$shortcut.WorkingDirectory = $install_dir
$shortcut.Description = "Shows the active keyboard language on the OLED"
$shortcut.Save()

Start-Process -FilePath $exe_path
Write-Host "Installation complete. The app will start after sign-in."
