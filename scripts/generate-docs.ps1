#!/usr/bin/env pwsh

# =============================================================================
# Terraform Documentation Generator - PowerShell Edition  
# =============================================================================
# Purpose: Automatically generate README.md documentation for Terraform modules
#          and environments using the terraform-docs tool on Windows systems
# Author: Infrastructure Team
# Requirements: PowerShell 5.1+ or PowerShell Core 6+
# =============================================================================

<#
.SYNOPSIS
    Generate comprehensive Terraform documentation using terraform-docs

.DESCRIPTION
    This PowerShell script automatically generates documentation for all Terraform 
    modules and environments using terraform-docs. It creates and updates README.md 
    files with current module information including inputs, outputs, resources, 
    and usage examples.

.PARAMETER Target
    Specify documentation scope:
    - 'all': Generate docs for both modules and environments (default)
    - 'modules': Generate documentation for modules only
    - 'environments': Generate documentation for environments only

.PARAMETER Install
    Attempt to install terraform-docs if not present on the system.
    Uses winget or Chocolatey package managers.

.EXAMPLE
    .\generate-docs.ps1 -Target all
    Generates documentation for all modules and environments

.EXAMPLE
    .\generate-docs.ps1 -Target modules
    Generates documentation for modules only

.EXAMPLE
    .\generate-docs.ps1 -Install
    Installs terraform-docs and generates all documentation
#>

# Define script parameters with validation
param(
    [ValidateSet('all', 'modules', 'environments')]
    [string]$Target = 'all',
    
    [switch]$Install
)

# =============================================================================
# OUTPUT FORMATTING CONFIGURATION
# =============================================================================
# Define color schemes for different types of output messages
# These hashtables are used with Write-Host to provide visual feedback

$Green = @{ ForegroundColor = "Green" }     # Success and status messages
$Yellow = @{ ForegroundColor = "Yellow" }   # Warning messages
$Red = @{ ForegroundColor = "Red" }         # Error messages
$Blue = @{ ForegroundColor = "Blue" }       # Information messages

# =============================================================================
# OUTPUT FORMATTING FUNCTIONS
# =============================================================================
# These functions provide consistent message formatting throughout the script
# Each function handles a specific type of output with appropriate styling

# Function: Write-Status
# Purpose: Display success and progress messages
function Write-Status {
    param($Message, $Color = $Green)
    Write-Host "[STATUS] $Message" @Color
}

# Function: Write-Error  
# Purpose: Display error messages with consistent formatting
function Write-Error {
    param($Message)
    Write-Host "[ERROR] $Message" @Red
}

# Function: Write-Info
# Purpose: Display informational messages
function Write-Info {
    param($Message)
    Write-Host "[INFO] $Message" @Blue
}

# Function: Test-TerraformDocs
# Purpose: Check if terraform-docs is installed and accessible
# Returns: $true if terraform-docs is available, $false otherwise
function Test-TerraformDocs {
    try {
        # Attempt to get terraform-docs version information
        # Redirect stderr to null to suppress error messages
        $version = terraform-docs --version 2>$null
        if ($version) {
            Write-Status "terraform-docs found: $version"
            return $true
        }
    }
    catch {
        # Command not found or execution failed
        return $false
    }
    return $false
}

# Function: Install-TerraformDocs
# Purpose: Install terraform-docs using available Windows package managers
# Process: Tries winget first, then Chocolatey, then provides manual instructions
function Install-TerraformDocs {
    Write-Status "Installing terraform-docs..."
    
    # Phase 1: Try Windows Package Manager (winget) - preferred method
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Status "Installing via Windows Package Manager (winget)..."
        try {
            # Use winget to install terraform-docs from the official repository
            winget install terraform-docs
            Write-Status "Installation via winget completed"
        }
        catch {
            Write-Error "winget installation failed: $_"
            exit 1
        }
    }
    # Phase 2: Try Chocolatey package manager as fallback
    elseif (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-Status "Installing via Chocolatey package manager..."
        try {
            # Use Chocolatey to install terraform-docs with auto-confirmation
            choco install terraform-docs -y
            Write-Status "Installation via Chocolatey completed"
        }
        catch {
            Write-Error "Chocolatey installation failed: $_"
            exit 1
        }
    }
    # Phase 3: No package managers available - provide manual instructions
    else {
        Write-Info "No supported package managers found. Please install terraform-docs manually:"
        Write-Host "  - Via GitHub releases: https://github.com/terraform-docs/terraform-docs/releases" @Yellow
        Write-Host "  - Via winget: winget install terraform-docs" @Yellow  
        Write-Host "  - Via Chocolatey: choco install terraform-docs" @Yellow
        Write-Host "  - Download binary and add to PATH" @Yellow
        exit 1
    }
}

