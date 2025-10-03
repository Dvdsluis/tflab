#!/usr/bin/env pwsh

# =============================================================================
# Git Hooks Installation Script for Terraform Documentation
# =============================================================================
# Purpose: Install pre-commit hooks for automatic Terraform documentation generation
# Author: Infrastructure Team  
# Requirements: Git repository, PowerShell 5.1+, Write permissions to .git/hooks
# =============================================================================

<#
.SYNOPSIS
    Install Git hooks for automated Terraform documentation generation

.DESCRIPTION
    This PowerShell script installs pre-commit hooks that automatically generate
    Terraform documentation using terraform-docs when .tf or .tfvars files are 
    committed. The hook detects changes to modules and environments, generates
    README.md files, and stages them for inclusion in the commit.

.PARAMETER Force
    Overwrite existing git hooks without user confirmation prompt.
    Use this for automated installations or when updating existing hooks.

.EXAMPLE
    .\install-hooks.ps1
    Install hooks with confirmation prompt if hooks already exist

.EXAMPLE  
    .\install-hooks.ps1 -Force
    Install hooks and overwrite any existing hooks without prompting

.NOTES
    - Must be run from the root of a Git repository
    - Requires write permissions to .git/hooks directory
    - Creates .git/hooks directory if it doesn't exist
    - Makes hooks executable on Unix-like systems
#>

# Define script parameters
param(
    [switch]$Force  # Flag to force overwrite existing hooks without confirmation
)

# =============================================================================
# OUTPUT FORMATTING CONFIGURATION
# =============================================================================
# Color scheme definitions for consistent output formatting across the script

$Green = @{ ForegroundColor = "Green" }     # Success and completion messages
$Yellow = @{ ForegroundColor = "Yellow" }   # Warning and caution messages
$Red = @{ ForegroundColor = "Red" }         # Error and failure messages  
$Blue = @{ ForegroundColor = "Blue" }       # Information and instruction messages

# =============================================================================
# OUTPUT FORMATTING FUNCTIONS
# =============================================================================
# Standardized message output functions for consistent user experience

# Function: Write-Status
# Purpose: Display success and progress status messages
function Write-Status {
    param($Message)
    Write-Host "[STATUS] $Message" @Green
}

# Function: Write-Error
# Purpose: Display error messages for critical failures
function Write-Error {
    param($Message)
    Write-Host "[ERROR] $Message" @Red
}

# Function: Write-Info  
# Purpose: Display informational messages and instructions
function Write-Info {
    param($Message)
    Write-Host "[INFO] $Message" @Blue
}

# Function: Write-Warning
# Purpose: Display warning messages for non-critical issues
function Write-Warning {
    param($Message)
    Write-Host "[WARNING] $Message" @Yellow
}

# =============================================================================
# ENVIRONMENT VALIDATION AND SETUP
# =============================================================================

# Phase 1: Validate Git repository environment
# Ensure script is executed from within a Git repository root directory
if (-not (Test-Path ".git")) {
    Write-Error "Not in a Git repository. Please run this script from the repository root directory."
    Write-Info "Expected: A .git directory should exist in the current working directory"
    exit 1
}

# Phase 2: Ensure Git hooks directory structure exists
# Create .git/hooks directory if it doesn't exist (Git may not create it automatically)
$hooksDir = ".git\hooks"
if (-not (Test-Path $hooksDir)) {
    try {
        New-Item -ItemType Directory -Path $hooksDir -Force | Out-Null
        Write-Status "Created .git/hooks directory"
    }
    catch {
        Write-Error "Failed to create .git/hooks directory: $_"
        exit 1
    }
}

# =============================================================================
# FILE PATH CONFIGURATION AND VALIDATION
# =============================================================================

# Phase 3: Define file paths for hook installation
$preCommitHook = Join-Path $hooksDir "pre-commit"           # Target hook location
$sourceHook = "scripts\pre-commit-hook.sh"                 # Source hook script

# Phase 4: Validate source hook file exists
# Ensure the pre-commit hook source file is available for installation
if (-not (Test-Path $sourceHook)) {
    Write-Error "Source pre-commit hook not found at: $sourceHook"
    Write-Info "Please ensure the pre-commit-hook.sh file exists in the scripts directory."
    Write-Info "Expected file structure: scripts/pre-commit-hook.sh"
    exit 1
}

