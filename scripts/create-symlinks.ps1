#Requires -Version 5.1
<#
.SYNOPSIS
    DEPRECATED - Use 'dot stow' instead
.DESCRIPTION
    This script has been deprecated. Use the main CLI instead:
    
    dot init     - Full setup (packages + symlinks)
    dot stow     - Create/update symlinks only
    dot doctor   - Check system health
    
    The main dot.ps1 provides a unified, idempotent interface
    and is the single source of truth for symlink management.
.NOTES
    Deprecated in favor of unified dot.ps1 CLI
#>

Write-Host ""
Write-Host "⚠️  DEPRECATED SCRIPT" -ForegroundColor Yellow
Write-Host ""
Write-Host "This script is deprecated. Use the main dotfiles CLI instead:" -ForegroundColor White
Write-Host ""
Write-Host "  dot init      - Full setup with packages and symlinks" -ForegroundColor Cyan
Write-Host "  dot stow      - Create or update symlinks" -ForegroundColor Cyan
Write-Host "  dot unstow    - Remove symlinks" -ForegroundColor Cyan
Write-Host "  dot doctor    - Check your setup" -ForegroundColor Cyan
Write-Host ""
Write-Host "Make sure Developer Mode is enabled before running:" -ForegroundColor Yellow
Write-Host "  Settings > Privacy & Security > For Developers > Developer Mode" -ForegroundColor DarkGray
Write-Host ""
exit 0
$source = "$env:USERPROFILE\.dotfiles\home"
$home = $env:USERPROFILE

Write-Host ""
Write-Host "Creating Dotfiles Symlinks" -ForegroundColor Cyan
Write-Host "==========================" -ForegroundColor Cyan
Write-Host ""

# Test symlink capability first
$testTarget = "$env:USERPROFILE\.dotfiles\symlink-test-delete-me"
try {
    New-Item -ItemType SymbolicLink -Path $testTarget -Target "$env:USERPROFILE\.dotfiles\README.md" -Force -ErrorAction Stop | Out-Null
    Remove-Item $testTarget -Force
    Write-Host "✓ Symlink capability confirmed" -ForegroundColor Green
} catch {
    Write-Host "✗ Symlink creation failed: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Possible fixes:" -ForegroundColor Yellow
    Write-Host "  1. Make sure Developer Mode is ON (Settings > Privacy & Security > For Developers)"
    Write-Host "  2. Close ALL terminal windows and open a NEW one"
    Write-Host "  3. Run this script in the NEW terminal"
    Write-Host ""
    exit 1
}

Write-Host ""

# Define all symlinks to create
$symlinks = @(
    @{ Source = "$source\.claude\CLAUDE.md"; Target = "$home\.claude\CLAUDE.md" }
    @{ Source = "$source\.claude\settings.json"; Target = "$home\.claude\settings.json" }
    @{ Source = "$source\.claude\commands"; Target = "$home\.claude\commands" }
    @{ Source = "$source\.claude\skills"; Target = "$home\.claude\skills" }
    @{ Source = "$source\.config\git\config"; Target = "$home\.gitconfig" }
    @{ Source = "$source\.config\git\ignore"; Target = "$home\.config\git\ignore" }
    @{ Source = "$source\.config\powershell\Microsoft.PowerShell_profile.ps1"; Target = "$home\Documents\PowerShell\Microsoft.PowerShell_profile.ps1" }
)

$success = 0
$failed = 0

foreach ($link in $symlinks) {
    # Ensure parent directory exists
    $parentDir = Split-Path $link.Target -Parent
    if (-not (Test-Path $parentDir)) {
        New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
    }
    
    # Remove existing file/directory (backup first if not a symlink)
    if (Test-Path $link.Target) {
        $existing = Get-Item $link.Target -Force
        if ($existing.LinkType -ne "SymbolicLink") {
            # Backup non-symlink files
            $backupPath = "$($link.Target).backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
            Move-Item $link.Target $backupPath -Force
            Write-Host "  Backed up: $($link.Target)" -ForegroundColor DarkGray
        } else {
            Remove-Item $link.Target -Force -Recurse
        }
    }
    
    # Create symlink
    try {
        # Check if source is directory or file
        $sourceItem = Get-Item $link.Source -Force
        if ($sourceItem.PSIsContainer) {
            New-Item -ItemType SymbolicLink -Path $link.Target -Target $link.Source -Force | Out-Null
        } else {
            New-Item -ItemType SymbolicLink -Path $link.Target -Target $link.Source -Force | Out-Null
        }
        
        # Verify
        $created = Get-Item $link.Target -Force
        if ($created.LinkType -eq "SymbolicLink") {
            $relativePath = $link.Target.Replace($home, "~")
            Write-Host "✓ $relativePath" -ForegroundColor Green
            $success++
        } else {
            Write-Host "✗ $($link.Target) (not a symlink)" -ForegroundColor Red
            $failed++
        }
    } catch {
        Write-Host "✗ $($link.Target): $_" -ForegroundColor Red
        $failed++
    }
}

Write-Host ""
Write-Host "────────────────────────────" -ForegroundColor DarkGray
Write-Host "Success: $success  Failed: $failed" -ForegroundColor $(if ($failed -eq 0) { 'Green' } else { 'Yellow' })
Write-Host ""

if ($failed -eq 0) {
    Write-Host "All symlinks created successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Now when you edit files in ~/.dotfiles/home/, the changes" -ForegroundColor White
    Write-Host "appear immediately in the active locations. One source of truth." -ForegroundColor White
} else {
    Write-Host "Some symlinks failed. Check errors above." -ForegroundColor Yellow
}

Write-Host ""
