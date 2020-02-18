function Get-MSBuildPath {
    $MSBuildToolsPath = Get-ChildItem -Path HKLM:\SOFTWARE\MICROSOFT\msbuild\toolsversions | Sort-Object -Property Name | Select-Object -Last 1 | Get-ItemProperty | Select-Object -ExpandProperty MSBuildToolsPath
    $MSBuildToolsPath32 = Join-Path ($MSBuildToolsPath -replace 'Framework64','Framework') 'msbuild.exe'
    if (Test-Path -Path $MSBuildToolsPath32) {
        Write-Host "Get-MSBuildPath: $MSBuildToolsPath32" 
        $MSBuildToolsPath32
    } elseif (Test-Path -Path $MSBuildToolsPath) {
        Write-Host "Get-MSBuildPath: $MSBuildToolsPath" 
        $MSBuildToolsPath
    } else {
        Write-Host "##vso[task.logissue type=error;] MSBuild not found."
    }
}