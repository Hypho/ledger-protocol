param(
  [Parameter(Mandatory = $true)]
  [string]$Target,

  [ValidateSet("auto", "all", "claude")]
  [string]$Mode = "auto",

  [switch]$Force
)

$ErrorActionPreference = "Stop"

$Root = Resolve-Path (Join-Path $PSScriptRoot "..")
$TargetPath = New-Item -ItemType Directory -Force -Path $Target
$TargetFullPath = (Resolve-Path $TargetPath.FullName).Path

function Get-LedgerInstallMode {
  $hasClaude = (Test-Path (Join-Path $TargetFullPath ".claude")) -or (Test-Path (Join-Path $TargetFullPath "CLAUDE.md"))

  if ($hasClaude) { return "claude" }
  return "all"
}

$RequestedMode = $Mode
if ($Mode -eq "auto") {
  $Mode = Get-LedgerInstallMode
}

function Copy-LedgerItem {
  param(
    [string]$Source,
    [string]$Destination
  )

  $sourcePath = Join-Path $Root $Source
  $destinationPath = Join-Path $TargetFullPath $Destination

  if (-not (Test-Path $sourcePath)) {
    throw "Missing source: $Source"
  }

  if ((Test-Path $destinationPath) -and (-not $Force)) {
    throw "Refusing to overwrite existing path: $Destination. Use -Force to overwrite."
  }

  if (Test-Path $destinationPath) {
    Remove-Item -Recurse -Force -LiteralPath $destinationPath
  }

  $parent = Split-Path -Parent $destinationPath
  if ($parent -and (-not (Test-Path $parent))) {
    New-Item -ItemType Directory -Force -Path $parent | Out-Null
  }

  Copy-Item -Recurse -Force -LiteralPath $sourcePath -Destination $destinationPath
}

switch ($Mode) {
  "all" {
    Copy-LedgerItem "CLAUDE.md" "CLAUDE.md"
    Copy-LedgerItem ".claude" ".claude"
    Copy-LedgerItem ".claude-plugin" ".claude-plugin"
    Copy-LedgerItem ".ledger" ".ledger"
    Copy-LedgerItem "skills" "skills"
    Copy-LedgerItem "hooks" "hooks"
  }
  "claude" {
    Copy-LedgerItem "CLAUDE.md" "CLAUDE.md"
    Copy-LedgerItem ".claude" ".claude"
    Copy-LedgerItem ".claude-plugin" ".claude-plugin"
    Copy-LedgerItem ".ledger" ".ledger"
    Copy-LedgerItem "skills" "skills"
    Copy-LedgerItem "hooks" "hooks"
  }
}

Write-Host "Ledger installed."
Write-Host ""
Write-Host "Target: $TargetFullPath"
Write-Host "Mode:   $Mode"
if ($RequestedMode -eq "auto") {
  Write-Host "Auto:   selected from existing project files"
}
Write-Host ""
Write-Host "Next:"
Write-Host "- Claude Code: run /ledger.init, then /ledger.scope before the first feature."
Write-Host "- Self-check:"
Write-Host "    cd `"$TargetFullPath`""
Write-Host "    bash .ledger/bin/ledger.sh check --project"
Write-Host ""
Write-Host "Windows note:"
Write-Host "- Run the bash check after cd into the project directory."
Write-Host "- Do not pass a C:\...\.ledger\bin\ledger.sh path directly to bash."
