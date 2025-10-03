#!/bin/bash#!/bin/bash



# =============================================================================# =============================================================================

# Terraform Documentation Generator# Terraform Documentation Generator

# =============================================================================# =============================================================================

# Purpose: Automatically generate README.md documentation for Terraform modules# Purpose: Automatically generate README.md documentation for Terraform modules

#          and environments using the terraform-docs tool#          and environments using the terraform-docs tool

# Author: Infrastructure Team# Author: Infrastructure Team

# Usage: ./generate-docs.sh [--install] [all|modules|environments]# Usage: ./generate-docs.sh [--install] [all|modules|environments]

# =============================================================================# =============================================================================



# Exit immediately if any command fails - ensures script stops on errors# Exit immediately if any command fails - ensures script stops on errors

set -eset -e



# =============================================================================

# COLOR DEFINITIONS

# =============================================================================set -eecho "🔧 Generating Terraform documentation..."

# Define ANSI color codes for terminal output formatting

# These provide visual feedback during script execution

RED='\033[0;31m'     # Error messages

GREEN='\033[0;32m'   # Success messages  # Colors# Check if terraform-docs is installed

YELLOW='\033[1;33m'  # Warning messages

BLUE='\033[0;34m'    # Information messagesRED='\033[0;31m'if ! command -v terraform-docs &> /dev/null; then

NC='\033[0m'         # No Color - reset to default

GREEN='\033[0;32m'    echo "❌ terraform-docs is not installed. Please install it first:"

# =============================================================================

# OUTPUT FORMATTING FUNCTIONSYELLOW='\033[1;33m'    echo "   https://terraform-docs.io/user-guide/installation/"

# =============================================================================

# These functions standardize output formatting across the scriptBLUE='\033[0;34m'    exit 1

# Each function prefixes messages with appropriate visual indicators

NC='\033[0m' # No Colorfi

# Print success/status messages in green

print_status() {

    echo -e "${GREEN}[STATUS] $1${NC}"

}# Functions# Create docs directory if it doesn't exist



# Print error messages in redprint_status() {mkdir -p docs

print_error() {

    echo -e "${RED}[ERROR] $1${NC}"    echo -e "${GREEN}🔧 $1${NC}"

}

}# Function to generate docs for a module

# Print informational messages in blue

