#Requires -Version 5.1
<#
.SYNOPSIS
    Install recommended fonts for development
.DESCRIPTION
    Downloads and installs Nerd Fonts for terminal and editor use
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

$fonts = @(
    @{
        Name = "CaskaydiaCove Nerd Font"
        Url = "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/CascadiaCode.zip"
    },
    @{
        Name = "JetBrainsMono Nerd Font"
        Url = "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip"
    }
)

$tempDir = Join-Path $env:TEMP "font-install-$(Get-Random)"
$fontsDir = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"

New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
New-Item -ItemType Directory -Path $fontsDir -Force | Out-Null

foreach ($font in $fonts) {
    Write-Status "Downloading $($font.Name)..."
    
    $zipPath = Join-Path $tempDir "$($font.Name).zip"
    $extractPath = Join-Path $tempDir $font.Name
    
    try {
        Invoke-WebRequest -Uri $font.Url -OutFile $zipPath -UseBasicParsing
        Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force
        
        $fontFiles = Get-ChildItem -Path $extractPath -Filter "*.ttf" -Recurse
        
        foreach ($fontFile in $fontFiles) {
            $destPath = Join-Path $fontsDir $fontFile.Name
            
            if (-not (Test-Path $destPath)) {
                Copy-Item -Path $fontFile.FullName -Destination $destPath -Force
                Write-Status "Installed: $($fontFile.Name)" -Type Success
            }
        }
    }
    catch {
        Write-Status "Failed to install $($font.Name): $_" -Type Error
    }
}

Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue

Write-Status "Font installation complete!" -Type Success
Write-Status "Restart your terminal to use new fonts." -Type Info
