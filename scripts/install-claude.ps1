#Requires -Version 5.1
<#
.SYNOPSIS
    Install and configure Claude Code
.DESCRIPTION
    Installs Claude Code and sets up initial configuration
#>

[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

function Write-Status {
    param([string]$Message, [string]$Type = 'Info')
    $prefix = switch ($Type) {
        'Success' { "✓"; $color = 'Green' }
        'Warning' { "⚠"; $color = 'Yellow' }
        'Error'   { "✗"; $color = 'Red' }
        default   { "→"; $color = 'Cyan' }
    }
    Write-Host "$prefix $Message" -ForegroundColor $color
}

Write-Host ""
Write-Host "Claude Code Setup" -ForegroundColor Cyan
Write-Host "=================" -ForegroundColor Cyan
Write-Host ""

# Check if already installed
$claude = Get-Command claude -ErrorAction SilentlyContinue

if ($claude) {
    Write-Status "Claude Code is already installed" -Type Success
}
else {
    Write-Status "Installing Claude Code..."
    
    try {
        # Use the official installer
        Invoke-RestMethod -Uri "https://claude.ai/install.ps1" | Invoke-Expression
        Write-Status "Claude Code installed" -Type Success
    }
    catch {
        Write-Status "Automated install failed. Trying alternative method..." -Type Warning
        
        # Try winget
        $winget = Get-Command winget -ErrorAction SilentlyContinue
        if ($winget) {
            winget install Anthropic.ClaudeCode --silent --accept-package-agreements
            Write-Status "Installed via winget" -Type Success
        }
        else {
            Write-Status "Please install manually from: https://claude.ai/download" -Type Error
            exit 1
        }
    }
}

# Verify installation
$claude = Get-Command claude -ErrorAction SilentlyContinue
if (-not $claude) {
    Write-Status "Claude not found in PATH. You may need to restart your terminal." -Type Warning
    exit 0
}

Write-Status "Claude Code installation verified" -Type Success

Write-Host ""
Write-Host "╔══════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║      Claude Code setup complete!         ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Status "Run 'claude' in any project directory to start" -Type Info
Write-Status "Run 'claude /init' to create a CLAUDE.md file" -Type Info
