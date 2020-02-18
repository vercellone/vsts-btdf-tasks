Get-ChildItem -Path $PSScriptRoot -Directory -Exclude Common | ForEach-Object {
    Copy-Item -Path (Join-Path $PSScriptRoot 'Common\*') -Destination $_ -Force -Recurse
}
