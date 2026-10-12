param([switch]$Reference, [switch]$Native, [switch]$Software)
$ErrorActionPreference = "Stop"
$exe = Join-Path $PSScriptRoot "build/coolboard2001.exe"
if (!(Test-Path -LiteralPath $exe)) { throw "Compile o projeto com build.ps1 primeiro." }
 $taskConfig = if ($Software) { "game-software.toml" } else { "game.toml" }
$taskRenderer = if ($Software) { "software" } else { [regex]::Match([IO.File]::ReadAllText((Join-Path $PSScriptRoot "game.toml")), '(?m)^renderer\s*=\s*"(software|opengl)"').Groups[1].Value }
$taskBios = Join-Path $PSScriptRoot "psxrecomp/bios/SCPH1001.BIN"
if (!(Test-Path -LiteralPath $taskBios)) { $taskBios = Join-Path $PSScriptRoot "psxrecomp/bios/openbios.bin" }
$taskOldNative = $env:PSX_OVERLAY_NATIVE_OFF
$taskOldInput = $env:PSX_DEV_INPUT
$taskOldCinema = $env:COOLBOARDERS_CINEMA
try {
    $taskVideoText = [IO.File]::ReadAllText((Join-Path $PSScriptRoot $taskConfig))
    $env:COOLBOARDERS_CINEMA = if (!$Software -and $taskVideoText -match '(?m)^aspect_ratio\s*=\s*"16:9"') { "1" } else { "0" }
    # Keep keyboard controls available alongside the connected P1 gamepad.
    $env:PSX_DEV_INPUT = "1"
    if ($Native -and !$Reference) { $env:PSX_OVERLAY_NATIVE_OFF = "0" }
    else { $env:PSX_OVERLAY_NATIVE_OFF = "1" }
    & $exe --game "$PSScriptRoot/$taskConfig" --disc "$PSScriptRoot/disc/coolboarders2001.cue" --bios $taskBios --renderer $taskRenderer --no-launcher
} finally {
    $env:PSX_OVERLAY_NATIVE_OFF = $taskOldNative
    $env:PSX_DEV_INPUT = $taskOldInput
    $env:COOLBOARDERS_CINEMA = $taskOldCinema
}
