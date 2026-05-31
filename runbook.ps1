[Console]::InputEncoding  = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['*:Encoding'] = 'utf8'

# Current directory
$RUNBOOK_SOURCE = "${(Get-Location).Path}/.runbook"

# Home
if (-not (Test-Path -Path $RUNBOOK_SOURCE)) {
  $RUNBOOK_SOURCE = "$HOME/.runbook"
}

# Script base
if (-not (Test-Path -Path $RUNBOOK_SOURCE)) {
  $RUNBOOK_SOURCE = "$PSScriptRoot/.runbook"
}

if (-not (Test-Path -Path $RUNBOOK_SOURCE)) {
    Write-Warning ("No .runbooks directory exists! Checked: " + @((Get-Location).Path, $HOME, $PSScriptRoot) -join '; ')
    exit 1
}

$viewer = Join-Path -Path "$PSScriptRoot" -ChildPath "preview.ps1"

$chosen = Get-ChildItem "$RUNBOOK_SOURCE" -Recurse 
  | ForEach-Object {
        Resolve-Path -Relative $_.FullName
    } 
  | fzf --multi --preview "pwsh -NoProfile -Command $viewer '{}'" --preview-window=right,60% `
    --bind 'ctrl-j:preview-down,ctrl-k:preview-up' `
    --bind "ctrl-y:execute-silent(echo {+} | clip.exe)" `
    --bind 'ctrl-a:execute(pwsh -NoProfile -Command Get-Content -Raw {} | clip.exe)' `
    --bind 'f2:toggle-preview' `
    --bind='f3:execute(fx {})+abort' `
    --bind='f4:execute(code {})+abort'

if ($chosen) {
    & "$chosen"
}
