param([switch]$Generate, [string]$Python = "python")
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot
$env:CMAKE_BUILD_PARALLEL_LEVEL = "2"
& $Python tools/apply_runtime_patches.py
if ($LASTEXITCODE) { throw "Runtime patch application failed" }
if ($Generate) {
    & $Python tools/normalize_exe.py
    if ($LASTEXITCODE) { throw "EXE normalization failed" }
    & $Python psxrecomp/psxrecomp_cli.py generate --project-root $PSScriptRoot --config game.toml --no-toolchain-download
    if ($LASTEXITCODE) { throw "Code generation failed" }
}
& $Python psxrecomp/psxrecomp_cli.py rebuild --project-root $PSScriptRoot --config game.toml --build-dir build --no-toolchain-download --no-pgo --cmake-extra=-DPSX_REWIND=OFF
if ($LASTEXITCODE) { throw "Native build failed" }
& $Python tools/stage_runtime_config.py
if ($LASTEXITCODE) { throw "Runtime config staging failed" }