print_info() {generate_module_docs() {

    echo -e "${BLUE}[INFO] $1${NC}"

}print_error() {    local module_path=$1



# Print warning messages in yellow    echo -e "${RED}❌ $1${NC}"    local module_name=$(basename "$module_path")

print_warning() {

    echo -e "${YELLOW}[WARNING] $1${NC}"}    

}

    echo "📝 Generating docs for $module_name module..."

# =============================================================================

# TERRAFORM-DOCS DETECTION AND INSTALLATIONprint_info() {    

# =============================================================================

    echo -e "${BLUE}ℹ️  $1${NC}"    # Generate README for the module

# Function: check_terraform_docs

# Purpose: Verify if terraform-docs is installed and accessible in PATH}    terraform-docs markdown table "$module_path" > "$module_path/README.md"

# Returns: 0 if found, 1 if not found

check_terraform_docs() {    

    # Check if terraform-docs command exists and is executable

    if command -v terraform-docs &> /dev/null; thenprint_warning() {    # Generate detailed docs in the docs directory

        # Get version information for confirmation

        local version=$(terraform-docs --version 2>/dev/null)    echo -e "${YELLOW}⚠️  $1${NC}"    terraform-docs markdown document "$module_path" > "docs/$module_name.md"

        print_status "terraform-docs found: $version"

        return 0}    

    else

        return 1    echo "✅ Documentation generated for $module_name"

    fi

}check_terraform_docs() {}



# Function: install_terraform_docs    if command -v terraform-docs &> /dev/null; then

# Purpose: Install terraform-docs based on the detected operating system

# Note: Requires appropriate package manager or manual installation        local version=$(terraform-docs --version 2>/dev/null)# Generate docs for each module

install_terraform_docs() {

    print_status "Installing terraform-docs..."        print_status "terraform-docs found: $version"for module_dir in modules/*/; do

    

    # Detect the operating system using uname command        return 0    if [[ -d "$module_dir" ]]; then

    case "$(uname -s)" in

        # macOS systems    else        generate_module_docs "$module_dir"

        Darwin*)

            # Check if Homebrew package manager is available        return 1    fi

            if command -v brew &> /dev/null; then

                print_status "Installing via Homebrew..."    fidone

                brew install terraform-docs

            else}

                print_error "Homebrew not found. Please install terraform-docs manually."

                exit 1# Generate docs for environments

            fi

            ;;install_terraform_docs() {for env_dir in environments/*/; do

        # Linux systems

        Linux*)    print_status "Installing terraform-docs..."    if [[ -d "$env_dir" ]]; then

            # Try different package managers based on availability

            if command -v apt-get &> /dev/null; then            env_name=$(basename "$env_dir")

                print_status "Installing via direct download (requires sudo)..."

                # Download and extract terraform-docs binary    # Detect OS        echo "📝 Generating docs for $env_name environment..."

                curl -sSLo ./terraform-docs.tar.gz https://terraform-docs.io/dl/v0.16.0/terraform-docs-v0.16.0-$(uname)-amd64.tar.gz

                tar -xzf terraform-docs.tar.gz    case "$(uname -s)" in        terraform-docs markdown table "$env_dir" > "$env_dir/README.md"

                chmod +x terraform-docs

                sudo mv terraform-docs /usr/local/bin/        Darwin*)        terraform-docs markdown document "$env_dir" > "docs/environment-$env_name.md"

                rm terraform-docs.tar.gz

            elif command -v yum &> /dev/null; then            if command -v brew &> /dev/null; then        echo "✅ Documentation generated for $env_name environment"

                print_status "Installing via direct download (requires sudo)..."

                # Same installation process for RPM-based systems                print_status "Installing via Homebrew..."    fi

                curl -sSLo ./terraform-docs.tar.gz https://terraform-docs.io/dl/v0.16.0/terraform-docs-v0.16.0-$(uname)-amd64.tar.gz

                tar -xzf terraform-docs.tar.gz                brew install terraform-docsdone

                chmod +x terraform-docs

                sudo mv terraform-docs /usr/local/bin/            else

                rm terraform-docs.tar.gz

            else                print_error "Homebrew not found. Please install terraform-docs manually."# Generate main documentation index

                print_error "Package manager not supported. Please install terraform-docs manually."

                exit 1                exit 1cat > docs/README.md << 'EOF'

            fi

            ;;            fi# Terraform Lab Documentation

        # Windows systems (Git Bash, MSYS2, Cygwin)

        MINGW*|MSYS*|CYGWIN*)            ;;

            print_info "Windows detected. Please use the PowerShell script or install terraform-docs manually:"

            print_info "  - Via GitHub releases: https://github.com/terraform-docs/terraform-docs/releases"        Linux*)This directory contains auto-generated documentation for all Terraform modules and environments.

            print_info "  - Via winget: winget install terraform-docs"

            print_info "  - Via Chocolatey: choco install terraform-docs"            if command -v apt-get &> /dev/null; then

            exit 1

            ;;                print_status "Installing via apt (requires sudo)..."## Modules

        # Unsupported systems

        *)                curl -sSLo ./terraform-docs.tar.gz https://terraform-docs.io/dl/v0.16.0/terraform-docs-v0.16.0-$(uname)-amd64.tar.gz

            print_error "Unsupported OS. Please install terraform-docs manually."

            exit 1                tar -xzf terraform-docs.tar.gz- [Networking Module](networking.md) - VPC, subnets, routing, and security

            ;;

    esac                chmod +x terraform-docs- [Compute Module](compute.md) - EC2 instances, Auto Scaling, and Load Balancers  

}

                sudo mv terraform-docs /usr/local/bin/- [Database Module](database.md) - RDS instances with security and monitoring

