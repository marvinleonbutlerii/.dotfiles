#!/usr/bin/env pwsh
#Requires -Version 5.1
<#
.SYNOPSIS
    Dotfiles management CLI for Windows
.DESCRIPTION
    A comprehensive dotfiles management system inspired by dmmulroy/.dotfiles
    Adapted for Windows with PowerShell, winget, and chezmoi
.NOTES
    Author: Generated for iusem
    Philosophy: This codebase will outlive you. Every shortcut becomes someone else's burden.
#>

[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [ValidateSet(
        'init', 'update', 'doctor', 'edit', 'stow', 'unstow',
        'backup', 'restore', 'summary', 'help',
        'package', 'check-packages', 'retry-failed', 'gen-ssh-key',
        'link', 'unlink', 'benchmark-shell', 'completions',
        'settings', 'fonts', 'claude'
    )]
    [string]$Command = 'help',

    [Alias('skip-ssh')]
    [switch]$SkipSsh,
    [Alias('skip-font')]
    [switch]$SkipFont,
    [switch]$Version,
    [Alias('h')]
    [switch]$Help,

    [Parameter(Position = 1, ValueFromRemainingArguments)]
    [string[]]$Arguments
)

# ============================================================================
# CONFIGURATION
# ============================================================================

$Script:DotfilesRoot = $PSScriptRoot
$Script:HomeDir = $env:USERPROFILE
$Script:ConfigDir = Join-Path $HomeDir ".config"
$Script:ClaudeDir = Join-Path $HomeDir ".claude"
$Script:BackupDir = Join-Path $DotfilesRoot "backups"
$Script:PackagesDir = Join-Path $DotfilesRoot "packages"
$Script:HomeSource = Join-Path $DotfilesRoot "home"
$Script:CliVersion = "1.0.0"

# Colors for output
$Script:Colors = @{
    Success = 'Green'
    Warning = 'Yellow'
    Error   = 'Red'
    Info    = 'Cyan'
    Muted   = 'DarkGray'
}

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

function Write-Status {
    param(
        [string]$Message,
        [ValidateSet('Success', 'Warning', 'Error', 'Info', 'Muted')]
        [string]$Type = 'Info',
        [switch]$NoNewline
    )
    $prefix = switch ($Type) {
        'Success' { "✓" }
        'Warning' { "⚠" }
        'Error'   { "✗" }
        'Info'    { "→" }
        'Muted'   { " " }
    }
    $color = $Colors[$Type]
    if ($NoNewline) {
        Write-Host "$prefix $Message" -ForegroundColor $color -NoNewline
    } else {
        Write-Host "$prefix $Message" -ForegroundColor $color
    }
}

function Test-Administrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-RelativePath {
    param([string]$Path, [string]$BasePath)
    return $Path.Replace($BasePath, '').TrimStart('\', '/')
}

function Invoke-SafeCommand {
    param(
        [scriptblock]$ScriptBlock,
        [string]$ErrorMessage = "Command failed"
    )
    try {
        & $ScriptBlock
        return $true
    } catch {
        Write-Status "$ErrorMessage`: $_" -Type Error
        return $false
    }
}

function Get-WingetCommand {
    $winget = Get-Command winget -ErrorAction SilentlyContinue
    if (-not $winget) {
        $wingetPath = Join-Path $env:LOCALAPPDATA "Microsoft\WindowsApps\winget.exe"
        if (Test-Path $wingetPath) {
            $winget = $wingetPath
        }
    }
    return $winget
}

# ============================================================================
# SYMLINK MANAGEMENT (GNU Stow equivalent)
# ============================================================================

function Install-Symlinks {
    [CmdletBinding()]
    param([switch]$Force)
    
    Write-Status "Creating symlinks from dotfiles to home directory..." -Type Info
    
    $sourceHome = $Script:HomeSource
    if (-not (Test-Path $sourceHome)) {
        Write-Status "Source home directory not found: $sourceHome" -Type Error
        return $false
    }
    
    $files = Get-ChildItem -Path $sourceHome -Recurse -File
    $created = 0
    $skipped = 0
    $failed = 0
    
    foreach ($file in $files) {
        $relativePath = Get-RelativePath -Path $file.FullName -BasePath $sourceHome
        $targetPath = Join-Path $HomeDir $relativePath
        $targetDir = Split-Path $targetPath -Parent
        
        # Create target directory if needed
        if (-not (Test-Path $targetDir)) {
            New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
        }
        
        # Check if target exists
        if (Test-Path $targetPath) {
            $existing = Get-Item $targetPath -Force
            if ($existing.LinkType -eq 'SymbolicLink') {
                $currentTarget = $existing.Target
                if ($currentTarget -eq $file.FullName) {
                    $skipped++
                    continue
                }
            }

            # Plain file with identical content — safe to replace with symlink
            if (-not $existing.LinkType) {
                $sourceHash = (Get-FileHash $file.FullName).Hash
                $targetHash = (Get-FileHash $targetPath).Hash
                if ($sourceHash -eq $targetHash) {
                    Remove-Item $targetPath -Force
                    Write-Status "Replacing identical copy with symlink: $relativePath" -Type Info
                } elseif ($Force) {
                    Remove-Item $targetPath -Force
                } else {
                    Write-Status "Conflict (different content): $relativePath" -Type Warning
                    $skipped++
                    continue
                }
            } elseif ($Force) {
                Remove-Item $targetPath -Force
            } else {
                Write-Status "Skipping (exists): $relativePath" -Type Warning
                $skipped++
                continue
            }
        }
        
        # Create symlink
        try {
            New-Item -ItemType SymbolicLink -Path $targetPath -Target $file.FullName -Force | Out-Null
            Write-Status "Linked: $relativePath" -Type Success
            $created++
        } catch {
            Write-Status "Failed to link: $relativePath - $_" -Type Error
            $failed++
        }
    }
    
    # Clean up orphan symlinks (point into dotfiles source but target no longer exists)
    $orphans = 0
    $managedDirs = Get-ChildItem -Path $sourceHome -Directory -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
        Join-Path $HomeDir (Get-RelativePath -Path $_.FullName -BasePath $sourceHome)
    }
    # Include the root home mapping too
    $managedDirs = @($HomeDir) + @($managedDirs)

    foreach ($dir in $managedDirs) {
        if (-not (Test-Path $dir)) { continue }
        Get-ChildItem -Path $dir -File -Force -ErrorAction SilentlyContinue | Where-Object {
            $_.LinkType -eq 'SymbolicLink' -and $_.Target -like "$sourceHome*" -and -not (Test-Path $_.Target)
        } | ForEach-Object {
            $relativePath = Get-RelativePath -Path $_.FullName -BasePath $HomeDir
            Remove-Item $_.FullName -Force
            Write-Status "Removed orphan: $relativePath" -Type Warning
            $orphans++
        }
    }

    Write-Host ""
    $summary = "Symlinks: $created created, $skipped skipped, $failed failed"
    if ($orphans -gt 0) { $summary += ", $orphans orphans removed" }
    Write-Status $summary -Type Info
    return ($failed -eq 0)
}

