Get-ChildItem -Path $PSScriptRoot -Directory -Exclude Common | ForEach-Object {
    $taskPath = $_
    Remove-Item -Path (Join-Path $taskPath 'ps_modules') -Force -Recurse
    Get-ChildItem -Path (Join-Path $PSScriptRoot 'Common\*.*') | ForEach-Object {
        Remove-Item -Path (Join-Path $taskPath $_.Name) -Force -Recurse
    }
}
