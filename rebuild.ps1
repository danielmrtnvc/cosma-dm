# rebuild.ps1  —  run from the project root: .\rebuild.ps1
# Regenerates the Cosma cosmoscope and copies the latest output to export/index.html.

Set-Location $PSScriptRoot

# ── 1. Generate cosmoscope ─────────────────────────────────────────────────
Write-Host "Building cosmoscope..." -ForegroundColor Cyan
cosma modelize
if ($LASTEXITCODE -ne 0) {
    Write-Host "cosma modelize failed. Aborting." -ForegroundColor Red
    exit 1
}

# ── 2. Copy latest history file to export/index.html ──────────────────────
# cosma modelize writes to history/ but does NOT update export/index.html itself.
$latest = Get-ChildItem (Join-Path $PSScriptRoot "history\*.html") |
          Sort-Object LastWriteTime |
          Select-Object -Last 1

if (-not $latest) {
    Write-Host "No history file found. Aborting." -ForegroundColor Red
    exit 1
}

$dest = Join-Path $PSScriptRoot "export\index.html"
$utf8NoBom = New-Object System.Text.UTF8Encoding $False
$html = [System.IO.File]::ReadAllText($latest.FullName)
[System.IO.File]::WriteAllText($dest, $html, $utf8NoBom)

Write-Host "Copied $($latest.Name) -> export/index.html" -ForegroundColor Green
Write-Host "Done. Commit and push export/index.html to deploy." -ForegroundColor Green