function Remove-Symlinks {
    [CmdletBinding()]
    param()
    
    Write-Status "Removing symlinks managed by dotfiles..." -Type Info
    
    $sourceHome = $Script:HomeSource
    $files = Get-ChildItem -Path $sourceHome -Recurse -File -ErrorAction SilentlyContinue
    $removed = 0
    
    foreach ($file in $files) {
        $relativePath = Get-RelativePath -Path $file.FullName -BasePath $sourceHome
        $targetPath = Join-Path $HomeDir $relativePath
        
        if (Test-Path $targetPath) {
            $item = Get-Item $targetPath -Force
            if ($item.LinkType -eq 'SymbolicLink' -and $item.Target -eq $file.FullName) {
                Remove-Item $targetPath -Force
                Write-Status "Removed: $relativePath" -Type Success
                $removed++
            }
        }
    }
    
    Write-Status "Removed $removed symlinks" -Type Info
}

# ============================================================================
# PACKAGE MANAGEMENT
# ============================================================================

function Get-PackageManifest {
    param([ValidateSet('base', 'work')][string]$Type = 'base')

    $manifestPath = switch ($Type) {
        'base' { Join-Path $PackagesDir "packages.json" }
        'work' { Join-Path $PackagesDir "packages.work.json" }
    }

    if (Test-Path $manifestPath) {
        return Get-Content $manifestPath -Raw | ConvertFrom-Json
    }
    return $null
}

function Save-PackageManifest {
    param(
        [Parameter(Mandatory = $true)][pscustomobject]$Manifest,
        [ValidateSet('base', 'work')][string]$Type = 'base'
    )

    $manifestPath = switch ($Type) {
        'base' { Join-Path $PackagesDir "packages.json" }
        'work' { Join-Path $PackagesDir "packages.work.json" }
    }

    $Manifest.updated = Get-Date -Format 'yyyy-MM-dd'
    $json = $Manifest | ConvertTo-Json -Depth 10
    Set-Content -LiteralPath $manifestPath -Value $json -Encoding UTF8
}

function Normalize-PackageList {
    param([string[]]$Packages)

    $clean = @()
    foreach ($pkg in $Packages) {
        if ([string]::IsNullOrWhiteSpace($pkg)) { continue }
        $clean += $pkg.Trim()
    }
    return @($clean | Sort-Object -Unique)
}

function Install-Packages {
    [CmdletBinding()]
    param(
        [ValidateSet('base', 'work', 'all')]
        [string]$Type = 'base',
        [switch]$SkipFailed
    )

    Write-Status "Installing packages ($Type)..." -Type Info

    $winget = Get-WingetCommand
    if (-not $winget) {
        Write-Status "winget not found. Install App Installer from Microsoft Store." -Type Error
        return $false
    }

    $skipList = @()
    if ($SkipFailed) {
        $latestFailed = Get-ChildItem $PackagesDir -Filter "failed_packages_*.txt" -ErrorAction SilentlyContinue |
            Sort-Object LastWriteTime -Descending |
            Select-Object -First 1
        if ($latestFailed) {
            $skipList = Get-Content $latestFailed.FullName | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
        }
    }

    $manifests = @()
    if ($Type -eq 'all' -or $Type -eq 'base') {
        $manifests += @{ Name = 'base'; Manifest = Get-PackageManifest -Type 'base' }
    }
    if ($Type -eq 'all' -or $Type -eq 'work') {
        $manifests += @{ Name = 'work'; Manifest = Get-PackageManifest -Type 'work' }
    }

    $failed = @()

    foreach ($entry in $manifests) {
        $manifest = $entry.Manifest
        if ($null -eq $manifest) { continue }

        if ($manifest.PSObject.Properties.Name -contains 'winget') {
            foreach ($pkg in $manifest.winget) {
                if ($SkipFailed -and $skipList -contains $pkg) {
                    Write-Status "Skipping failed package: $pkg" -Type Muted
                    continue
                }
                Write-Status "Installing: $pkg" -Type Info
                & $winget install --id $pkg --silent --accept-package-agreements --accept-source-agreements 2>&1 | Out-Null
                if ($LASTEXITCODE -ne 0) {
                    Write-Status "Failed: $pkg" -Type Warning
                    $failed += $pkg
                } else {
                    Write-Status "Installed: $pkg" -Type Success
                }
            }
        }

        if ($manifest.PSObject.Properties.Name -contains 'scoop' -and $manifest.scoop.Count -gt 0) {
            $scoop = Get-Command scoop -ErrorAction SilentlyContinue
            if (-not $scoop) {
                Write-Status "scoop not found. Skipping scoop packages for $($entry.Name)." -Type Warning
                continue
            }
            foreach ($pkg in $manifest.scoop) {
                Write-Status "Installing (scoop): $pkg" -Type Info
                & $scoop install $pkg 2>&1 | Out-Null
                if ($LASTEXITCODE -ne 0) {
                    Write-Status "Failed (scoop): $pkg" -Type Warning
                    $failed += $pkg
                } else {
                    Write-Status "Installed (scoop): $pkg" -Type Success
                }
            }
        }
    }

    if ($failed.Count -gt 0) {
        $failedPath = Join-Path $PackagesDir "failed_packages_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
        $failed | Out-File $failedPath
        Write-Status "Failed packages logged to: $failedPath" -Type Warning
    }

    return ($failed.Count -eq 0)
}

function Update-Packages {
    [CmdletBinding()]
    param(
        [string]$Name = 'all',
        [ValidateSet('base', 'work', 'all')]
        [string]$Bundle = 'all'
    )

    $winget = Get-WingetCommand
    if (-not $winget) {
        Write-Status "winget not found. Install App Installer from Microsoft Store." -Type Error
        return $false
    }

    if ([string]::IsNullOrWhiteSpace($Name) -or $Name -eq 'all') {
        if ($Bundle -eq 'all') {
            Write-Status "Updating all packages..." -Type Info
            & $winget upgrade --all --silent --accept-package-agreements --accept-source-agreements 2>&1 | Out-Null
            return ($LASTEXITCODE -eq 0)
        }

        $manifest = Get-PackageManifest -Type $Bundle
        if ($null -eq $manifest -or -not $manifest.winget) {
            Write-Status "No packages found for bundle: $Bundle" -Type Warning
            return $false
        }

        foreach ($pkg in $manifest.winget) {
            Write-Status "Updating: $pkg" -Type Info
            & $winget upgrade --id $pkg --silent --accept-package-agreements --accept-source-agreements 2>&1 | Out-Null
        }
        return $true
    }

    Write-Status "Updating package: $Name" -Type Info
    & $winget upgrade --id $Name --silent --accept-package-agreements --accept-source-agreements 2>&1 | Out-Null
    return ($LASTEXITCODE -eq 0)
}

