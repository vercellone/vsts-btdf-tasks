param(
    [Parameter(Mandatory,HelpMessage="Product name, Guid, or path to an MSI to uninstall.")]
    [string]$Product,

    [Parameter(HelpMessage="Additional msiexec.exe command line arguments")]
    [string]$Arguments
)
. "$PSScriptRoot\Init-BTDFTasks.ps1"
. "$PSScriptRoot\Get-MSIFileInformation.ps1"

$InstallGuid = [Guid]::Empty

if (-not [Guid]::TryParse($Product, [ref] $InstallGuid)) {
    if (Test-Path -Path "$Product" -ErrorAction SilentlyContinue) {
        $MSI = Get-Item -Path "$Product" -ErrorAction Stop
        $FoundMSIGuid = Get-MSIFileInformation -Path "$MSI" -Property "ProductCode"
        if (-not [Guid]::TryParse($FoundMSIGuid, [ref] $InstallGuid)) {
            $Name = [Regex]::Match($MSI.BaseName,'^(\.?[a-zA-Z]+)*').Value
        }
    } else {
        $Name = "$Product"
    }

    if([Guid]::Empty -eq $InstallGuid) {
        $InstallGuid = Get-ChildItem $UninstallPath | Where-Object { ( $_ | Get-ItemProperty -Name DisplayName -ErrorAction SilentlyContinue).DisplayName -eq "$Name" } | Select-Object -ExpandProperty PSChildName
        if ($null -eq $InstallGuid) {
            Write-Host ("##vso[task.logissue type=warning;] Product not found [{0}]" -f $Name)
        }
    }
}

$msiexec = 'msiexec.exe'
$args = [string[]]@(
    "/x {0:B}"  -f $InstallGuid
    "/qn"
)
if (-not [string]::IsNullOrWhiteSpace($Arguments)) {
    $args += $Arguments -split ' '
}

Write-Host ('msiexec.exe',($args -join ' ') -join ' ')
Start-Process -FilePath $msiexec -ArgumentList $args -NoNewWindow -Wait
