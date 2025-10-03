#!/bin/bash

# setup-environment.sh
# Utility script to initialize Terraform environment from examples
# Usage: ./scripts/setup-environment.sh <environment>

set -euo pipefail

ENVIRONMENT=${1:-"dev"}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ENV_DIR="$PROJECT_ROOT/environments/$ENVIRONMENT"

# Validate environment parameter
if [[ ! "$ENVIRONMENT" =~ ^(dev|staging|prod)$ ]]; then
    echo "Error: Environment must be one of: dev, staging, prod"
    echo "Usage: $0 <environment>"
    exit 1
fi

# Check if environment directory exists
if [[ ! -d "$ENV_DIR" ]]; then
    echo "Error: Environment directory does not exist: $ENV_DIR"
    exit 1
fi

echo "Setting up $ENVIRONMENT environment..."

# Copy terraform.tfvars from example if it doesn't exist
TFVARS_FILE="$ENV_DIR/terraform.tfvars"
EXAMPLE_FILE="$ENV_DIR/terraform.tfvars.example"

if [[ -f "$TFVARS_FILE" ]]; then
    echo "terraform.tfvars already exists in $ENVIRONMENT environment"
    read -p "Overwrite existing file? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Skipping terraform.tfvars creation"
    else
        cp "$EXAMPLE_FILE" "$TFVARS_FILE"
        echo "Copied $EXAMPLE_FILE to $TFVARS_FILE"
    fi
else
    cp "$EXAMPLE_FILE" "$TFVARS_FILE"
    echo "Created $TFVARS_FILE from example"
fi

# Validate Terraform configuration
echo "Validating Terraform configuration..."
cd "$ENV_DIR"

if terraform fmt -check -diff; then
    echo "✓ Terraform formatting is correct"
else
    echo "! Running terraform fmt to fix formatting..."
    terraform fmt
fi

# Initialize Terraform (without backend to avoid state issues)
echo "Initializing Terraform..."
terraform init -backend=false

# Validate configuration
if terraform validate; then
    echo "✓ Terraform configuration is valid"
else
    echo "✗ Terraform validation failed"
    exit 1
fi

echo ""
echo "Environment setup complete!"
echo ""
echo "Next steps:"
echo "1. Edit $TFVARS_FILE with your specific values"
echo "2. Configure your Azure credentials: az login"
echo "3. Initialize with backend: terraform init"
echo "4. Plan your deployment: terraform plan"
echo "5. Apply when ready: terraform apply"
echo ""
echo "Security reminder:"
echo "- Never commit terraform.tfvars files"
echo "- Use environment-specific Azure subscriptions"
echo "- Implement proper RBAC controls"