function Get-InstalledPackages {
    [CmdletBinding()]
    param(
        [ValidateSet('base', 'work', 'all')]
        [string]$Type = 'base'
    )

    Write-Status "Checking installed packages..." -Type Info

    $winget = Get-WingetCommand
    if (-not $winget) {
        Write-Status "winget not found. Install App Installer from Microsoft Store." -Type Error
        return
    }

    $installed = & $winget list --disable-interactivity 2>$null | Out-String

    $bundles = @()
    if ($Type -eq 'all' -or $Type -eq 'base') {
        $bundles += @{ Name = 'Base'; Manifest = Get-PackageManifest -Type 'base'; File = 'packages.json' }
    }
    if ($Type -eq 'all' -or $Type -eq 'work') {
        $bundles += @{ Name = 'Work'; Manifest = Get-PackageManifest -Type 'work'; File = 'packages.work.json' }
    }

    foreach ($bundle in $bundles) {
        $manifest = $bundle.Manifest
        if ($null -eq $manifest) {
            Write-Status "No package manifest found for $($bundle.Name)" -Type Warning
            continue
        }

        Write-Host ""
        Write-Host "$($bundle.Name) packages ($($bundle.File)):" -ForegroundColor Cyan
        Write-Host ("=" * (14 + $bundle.Name.Length + $bundle.File.Length)) -ForegroundColor Cyan

        foreach ($pkg in $manifest.winget) {
            $isInstalled = $installed -match [regex]::Escape($pkg)
            if ($isInstalled) {
                Write-Status "$pkg" -Type Success
            } else {
                Write-Status "$pkg (not installed)" -Type Warning
            }
        }
    }
}

function Add-Package {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [ValidateSet('winget', 'scoop')]
        [string]$Type = 'winget',
        [ValidateSet('base', 'work')]
        [string]$Bundle = 'base'
    )

    $manifest = Get-PackageManifest -Type $Bundle
    if ($null -eq $manifest) {
        Write-Status "Package manifest not found for bundle: $Bundle" -Type Error
        return $false
    }

    if ($Type -eq 'winget') {
        $current = @()
        if ($manifest.PSObject.Properties.Name -contains 'winget') {
            $current = @($manifest.winget)
        }
        if ($current -contains $Name) {
            Write-Status "Package already exists in ${Bundle}: $Name" -Type Warning
            return $true
        }
        $manifest.winget = Normalize-PackageList -Packages ($current + $Name)
    } else {
        $current = @()
        if ($manifest.PSObject.Properties.Name -contains 'scoop') {
            $current = @($manifest.scoop)
        } else {
            $manifest | Add-Member -NotePropertyName "scoop" -NotePropertyValue @()
        }
        if ($current -contains $Name) {
            Write-Status "Package already exists in ${Bundle}: $Name" -Type Warning
            return $true
        }
        $manifest.scoop = Normalize-PackageList -Packages ($current + $Name)
    }

    Save-PackageManifest -Manifest $manifest -Type $Bundle
    Write-Status "Added $Name to $Bundle ($Type)" -Type Success

    if ($Type -eq 'winget') {
        $winget = Get-WingetCommand
        if ($winget) {
            Write-Status "Installing: $Name" -Type Info
            & $winget install --id $Name --silent --accept-package-agreements --accept-source-agreements 2>&1 | Out-Null
            if ($LASTEXITCODE -ne 0) {
                Write-Status "Failed to install: $Name" -Type Warning
                return $false
            }
            Write-Status "Installed: $Name" -Type Success
        } else {
            Write-Status "winget not found. Package added to manifest only." -Type Warning
        }
    } else {
        $scoop = Get-Command scoop -ErrorAction SilentlyContinue
        if ($scoop) {
            Write-Status "Installing (scoop): $Name" -Type Info
            & $scoop install $Name 2>&1 | Out-Null
            if ($LASTEXITCODE -ne 0) {
                Write-Status "Failed to install (scoop): $Name" -Type Warning
                return $false
            }
            Write-Status "Installed (scoop): $Name" -Type Success
        } else {
            Write-Status "scoop not found. Package added to manifest only." -Type Warning
        }
    }

    return $true
}

function Remove-Package {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [ValidateSet('base', 'work', 'all')]
        [string]$Bundle = 'all'
    )

    $bundles = if ($Bundle -eq 'all') { @('base', 'work') } else { @($Bundle) }
    $removed = $false

    foreach ($bundleType in $bundles) {
        $manifest = Get-PackageManifest -Type $bundleType
        if ($null -eq $manifest) { continue }

        $changed = $false

        if ($manifest.PSObject.Properties.Name -contains 'winget') {
            $updatedWinget = @($manifest.winget | Where-Object { $_ -ne $Name })
            if ($updatedWinget.Count -ne $manifest.winget.Count) {
                $manifest.winget = Normalize-PackageList -Packages $updatedWinget
                $changed = $true
            }
        }

        if ($manifest.PSObject.Properties.Name -contains 'scoop') {
            $updatedScoop = @($manifest.scoop | Where-Object { $_ -ne $Name })
            if ($updatedScoop.Count -ne $manifest.scoop.Count) {
                $manifest.scoop = Normalize-PackageList -Packages $updatedScoop
                $changed = $true
            }
        }

        if ($changed) {
            Save-PackageManifest -Manifest $manifest -Type $bundleType
            Write-Status "Removed $Name from $bundleType" -Type Success
            $removed = $true
        }
    }

    if (-not $removed) {
        Write-Status "Package not found in manifests: $Name" -Type Warning
        return $false
    }

    $response = Read-Host "Uninstall '$Name' from system? (y/N)"
    if ($response -match '^(?i)y') {
        $winget = Get-WingetCommand
        if ($winget) {
            Write-Status "Uninstalling (winget): $Name" -Type Info
            & $winget uninstall --id $Name 2>&1 | Out-Null
        }
        $scoop = Get-Command scoop -ErrorAction SilentlyContinue
        if ($scoop) {
            Write-Status "Uninstalling (scoop): $Name" -Type Info
            & $scoop uninstall $Name 2>&1 | Out-Null
        }
    } else {
        Write-Status "Package removed from manifest only" -Type Info
    }

    return $true
}

function Retry-FailedPackages {
    [CmdletBinding()]
    param()

    $latestFailed = Get-ChildItem $PackagesDir -Filter "failed_packages_*.txt" -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    if (-not $latestFailed) {
        Write-Status "No failed package log found" -Type Warning
        return $false
    }

    $packages = Get-Content $latestFailed.FullName | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
    if ($packages.Count -eq 0) {
        Write-Status "No packages to retry in: $($latestFailed.Name)" -Type Warning
        return $false
    }

    Write-Status "Retrying failed packages from: $($latestFailed.Name)" -Type Info

    $winget = Get-WingetCommand
    if (-not $winget) {
        Write-Status "winget not found. Install App Installer from Microsoft Store." -Type Error
        return $false
    }

    foreach ($pkg in $packages) {
        Write-Status "Retrying: $pkg" -Type Info
        & $winget install --id $pkg --silent --accept-package-agreements --accept-source-agreements 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) {
            Write-Status "Still failed: $pkg" -Type Warning
        } else {
            Write-Status "Installed: $pkg" -Type Success
        }
    }

    return $true
}

