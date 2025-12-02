<#
PowerShell helper to download and run Visual Studio installer for Flutter Windows desktop builds.
Usage (run as Administrator):
  PowerShell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install_vs.ps1
  or to install Build Tools-only: .\scripts\install_vs.ps1 -UseBuildTools
#>
param(
    [switch]$UseBuildTools
)

$ProgressPreference = 'SilentlyContinue'
$installer = if ($UseBuildTools) { "$env:TEMP\vs_buildtools.exe" } else { "$env:TEMP\vs_community.exe" }

Write-Host "Downloading installer to: $installer"

if ($UseBuildTools) {
    $url = 'https://aka.ms/vs/17/release/vs_buildtools.exe'
} else {
    $url = 'https://aka.ms/vs/17/release/vs_community.exe'
}

Invoke-WebRequest -Uri $url -OutFile $installer -UseBasicParsing

Write-Host "Installer downloaded. Starting Visual Studio installer (elevated). This will prompt for admin rights."

$args = @(
    '--wait',
    '--norestart',
    '--nocache'
)

if ($UseBuildTools) {
    $args += '--add','Microsoft.VisualStudio.Workload.VCTools'
    $args += '--add','Microsoft.VisualStudio.Component.VC.CMake.Project'
    # Windows SDK component may vary; fallback to a commonly available SDK
    $args += '--add','Microsoft.VisualStudio.Component.Windows10SDK.19041'
} else {
    $args += '--add','Microsoft.VisualStudio.Workload.NativeDesktop'
    $args += '--add','Microsoft.VisualStudio.Component.VC.Tools.x86.x64'
    $args += '--add','Microsoft.VisualStudio.Component.VC.CMake.Project'
    $args += '--add','Microsoft.VisualStudio.Component.Windows10SDK.19041'
}

# Use GUI install if user wants to intervene. Remove --quiet to show UI. Using quiet install is commented out by default.
# $args += '--quiet'

Start-Process -FilePath $installer -ArgumentList $args -Verb RunAs -Wait

Write-Host "Installer finished. If a restart was required, please reboot the machine before proceeding."

Write-Host "Next steps (run after reboot if prompted):"
Write-Host "  1) Enable Windows desktop support for Flutter:"
Write-Host "       flutter config --enable-windows-desktop"
Write-Host "  2) Verify toolchain:"
Write-Host "       flutter doctor -v"

Write-Host "If flutter doctor reports missing components, re-run this script to add the reported components or open the Visual Studio Installer to modify the installation."