# Function: Generate-ModuleDocs
# Purpose: Generate comprehensive documentation for a specific Terraform module
# Parameters: $ModulePath - Full path to module directory, $ModuleName - Module name
# Process: Creates custom header, generates terraform-docs output, handles errors
function Generate-ModuleDocs {
    param($ModulePath, $ModuleName)
    
    Write-Status "Generating documentation for module: $ModuleName"
    
    # Phase 1: Create module-specific configuration header
    # This header provides context, usage examples, and module description
    $moduleConfig = @"
# $ModuleName Module

This module provides $ModuleName functionality for the Terraform Lab project.

## Usage

``````hcl
module "$ModuleName" {
  source = "../../modules/$ModuleName"
  
  # Required variables
  name_prefix         = "my-project"
  resource_group_name = "my-rg"
  location           = "East US"
  
  # Additional configuration...
}
``````

"@

    # Phase 2: Check and update main.tf header if needed
    # Ensures module files have proper documentation headers
    $mainTf = Join-Path $ModulePath "main.tf"
    if (Test-Path $mainTf) {
        $content = Get-Content $mainTf -Raw
        # Only add header if it doesn't already exist to avoid duplication
        if (-not $content.StartsWith("# $ModuleName Module")) {
            $newContent = "# $ModuleName Module`n# $moduleConfig`n`n$content"
            Set-Content -Path $mainTf -Value $newContent -NoNewline
        }
    }
    
    # Phase 3: Generate documentation using terraform-docs
    # Change to module directory for proper context and resource detection
    Push-Location $ModulePath
    try {
        # Create temporary header file for terraform-docs processing
        $moduleConfig | Out-File -FilePath ".terraform-docs-header.md" -Encoding UTF8
        
        # Execute terraform-docs with markdown table format and custom header
        terraform-docs markdown table . --header-from ".terraform-docs-header.md" --output-file README.md
        
        # Clean up temporary files
        Remove-Item ".terraform-docs-header.md" -ErrorAction SilentlyContinue
        
        Write-Status "Documentation generated successfully for $ModuleName"
    }
    catch {
        Write-Error "Failed to generate documentation for $ModuleName : $_"
    }
    finally {
        # Always return to original directory, even if errors occurred
        Pop-Location
    }
}

# Function: Generate-EnvironmentDocs
# Purpose: Generate documentation for environment-specific Terraform configurations  
# Parameters: $EnvPath - Path to environment directory, $EnvName - Environment name
# Process: Creates environment context, deployment instructions, file descriptions
function Generate-EnvironmentDocs {
    param($EnvPath, $EnvName)
    
    Write-Status "Generating documentation for environment: $EnvName"
    
    # Change to environment directory for proper terraform-docs context
    Push-Location $EnvPath
    try {
        # Phase 1: Create environment-specific overview content
        # Includes deployment instructions and configuration file descriptions
        $envOverview = @"
# $EnvName Environment

This directory contains the $EnvName environment configuration for the Terraform Lab project.

## Deployment Instructions

``````bash
# Step 1: Initialize Terraform working directory
terraform init

# Step 2: Review planned infrastructure changes
terraform plan -var-file="terraform.tfvars"

# Step 3: Apply infrastructure changes  
terraform apply -var-file="terraform.tfvars"
``````

## Configuration Files

- **main.tf**: Main configuration file containing module calls and resource definitions
- **variables.tf**: Variable declarations with descriptions and validation rules
- **outputs.tf**: Output definitions for resource references and integration points
- **terraform.tfvars**: Environment-specific variable values and configuration settings

"@
        
        # Phase 2: Generate documentation with terraform-docs
        # Create temporary header file with environment context
        $envOverview | Out-File -FilePath ".terraform-docs-header.md" -Encoding UTF8
        
        # Execute terraform-docs to combine header with generated content
        terraform-docs markdown table . --header-from ".terraform-docs-header.md" --output-file README.md
        
        # Phase 3: Clean up temporary files
        Remove-Item ".terraform-docs-header.md" -ErrorAction SilentlyContinue
        
        Write-Status "Documentation generated successfully for $EnvName environment"
    }
    catch {
        Write-Error "Failed to generate documentation for $EnvName environment: $_"
    }
    finally {
        # Always return to original directory
        Pop-Location
    }
}