function Show-PackageHelp {
    Write-Host "dot package - Package management commands" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Usage:" -ForegroundColor White
    Write-Host "  dot package [subcommand] [options]"
    Write-Host ""
    Write-Host "Subcommands:" -ForegroundColor Yellow
    Write-Host "  list [bundle]                 List packages (bundle: base|work|all)"
    Write-Host "  install [bundle]              Install packages from bundle (default: base)"
    Write-Host "  add NAME [type] [bundle]      Add package and install it"
    Write-Host "  remove NAME [bundle]          Remove package (optionally uninstall)"
    Write-Host "  update [NAME] [bundle]        Update packages (all by default)"
    Write-Host "  help                          Show this help"
    Write-Host ""
    Write-Host "Options:" -ForegroundColor Yellow
    Write-Host "  type   winget|scoop (default: winget)"
    Write-Host "  bundle base|work|all (default varies by command)"
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Yellow
    Write-Host "  dot package list"
    Write-Host "  dot package list work"
    Write-Host "  dot package add Git.Git winget base"
    Write-Host "  dot package remove Git.Git"
    Write-Host "  dot package update"
    Write-Host "  dot package update Microsoft.PowerShell"
}

# ============================================================================
# SSH KEY MANAGEMENT
# ============================================================================

function Invoke-SshKeyGeneration {
    [CmdletBinding()]
    param(
        [string]$Email,
        [switch]$Force
    )

    Write-Status "Generating SSH key..." -Type Info

    $sshKeygen = Get-Command ssh-keygen -ErrorAction SilentlyContinue
    if (-not $sshKeygen) {
        Write-Status "ssh-keygen not found. Install OpenSSH Client." -Type Error
        return $false
    }

    if ([string]::IsNullOrWhiteSpace($Email)) {
        $git = Get-Command git -ErrorAction SilentlyContinue
        if ($git) {
            $Email = (git config --global user.email 2>$null).Trim()
        }
    }

    if ([string]::IsNullOrWhiteSpace($Email)) {
        $Email = Read-Host "Email for SSH key (optional)"
    }

    $domain = $null
    if ($Email -match "@(.+)$") {
        $domain = $Matches[1]
    }
    $safeDomain = if ($domain) { ($domain -replace '[^A-Za-z0-9]+', '_').Trim('_') } else { $null }
    $keyName = if ($safeDomain) { "id_ed25519_$safeDomain" } else { "id_ed25519" }

    $sshDir = Join-Path $HomeDir ".ssh"
    if (-not (Test-Path $sshDir)) {
        New-Item -ItemType Directory -Path $sshDir -Force | Out-Null
    }

    $keyPath = Join-Path $sshDir $keyName
    if ((Test-Path $keyPath) -or (Test-Path "$keyPath.pub")) {
        if (-not $Force) {
            $confirm = Read-Host "Key exists at $keyPath. Overwrite? (y/N)"
            if ($confirm -notmatch '^(?i)y') {
                Write-Status "SSH key generation cancelled" -Type Warning
                return $false
            }
        }
        Remove-Item $keyPath -Force -ErrorAction SilentlyContinue
        Remove-Item "$keyPath.pub" -Force -ErrorAction SilentlyContinue
    }

    $args = @('-t', 'ed25519', '-f', $keyPath)
    if (-not [string]::IsNullOrWhiteSpace($Email)) {
        $args += @('-C', $Email)
    }

    & $sshKeygen @args
    if ($LASTEXITCODE -ne 0) {
        Write-Status "ssh-keygen failed" -Type Error
        return $false
    }

    Write-Status "SSH key created: $keyPath" -Type Success

    $agent = Get-Service ssh-agent -ErrorAction SilentlyContinue
    if ($agent) {
        if ($agent.Status -ne 'Running') {
            try {
                Start-Service ssh-agent -ErrorAction Stop
            } catch {
                Write-Status "Failed to start ssh-agent: $_" -Type Warning
            }
        }
    }

    $sshAdd = Get-Command ssh-add -ErrorAction SilentlyContinue
    if ($sshAdd) {
        & $sshAdd $keyPath 2>&1 | Out-Null
    }

    $pubPath = "$keyPath.pub"
    if (Test-Path $pubPath) {
        $setClipboard = Get-Command Set-Clipboard -ErrorAction SilentlyContinue
        if ($setClipboard) {
            Get-Content $pubPath | Set-Clipboard
            Write-Status "Public key copied to clipboard" -Type Success
        }
        Write-Status "Public key: $pubPath" -Type Info
    }

    return $true
}

# ============================================================================
# BACKUP & RESTORE
# ============================================================================

function New-Backup {
    [CmdletBinding()]
    param([string]$Name)
    
    if ([string]::IsNullOrEmpty($Name)) {
        $Name = Get-Date -Format "yyyy-MM-dd_HHmmss"
    }
    
    $backupPath = Join-Path $BackupDir $Name
    
    if (Test-Path $backupPath) {
        Write-Status "Backup '$Name' already exists" -Type Error
        return $false
    }
    
    Write-Status "Creating backup: $Name" -Type Info
    
    New-Item -ItemType Directory -Path $backupPath -Force | Out-Null
    
    # Items to backup
    $items = @(
        @{ Source = (Join-Path $HomeDir ".claude"); Dest = ".claude" },
        @{ Source = (Join-Path $HomeDir ".gitconfig"); Dest = ".gitconfig" },
        @{ Source = (Join-Path $HomeDir ".ideavimrc"); Dest = ".ideavimrc" },
        @{ Source = (Join-Path $HomeDir ".config"); Dest = ".config" },
        @{ Source = (Join-Path $HomeDir "Documents\WindowsPowerShell"); Dest = "WindowsPowerShell" },
        @{ Source = (Join-Path $HomeDir "Documents\PowerShell"); Dest = "PowerShell" }
    )
    
    foreach ($item in $items) {
        if (Test-Path $item.Source) {
            $dest = Join-Path $backupPath $item.Dest
            Copy-Item -Path $item.Source -Destination $dest -Recurse -Force
            Write-Status "Backed up: $($item.Dest)" -Type Success
        }
    }
    
    # Compress backup
    $archivePath = "$backupPath.zip"
    Compress-Archive -Path $backupPath -DestinationPath $archivePath -Force
    Remove-Item $backupPath -Recurse -Force
    
    Write-Status "Backup created: $archivePath" -Type Success
    return $true
}