# =============================================================================

# DOCUMENTATION GENERATION FUNCTIONS                rm terraform-docs.tar.gz

# =============================================================================

            elif command -v yum &> /dev/null; then## Environments

# Function: generate_module_docs

# Purpose: Generate documentation for a specific Terraform module                print_status "Installing via direct download (requires sudo)..."

# Parameters: $1 = module path, $2 = module name

generate_module_docs() {                curl -sSLo ./terraform-docs.tar.gz https://terraform-docs.io/dl/v0.16.0/terraform-docs-v0.16.0-$(uname)-amd64.tar.gz- [Development Environment](environment-dev.md) - Development deployment configuration

    local module_path="$1"

    local module_name="$2"                tar -xzf terraform-docs.tar.gz

    

    print_status "Generating docs for module: $module_name"                chmod +x terraform-docs## Learning Resources

    

    # Create module-specific configuration header for README                sudo mv terraform-docs /usr/local/bin/

    # This provides context and usage examples for each module

    local module_config=$(cat <<EOF                rm terraform-docs.tar.gz### Module Composition Patterns

# $module_name Module

            else

This module provides $module_name functionality for the Terraform Lab project.

                print_error "Package manager not supported. Please install terraform-docs manually."The modules in this lab demonstrate several important Terraform patterns:

## Usage

                exit 1

\`\`\`hcl

module "$module_name" {            fi1. **Input Validation**: All variables include validation rules

  source = "../../modules/$module_name"

              ;;2. **Output Organization**: Comprehensive outputs for module composition

  # Required variables

  name_prefix         = "my-project"        MINGW*|MSYS*|CYGWIN*)3. **Tagging Strategy**: Consistent tagging across all resources

  resource_group_name = "my-rg"

  location           = "East US"            print_info "Windows detected. Please use the PowerShell script or install terraform-docs manually:"4. **Security Best Practices**: Least privilege security groups and network isolation

  

  # Additional configuration...            print_info "  - Via GitHub releases: https://github.com/terraform-docs/terraform-docs/releases"5. **Conditional Resources**: Resources that can be enabled/disabled via variables

}

\`\`\`            print_info "  - Via winget: winget install terraform-docs"



EOF            print_info "  - Via Chocolatey: choco install terraform-docs"### Variable Inheritance

)

                exit 1

    # Change to module directory for terraform-docs execution

    pushd "$module_path" > /dev/null            ;;Notice how variables flow from the root module to child modules:

    

    # Create temporary header file for terraform-docs to use        *)

    echo "$module_config" > .terraform-docs-header.md

                print_error "Unsupported OS. Please install terraform-docs manually."```

    # Generate documentation using terraform-docs

    # - markdown table: Output format as markdown tables            exit 1Root Environment (dev/) 

    # - --header-from: Include custom header from file

    # - --output-file: Write to README.md            ;;  ├── Defines high-level configuration

    if terraform-docs markdown table . --header-from .terraform-docs-header.md --output-file README.md; then

        print_status "Documentation generated successfully for $module_name"    esac  ├── Passes values to modules

    else

        print_error "Failed to generate docs for $module_name"}  └── Modules use their own variable definitions

    fi

    ```

    # Clean up temporary files

    rm -f .terraform-docs-header.mdgenerate_module_docs() {

    

    # Return to previous directory    local module_path="$1"### Testing Strategy

    popd > /dev/null

}    local module_name="$2"



# Function: generate_environment_docs    The test suite demonstrates:

# Purpose: Generate documentation for a specific environment configuration

# Parameters: $1 = environment path, $2 = environment name    print_status "Generating docs for module: $module_name"

generate_environment_docs() {

    local env_path="$1"    - Unit testing individual modules

    local env_name="$2"

        # Create module-specific config- Integration testing full environments

    print_status "Generating docs for environment: $env_name"

        local module_config=$(cat <<EOF- Validation of AWS resource creation

    # Change to environment directory

    pushd "$env_path" > /dev/null# $module_name Module- Output verification

    

    # Create environment-specific overview content

    # This provides deployment instructions and file descriptions

    local env_overview=$(cat <<EOFThis module provides $module_name functionality for the Terraform Lab project.### Documentation Generation

# $env_name Environment



This directory contains the $env_name environment configuration for the Terraform Lab project.

## UsageDocumentation is automatically generated using terraform-docs:

## Deployment



\`\`\`bash

# Initialize Terraform working directory\`\`\`hcl```bash

terraform init

module "$module_name" {./scripts/generate-docs.sh

# Review planned changes

terraform plan -var-file="terraform.tfvars"  source = "../../modules/$module_name"```



# Apply infrastructure changes  

terraform apply -var-file="terraform.tfvars"

\`\`\`  # Required variablesThis creates:



## Configuration Files  name_prefix         = "my-project"- README.md files in each module/environment directory



- **main.tf**: Main configuration file with module calls  resource_group_name = "my-rg"- Detailed documentation in the docs/ directory

- **variables.tf**: Variable declarations with descriptions

- **outputs.tf**: Output definitions for resource references  location           = "East US"- Complete variable and output references

- **terraform.tfvars**: Environment-specific variable values

  EOF

EOF

)  # Additional configuration...

    

    # Generate documentation with custom environment header}echo ""

    echo "$env_overview" > .terraform-docs-header.md

    \`\`\`echo "🎉 Documentation generation complete!"

    # Run terraform-docs to generate README with environment context

    if terraform-docs markdown table . --header-from .terraform-docs-header.md --output-file README.md; thenecho ""

        print_status "Documentation generated successfully for $env_name environment"

    elseEOFecho "📂 Generated files:"

        print_error "Failed to generate docs for $env_name environment"

    fi)echo "   - Module READMEs: modules/*/README.md"

    

    # Clean up temporary header file    echo "   - Environment READMEs: environments/*/README.md"

    rm -f .terraform-docs-header.md

        # Generate documentationecho "   - Detailed docs: docs/*.md"

    # Return to previous directory

    popd > /dev/null    pushd "$module_path" > /dev/nullecho ""

}

    echo "🔗 View the main documentation index: docs/README.md"

# Function: update_root_readme    # Create a temporary header file

# Purpose: Create/update the main project README with navigation links    echo "$module_config" > .terraform-docs-header.md

update_root_readme() {    

    print_status "Updating root README.md..."    if terraform-docs markdown table . --header-from .terraform-docs-header.md --output-file README.md; then

            print_status "✅ Documentation generated for $module_name"

    # Create comprehensive project overview content    else

    # This serves as the main entry point for the project        print_error "Failed to generate docs for $module_name"

    local root_readme=$(cat <<'EOF'    fi

# Terraform Azure Lab Project    

    # Clean up

A comprehensive Terraform lab project demonstrating Azure infrastructure deployment with modular architecture.    rm -f .terraform-docs-header.md

    

## Architecture Overview    popd > /dev/null

}

This project implements a multi-tier Azure architecture with:

generate_environment_docs() {

- **Networking**: Virtual Networks, subnets, Network Security Groups, NAT Gateway    local env_path="$1"

- **Compute**: Virtual Machine Scale Sets, Load Balancers for web and application tiers    local env_name="$2"

- **Database**: PostgreSQL Flexible Server with Azure Key Vault integration    

- **Security**: Network Security Groups, Key Vault for secrets management    print_status "Generating docs for environment: $env_name"

    

## Project Structure    pushd "$env_path" > /dev/null

    

```    # Create environment overview

.    local env_overview=$(cat <<EOF

├── environments/          # Environment-specific configurations# $env_name Environment

│   ├── dev/              # Development environment

│   ├── staging/          # Staging environmentThis directory contains the $env_name environment configuration for the Terraform Lab project.

│   └── prod/            # Production environment

├── modules/              # Reusable Terraform modules## Deployment

│   ├── networking/       # Network infrastructure components

│   ├── compute/         # VM Scale Sets and Load Balancers\`\`\`bash

│   └── database/        # Database and Key Vault resources# Initialize and apply

├── tests/               # Terraform native test configurationsterraform init

└── scripts/             # Automation and documentation scriptsterraform plan -var-file="terraform.tfvars"

```terraform apply -var-file="terraform.tfvars"

\`\`\`

## Quick Start Guide

## Configuration Files

### 1. Environment Setup

```bash- **main.tf**: Main configuration file with module calls

# Navigate to desired environment- **variables.tf**: Variable declarations

cd environments/dev- **outputs.tf**: Output definitions  

```- **terraform.tfvars**: Environment-specific variable values



### 2. ConfigurationEOF

```bash)

# Copy and customize variables file    

cp terraform.tfvars.example terraform.tfvars    # Generate docs with custom header

# Edit terraform.tfvars with your specific values    echo "$env_overview" > .terraform-docs-header.md

```    

    if terraform-docs markdown table . --header-from .terraform-docs-header.md --output-file README.md; then

### 3. Infrastructure Deployment        print_status "✅ Documentation generated for $env_name environment"

```bash    else

# Initialize Terraform working directory        print_error "Failed to generate docs for $env_name environment"

terraform init    fi

    

# Review planned infrastructure changes    # Clean up

terraform plan -var-file="terraform.tfvars"    rm -f .terraform-docs-header.md

    

# Deploy infrastructure    popd > /dev/null

terraform apply -var-file="terraform.tfvars"}

```

update_root_readme() {

## Testing Framework    print_status "Updating root README.md..."

    

Execute Terraform native tests to validate configurations:    local root_readme=$(cat <<'EOF'

```bash# Terraform Azure Lab Project

cd tests/

terraform initA comprehensive Terraform lab project demonstrating Azure infrastructure deployment with modular architecture.

terraform test

```## 🏗️ Architecture



## Documentation StructureThis project implements a multi-tier Azure architecture with:



- [Learning Guide](LEARNING_GUIDE.md) - Comprehensive step-by-step learning path- **Networking**: VNet, subnets, NSGs, NAT Gateway

- Module Documentation:- **Compute**: VM Scale Sets, Load Balancers  

EOF- **Database**: PostgreSQL Flexible Server with Key Vault integration

)- **Security**: Network Security Groups, Key Vault for secrets

    

    # Dynamically build module documentation links## 📁 Project Structure

    local module_links=""

    if [ -d "modules" ]; then```

        # Iterate through each module directory.

        for module_dir in modules/*/; do├── environments/          # Environment-specific configurations

            if [ -d "$module_dir" ]; then│   ├── dev/              # Development environment

                local module_name=$(basename "$module_dir")│   ├── staging/          # Staging environment

                module_links+="  - [$module_name Module](modules/$module_name/README.md)"$'\n'│   └── prod/            # Production environment

            fi├── modules/              # Reusable Terraform modules

        done│   ├── networking/       # Network infrastructure

    fi│   ├── compute/         # VM Scale Sets and Load Balancers

    │   └── database/        # Database and Key Vault

    # Dynamically build environment documentation links├── tests/               # Terraform native tests

    local env_links=""└── scripts/             # Automation scripts

    if [ -d "environments" ]; then```

        # Iterate through each environment directory

        for env_dir in environments/*/; do## 🚀 Quick Start

            if [ -d "$env_dir" ]; then

                local env_name=$(basename "$env_dir")1. **Clone and navigate to environment:**

                env_links+="  - [$env_name Environment](environments/$env_name/README.md)"$'\n'   ```bash

            fi   cd environments/dev

        done   ```

    fi

    2. **Configure variables:**

    # Combine all content into final README   ```bash

    local full_readme="$root_readme"$'\n'"$module_links"$'\n'"- Environment Documentation:"$'\n'"$env_links"   cp terraform.tfvars.example terraform.tfvars

       # Edit terraform.tfvars with your values

    # Write the complete README to file   ```

    echo "$full_readme" > README.md

    print_status "Root README.md updated successfully"3. **Deploy infrastructure:**

}   ```bash

   terraform init

# =============================================================================   terraform plan -var-file="terraform.tfvars"

# HELP AND USAGE INFORMATION   terraform apply -var-file="terraform.tfvars"

# =============================================================================   ```



