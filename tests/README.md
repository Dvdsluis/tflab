# Terraform Test Organization

This directory contains organized Terraform tests for the infrastructure lab.

## Test Structure

```
tests/
├── unit/                           # Fast unit tests (plan-time validation)
│   └── basic-validation.tftest.hcl    # Configuration and policy validation
├── integration/                    # Module integration tests
│   └── module-integration.tftest.hcl  # Cross-module dependency validation
├── e2e/                           # End-to-end tests (full deployment)
│   └── azure-deployment.tftest.hcl    # Full Azure deployment validation
└── security-validation.tftest.hcl # Comprehensive security tests
```

## Test Categories

### 1. Unit Tests (`unit/`)
- **Purpose**: Fast validation of configuration syntax and policies
- **Command**: `terraform test tests/unit/`
- **Duration**: < 30 seconds
- **Scope**: Plan-time validation only, no Azure API calls

**Features:**
- Configuration syntax validation
- Infrastructure policy compliance
- Network configuration validation
- Security configuration validation

### 2. Integration Tests (`integration/`)
- **Purpose**: Validate module interactions and output dependencies
- **Command**: `terraform test tests/integration/`
- **Duration**: < 1 minute
- **Scope**: Plan-time validation with module integration

**Features:**
- Module output dependencies
- Security group integration
- VMSS configuration integration
- Cross-module validation

### 3. End-to-End Tests (`e2e/`)
- **Purpose**: Full deployment validation with Azure API checks
- **Command**: `terraform test tests/e2e/`
- **Duration**: 10-15 minutes
- **Scope**: Full deployment and Azure resource validation

**Features:**
- Real Azure deployment validation
- Resource status verification
- Azure API health checks
- Post-deployment validation

### 4. Security Validation (`security-validation.tftest.hcl`)
- **Purpose**: Comprehensive security and compliance testing
- **Command**: `terraform test tests/security-validation.tftest.hcl`
- **Duration**: 5-10 minutes
- **Scope**: Plan + Apply validation with security focus

## Running Tests

### Run All Tests
```bash
cd /workspaces/tflab/environments/dev
terraform test
```

### Run Specific Test Categories
```bash
# Fast unit tests only
terraform test ../../tests/unit/

# Integration tests
terraform test ../../tests/integration/

# Full deployment tests
terraform test ../../tests/e2e/

# Security validation
terraform test ../../tests/security-validation.tftest.hcl
```

### Run Individual Test Files
```bash
# Basic validation
terraform test ../../tests/unit/basic-validation.tftest.hcl

# Module integration
terraform test ../../tests/integration/module-integration.tftest.hcl

# Azure deployment
terraform test ../../tests/e2e/azure-deployment.tftest.hcl
```

## Test Variables

All tests use a consistent variable structure:

```hcl
variables {
  project_name = "terraform-lab"
  environment = "dev"
  azure_region = "East US"
  vnet_cidr = "10.0.0.0/16"          # Unit/Integration tests
  vnet_cidr = "10.2.0.0/16"          # E2E tests (different CIDR)
  # ... other variables
}
```

## Best Practices

1. **Run unit tests first** - Fast feedback on configuration issues
2. **Use different CIDRs** - E2E tests use different CIDR ranges to avoid conflicts
3. **Clean state between tests** - Each test category uses isolated configurations
4. **Validate before deployment** - Unit tests catch policy violations before expensive deployments

## Azure API Validation

The tests demonstrate comprehensive Azure validation beyond `terraform plan`:

- **Resource conflict detection** - Existing resource name conflicts
- **CIDR overlap validation** - Network configuration conflicts
- **Resource status verification** - Actual deployment health
- **Policy compliance** - Enterprise governance rules
- **Security validation** - NSG, Key Vault, access policies

This catches deployment issues that `terraform plan` cannot detect, such as:
- Overlapping CIDR ranges with existing VNets
- Resource naming conflicts
- Azure resource quota limits
- Network security policy violations