function Restore-Backup {
    [CmdletBinding()]
    param([string]$Name)
    
    if ([string]::IsNullOrEmpty($Name)) {
        # List available backups
        Write-Status "Available backups:" -Type Info
        Get-ChildItem $BackupDir -Filter "*.zip" | ForEach-Object {
            Write-Host "  $($_.BaseName)" -ForegroundColor White
        }
        return
    }
    
    $archivePath = Join-Path $BackupDir "$Name.zip"
    if (-not (Test-Path $archivePath)) {
        Write-Status "Backup not found: $Name" -Type Error
        return $false
    }
    
    Write-Status "Restoring backup: $Name" -Type Info
    
    $tempPath = Join-Path $env:TEMP "dotfiles_restore_$(Get-Random)"
    Expand-Archive -Path $archivePath -DestinationPath $tempPath -Force
    
    $backupContents = Join-Path $tempPath $Name
    
    Get-ChildItem $backupContents | ForEach-Object {
        $dest = switch ($_.Name) {
            ".claude" { Join-Path $HomeDir ".claude" }
            ".gitconfig" { Join-Path $HomeDir ".gitconfig" }
            ".ideavimrc" { Join-Path $HomeDir ".ideavimrc" }
            ".config" { Join-Path $HomeDir ".config" }
            "WindowsPowerShell" { Join-Path $HomeDir "Documents\WindowsPowerShell" }
            "PowerShell" { Join-Path $HomeDir "Documents\PowerShell" }
            default { $null }
        }
        
        if ($dest) {
            if (Test-Path $dest) {
                Remove-Item $dest -Recurse -Force
            }
            Copy-Item -Path $_.FullName -Destination $dest -Recurse -Force
            Write-Status "Restored: $($_.Name)" -Type Success
        }
    }
    
    Remove-Item $tempPath -Recurse -Force
    Write-Status "Restore complete" -Type Success
    return $true
}

function Remove-OldBackups {
    [CmdletBinding()]
    param([int]$DaysOld = 30)
    
    Write-Status "Removing backups older than $DaysOld days..." -Type Info
    
    $cutoff = (Get-Date).AddDays(-$DaysOld)
    $removed = 0
    
    Get-ChildItem $BackupDir -Filter "*.zip" | Where-Object {
        $_.CreationTime -lt $cutoff
    } | ForEach-Object {
        Remove-Item $_.FullName -Force
        Write-Status "Removed: $($_.Name)" -Type Muted
        $removed++
    }
    
    Write-Status "Removed $removed old backups" -Type Info
}

# ============================================================================
# DOCTOR / DIAGNOSTICS
# ============================================================================

function Invoke-Doctor {
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║                    Dotfiles Health Check                     ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    
    $issues = @()
    
    # System Info
    Write-Host "System Information" -ForegroundColor Yellow
    Write-Host "──────────────────" -ForegroundColor DarkGray
    Write-Status "OS: $([System.Environment]::OSVersion.VersionString)" -Type Info
    Write-Status "PowerShell: $($PSVersionTable.PSVersion)" -Type Info
    Write-Status "User: $env:USERNAME" -Type Info
    Write-Host ""
    
    # Required Tools
    Write-Host "Required Tools" -ForegroundColor Yellow
    Write-Host "──────────────" -ForegroundColor DarkGray
    
    $tools = @(
        @{ Name = "winget"; Check = { if (Get-Command winget -ErrorAction SilentlyContinue) { $true } else { Test-Path "$env:LOCALAPPDATA\Microsoft\WindowsApps\winget.exe" } }; Install = "Microsoft Store: App Installer" },
        @{ Name = "git"; Check = { Get-Command git -ErrorAction SilentlyContinue }; Install = "winget install Git.Git" },
        @{ Name = "claude"; Check = { Get-Command claude -ErrorAction SilentlyContinue }; Install = "irm https://claude.ai/install.ps1 | iex" },
        @{ Name = "code"; Check = { Get-Command code -ErrorAction SilentlyContinue }; Install = "winget install Microsoft.VisualStudioCode" }
    )
    
    foreach ($tool in $tools) {
        $installed = & $tool.Check
        if ($installed) {
            Write-Status "$($tool.Name)" -Type Success
        } else {
            Write-Status "$($tool.Name) (not found)" -Type Warning
            $issues += "Missing: $($tool.Name) - Install with: $($tool.Install)"
        }
    }
    Write-Host ""
    
    # Claude Code
    Write-Host "Claude Code" -ForegroundColor Yellow
    Write-Host "───────────" -ForegroundColor DarkGray
    
    $claudeSettings = Join-Path $ClaudeDir "settings.json"
    if (Test-Path $claudeSettings) {
        Write-Status "settings.json exists" -Type Success
    } else {
        Write-Status "settings.json missing" -Type Warning
        $issues += "Claude Code settings not configured"
    }
    
    $globalClaudeMd = Join-Path $ClaudeDir "CLAUDE.md"
    if (Test-Path $globalClaudeMd) {
        Write-Status "Global CLAUDE.md exists" -Type Success
    } else {
        Write-Status "Global CLAUDE.md missing" -Type Warning
        $issues += "No global CLAUDE.md - run 'dot stow' to create"
    }
    Write-Host ""
    
    # Symlinks
    Write-Host "Symlinks" -ForegroundColor Yellow
    Write-Host "────────" -ForegroundColor DarkGray
    
    $sourceHome = $Script:HomeSource
    if (Test-Path $sourceHome) {
        $files = Get-ChildItem -Path $sourceHome -Recurse -File -ErrorAction SilentlyContinue
        $linked = 0
        $broken = 0
        $missing = 0
        
        foreach ($file in $files) {
            $relativePath = Get-RelativePath -Path $file.FullName -BasePath $sourceHome
            $targetPath = Join-Path $HomeDir $relativePath
            
            if (Test-Path $targetPath) {
                $item = Get-Item $targetPath -Force -ErrorAction SilentlyContinue
                if ($item.LinkType -eq 'SymbolicLink') {
                    if ($item.Target -eq $file.FullName) {
                        $linked++
                    } else {
                        $broken++
                    }
                }
            } else {
                $missing++
            }
        }
        
        Write-Status "Active symlinks: $linked" -Type $(if ($linked -gt 0) { 'Success' } else { 'Warning' })
        if ($broken -gt 0) {
            Write-Status "Broken symlinks: $broken" -Type Warning
            $issues += "$broken broken symlinks found"
        }
        if ($missing -gt 0) {
            Write-Status "Missing symlinks: $missing" -Type Warning
            $issues += "$missing symlinks not created - run 'dot stow'"
        }
    } else {
        Write-Status "Home source directory not found" -Type Error
        $issues += "Dotfiles home directory missing"
    }
    Write-Host ""
    
    # PATH Check
    Write-Host "PATH Configuration" -ForegroundColor Yellow
    Write-Host "──────────────────" -ForegroundColor DarkGray
    
    $dotfilesInPath = $env:PATH -split ';' | Where-Object { $_ -like "*\.dotfiles*" }
    if ($dotfilesInPath) {
        Write-Status "Dotfiles in PATH" -Type Success
    } else {
        Write-Status "Dotfiles not in PATH" -Type Warning
        $issues += "Run 'dot link' to add dotfiles to PATH"
    }
    Write-Host ""
    
    # Summary
    if ($issues.Count -eq 0) {
        Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
        Write-Host "║                    All checks passed! ✓                      ║" -ForegroundColor Green
        Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Green
    } else {
        Write-Host "Issues Found ($($issues.Count)):" -ForegroundColor Yellow
        Write-Host "────────────────────" -ForegroundColor DarkGray
        foreach ($issue in $issues) {
            Write-Status $issue -Type Warning
        }
    }
    Write-Host ""
}

