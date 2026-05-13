param(
  [string]$Target = ".",

  [ValidateSet("auto", "all", "claude")]
  [string]$Mode = "auto",

  [string]$Ref = "main",

  [switch]$Force
)

$ErrorActionPreference = "Stop"

$repo = if ($env:LEDGER_REPO) { $env:LEDGER_REPO } else { "Hypho/ledger-protocol" }
$archiveKind = if ($Ref.StartsWith("v")) { "tags" } else { "heads" }
$archiveUrl = "https://github.com/$repo/archive/refs/$archiveKind/$Ref.zip"

$tmpRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("ledger-" + [System.Guid]::NewGuid().ToString("N"))
$zipPath = Join-Path $tmpRoot "ledger.zip"

New-Item -ItemType Directory -Force -Path $tmpRoot | Out-Null

try {
  Write-Host "Downloading Ledger from $repo@$Ref..."
  Invoke-WebRequest -UseBasicParsing -Uri $archiveUrl -OutFile $zipPath
  Expand-Archive -LiteralPath $zipPath -DestinationPath $tmpRoot -Force

  $sourceDir = Get-ChildItem -LiteralPath $tmpRoot -Directory | Select-Object -First 1
  if (-not $sourceDir) {
    throw "Failed to extract Ledger archive."
  }

  $installer = Join-Path $sourceDir.FullName "scripts\install-ledger.ps1"
  $args = @{
    Target = $Target
    Mode = $Mode
  }
  if ($Force) {
    $args.Force = $true
  }

  & $installer @args
}
finally {
  Remove-Item -Recurse -Force -LiteralPath $tmpRoot -ErrorAction SilentlyContinue
}
