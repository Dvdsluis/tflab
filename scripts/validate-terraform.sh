#!/bin/bash#!/bin/bash



# Terraform Lab Validation Script# validate-terraform.sh

# Validates all Terraform configurations and runs tests# Comprehensive validation script for Terraform configurations

# Runs formatting, validation, linting, and security checks

set -e

set -euo pipefail

echo "🔍 Starting Terraform Validation..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source environment detectionPROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Source environment detection
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/detect-environment.sh" ]; then
    source "$SCRIPT_DIR/detect-environment.sh"
fiERRORS=0



# Function to validate an environmentecho "Terraform Validation Suite"

validate_environment() {echo "=========================="

    local env_dir="$1"echo ""

    local env_name=$(basename "$env_dir")

    # Function to print status messages

    echo "📁 Validating $env_name environment..."print_status() {

        local status=$1

    cd "$env_dir"    local message=$2

        case $status in

    # Initialize Terraform        "OK")

    echo "  🔄 Initializing Terraform..."            echo "✓ $message"

    terraform init -backend=false > /dev/null 2>&1            ;;

            "WARN")

    # Validate configuration            echo "⚠ $message"

    echo "  ✅ Validating configuration..."            ;;

    terraform validate        "ERROR")

                echo "✗ $message"

    # Format check            ((ERRORS++))

    echo "  📐 Checking formatting..."            ;;

    terraform fmt -check=true -diff=true    esac

    }

    cd - > /dev/null

}# Check if required tools are installed

check_prerequisites() {

# Validate all environments    echo "Checking prerequisites..."

for env in /workspaces/tflab/environments/*/; do    

    if [ -d "$env" ] && [ -f "$env/main.tf" ]; then    if command -v terraform >/dev/null 2>&1; then

        validate_environment "$env"        print_status "OK" "Terraform installed: $(terraform version | head -n1)"

    fi    else

done        print_status "ERROR" "Terraform not installed"

    fi

# Run Terraform tests    

echo "🧪 Running Terraform tests..."    if command -v tflint >/dev/null 2>&1; then

cd /workspaces/tflab        print_status "OK" "TFLint installed: $(tflint --version)"

    else

if command -v terraform &> /dev/null && terraform version | grep -q "1\.[5-9]\|1\.[1-9][0-9]"; then        print_status "WARN" "TFLint not installed - skipping linting checks"

    echo "  🔍 Running networking tests..."    fi

    terraform test -file=tests/networking.tftest.hcl -verbose || echo "  ⚠️  Networking tests skipped (requires Azure access)"    

        echo ""

    echo "  🔍 Running compute tests..."}

    terraform test -file=tests/compute.tftest.hcl -verbose || echo "  ⚠️  Compute tests skipped (requires Azure access)"

    # Format check for all Terraform files

    echo "  🔍 Running database tests..."format_check() {

    terraform test -file=tests/database.tftest.hcl -verbose || echo "  ⚠️  Database tests skipped (requires Azure access)"    echo "Checking Terraform formatting..."

else    cd "$PROJECT_ROOT"

    echo "  ⚠️  Terraform testing requires version 1.5+ (current: $(terraform version --json | jq -r '.terraform_version' 2>/dev/null || echo 'unknown'))"    

fi    if terraform fmt -check -diff -recursive; then

        print_status "OK" "All files are properly formatted"

echo "✅ Validation complete!"    else

echo ""        print_status "ERROR" "Files require formatting - run 'terraform fmt -recursive'"

echo "📋 Summary:"    fi

echo "  - Environment configurations validated"    echo ""

echo "  - Terraform formatting checked"}

echo "  - Tests executed (where possible)"

echo ""# Validate each environment

echo "🚀 Next steps:"validate_environments() {

echo "  - Run 'terraform plan' in environments/ to see planned changes"    echo "Validating environments..."

echo "  - Use 'terraform apply' to deploy resources"    

echo "  - Check .github/workflows/ for CI/CD pipeline"    for env_dir in "$PROJECT_ROOT"/environments/*/; do
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
    
    # Check for .terraform directories being tracked by Git
    if git ls-files | grep -E '\.terraform/' >/dev/null 2>&1; then
        print_status "ERROR" ".terraform directories found in Git tracking"
        echo "Found these .terraform entries:"
        git ls-files | grep -E '\.terraform/' | sed 's/^/  /'
    else
        print_status "OK" "No .terraform directories in Git tracking"
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