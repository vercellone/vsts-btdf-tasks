# http://blog.devmatter.com/custom-build-tasks-in-vso/
# https://github.com/Microsoft/vso-agent-tasks/blob/master/docs/contribute.md

$ProgramFiles = $env:ProgramFiles
$UninstallPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
if ([Environment]::Is64BitOperatingSystem) {
    $ProgramFiles = ${env:ProgramFiles(x86)}
    $UninstallPath = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
}
. "$PSScriptRoot\Get-MSBuildPath.ps1"