# ============================================================================
# INITIALIZATION
# ============================================================================

function Initialize-Dotfiles {
    [CmdletBinding()]
    param(
        [switch]$SkipPackages,
        [switch]$SkipGit,
        [switch]$SkipSsh,
        [switch]$SkipFont
    )
    
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║                  Dotfiles Initialization                     ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    
    # Ensure backup directory exists first
    if (-not (Test-Path $BackupDir)) {
        New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
    }
    
    # Check for Developer Mode (required for symlinks on Windows)
    $devModeKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
    $hasDevMode = $false
    if (Test-Path $devModeKey) {
        $devModeValue = Get-ItemProperty $devModeKey -Name "AllowDevelopmentWithoutDevLicense" -ErrorAction SilentlyContinue
        $hasDevMode = $devModeValue.AllowDevelopmentWithoutDevLicense -eq 1
    }
    
    if (-not $hasDevMode) {
        Write-Status "ERROR: Developer Mode is NOT enabled" -Type Error
        Write-Host ""
        Write-Host "Symlinks require Developer Mode on Windows." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "To enable it:" -ForegroundColor Yellow
        Write-Host "  1. Open Windows Settings" -ForegroundColor DarkGray
        Write-Host "  2. Go to: Privacy & Security > For Developers" -ForegroundColor DarkGray
        Write-Host "  3. Toggle ON: Developer Mode" -ForegroundColor DarkGray
        Write-Host "  4. Restart your terminal and run 'dot init' again" -ForegroundColor DarkGray
        Write-Host ""
        return
    }
    
    Write-Status "Developer Mode confirmed" -Type Success
    
    # Run Windows settings configuration (admin required)
    Invoke-WindowsSettings -NoRestart

    # Generate SSH key (optional)
    if (-not $SkipSsh) {
        Invoke-SshKeyGeneration | Out-Null
    } else {
        Write-Status "Skipping SSH key generation" -Type Muted
    }

    # Install development fonts (optional)
    if (-not $SkipFont) {
        Invoke-FontInstall | Out-Null
    } else {
        Write-Status "Skipping font installation" -Type Muted
    }

    # Setup Claude Code
    Invoke-ClaudeSetup | Out-Null
    

    # Check git user configuration
    $gitConfigPath = Join-Path $HomeSource ".config\git\config"
    if (Test-Path $gitConfigPath) {
        $gitConfigContent = Get-Content $gitConfigPath -Raw
        $nameMatch = $gitConfigContent -match "(?m)^\s*name\s*=\s*([^#\n]+)"
        $emailMatch = $gitConfigContent -match "(?m)^\s*email\s*=\s*([^#\n]+)"
        if (-not $nameMatch -or -not $emailMatch) {
            Write-Status "ERROR: Git user not configured" -Type Error
            Write-Host ""
            Write-Host "Before initializing, you must configure git:" -ForegroundColor Yellow
            Write-Host "  1. Edit: ~/.dotfiles/home/.config/git/config" -ForegroundColor DarkGray
            Write-Host "  2. Add your name and email under [user]" -ForegroundColor DarkGray
            Write-Host "  3. Save and run 'dot init' again" -ForegroundColor DarkGray
            Write-Host ""
            return
        }
    }

    Write-Status "Git configuration verified" -Type Success

    # Install git hooks
    $hooksSource = Join-Path $DotfilesRoot "scripts\hooks"
    $hooksDest = Join-Path $DotfilesRoot ".git\hooks"
    if (Test-Path $hooksSource) {
        Get-ChildItem $hooksSource -File | ForEach-Object {
            Copy-Item $_.FullName (Join-Path $hooksDest $_.Name) -Force
        }
        Write-Status "Git hooks installed" -Type Success
    }

    # Create backup first
    Write-Status "Creating pre-init backup..." -Type Info
    New-Backup -Name "pre-init-$(Get-Date -Format 'yyyyMMdd')" | Out-Null
    
    # Install packages
    if (-not $SkipPackages) {
        Write-Host ""
        Write-Status "Installing packages..." -Type Info
        Install-Packages -Type 'base' -SkipFailed
    }
    
    # Create symlinks
    Write-Host ""
    Write-Status "Creating symlinks..." -Type Info
    Install-Symlinks -Force
    
    # Link dotfiles CLI
    Write-Host ""
    Add-ToPath
    
    # Run doctor
    Write-Host ""
    Invoke-Doctor
    
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║                  Initialization Complete!                    ║" -ForegroundColor Green
    Write-Host "║                                                              ║" -ForegroundColor Green
    Write-Host "║  Restart your terminal to apply all changes.                 ║" -ForegroundColor Green
    Write-Host "║  Run 'dot doctor' to verify your setup.                      ║" -ForegroundColor Green
    Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
}

# ============================================================================
# PATH MANAGEMENT
# ============================================================================