function Update-RootReadme {
    Write-Status "Updating root README.md..."
    
    $rootReadme = @"
# Terraform Azure Lab Project

A comprehensive Terraform lab project demonstrating Azure infrastructure deployment with modular architecture.

## 🏗️ Architecture

This project implements a multi-tier Azure architecture with:

- **Networking**: VNet, subnets, NSGs, NAT Gateway
- **Compute**: VM Scale Sets, Load Balancers  
- **Database**: PostgreSQL Flexible Server with Key Vault integration
- **Security**: Network Security Groups, Key Vault for secrets

## 📁 Project Structure

``````
.
├── environments/          # Environment-specific configurations
│   ├── dev/              # Development environment
│   ├── staging/          # Staging environment
│   └── prod/            # Production environment
├── modules/              # Reusable Terraform modules
│   ├── networking/       # Network infrastructure
│   ├── compute/         # VM Scale Sets and Load Balancers
│   └── database/        # Database and Key Vault
├── tests/               # Terraform native tests
└── scripts/             # Automation scripts
``````

## 🚀 Quick Start

1. **Clone and navigate to environment:**
   ``````bash
   cd environments/dev
   ``````

2. **Configure variables:**
   ``````bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ``````

3. **Deploy infrastructure:**
   ``````bash
   terraform init
   terraform plan -var-file="terraform.tfvars"
   terraform apply -var-file="terraform.tfvars"
   ``````

## 🧪 Testing

Run Terraform native tests:
``````bash
cd tests/
terraform init
terraform test
``````

## 📚 Documentation

- [Learning Guide](LEARNING_GUIDE.md) - Step-by-step learning path
- Module Documentation:
"@

    # Add module links
    $moduleLinks = ""
    if (Test-Path "modules") {
        Get-ChildItem "modules" -Directory | ForEach-Object {
            $moduleLinks += "  - [$($_.Name) Module](modules/$($_.Name)/README.md)`n"
        }
    }
    
    # Add environment links  
    $envLinks = ""
    if (Test-Path "environments") {
        Get-ChildItem "environments" -Directory | ForEach-Object {
            $envLinks += "  - [$($_.Name) Environment](environments/$($_.Name)/README.md)`n"
        }
    }
    
    $fullReadme = $rootReadme + "`n" + $moduleLinks + "`n- Environment Documentation:`n" + $envLinks
    
    Set-Content -Path "README.md" -Value $fullReadme
    Write-Status "✅ Root README.md updated"
}

# Main execution
Write-Info "Terraform Documentation Generator"
Write-Info "================================"

# Check if terraform-docs is installed
if (-not (Test-TerraformDocs)) {
    if ($Install) {
        Install-TerraformDocs
        if (-not (Test-TerraformDocs)) {
            Write-Error "terraform-docs installation failed"
            exit 1
        }
    } else {
        Write-Error "terraform-docs not found. Run with -Install to install it."
        exit 1
    }
}

# Generate documentation based on target
switch ($Target) {
    'all' {
        Write-Status "Generating documentation for all modules and environments..."
        
        # Generate module docs
        if (Test-Path "modules") {
            Get-ChildItem "modules" -Directory | ForEach-Object {
                Generate-ModuleDocs $_.FullName $_.Name
            }
        }
        
        # Generate environment docs
        if (Test-Path "environments") {
            Get-ChildItem "environments" -Directory | ForEach-Object {
                Generate-EnvironmentDocs $_.FullName $_.Name
            }
        }
        
        # Update root README
        Update-RootReadme
    }
    
    'modules' {
        Write-Status "Generating documentation for modules only..."
        if (Test-Path "modules") {
            Get-ChildItem "modules" -Directory | ForEach-Object {
                Generate-ModuleDocs $_.FullName $_.Name
            }
        }
    }
    
    'environments' {
        Write-Status "Generating documentation for environments only..."
        if (Test-Path "environments") {
            Get-ChildItem "environments" -Directory | ForEach-Object {
                Generate-EnvironmentDocs $_.FullName $_.Name
            }
        }
    }
}

Write-Status "✅ Documentation generation complete!"
Write-Info "📖 Check the generated README.md files in each module/environment directory."