# Function: show_help## 🧪 Testing

# Purpose: Display usage information and available options

show_help() {Run Terraform native tests:

    cat <<EOF```bash

Terraform Documentation Generatorcd tests/

terraform init

DESCRIPTION:terraform test

    Automatically generates comprehensive documentation for Terraform modules```

    and environments using terraform-docs tool. Creates README.md files with

    input variables, output values, and resource information.## 📚 Documentation



USAGE: - [Learning Guide](LEARNING_GUIDE.md) - Step-by-step learning path

    $0 [OPTIONS] [TARGET]- Module Documentation:

EOF

OPTIONS:)

    -i, --install       Install terraform-docs if not present on system    

    -h, --help         Display this help message and exit    # Add module links

    local module_links=""

TARGET:    if [ -d "modules" ]; then

    all                Generate documentation for modules and environments (default)        for module_dir in modules/*/; do

    modules            Generate documentation for modules only            if [ -d "$module_dir" ]; then

    environments       Generate documentation for environments only                local module_name=$(basename "$module_dir")

                module_links+="  - [$module_name Module](modules/$module_name/README.md)"$'\n'

EXAMPLES:            fi

    $0                 # Generate all documentation        done

    $0 modules         # Generate module docs only    fi

    $0 environments    # Generate environment docs only    

    $0 --install all   # Install terraform-docs and generate all docs    # Add environment links  

    local env_links=""

REQUIREMENTS:    if [ -d "environments" ]; then

    - terraform-docs tool (will be installed if --install flag is used)        for env_dir in environments/*/; do

    - Proper Terraform module structure with .tf files            if [ -d "$env_dir" ]; then

    - Write permissions in target directories                local env_name=$(basename "$env_dir")

                env_links+="  - [$env_name Environment](environments/$env_name/README.md)"$'\n'

