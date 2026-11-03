$ErrorActionPreference = "Stop"

$host_app_dir = $PSScriptRoot
$project_root = Split-Path -Parent $host_app_dir
$build_venv = Join-Path $host_app_dir ".build-venv"
$python = Join-Path $build_venv "Scripts\python.exe"
$dist_dir = Join-Path $host_app_dir "dist"
$build_dir = Join-Path $host_app_dir "build"
$exe_name = "OledLanguageIndicator.exe"
$install_dir = Join-Path $env:LOCALAPPDATA "Programs\OledLanguageIndicator"
$startup_dir = Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs\Startup"
$startup_link = Join-Path $startup_dir "OLED Language Indicator.lnk"

if (-not (Get-Command py -ErrorAction SilentlyContinue)) {
    throw "Python Launcher (py) was not found. Install Python 3.10+ and run setup again."
}

if (-not (Test-Path $python)) {
    & py -3 -m venv $build_venv
    if ($LASTEXITCODE -ne 0) { throw "Could not create the Python build environment." }
}

& $python -m pip install --disable-pip-version-check -r (Join-Path $host_app_dir "requirements.txt") pyinstaller
if ($LASTEXITCODE -ne 0) { throw "Could not install build dependencies." }

& $python -m PyInstaller `
    --noconfirm `
    --clean `
    --onefile `
    --windowed `
    --name OledLanguageIndicator `
    --distpath $dist_dir `
    --workpath $build_dir `
    --specpath $build_dir `
    --hidden-import serial.tools.list_ports_windows `
    --hidden-import serial.serialwin32 `
    (Join-Path $host_app_dir "keyboard_language.py")
if ($LASTEXITCODE -ne 0) { throw "PyInstaller could not build the Windows app." }

$built_exe = Join-Path $dist_dir $exe_name
if (-not (Test-Path $built_exe)) { throw "Built application was not found: $built_exe" }

Get-Process -Name "OledLanguageIndicator" -ErrorAction SilentlyContinue | Stop-Process -Force
New-Item -ItemType Directory -Path $install_dir -Force | Out-Null
New-Item -ItemType Directory -Path $startup_dir -Force | Out-Null
Copy-Item -Path $built_exe -Destination (Join-Path $install_dir $exe_name) -Force
Copy-Item -Path (Join-Path $host_app_dir "uninstall_windows.ps1") -Destination (Join-Path $install_dir "uninstall_windows.ps1") -Force

$wsh_shell = New-Object -ComObject WScript.Shell
$shortcut = $wsh_shell.CreateShortcut($startup_link)
$shortcut.TargetPath = Join-Path $install_dir $exe_name
$shortcut.WorkingDirectory = $install_dir
$shortcut.Description = "Shows the active keyboard language on the OLED"
$shortcut.Save()

Write-Host "Installation complete. Auto-start is enabled after sign-in."
Write-Host "Installed app: $(Join-Path $install_dir $exe_name)"
Start-Process -FilePath (Join-Path $install_dir $exe_name)
Write-Host "The app is running and will start automatically after future sign-ins."