function Add-ToPath {
    Write-Status "Adding dotfiles to PATH..." -Type Info
    
    $currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    if ($currentPath -notlike "*$DotfilesRoot*") {
        $newPath = "$DotfilesRoot;$currentPath"
        [Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
        $env:PATH = "$DotfilesRoot;$env:PATH"
        Write-Status "Added to user PATH" -Type Success
    } else {
        Write-Status "Already in PATH" -Type Success
    }
}

function Remove-FromPath {
    Write-Status "Removing dotfiles from PATH..." -Type Info
    
    $currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    $newPath = ($currentPath -split ';' | Where-Object { $_ -ne $DotfilesRoot }) -join ';'
    [Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
    Write-Status "Removed from user PATH" -Type Success
}

# ============================================================================
# SHELL BENCHMARK
# ============================================================================

function Measure-ShellStartup {
    [CmdletBinding()]
    param([int]$Runs = 10)
    
    Write-Host ""
    Write-Host "PowerShell Startup Benchmark" -ForegroundColor Cyan
    Write-Host "════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    
    $times = @()
    
    for ($i = 1; $i -le $Runs; $i++) {
        Write-Host "Run $i/$Runs..." -NoNewline -ForegroundColor DarkGray
        
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        $null = powershell -NoProfile -Command "exit"
        $sw.Stop()
        
        $times += $sw.Elapsed.TotalMilliseconds
        Write-Host " $([math]::Round($sw.Elapsed.TotalMilliseconds))ms" -ForegroundColor DarkGray
    }
    
    $avg = ($times | Measure-Object -Average).Average
    $min = ($times | Measure-Object -Minimum).Minimum
    $max = ($times | Measure-Object -Maximum).Maximum
    
    Write-Host ""
    Write-Host "Results:" -ForegroundColor Yellow
    Write-Host "────────" -ForegroundColor DarkGray
    Write-Status "Average: $([math]::Round($avg))ms" -Type Info
    Write-Status "Fastest: $([math]::Round($min))ms" -Type Success
    Write-Status "Slowest: $([math]::Round($max))ms" -Type Warning
    
    Write-Host ""
    if ($avg -le 200) {
        Write-Status "Excellent startup performance!" -Type Success
    } elseif ($avg -le 500) {
        Write-Status "Good startup performance" -Type Info
    } elseif ($avg -le 1000) {
        Write-Status "Fair startup performance - consider profiling" -Type Warning
    } else {
        Write-Status "Slow startup - profile your \$PROFILE" -Type Error
    }
}

# ============================================================================
# AI SUMMARY (Claude Code Integration)
# ============================================================================

function Get-CommitSummary {
    [CmdletBinding()]
    param(
        [int]$Count = 3,
        [switch]$ShowVerbose,
        [switch]$IncludeDiffs
    )
    
    $git = Get-Command git -ErrorAction SilentlyContinue
    if (-not $git) {
        Write-Status "git not found" -Type Error
        return
    }
    
    $claude = Get-Command claude -ErrorAction SilentlyContinue
    if (-not $claude) {
        Write-Status "claude not found" -Type Error
        return
    }
    
    Write-Status "Gathering commit history..." -Type Info
    
    $logFormat = if ($ShowVerbose) { "--stat" } else { "--oneline" }
    $commits = git log -n $Count $logFormat 2>&1
    
    if ($LASTEXITCODE -ne 0) {
        Write-Status "Not in a git repository" -Type Error
        return
    }
    
    $prompt = @"
Analyze these recent git commits and provide a concise summary:

$commits

Focus on:
1. Main development themes
2. Technical patterns
3. Notable changes

Keep the summary under 200 words.
"@

    Write-Status "Generating summary with Claude..." -Type Info
    Write-Host ""
    
    Write-Output $prompt | claude --print 2>&1
}

# ============================================================================
# HELPER SCRIPTS INTEGRATION
# ============================================================================

function Invoke-WindowsSettings {
    [CmdletBinding()]
    param([switch]$NoRestart)
    
    Write-Status "Configuring Windows settings..." -Type Info
    
    $scriptPath = Join-Path $PSScriptRoot "scripts\windows-settings.ps1"
    if (-not (Test-Path $scriptPath)) {
        Write-Status "Settings script not found: $scriptPath" -Type Error
        return $false
    }
    
    try {
        if ($NoRestart) {
            & $scriptPath -NoRestart -ErrorAction Stop
        } else {
            & $scriptPath -ErrorAction Stop
        }
        Write-Status "Windows settings configured" -Type Success
        return $true
    } catch {
        Write-Status "Failed to configure settings: $_" -Type Error
        return $false
    }
}

function Invoke-FontInstall {
    [CmdletBinding()]
    param()
    
    Write-Status "Installing development fonts..." -Type Info
    
    $scriptPath = Join-Path $PSScriptRoot "scripts\install-fonts.ps1"
    if (-not (Test-Path $scriptPath)) {
        Write-Status "Font script not found: $scriptPath" -Type Error
        return $false
    }
    
    try {
        & $scriptPath -ErrorAction Stop
        Write-Status "Fonts installed" -Type Success
        return $true
    } catch {
        Write-Status "Failed to install fonts: $_" -Type Warning
        # Non-fatal error
        return $true
    }
}

function Invoke-ClaudeSetup {
    [CmdletBinding()]
    param()
    
    Write-Status "Setting up Claude Code..." -Type Info
    
    $scriptPath = Join-Path $PSScriptRoot "scripts\install-claude.ps1"
    if (-not (Test-Path $scriptPath)) {
        Write-Status "Claude setup script not found: $scriptPath" -Type Error
        return $false
    }
    
    try {
        & $scriptPath -ErrorAction Stop
        Write-Status "Claude Code setup complete" -Type Success
        return $true
    } catch {
        Write-Status "Failed to setup Claude Code: $_" -Type Warning
        # Non-fatal error
        return $true
    }
}

# ============================================================================
# UPDATE
# ============================================================================

function Update-Dotfiles {
    Write-Host ""
    Write-Status "Updating dotfiles..." -Type Info
    
    Push-Location $DotfilesRoot
    
    $git = Get-Command git -ErrorAction SilentlyContinue
    if ($git) {
        Write-Status "Pulling latest changes..." -Type Info
        git pull 2>&1 | ForEach-Object { Write-Host "  $_" -ForegroundColor DarkGray }
    }
    
    Write-Status "Re-creating symlinks..." -Type Info
    Install-Symlinks
    
    Write-Status "Updating packages..." -Type Info
    $winget = Get-Command winget -ErrorAction SilentlyContinue
    if ($winget) {
        winget upgrade --all --silent --accept-package-agreements --accept-source-agreements 2>&1 | Out-Null
    }
    
    Pop-Location
    
    Write-Status "Update complete!" -Type Success
}

# ============================================================================
# HELP
# ============================================================================

function Show-Help {
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║                     Dotfiles CLI                             ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usage: dot [options] <command> [arguments]" -ForegroundColor White
    Write-Host ""
    Write-Host "Commands:" -ForegroundColor Yellow
    Write-Host "  init              Initialize dotfiles (install packages, create symlinks)"
    Write-Host "  update            Pull latest changes and refresh symlinks"
    Write-Host "  doctor            Run health check diagnostics"
    Write-Host "  stow              Create/update symlinks"
    Write-Host "  unstow            Remove managed symlinks"
    Write-Host "  edit              Open dotfiles in editor"
    Write-Host "  gen-ssh-key        Generate SSH key (optional email)"
    Write-Host "  link              Add dotfiles to PATH"
    Write-Host "  unlink            Remove dotfiles from PATH"
    Write-Host "  settings          Apply Windows settings"
    Write-Host "  fonts             Install development fonts"
    Write-Host "  claude            Setup Claude Code"
    Write-Host ""
    Write-Host "  backup [name]     Create backup (optional name)"
    Write-Host "  restore [name]    Restore from backup (list if no name)"
    Write-Host ""
    Write-Host "  package list      List packages and status"
    Write-Host "  package install   Install packages from manifest"
    Write-Host "  package add       Add package to manifest and install"
    Write-Host "  package remove    Remove package from manifest"
    Write-Host "  package update    Update packages"
    Write-Host "  check-packages    Check package installation status"
    Write-Host "  retry-failed      Retry failed package installs"
    Write-Host ""
    Write-Host "  summary [-n N]    AI summary of recent commits"
    Write-Host "  benchmark-shell   Measure shell startup time"
    Write-Host ""
    Write-Host "Options:" -ForegroundColor Yellow
    Write-Host "  --skip-ssh         Skip SSH key generation (init only)"
    Write-Host "  --skip-font        Skip font installation (init only)"
    Write-Host "  --version          Show version information"
    Write-Host "  -h, --help         Show this help"
    Write-Host ""
    Write-Host "  help              Show this help"
    Write-Host ""
    Write-Host "Philosophy:" -ForegroundColor Yellow
    Write-Host "  This codebase will outlive you. Every shortcut becomes" -ForegroundColor DarkGray
    Write-Host "  someone else's burden. Every hack compounds into technical" -ForegroundColor DarkGray
    Write-Host "  debt. Fight entropy. Leave it better than you found it." -ForegroundColor DarkGray
    Write-Host ""
}

# ============================================================================
# MAIN DISPATCH
# ============================================================================

if ($Version) {
    Write-Host "dot version $Script:CliVersion"
    return
}

if ($Help) {
    Show-Help
    return
}

switch ($Command) {
    'init' {
        $skipPkg = $Arguments -contains '--skip-packages'
        $skipGit = $Arguments -contains '--skip-git'
        $skipSsh = $SkipSsh -or ($Arguments -contains '--skip-ssh')
        $skipFont = $SkipFont -or ($Arguments -contains '--skip-font')
        Initialize-Dotfiles -SkipPackages:$skipPkg -SkipGit:$skipGit -SkipSsh:$skipSsh -SkipFont:$skipFont
    }
    'update' {
        Update-Dotfiles
    }
    'doctor' {
        Invoke-Doctor
    }
    'stow' {
        Install-Symlinks -Force:($Arguments -contains '--force')
    }
    'unstow' {
        Remove-Symlinks
    }
    'edit' {
        $editor = $env:EDITOR
        if (-not $editor) { $editor = "code" }
        & $editor $DotfilesRoot
    }
    'settings' {
        Invoke-WindowsSettings -NoRestart
    }
    'fonts' {
        Invoke-FontInstall
    }
    'claude' {
        Invoke-ClaudeSetup
    }
    'link' {
        Add-ToPath
    }
    'unlink' {
        Remove-FromPath
    }
    'backup' {
        if ($Arguments.Count -gt 0 -and $Arguments[0] -eq 'clean') {
            Remove-OldBackups
        } elseif ($Arguments.Count -gt 0 -and $Arguments[0] -eq 'list') {
            Get-ChildItem $BackupDir -Filter "*.zip" | ForEach-Object {
                Write-Host "  $($_.BaseName)  ($($_.LastWriteTime.ToString('yyyy-MM-dd HH:mm')))" -ForegroundColor White
            }
        } else {
            New-Backup -Name ($Arguments | Select-Object -First 1)
        }
    }
    'restore' {
        Restore-Backup -Name ($Arguments | Select-Object -First 1)
    }
    'package' {
        $subCommand = $Arguments | Select-Object -First 1
        $subArgs = @()
        if ($Arguments.Count -gt 1) {
            $subArgs = $Arguments[1..($Arguments.Count - 1)]
        }
        switch ($subCommand) {
            'list' {
                $bundle = if ($subArgs.Count -gt 0) { $subArgs[0] } else { 'all' }
                if ($bundle -notin @('base', 'work', 'all')) { Show-PackageHelp; break }
                Get-InstalledPackages -Type $bundle
            }
            'install' {
                $bundle = if ($subArgs.Count -gt 0) { $subArgs[0] } else { 'base' }
                if ($bundle -notin @('base', 'work', 'all')) { Show-PackageHelp; break }
                Install-Packages -Type $bundle
            }
            'add' {
                if ($subArgs.Count -lt 1) { Show-PackageHelp; break }
                $name = $subArgs[0]
                $type = 'winget'
                $bundle = 'base'
                if ($subArgs.Count -ge 2) {
                    if ($subArgs[1] -in @('winget', 'scoop')) {
                        $type = $subArgs[1]
                        if ($subArgs.Count -ge 3) { $bundle = $subArgs[2] }
                    } elseif ($subArgs[1] -in @('base', 'work')) {
                        $bundle = $subArgs[1]
                    }
                }
                Add-Package -Name $name -Type $type -Bundle $bundle
            }
            'remove' {
                if ($subArgs.Count -lt 1) { Show-PackageHelp; break }
                $name = $subArgs[0]
                $bundle = if ($subArgs.Count -ge 2) { $subArgs[1] } else { 'all' }
                if ($bundle -notin @('base', 'work', 'all')) { Show-PackageHelp; break }
                Remove-Package -Name $name -Bundle $bundle
            }
            'update' {
                $name = 'all'
                $bundle = 'all'
                if ($subArgs.Count -ge 1) {
                    if ($subArgs[0] -in @('base', 'work')) {
                        $bundle = $subArgs[0]
                    } else {
                        $name = $subArgs[0]
                    }
                }
                if ($subArgs.Count -ge 2) { $bundle = $subArgs[1] }
                if ($bundle -notin @('base', 'work', 'all')) { Show-PackageHelp; break }
                Update-Packages -Name $name -Bundle $bundle
            }
            'help' { Show-PackageHelp }
            default { Show-PackageHelp }
        }
    }
    'check-packages' {
        Get-InstalledPackages -Type 'all'
    }
    'retry-failed' {
        Retry-FailedPackages
    }
    'summary' {
        $count = 3
        $verbose = $false
        $diffs = $false
        for ($i = 0; $i -lt $Arguments.Count; $i++) {
            if ($Arguments[$i] -eq '-n' -and $i + 1 -lt $Arguments.Count) {
                $count = [int]$Arguments[$i + 1]
            }
            if ($Arguments[$i] -eq '-v') { $verbose = $true }
            if ($Arguments[$i] -eq '-d') { $diffs = $true }
        }
        Get-CommitSummary -Count $count -Verbose:$verbose -IncludeDiffs:$diffs
    }
    'benchmark-shell' {
        $runs = 10
        for ($i = 0; $i -lt $Arguments.Count; $i++) {
            if ($Arguments[$i] -eq '-r' -and $i + 1 -lt $Arguments.Count) {
                $runs = [int]$Arguments[$i + 1]
            }
        }
        Measure-ShellStartup -Runs $runs
    }
    'gen-ssh-key' {
        $email = $Arguments | Select-Object -First 1
        Invoke-SshKeyGeneration -Email $email | Out-Null
    }
    'completions' {
        Write-Status "Tab completions for PowerShell are built-in via ArgumentCompleter" -Type Info
    }
    'help' {
        Show-Help
    }
    default {
        Show-Help
    }
}
