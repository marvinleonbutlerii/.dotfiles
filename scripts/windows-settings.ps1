#Requires -Version 5.1
#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Configure Windows settings for development
.DESCRIPTION
    Sets developer-friendly Windows defaults:
    - Enables Developer Mode
    - Shows file extensions
    - Shows hidden files
    - Configures Explorer settings
.NOTES
    Requires Administrator privileges
#>

[CmdletBinding()]
param(
    [switch]$NoRestart
)

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
Write-Host "Windows Developer Settings" -ForegroundColor Cyan
Write-Host "==========================" -ForegroundColor Cyan
Write-Host ""

# Enable Developer Mode (for symlinks without admin)
Write-Status "Enabling Developer Mode..."
try {
    $devModeKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
    if (-not (Test-Path $devModeKey)) {
        New-Item -Path $devModeKey -Force | Out-Null
    }
    Set-ItemProperty -Path $devModeKey -Name "AllowDevelopmentWithoutDevLicense" -Value 1 -Type DWord
    Set-ItemProperty -Path $devModeKey -Name "AllowAllTrustedApps" -Value 1 -Type DWord
    Write-Status "Developer Mode enabled" -Type Success
}
catch {
    Write-Status "Failed to enable Developer Mode: $_" -Type Error
}

# Explorer Settings
$explorerKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"

# Show file extensions
Write-Status "Showing file extensions..."
Set-ItemProperty -Path $explorerKey -Name "HideFileExt" -Value 0 -Type DWord
Write-Status "File extensions visible" -Type Success

# Show hidden files
Write-Status "Showing hidden files..."
Set-ItemProperty -Path $explorerKey -Name "Hidden" -Value 1 -Type DWord
Write-Status "Hidden files visible" -Type Success

# Show protected system files (careful with this one)
# Set-ItemProperty -Path $explorerKey -Name "ShowSuperHidden" -Value 1 -Type DWord

# Launch Explorer windows in separate process
Write-Status "Configuring Explorer stability..."
Set-ItemProperty -Path $explorerKey -Name "SeparateProcess" -Value 1 -Type DWord
Write-Status "Explorer windows in separate processes" -Type Success

# Disable Bing search in Start Menu
Write-Status "Disabling Bing search in Start Menu..."
$searchKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"
if (-not (Test-Path $searchKey)) {
    New-Item -Path $searchKey -Force | Out-Null
}
Set-ItemProperty -Path $searchKey -Name "BingSearchEnabled" -Value 0 -Type DWord
Write-Status "Bing search disabled" -Type Success

# Disable web search in Start Menu
Set-ItemProperty -Path $searchKey -Name "CortanaConsent" -Value 0 -Type DWord

# Privacy: Disable advertising ID
Write-Status "Disabling advertising ID..."
$privacyKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
if (-not (Test-Path $privacyKey)) {
    New-Item -Path $privacyKey -Force | Out-Null
}
Set-ItemProperty -Path $privacyKey -Name "Enabled" -Value 0 -Type DWord
Write-Status "Advertising ID disabled" -Type Success

# Set dark mode
Write-Status "Enabling dark mode..."
$personalizationKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
Set-ItemProperty -Path $personalizationKey -Name "AppsUseLightTheme" -Value 0 -Type DWord
Set-ItemProperty -Path $personalizationKey -Name "SystemUsesLightTheme" -Value 0 -Type DWord
Write-Status "Dark mode enabled" -Type Success

# Remove long path limitation
Write-Status "Enabling long paths..."
try {
    $longPathKey = "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem"
    Set-ItemProperty -Path $longPathKey -Name "LongPathsEnabled" -Value 1 -Type DWord
    Write-Status "Long paths enabled" -Type Success
}
catch {
    Write-Status "Failed to enable long paths: $_" -Type Warning
}

# Disable Windows tips and suggestions
Write-Status "Disabling Windows tips..."
$tipsKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
Set-ItemProperty -Path $tipsKey -Name "SubscribedContent-338389Enabled" -Value 0 -Type DWord
Set-ItemProperty -Path $tipsKey -Name "SubscribedContent-310093Enabled" -Value 0 -Type DWord
Set-ItemProperty -Path $tipsKey -Name "SubscribedContent-338388Enabled" -Value 0 -Type DWord
Write-Status "Tips disabled" -Type Success

Write-Host ""
Write-Host "╔══════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║     Settings configured successfully!    ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

if (-not $NoRestart) {
    Write-Status "Some changes require Explorer restart." -Type Info
    $restart = Read-Host "Restart Explorer now? (y/n)"
    if ($restart -eq 'y') {
        Stop-Process -Name explorer -Force
        Start-Process explorer
        Write-Status "Explorer restarted" -Type Success
    }
}
