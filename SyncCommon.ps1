$Path = Split-Path -Parent $MyInvocation.MyCommand.Path
Get-ChildItem -Path $Path -Directory -Exclude Common | ForEach-Object {
    Copy-Item -Path (Join-Path $Path 'Common\*.*') -Destination $_ -Force -Recurse
}