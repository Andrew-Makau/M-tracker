<#
  Flatten monorepo script

  Usage:
    # Dry run: show what would be done
    .\scripts\flatten_monorepo.ps1

    # Provide remote URL to add origin and push
    .\scripts\flatten_monorepo.ps1 -RemoteUrl "https://github.com/yourname/your-repo.git"

  The script will:
   - create `.git_backups` and move nested `.git` directories into it
   - remove any staged embedded repos from the index
   - add and commit the flattened tree
   - optionally add remote `origin` and push `main`
#>

param(
  [string]$RemoteUrl = ""
)

Set-StrictMode -Version Latest

function Write-Info($m) { Write-Host "[info] $m" -ForegroundColor Cyan }
function Write-Warn($m) { Write-Host "[warn] $m" -ForegroundColor Yellow }
function Write-Err($m)  { Write-Host "[error] $m" -ForegroundColor Red }

try {
  $scriptPath = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
  Set-Location $scriptPath
  Write-Info "Working directory: $(Get-Location)"

  $backupDir = Join-Path (Get-Location) '.git_backups'
  if (-not (Test-Path $backupDir)) {
    New-Item -Path $backupDir -ItemType Directory -Force | Out-Null
    Write-Info "Created backup dir: $backupDir"
  } else {
    Write-Info "Using existing backup dir: $backupDir"
  }

  $subfolders = @('budget_app_frontend','budget_app_backend')
  foreach ($sub in $subfolders) {
    $gitDir = Join-Path (Join-Path (Get-Location) $sub) '.git'
    if (Test-Path $gitDir) {
      $dest = Join-Path $backupDir ($sub + '_git')
      Write-Info "Backing up $gitDir -> $dest"
      Move-Item -Path $gitDir -Destination $dest -Force
    } else {
      Write-Info "No nested .git found for $sub"
    }
  }

  # If the nested folders were previously staged as embedded repos, remove them from index
  Write-Info "Removing any embedded repo entries from index (if present)"
  & git rm --cached -r budget_app_frontend budget_app_backend 2>$null

  Write-Info "Adding all files to index"
  & git add .

  Write-Info "Committing flattened repository"
  & git commit -m "Flatten project: make frontend and backend regular folders (nested .git backed up in .git_backups)" 2>$null
  if ($LASTEXITCODE -ne 0) {
    Write-Warn "git commit returned non-zero exit code. There may be nothing to commit or an error occurred."
  } else {
    Write-Info "Commit created successfully"
  }

  if ($RemoteUrl -ne '') {
    Write-Info "Configuring remote origin -> $RemoteUrl"
    $existing = & git remote get-url origin 2>$null
    if ($LASTEXITCODE -ne 0) {
      & git remote add origin $RemoteUrl
      Write-Info "Added remote origin"
    } else {
      & git remote set-url origin $RemoteUrl
      Write-Info "Updated remote origin URL"
    }

    Write-Info "Pushing to origin main (you may be prompted for auth)"
    & git push -u origin main
    if ($LASTEXITCODE -ne 0) {
      Write-Warn "Push failed — check remote URL and credentials."
    } else {
      Write-Info "Push completed"
    }
  } else {
    Write-Info "No remote URL provided. Skip adding remote and pushing."
  }

  Write-Info "Done. Backups are in .git_backups"
} catch {
  Write-Err "Unexpected error: $_"
  exit 1
}
