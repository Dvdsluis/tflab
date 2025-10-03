#!/bin/bash

# validate-terraform.sh
# Comprehensive validation script for Terraform configurations
# Runs formatting, validation, linting, and security checks

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ERRORS=0

echo "Terraform Validation Suite"
echo "=========================="
echo ""

# Function to print status messages
print_status() {
    local status=$1
    local message=$2
    case $status in
        "OK")
            echo "✓ $message"
            ;;
        "WARN")
            echo "⚠ $message"
            ;;
        "ERROR")
            echo "✗ $message"
            ((ERRORS++))
            ;;
    esac
}

# Check if required tools are installed
check_prerequisites() {
    echo "Checking prerequisites..."
    
    if command -v terraform >/dev/null 2>&1; then
        print_status "OK" "Terraform installed: $(terraform version | head -n1)"
    else
        print_status "ERROR" "Terraform not installed"
    fi
    
    if command -v tflint >/dev/null 2>&1; then
        print_status "OK" "TFLint installed: $(tflint --version)"
    else
        print_status "WARN" "TFLint not installed - skipping linting checks"
    fi
    
    echo ""
}

# Format check for all Terraform files
format_check() {
    echo "Checking Terraform formatting..."
    cd "$PROJECT_ROOT"
    
    if terraform fmt -check -diff -recursive; then
        print_status "OK" "All files are properly formatted"
    else
        print_status "ERROR" "Files require formatting - run 'terraform fmt -recursive'"
    fi
    echo ""
}

# Validate each environment
validate_environments() {
    echo "Validating environments..."
    
    for env_dir in "$PROJECT_ROOT"/environments/*/; do
        if [[ -d "$env_dir" ]]; then
            env_name=$(basename "$env_dir")
            echo "Validating $env_name environment..."
            
            cd "$env_dir"
            
            # Initialize without backend to avoid state conflicts
            if terraform init -backend=false >/dev/null 2>&1; then
                print_status "OK" "$env_name: Initialization successful"
            else
                print_status "ERROR" "$env_name: Initialization failed"
                continue
            fi
            
            # Validate configuration
            if terraform validate >/dev/null 2>&1; then
                print_status "OK" "$env_name: Configuration valid"
            else
                print_status "ERROR" "$env_name: Configuration invalid"
            fi
        fi
    done
    echo ""
}

# Run TFLint on modules and environments
run_tflint() {
    if ! command -v tflint >/dev/null 2>&1; then
        print_status "WARN" "TFLint not available - skipping linting"
        return
    fi
    
    echo "Running TFLint..."
    cd "$PROJECT_ROOT"
    
    # Initialize TFLint
    if tflint --init >/dev/null 2>&1; then
        print_status "OK" "TFLint initialized"
    else
        print_status "WARN" "TFLint initialization failed"
        return
    fi
    
    # Lint modules
    for module_dir in "$PROJECT_ROOT"/modules/*/; do
        if [[ -d "$module_dir" ]]; then
            module_name=$(basename "$module_dir")
            cd "$module_dir"
            
            if tflint >/dev/null 2>&1; then
                print_status "OK" "Module $module_name: No linting issues"
            else
                print_status "ERROR" "Module $module_name: Linting issues found"
            fi
        fi
    done
    
    # Lint environments
    for env_dir in "$PROJECT_ROOT"/environments/*/; do
        if [[ -d "$env_dir" ]]; then
            env_name=$(basename "$env_dir")
            cd "$env_dir"
            
            if tflint >/dev/null 2>&1; then
                print_status "OK" "Environment $env_name: No linting issues"
            else
                print_status "ERROR" "Environment $env_name: Linting issues found"
            fi
        fi
    done
    echo ""
}

# Check for sensitive files in Git
check_sensitive_files() {
    echo "Checking for sensitive files..."
    cd "$PROJECT_ROOT"
    
    # Check if any sensitive files are staged
    if git ls-files | grep -E '\.(tfstate|tfvars)$' >/dev/null 2>&1; then
        print_status "ERROR" "Sensitive files found in Git tracking"
        echo "Found these sensitive files:"
        git ls-files | grep -E '\.(tfstate|tfvars)$' | sed 's/^/  /'
    else
        print_status "OK" "No sensitive files in Git tracking"
    fi
    
    # Check for .terraform directories
    if find . -name ".terraform" -type d | grep -v ".git" >/dev/null 2>&1; then
        print_status "WARN" ".terraform directories found (should be in .gitignore)"
    else
        print_status "OK" "No .terraform directories tracked"
    fi
    echo ""
}

# Check variable file examples exist
check_examples() {
    echo "Checking example files..."
    
    for env_dir in "$PROJECT_ROOT"/environments/*/; do
        if [[ -d "$env_dir" ]]; then
            env_name=$(basename "$env_dir")
            example_file="$env_dir/terraform.tfvars.example"
            
            if [[ -f "$example_file" ]]; then
                print_status "OK" "$env_name: Example variables file exists"
            else
                print_status "WARN" "$env_name: No example variables file found"
            fi
        fi
    done
    echo ""
}

# Main execution
main() {
    check_prerequisites
    format_check
    validate_environments
    run_tflint
    check_sensitive_files
    check_examples
    
    echo "Validation Summary"
    echo "=================="
    if [[ $ERRORS -eq 0 ]]; then
        echo "✓ All validations passed successfully!"
        exit 0
    else
        echo "✗ $ERRORS error(s) found. Please fix before committing."
        exit 1
    fi
}

# Run main function
main "$@"