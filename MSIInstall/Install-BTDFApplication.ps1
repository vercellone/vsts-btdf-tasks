param(
    [Parameter(Mandatory,HelpMessage="Full path to the MSI file to install")]
    [Alias("MsiFile")]
    [string]$Path,

    [Parameter(HelpMessage="Product name (BizTalk application) to install. (optional; default is the non-numeric portion of the MSI base file name)")]
    [Alias("ApplicationName")]
    [string]$Name,

    [Parameter(HelpMessage="Path to the directory to which the product will be installed (optional; default is a subfolder by the same name as the product in `$env:ProgramFiles or `$env:ProgramFiles(x86))")]
    [Alias("InstallDir")]
    [Alias("InstallationDirectory")]
    [string]$Destination,

    [Parameter(HelpMessage="msiexec.exe command line arguments")]
    [string]$Arguments
)
. "$PSScriptRoot\Init-BTDFTasks.ps1"

$MSI = Get-Item -Path $Path -ErrorAction Stop

if ([string]::IsNullOrWhiteSpace($Destination)) {
    if ([string]::IsNullOrWhiteSpace($Name)) {
        $Name = [Regex]::Match($MSI.BaseName,'^(\.?[a-zA-Z]+)*').Value
    }
    $Destination = Join-Path $ProgramFiles $Name
}

$msiexec = 'msiexec.exe'
$args = [string[]]@(
    '/i "{0}"' -f $MSI.FullName
    "/qn"
)
if (-not [string]::IsNullOrWhiteSpace($Destination)) {
    $args += "INSTALLDIR=""$Destination"""
}
if (-not [string]::IsNullOrWhiteSpace($Arguments)) {
    $args += $Arguments -split ' '
}

Write-Host ('msiexec.exe',($args -join ' ') -join ' ')
Start-Process -FilePath $msiexec -ArgumentList $args -NoNewWindow -Wait