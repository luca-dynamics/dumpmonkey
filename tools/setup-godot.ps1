$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$engineDirectory = Join-Path $projectRoot '.tools/godot'
$engineArchive = Join-Path $engineDirectory 'engine.zip'
$engineExecutable = Join-Path $engineDirectory 'Godot_v4.7.2-stable_win64_console.exe'
$filename = 'Godot_v4.7.2-stable_win64.exe.zip'
$releaseRoot = 'https://github.com/godotengine/godot/releases/download/4.7.2-stable'
New-Item -ItemType Directory -Force -Path $engineDirectory | Out-Null
if (-not (Test-Path -LiteralPath $engineArchive)) {
    Invoke-WebRequest "$releaseRoot/$filename" -OutFile $engineArchive
}
$checksums = (Invoke-WebRequest "$releaseRoot/SHA512-SUMS.txt").Content
if ($checksums -is [byte[]]) { $checksums = [Text.Encoding]::UTF8.GetString($checksums) }
$line = ($checksums -split "`n" | Where-Object { $_.TrimEnd().EndsWith($filename) } | Select-Object -First 1)
if (-not $line) { throw 'Official checksum entry not found.' }
$expected = ($line.Trim() -split '\s+')[0]
$actual = (Get-FileHash -LiteralPath $engineArchive -Algorithm SHA512).Hash
if ($actual -ne $expected) { throw 'Engine archive failed official SHA512 verification.' }
if (-not (Test-Path -LiteralPath $engineExecutable)) {
    Expand-Archive -LiteralPath $engineArchive -DestinationPath $engineDirectory
}
Push-Location $projectRoot
try {
    node tools/fetch-web-templates.mjs --install
    if ($LASTEXITCODE -ne 0) { throw 'Web template setup failed.' }
    & $engineExecutable --headless --path game --editor --import --quit
    if ($LASTEXITCODE -ne 0) { throw 'Godot import failed.' }
} finally {
    Pop-Location
}
Write-Host "Godot ready: $engineExecutable"
