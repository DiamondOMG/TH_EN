$ErrorActionPreference = "Stop"

$host_app_dir = $PSScriptRoot
$dist_dir = Join-Path $host_app_dir "dist"
$staging_dir = Join-Path $host_app_dir "installer-staging"
$installer_path = Join-Path $dist_dir "OledLanguageIndicatorSetup.exe"
$sed_path = Join-Path $host_app_dir "OledLanguageIndicatorSetup.sed"
$iexpress_path = Join-Path $env:WINDIR "System32\iexpress.exe"
$app_path = Join-Path $dist_dir "OledLanguageIndicator.exe"

if (-not (Test-Path $app_path)) {
    throw "Build the app first by running setup_windows.ps1."
}
if (-not (Test-Path $iexpress_path)) {
    throw "IExpress was not found on this Windows installation."
}

New-Item -ItemType Directory -Path $dist_dir -Force | Out-Null
New-Item -ItemType Directory -Path $staging_dir -Force | Out-Null
Copy-Item -Path $app_path -Destination (Join-Path $staging_dir "OledLanguageIndicator.exe") -Force
Copy-Item -Path (Join-Path $host_app_dir "uninstall_windows.ps1") -Destination (Join-Path $staging_dir "uninstall_windows.ps1") -Force
Copy-Item -Path (Join-Path $host_app_dir "installer_source\install_payload.ps1") -Destination (Join-Path $staging_dir "install_payload.ps1") -Force

$sed_content = @"
[Version]
Class=IEXPRESS
SEDVersion=3
[Options]
PackagePurpose=InstallApp
ShowInstallProgramWindow=1
HideExtractAnimation=1
UseLongFileName=1
InsideCompressed=1
CAB_FixedSize=0
CAB_ResvCodeSigning=0
RebootMode=N
InstallPrompt=
DisplayLicense=
FinishMessage=
TargetName=$installer_path
FriendlyName=OLED Language Indicator Setup
AppLaunched=powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File install_payload.ps1
PostInstallCmd=<None>
AdminQuietInstCmd=
UserQuietInstCmd=
SourceFiles=SourceFiles
[SourceFiles]
SourceFiles0=$staging_dir
[SourceFiles0]
%FILE0%=
%FILE1%=
%FILE2%=
[Strings]
FILE0=OledLanguageIndicator.exe
FILE1=install_payload.ps1
FILE2=uninstall_windows.ps1
"@

Set-Content -Path $sed_path -Value $sed_content -Encoding ASCII
if (Test-Path $installer_path) { Remove-Item -Path $installer_path -Force }
& $iexpress_path /N /Q $sed_path
$deadline = (Get-Date).AddMinutes(2)
$last_length = 0
$stable_count = 0
while ((Get-Date) -lt $deadline -and $stable_count -lt 3) {
    if (Test-Path $installer_path) {
        $current_length = (Get-Item -Path $installer_path).Length
        if ($current_length -ge 1000000 -and $current_length -eq $last_length) {
            $stable_count++
        } else {
            $stable_count = 0
        }
        $last_length = $current_length
    }
    Start-Sleep -Seconds 1
}
if (-not (Test-Path $installer_path) -or (Get-Item -Path $installer_path).Length -lt 1000000) {
    throw "Installer package was not created or is incomplete: $installer_path"
}

Write-Host "Shareable installer created: $installer_path"
