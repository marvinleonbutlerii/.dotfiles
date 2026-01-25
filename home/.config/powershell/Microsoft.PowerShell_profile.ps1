# PowerShell Profile
# Managed by dotfiles: ~/.dotfiles
# 
# Philosophy: Keep it fast. Keep it useful. Keep it maintainable.

#region Timing
$ProfileLoadStart = Get-Date
#endregion

#region Environment Variables
$env:EDITOR = "code --wait"
$env:VISUAL = "code --wait"
$env:PAGER = "less"
$env:DOTFILES = "$env:USERPROFILE\.dotfiles"
$env:RIPGREP_CONFIG_PATH = "$env:USERPROFILE\.config\ripgrep\config"
$env:STARSHIP_CONFIG = "$env:USERPROFILE\.config\starship.toml"

# XDG-style directories for Windows
$env:XDG_CONFIG_HOME = "$env:USERPROFILE\.config"
$env:XDG_DATA_HOME = "$env:USERPROFILE\.local\share"
$env:XDG_CACHE_HOME = "$env:USERPROFILE\.cache"
#endregion

#region Path Additions
$pathAdditions = @(
    "$env:USERPROFILE\.dotfiles"
    "$env:USERPROFILE\.local\bin"
    "$env:USERPROFILE\AppData\Local\Microsoft\WindowsApps"
)

foreach ($path in $pathAdditions) {
    if ((Test-Path $path) -and ($env:PATH -notlike "*$path*")) {
        $env:PATH = "$path;$env:PATH"
    }
}
#endregion

#region Aliases - Navigation
Set-Alias -Name ll -Value Get-ChildItem -Option AllScope
Set-Alias -Name la -Value Get-ChildItem -Option AllScope
Set-Alias -Name which -Value Get-Command -Option AllScope
Set-Alias -Name touch -Value New-Item -Option AllScope

function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function .... { Set-Location ..\..\.. }
function ~ { Set-Location $env:USERPROFILE }

# Quick directory jumps
function dev { Set-Location "$env:USERPROFILE\Documents\dev" }
function docs { Set-Location "$env:USERPROFILE\Documents" }
function dl { Set-Location "$env:USERPROFILE\Downloads" }
function dt { Set-Location "$env:USERPROFILE\Desktop" }
#endregion

#region Aliases - Git
function gs { git status }
function ga { git add $args }
function gaa { git add --all }
function gc { git commit -m $args }
function gco { git checkout $args }
function gcb { git checkout -b $args }
function gd { git diff $args }
function gds { git diff --staged $args }
function gl { git log --oneline -20 }
function gp { git push $args }
function gpl { git pull $args }
function gb { git branch $args }
function gst { git stash $args }
function gstp { git stash pop }
#endregion

#region Aliases - Dotfiles
function dot { & "$env:DOTFILES\dot.ps1" @args }
function dotdir { Set-Location $env:DOTFILES }
function dotedit { code $env:DOTFILES }
#endregion

#region Aliases - Tools (when available)
if (Get-Command eza -ErrorAction SilentlyContinue) {
    Remove-Item alias:ls -Force -ErrorAction SilentlyContinue
    function ls { eza --icons --group-directories-first $args }
    function ll { eza -la --icons --group-directories-first $args }
    function lt { eza --tree --level=2 --icons $args }
}

if (Get-Command bat -ErrorAction SilentlyContinue) {
    Remove-Item alias:cat -Force -ErrorAction SilentlyContinue
    function cat { bat --paging=never $args }
}

if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}
#endregion

#region Utility Functions

function mkcd {
    param([string]$Path)
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
    Set-Location $Path
}

function take {
    param([string]$Path)
    mkcd $Path
}

function Get-PublicIP {
    (Invoke-WebRequest -Uri "https://api.ipify.org" -UseBasicParsing).Content
}

function Get-Weather {
    param([string]$Location = "")
    (Invoke-WebRequest -Uri "https://wttr.in/$Location?format=3" -UseBasicParsing).Content
}

function Find-InFiles {
    param(
        [Parameter(Mandatory)]
        [string]$Pattern,
        [string]$Path = "."
    )
    if (Get-Command rg -ErrorAction SilentlyContinue) {
        rg $Pattern $Path
    } else {
        Get-ChildItem -Path $Path -Recurse -File | Select-String -Pattern $Pattern
    }
}