EOF            fi

}        done

    fi

# =============================================================================    

# ARGUMENT PARSING AND VALIDATION    local full_readme="$root_readme"$'\n'"$module_links"$'\n'"- Environment Documentation:"$'\n'"$env_links"

# =============================================================================    

    echo "$full_readme" > README.md

# Initialize default values    print_status "✅ Root README.md updated"

TARGET="all"}

INSTALL=false

show_help() {

# Process command line arguments    cat <<EOF

while [[ $# -gt 0 ]]; doTerraform Documentation Generator

    case $1 in

        -i|--install)Usage: $0 [OPTIONS] [TARGET]

            INSTALL=true

            shiftOPTIONS:

            ;;    -i, --install       Install terraform-docs if not present

        -h|--help)    -h, --help         Show this help message

            show_help

            exit 0TARGET:

            ;;    all                Generate docs for all modules and environments (default)

        all|modules|environments)    modules            Generate docs for modules only

            TARGET="$1"    environments       Generate docs for environments only

            shift

            ;;Examples:

        *)    $0                 # Generate all documentation

            print_error "Unknown option: $1"    $0 modules         # Generate module docs only

            show_help    $0 environments    # Generate environment docs only

            exit 1    $0 --install all   # Install terraform-docs and generate all docs

            ;;

    esacEOF

