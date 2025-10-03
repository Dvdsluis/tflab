#!/bin/bash

# Terraform Documentation Generation Script
# Generates documentation for all modules and environments

set -e

echo "Terraform Documentation Generation"
echo "=================================="

# Check if terraform-docs is installed
if ! command -v terraform-docs &> /dev/null; then
    echo "Error: terraform-docs is not installed"
    echo "Please install it from: https://terraform-docs.io/user-guide/installation/"
    exit 1
fi

echo "Using terraform-docs version: $(terraform-docs --version)"
echo

# Generate documentation for each module
echo
echo "Generating module documentation..."
for module in modules/*/; do
    if [ -d "$module" ]; then
        module_name=$(basename "$module")
        echo "  Processing module: $module_name"
        cd "$module"
        terraform-docs markdown table --output-file README.md .
        cd - > /dev/null
        echo "  ✓ $module_name documentation updated"
    fi
done

# Generate documentation for each environment
echo
echo "Generating environment documentation..."
for env in environments/*/; do
    if [ -d "$env" ]; then
        env_name=$(basename "$env")
        echo "  Processing environment: $env_name"
        cd "$env"
        terraform-docs markdown table --output-file README.md .
        cd - > /dev/null
        echo "  ✓ $env_name documentation updated"
    fi
done

echo
echo "Documentation generation completed successfully!"
echo
echo "Files updated:"
find modules -name "README.md" -exec echo "- {}" \;
find environments -name "README.md" -exec echo "- {}" \;
echo

# Check for any uncommitted documentation changes
if command -v git &> /dev/null && git rev-parse --git-dir > /dev/null 2>&1; then
    if git diff --quiet; then
        echo "No documentation changes detected."
    else
        echo "Documentation changes detected. Run 'git status' to see modified files."
        echo "To commit these changes:"
        echo "  git add ."
        echo "  git commit -m 'docs: update terraform documentation'"
    fi
fi