function Get-Size {
    param([string]$Path = ".")
    $size = (Get-ChildItem -Path $Path -Recurse -File | Measure-Object -Property Length -Sum).Sum
    if ($size -gt 1GB) {
        "{0:N2} GB" -f ($size / 1GB)
    } elseif ($size -gt 1MB) {
        "{0:N2} MB" -f ($size / 1MB)
    } elseif ($size -gt 1KB) {
        "{0:N2} KB" -f ($size / 1KB)
    } else {
        "$size bytes"
    }
}

function Edit-Profile {
    code $PROFILE
}

function Reload-Profile {
    . $PROFILE
    Write-Host "Profile reloaded." -ForegroundColor Green
}

function Get-Path {
    $env:PATH -split ';' | ForEach-Object { $_ }
}

# Quick project scaffolding
function New-Project {
    param(
        [Parameter(Mandatory)]
        [string]$Name,
        [ValidateSet("node", "python", "rust", "basic")]
        [string]$Type = "basic"
    )
    
    $projectPath = Join-Path (Get-Location) $Name
    New-Item -ItemType Directory -Path $projectPath -Force | Out-Null
    Set-Location $projectPath
    
    switch ($Type) {
        "node" {
            npm init -y
            git init
        }
        "python" {
            python -m venv venv
            @"
# $Name
"@ | Out-File README.md
            @"
venv/
__pycache__/
*.pyc
.env
"@ | Out-File .gitignore
            git init
        }
        "rust" {
            cargo init
        }
        "basic" {
            git init
            @"
# $Name
"@ | Out-File README.md
            @"
# Project Context

## What this is
$Name - [description]

## Current state
- [ ] Initial setup

## My constraints
[list constraints]

## What I value
[list values]
"@ | Out-File CLAUDE.md
        }
    }
    
    Write-Host "Created $Type project: $Name" -ForegroundColor Green
}
#endregion

#region PSReadLine Configuration
if (Get-Module -ListAvailable -Name PSReadLine) {
    Set-PSReadLineOption -EditMode Emacs
    try { Set-PSReadLineOption -PredictionSource History -ErrorAction Stop } catch {}
    try { Set-PSReadLineOption -PredictionViewStyle ListView -ErrorAction Stop } catch {}
    Set-PSReadLineOption -HistorySearchCursorMovesToEnd
    
    # Key bindings
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
    Set-PSReadLineKeyHandler -Key Ctrl+d -Function DeleteCharOrExit
    Set-PSReadLineKeyHandler -Key Ctrl+w -Function BackwardDeleteWord
    Set-PSReadLineKeyHandler -Key Ctrl+u -Function BackwardDeleteLine
    Set-PSReadLineKeyHandler -Key Ctrl+a -Function BeginningOfLine
    Set-PSReadLineKeyHandler -Key Ctrl+e -Function EndOfLine
    
    # Colors
    Set-PSReadLineOption -Colors @{
        Command   = 'Yellow'
        Parameter = 'Green'
        String    = 'DarkCyan'
        Operator  = 'Magenta'
        Variable  = 'Cyan'
        Comment   = 'DarkGray'
        Keyword   = 'Green'
        Error     = 'Red'
    }
}
#endregion

#region Completions
# Add tab completions for common tools
if (Get-Command winget -ErrorAction SilentlyContinue) {
    Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
        param($wordToComplete, $commandAst, $cursorPosition)
        [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
        $Local:word = $wordToComplete.Replace('"', '""')
        $Local:ast = $commandAst.ToString().Replace('"', '""')
        winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
    }
}

if (Get-Command gh -ErrorAction SilentlyContinue) {
    Invoke-Expression -Command $(gh completion -s powershell | Out-String)
}
#endregion

#region Startup Message
$ProfileLoadEnd = Get-Date
$LoadTime = ($ProfileLoadEnd - $ProfileLoadStart).TotalMilliseconds

# Only show on interactive sessions
if ($Host.Name -eq 'ConsoleHost' -and $env:TERM_PROGRAM -ne 'vscode') {
    Write-Host ""
    Write-Host "  PowerShell $($PSVersionTable.PSVersion)" -ForegroundColor Cyan
    Write-Host "  Profile loaded in $([math]::Round($LoadTime))ms" -ForegroundColor DarkGray
    Write-Host ""
}
#endregion