done}



# =============================================================================# Parse arguments

# MAIN EXECUTION LOGICTARGET="all"

# =============================================================================INSTALL=false



print_info "Terraform Documentation Generator"while [[ $# -gt 0 ]]; do

print_info "================================"    case $1 in

        -i|--install)

# Phase 1: Verify terraform-docs installation            INSTALL=true

if ! check_terraform_docs; then            shift

    if [ "$INSTALL" = true ]; then            ;;

        # Attempt to install terraform-docs        -h|--help)

        install_terraform_docs            show_help

        # Verify installation was successful            exit 0

        if ! check_terraform_docs; then            ;;

            print_error "terraform-docs installation failed"        all|modules|environments)

            exit 1            TARGET="$1"

        fi            shift

    else            ;;

        print_error "terraform-docs not found. Run with --install to install it."        *)

        exit 1            print_error "Unknown option: $1"

    fi            show_help

fi            exit 1

            ;;

# Phase 2: Execute documentation generation based on target selection    esac

case "$TARGET" indone

    "all")

        print_status "Generating documentation for all modules and environments..."# Main execution

        print_info "Terraform Documentation Generator"

        # Generate documentation for all modulesprint_info "================================"

        if [ -d "modules" ]; then

            for module_dir in modules/*/; do# Check if terraform-docs is installed

                if [ -d "$module_dir" ]; thenif ! check_terraform_docs; then

                    module_name=$(basename "$module_dir")    if [ "$INSTALL" = true ]; then

                    generate_module_docs "$module_dir" "$module_name"        install_terraform_docs

                fi        if ! check_terraform_docs; then

            done            print_error "terraform-docs installation failed"

        fi            exit 1

                fi

        # Generate documentation for all environments    else

        if [ -d "environments" ]; then        print_error "terraform-docs not found. Run with --install to install it."

            for env_dir in environments/*/; do        exit 1

                if [ -d "$env_dir" ]; then    fi

                    env_name=$(basename "$env_dir")fi

                    generate_environment_docs "$env_dir" "$env_name"

                fi# Generate documentation based on target

            donecase "$TARGET" in

        fi    "all")

                print_status "Generating documentation for all modules and environments..."

        # Update root project README with navigation        

        update_root_readme        # Generate module docs

        ;;        if [ -d "modules" ]; then

                    for module_dir in modules/*/; do

    "modules")                if [ -d "$module_dir" ]; then

        print_status "Generating documentation for modules only..."                    module_name=$(basename "$module_dir")

        if [ -d "modules" ]; then                    generate_module_docs "$module_dir" "$module_name"

            for module_dir in modules/*/; do                fi

                if [ -d "$module_dir" ]; then            done

                    module_name=$(basename "$module_dir")        fi

                    generate_module_docs "$module_dir" "$module_name"        

                fi        # Generate environment docs

            done        if [ -d "environments" ]; then

        fi            for env_dir in environments/*/; do

        ;;                if [ -d "$env_dir" ]; then

                            env_name=$(basename "$env_dir")

    "environments")                    generate_environment_docs "$env_dir" "$env_name"

        print_status "Generating documentation for environments only..."                fi

        if [ -d "environments" ]; then            done

            for env_dir in environments/*/; do        fi

                if [ -d "$env_dir" ]; then        

                    env_name=$(basename "$env_dir")        # Update root README

                    generate_environment_docs "$env_dir" "$env_name"        update_root_readme

                fi        ;;

            done        

        fi    "modules")

        ;;        print_status "Generating documentation for modules only..."

esac        if [ -d "modules" ]; then

            for module_dir in modules/*/; do

# Phase 3: Completion notification                if [ -d "$module_dir" ]; then

print_status "Documentation generation completed successfully"                    module_name=$(basename "$module_dir")

print_info "Generated README.md files are available in each module and environment directory"                    generate_module_docs "$module_dir" "$module_name"
                fi
            done
        fi
        ;;
        
    "environments")
        print_status "Generating documentation for environments only..."
        if [ -d "environments" ]; then
            for env_dir in environments/*/; do
                if [ -d "$env_dir" ]; then
                    env_name=$(basename "$env_dir")
                    generate_environment_docs "$env_dir" "$env_name"
                fi
            done
        fi
        ;;
esac

print_status "✅ Documentation generation complete!"
print_info "📖 Check the generated README.md files in each module/environment directory."