param([switch]$Reference, [switch]$Native)
$ErrorActionPreference = "Stop"
$exe = Join-Path $PSScriptRoot "build/Cool_Boarders_2001_Recompiled.exe"
if (!(Test-Path -LiteralPath $exe)) { throw "Compile o projeto com build.ps1 primeiro." }
$taskOldNative = $env:PSX_OVERLAY_NATIVE_OFF
try {
    if ($Native -and !$Reference) { $env:PSX_OVERLAY_NATIVE_OFF = "0" }
    else { $env:PSX_OVERLAY_NATIVE_OFF = "1" }
    & $exe --game "$PSScriptRoot/game.toml" --disc "$PSScriptRoot/disc/coolboarders2001.cue" --bios "$PSScriptRoot/psxrecomp/bios/openbios.bin" --renderer software --no-launcher
} finally {
    $env:PSX_OVERLAY_NATIVE_OFF = $taskOldNative
}
