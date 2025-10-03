#!/bin/bash

# =============================================================================
# Git Pre-Commit Hook for Terraform Documentation
# =============================================================================
# Purpose: Automatically generate Terraform documentation when .tf files change
# Trigger: Executes before each git commit containing Terraform files
# Process: Detects changed modules/environments, generates docs, stages updates
# =============================================================================

# Exit on any error to prevent commits with documentation generation failures
set -e

# =============================================================================
# COLOR DEFINITIONS FOR OUTPUT FORMATTING
# =============================================================================
# ANSI color codes for different types of messages during hook execution
RED='\033[0;31m'     # Error messages and failures
GREEN='\033[0;32m'   # Success messages and completions  
YELLOW='\033[1;33m'  # Warning messages and skipped actions
BLUE='\033[0;34m'    # Information and status messages
NC='\033[0m'         # No Color - reset to default terminal color

# =============================================================================
# OUTPUT FORMATTING FUNCTIONS  
# =============================================================================
# Standardized message formatting for consistent hook output

# Display success and progress messages
print_status() {
    echo -e "${GREEN}[HOOK-STATUS] $1${NC}"
}

# Display error messages for failures
print_error() {
    echo -e "${RED}[HOOK-ERROR] $1${NC}"
}

# Display informational messages
print_info() {
    echo -e "${BLUE}[HOOK-INFO] $1${NC}"
}

# Display warning messages for non-critical issues
print_warning() {
    echo -e "${YELLOW}[HOOK-WARNING] $1${NC}"
}

# =============================================================================
# PREREQUISITE VALIDATION
# =============================================================================

# Phase 1: Check if terraform-docs tool is available
# If not installed, skip documentation generation with informative message
if ! command -v terraform-docs &> /dev/null; then
    print_warning "terraform-docs not found. Skipping automatic documentation generation."
    print_info "Install terraform-docs to enable automatic documentation generation:"
    print_info "  https://terraform-docs.io/user-guide/installation/"
    # Exit with success code to allow commit to proceed
    exit 0
fi

# =============================================================================
# FILE CHANGE DETECTION AND ANALYSIS
# =============================================================================

# Phase 2: Get list of files staged for commit
# Only process Added, Copied, and Modified files (ACM filter)
staged_files=$(git diff --cached --name-only --diff-filter=ACM)

# Initialize tracking variables for change detection
terraform_files_changed=false
modules_changed=()      # Array to track which modules have changes
environments_changed=() # Array to track which environments have changes

# Phase 3: Analyze staged files to identify Terraform-related changes
for file in $staged_files; do
    # Check if file is a Terraform configuration file (.tf or .tfvars)
    if [[ $file =~ \.(tf|tfvars)$ ]]; then
        terraform_files_changed=true
        
        # Phase 3a: Detect module changes using regex pattern matching
        # Pattern: modules/[module-name]/... captures module name in BASH_REMATCH[1]
        if [[ $file =~ ^modules/([^/]+)/ ]]; then
            module_name="${BASH_REMATCH[1]}"
            # Add to modules_changed array if not already present (avoid duplicates)
            if [[ ! " ${modules_changed[@]} " =~ " ${module_name} " ]]; then
                modules_changed+=("$module_name")
            fi
        fi
        
        # Phase 3b: Detect environment changes using regex pattern matching  
        # Pattern: environments/[env-name]/... captures environment name
        if [[ $file =~ ^environments/([^/]+)/ ]]; then
            env_name="${BASH_REMATCH[1]}"
            # Add to environments_changed array if not already present
            if [[ ! " ${environments_changed[@]} " =~ " ${env_name} " ]]; then
                environments_changed+=("$env_name")
            fi
        fi
    fi
done

# Phase 4: Early exit if no Terraform files are being committed
# This prevents unnecessary processing when commits don't affect infrastructure
if [ "$terraform_files_changed" = false ]; then
    exit 0
fi

# Phase 5: Notify user that documentation generation is starting
print_info "Terraform files detected in commit. Initiating documentation generation..."

# =============================================================================
# DOCUMENTATION GENERATION FUNCTION
# =============================================================================

# Function: generate_docs_for_dir
# Purpose: Generate documentation for a specific module or environment directory
# Parameters: 
#   $1 = dir_path (full path to directory)
#   $2 = dir_name (name of module/environment) 
#   $3 = dir_type (type: "module" or "environment")
# Process: Changes to directory, runs terraform-docs, stages results
generate_docs_for_dir() {
    local dir_path="$1"
    local dir_name="$2" 
    local dir_type="$3"
    
    # Validate that target directory exists before processing
    if [ -d "$dir_path" ]; then
        print_status "Updating documentation for $dir_type: $dir_name"
        
        # Phase 1: Change to target directory for proper terraform-docs context
        pushd "$dir_path" > /dev/null
        
        # Phase 2: Generate documentation using terraform-docs
        # - markdown table: Format output as markdown tables
        # - --output-file README.md: Write results directly to README.md
        # - Suppress stdout/stderr to avoid cluttering commit output
        if terraform-docs markdown table . --output-file README.md > /dev/null 2>&1; then
            
            # Phase 3: Stage the generated README.md for commit inclusion
            # Only stage if file exists and was successfully created/modified
            if [ -f "README.md" ]; then
                git add README.md
                print_status "Documentation updated and staged for $dir_name"
            fi
        else
            # Non-critical failure - warn but don't block commit
            print_warning "Failed to generate documentation for $dir_name"
        fi
        
        # Phase 4: Return to original directory
        popd > /dev/null
    fi
}

# =============================================================================
# MAIN DOCUMENTATION GENERATION EXECUTION
# =============================================================================

# Phase 6: Generate documentation for all changed modules
# Iterate through modules that have file changes and update their documentation
for module in "${modules_changed[@]}"; do
    generate_docs_for_dir "modules/$module" "$module" "module"
done

# Phase 7: Generate documentation for all changed environments  
# Iterate through environments that have file changes and update their documentation
for env in "${environments_changed[@]}"; do
    generate_docs_for_dir "environments/$env" "$env" "environment"
done

# Phase 8: Update root README if any infrastructure components changed
# The root README provides navigation and project overview, updated when modules/envs change
if [ ${#modules_changed[@]} -gt 0 ] || [ ${#environments_changed[@]} -gt 0 ]; then
    print_status "Updating root project README.md..."
    
    # Phase 8a: Execute full documentation generation script for root README
    # Check if documentation generation script exists before execution
    if [ -f "scripts/generate-docs.sh" ]; then
        # Run script silently to update root README structure and navigation
        # Use '|| true' to prevent commit failure if script has minor issues
        bash scripts/generate-docs.sh > /dev/null 2>&1 || true
        
        # Phase 8b: Stage root README if it was successfully generated/modified
        if [ -f "README.md" ]; then
            git add README.md
            print_status "Root README.md updated and staged"
        fi
    fi
fi

# =============================================================================
# COMPLETION AND EXIT
# =============================================================================

# Phase 9: Notify completion and allow commit to proceed
print_info "Automatic documentation generation completed successfully"
print_info "Generated README.md files have been staged for commit"

# Exit with success code to allow git commit to proceed normally
exit 0