# =============================================================================
# EXISTING HOOK DETECTION AND USER CONFIRMATION
# =============================================================================

# Phase 5: Handle existing pre-commit hook
# Check if a pre-commit hook already exists and handle appropriately
if (Test-Path $preCommitHook) {
    if (-not $Force) {
        # Phase 5a: Prompt user for confirmation when Force flag not used
        Write-Warning "Pre-commit hook already exists at: $preCommitHook"
        $response = Read-Host "Do you want to overwrite the existing hook? (y/N)"
        
        # Phase 5b: Process user response (default to No if not explicitly Yes)
        if ($response -notmatch '^[Yy]') {
            Write-Info "Hook installation cancelled by user."
            Write-Info "Use -Force parameter to overwrite without prompting."
            exit 0
        }
    }
    # Phase 5c: Notify about overwriting existing hook
    Write-Warning "Overwriting existing pre-commit hook..."
}

# =============================================================================
# HOOK INSTALLATION AND CONFIGURATION
# =============================================================================

try {
    # Phase 6: Copy hook file to Git hooks directory
    # Install the pre-commit hook by copying from source to target location
    Copy-Item $sourceHook $preCommitHook -Force
    Write-Status "Pre-commit hook file copied successfully"
    
    # Phase 7: Handle executable permissions based on platform
    # Different platforms require different approaches for making scripts executable
    if ($IsLinux -or $IsMacOS) {
        # Phase 7a: Unix-like systems (Linux/macOS) - set executable permissions
        try {
            & chmod +x $preCommitHook
            Write-Status "Hook made executable with chmod +x"
        }
        catch {
            Write-Warning "Failed to set executable permissions: $_"
            Write-Info "You may need to manually run: chmod +x $preCommitHook"
        }
    } else {
        # Phase 7b: Windows systems - Git for Windows handles .sh files automatically
        Write-Info "Windows detected - Git Bash will handle script execution automatically"
        Write-Info "Ensure Git for Windows is installed for proper .sh file support"
    }
    
    # =============================================================================
    # INSTALLATION COMPLETION AND USER GUIDANCE
    # =============================================================================
    
    # Phase 8: Notify successful installation
    Write-Status "Git hooks installed and configured successfully"
    Write-Info ""
    
    # Phase 9: Provide user guidance on hook functionality
    Write-Info "AUTOMATIC DOCUMENTATION FEATURES:"
    Write-Info "The pre-commit hook will now automatically:"
    Write-Info "   • Detect changes to .tf and .tfvars files during commits"
    Write-Info "   • Generate documentation using terraform-docs tool"
    Write-Info "   • Create/update README.md files for changed modules and environments"
    Write-Info "   • Stage updated documentation files for inclusion in commits"
    Write-Info ""
    
    # Phase 10: Provide usage instructions and tips
    Write-Info "USAGE INSTRUCTIONS:"
    Write-Info "   • Normal commits will trigger automatic documentation generation"
    Write-Info "   • To bypass hook temporarily: git commit --no-verify"
    Write-Info "   • To manually generate docs anytime:"
    Write-Info "     PowerShell: .\scripts\generate-docs.ps1"
    Write-Info "     Bash/Linux: ./scripts/generate-docs.sh"
    Write-Info ""
    
    # Phase 11: Provide troubleshooting information  
    Write-Info "REQUIREMENTS:"
    Write-Info "   • terraform-docs tool must be installed and accessible in PATH"
    Write-Info "   • Install via: winget install terraform-docs"
    Write-Info "   • Or via Chocolatey: choco install terraform-docs"
}
catch {
    # Phase 12: Handle installation failures with detailed error information
    Write-Error "Failed to install git hooks: $_"
    Write-Info "Troubleshooting steps:"
    Write-Info "   1. Ensure you have write permissions to .git/hooks directory"  
    Write-Info "   2. Verify the source hook file exists: $sourceHook"
    Write-Info "   3. Check if Git repository is properly initialized"
    exit 1
}