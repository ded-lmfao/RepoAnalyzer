[CmdletBinding()]
param(
    [ValidateSet('Workspace', 'Global')]
    [string]$Scope = 'Workspace',
    [string]$TargetPath = (Get-Location).Path
)

$repositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$skillSource = Join-Path $repositoryRoot 'plugins\repo-analyze\skills\repo-analyze'

if ($Scope -eq 'Global') {
    $skillDestination = Join-Path $HOME '.gemini\config\skills\repo-analyze'
} else {
    $skillDestination = Join-Path (Resolve-Path $TargetPath).Path '.agents\skills\repo-analyze'
}

if (-not (Test-Path (Join-Path $skillSource 'SKILL.md'))) {
    throw "Analyzer skill not found: $skillSource"
}

New-Item -ItemType Directory -Force -Path (Split-Path $skillDestination) | Out-Null
Copy-Item -Path $skillSource -Destination $skillDestination -Recurse -Force
Write-Output "Installed repo-analyze skill to $skillDestination"