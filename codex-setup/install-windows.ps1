param(
  [string]$ProjectPath = "",
  [string]$ConversationUrl = "",
  [switch]$ForceConfig
)

$ErrorActionPreference = "Stop"

function Write-Step {
  param([string]$Message)
  Write-Host ""
  Write-Host "==> $Message" -ForegroundColor Cyan
}

function Ensure-Directory {
  param([string]$Path)
  if (-not (Test-Path -LiteralPath $Path)) {
    New-Item -ItemType Directory -Path $Path | Out-Null
  }
}

function Require-Command {
  param([string]$Name, [string]$Hint)
  if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
    throw "$Name was not found. $Hint"
  }
}

$ScriptPath = $MyInvocation.MyCommand.Path
$SetupDir = Split-Path -Parent $ScriptPath
$RepoRoot = Split-Path -Parent $SetupDir
$HomeDir = [Environment]::GetFolderPath("UserProfile")

Write-Step "Checking local tools"
Require-Command "git" "Install Git for Windows, then rerun this script."
Require-Command "node" "Install Node.js 24 or newer, then rerun this script."
Require-Command "npm" "Install Node.js 24 or newer, then rerun this script."

$nodeMajorText = (& node -p "process.versions.node.split('.')[0]").Trim()
$nodeMajor = [int]$nodeMajorText
if ($nodeMajor -lt 24) {
  throw "Node.js 24 or newer is required. Current major version: $nodeMajorText"
}

if (-not (Get-Command "pnpm" -ErrorAction SilentlyContinue)) {
  Write-Step "Enabling pnpm through Corepack"
  Require-Command "corepack" "Install Node.js with Corepack support, or install pnpm manually."
  & corepack enable
  & corepack prepare pnpm@10.33.2 --activate
}

Write-Step "Installing dependencies"
Push-Location $RepoRoot
try {
  & pnpm install
  if ($LASTEXITCODE -ne 0) { throw "pnpm install failed." }

  Write-Step "Building Oracle"
  & pnpm run build
  if ($LASTEXITCODE -ne 0) { throw "pnpm run build failed." }

  Write-Step "Linking the local modified oracle command"
  & npm link
  if ($LASTEXITCODE -ne 0) { throw "npm link failed." }
}
finally {
  Pop-Location
}

Write-Step "Installing the Codex oracle skill"
$CodexSkillsDir = Join-Path $HomeDir ".codex\skills"
$TargetSkillDir = Join-Path $CodexSkillsDir "oracle"
$SourceSkillDir = Join-Path $RepoRoot "skills\oracle"
Ensure-Directory $CodexSkillsDir
Ensure-Directory $TargetSkillDir
Get-ChildItem -LiteralPath $SourceSkillDir -Force | ForEach-Object {
  Copy-Item -LiteralPath $_.FullName -Destination $TargetSkillDir -Recurse -Force
}

Write-Step "Adding Oracle guidance to Codex AGENTS.md"
$CodexDir = Join-Path $HomeDir ".codex"
$AgentsPath = Join-Path $CodexDir "AGENTS.md"
$AppendPath = Join-Path $SetupDir "AGENTS.oracle-append.md"
Ensure-Directory $CodexDir
if (-not (Test-Path -LiteralPath $AgentsPath)) {
  "# Personal Codex Guidance`r`n" | Set-Content -LiteralPath $AgentsPath -Encoding UTF8
}
$agentsText = Get-Content -LiteralPath $AgentsPath -Raw -Encoding UTF8
if ($agentsText -notmatch "Oracle OSS GPT routing guardrail") {
  $appendText = Get-Content -LiteralPath $AppendPath -Raw -Encoding UTF8
  Add-Content -LiteralPath $AgentsPath -Value "`r`n$appendText" -Encoding UTF8
}

Write-Step "Writing Oracle global config"
$OracleDir = Join-Path $HomeDir ".oracle"
$OracleConfigPath = Join-Path $OracleDir "config.json"
Ensure-Directory $OracleDir
if ($ForceConfig -or -not (Test-Path -LiteralPath $OracleConfigPath)) {
  $manualProfile = (Join-Path $OracleDir "browser-profile").Replace("\", "\\")
  $config = @"
{
  // Default to the modified local Oracle browser workflow.
  // API runs should be explicit, not accidental.
  engine: "browser",
  model: "gpt-5.5-pro",
  filesReport: true,
  browser: {
    manualLogin: true,
    manualLoginProfileDir: "$manualProfile",
    modelStrategy: "select",
    archiveConversations: "never",
    attachmentTimeoutMs: 180000,
    inputTimeoutMs: 120000,
    timeoutMs: 480000
  }
}
"@
  Set-Content -LiteralPath $OracleConfigPath -Value $config -Encoding UTF8
}
else {
  Write-Host "Existing config kept: $OracleConfigPath"
}

if ($ProjectPath -and $ConversationUrl) {
  Write-Step "Writing project conversation config"
  $ResolvedProjectPath = (Resolve-Path -LiteralPath $ProjectPath).Path
  $ProjectOracleDir = Join-Path $ResolvedProjectPath ".oracle"
  Ensure-Directory $ProjectOracleDir
  $ProjectConfigPath = Join-Path $ProjectOracleDir "config.json"
  $projectConfig = @"
{
  browser: {
    conversationUrl: "$ConversationUrl"
  }
}
"@
  Set-Content -LiteralPath $ProjectConfigPath -Value $projectConfig -Encoding UTF8
}
elseif ($ProjectPath -or $ConversationUrl) {
  Write-Host "Project config skipped: pass both -ProjectPath and -ConversationUrl to create it." -ForegroundColor Yellow
}

Write-Step "Verifying oracle command"
& oracle --dry-run summary --files-report -p "setup smoke test; do not send" --file (Join-Path $RepoRoot "README.md") | Select-Object -First 12
if ($LASTEXITCODE -ne 0) { throw "oracle verification failed." }

Write-Host ""
Write-Host "Oracle Codex setup complete." -ForegroundColor Green
Write-Host "Next step: run an Oracle browser command once and sign into ChatGPT in the Oracle browser profile if prompted."
