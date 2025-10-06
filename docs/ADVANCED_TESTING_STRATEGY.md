# Advanced Terraform Testing Strategy

## Overview

This document outlines our **enterprise-grade testing approach** that goes beyond basic configuration validation to test **actual Azure resource state** and **network behavior** using **pure Terraform and GitHub Actions**.

## 🎯 Testing Philosophy

**"Test infrastructure like you test code"** - but with real cloud resources and network flows.

### Key Principles:
- ✅ **Terraform-native**: Use Terraform's built-in testing capabilities
- ✅ **Azure data sources**: Query actual resource state via Azure provider
- ✅ **GitHub Actions integration**: Automated testing in CI/CD pipeline  
- ✅ **No external scripts**: Everything self-contained in Terraform/GitHub Actions
- ✅ **Real resource validation**: Test against live Azure infrastructure

## 🧪 Testing Levels

### 1. Unit Tests (Fast, Configuration-focused)
**File**: `tests/compute.tftest.hcl`, `tests/networking.tftest.hcl`, `tests/database.tftest.hcl`
- **Speed**: Seconds
- **Cost**: Free (plan-only)
- **Purpose**: Validate Terraform configuration correctness

```hcl
assert {
  condition     = azurerm_linux_virtual_machine_scale_set.app.name == "app-scaleset"
  error_message = "App VMSS must be named 'app-scaleset' for policy compliance"
}
```

### 2. Integration Tests (Advanced, Resource State Validation)
**File**: `tests/advanced-integration.tftest.hcl`
- **Speed**: Fast (uses data sources)
- **Cost**: Free (no resource creation)
- **Purpose**: Validate actual Azure resource state and configuration

```hcl
# Real Azure resource validation
data "azurerm_virtual_network" "test_vnet" {
  name                = "terraform-lab-dev-vnet"
  resource_group_name = "kml_rg_main-5ae9e84837c64352"
}

assert {
  condition     = contains(data.azurerm_virtual_network.test_vnet.address_space, "10.0.0.0/16")
  error_message = "VNet should have correct address space"
}
```

### 3. Network Security Validation (GitHub Actions + Azure CLI)
**File**: `.github/workflows/advanced-testing.yml`
- **Speed**: Fast
- **Cost**: Free
- **Purpose**: Validate network flows, security rules, and compliance

```yaml
- name: Network Security Validation
  run: |
    # Check for overly permissive NSG rules
    OPEN_RULES=$(az network nsg rule list \
      --resource-group $RG \
      --nsg-name $nsg \
      --query "[?sourceAddressPrefix=='*' && access=='Allow'].name")
```

## 🔧 Advanced Testing Capabilities

### 1. Real Azure Resource State Testing

Instead of just checking Terraform configuration, we **query actual Azure resources**:

```hcl
# Test actual subnet delegation
assert {
  condition = length([
    for delegation in data.azurerm_subnet.test_database_subnet.delegation :
    delegation if delegation.service_delegation[0].name == "Microsoft.DBforPostgreSQL/flexibleServers"
  ]) > 0
  error_message = "Database subnet should be delegated to PostgreSQL service"
}
```

### 2. Network Security Rule Validation

Validate that security rules are correctly configured:

```hcl
# Ensure database NSG doesn't allow access from anywhere
assert {
  condition = length([
    for rule in data.azurerm_network_security_group.test_database_nsg.security_rule :
    rule if rule.access == "Allow" && rule.source_address_prefix == "*"
  ]) == 0
  error_message = "Database NSG should not have any rules allowing access from anywhere (*)"
}
```

### 3. Policy Compliance Testing

Test Azure Policy compliance directly:

```hcl
# Test App VMSS naming for policy compliance
assert {
  condition = length([
    for rule in data.azurerm_network_security_group.test_web_nsg.security_rule :
    rule if rule.name == "Allow-SSH" && rule.source_address_prefix == "10.0.0.0/16"
  ]) == 1
  error_message = "Web NSG SSH access should be restricted to VNet (10.0.0.0/16)"
}
```

### 4. Resource Tagging Compliance

Ensure all resources follow enterprise tagging standards:

```hcl
assert {
  condition     = data.azurerm_virtual_network.test_vnet.tags["ManagedBy"] == "terraform"
  error_message = "VNet ManagedBy tag should be 'terraform'"
}
```

## 🚀 GitHub Actions Workflow

### Advanced Testing Pipeline

Our `.github/workflows/advanced-testing.yml` provides:

1. **Terraform Validation**: Basic syntax and configuration checks
2. **Unit Tests**: Fast assert-based testing  
3. **Advanced Integration Tests**: Real Azure resource validation
4. **Azure CLI Validation**: Network and security compliance

### Key Features:

- **Real-time Azure inventory** in PR comments
- **Security compliance warnings** for risky configurations
- **Network topology validation** 
- **Resource state verification**

## 📊 Test Execution

### Local Testing
```bash
# Run unit tests
terraform test -test-directory=./tests

# Run specific test
terraform test -test-directory=./tests -filter="advanced-integration.tftest.hcl"
```

### GitHub Actions Testing
- **Triggers**: PR creation, push to main/develop
- **Environments**: Uses Azure service principal authentication
- **Outputs**: Rich markdown summaries in PR comments

## 🔍 What Gets Tested

### ✅ Infrastructure State
- VNet configuration and address spaces
- Subnet configurations and delegations  
- NAT Gateway and Public IP associations
- Load balancer configurations

### ✅ Security Compliance
- NSG rule analysis for overly permissive access
- SSH access restrictions
- Database isolation validation
- Public access restrictions

### ✅ Enterprise Standards
- Resource tagging compliance
- Naming convention adherence  
- Policy compliance (VMSS naming, instance limits)
- SKU and configuration standards

### ✅ Network Architecture
- Subnet routing and isolation
- NAT Gateway configuration
- Load balancer frontend/backend configuration
- Service delegation validation

## 🎯 Benefits

### For Developers:
- **Fast feedback** on infrastructure changes
- **Clear error messages** when tests fail
- **No external tool dependencies**
- **Integrated with existing workflow**

### For Enterprise:
- **Policy compliance validation**
- **Security rule verification**
- **Consistent resource validation**
- **Audit trail in GitHub Actions**

### For Operations:
- **Automated infrastructure validation**
- **Early detection of misconfigurations**
- **Standardized testing approach**
- **Rich reporting and visibility**

## 📈 Testing Strategy Evolution

### Current State: ✅ Advanced Resource Validation
- Terraform-native testing with assert blocks
- Azure data source integration
- GitHub Actions automation
- Real resource state validation

### Future Enhancements:
- **Performance testing** with Azure Monitor integration
- **Cost validation** with Azure Cost Management APIs
- **Compliance scanning** with Azure Policy integration
- **Connectivity testing** with Azure Network Watcher

## 🔧 How to Add New Tests

### 1. Add Unit Test
```hcl
# In tests/your-module.tftest.hcl
assert {
  condition     = your_condition_here
  error_message = "Clear error message"
}
```

### 2. Add Integration Test
```hcl
# In tests/advanced-integration.tftest.hcl
data "azurerm_your_resource" "test" {
  # Resource identification
}

assert {
  condition     = data.azurerm_your_resource.test.property == "expected_value"
  error_message = "Resource should have expected configuration"
}
```

### 3. Add GitHub Actions Validation
```yaml
# In .github/workflows/advanced-testing.yml
- name: Your Custom Validation
  run: |
    echo "Running custom validation..."
    # Azure CLI commands or other validation logic
```

## 📋 Best Practices

1. **Test Early, Test Often**: Run tests in development environment first
2. **Clear Error Messages**: Make test failures actionable
3. **Focused Tests**: Each test should validate one specific thing
4. **Use Data Sources**: Leverage Terraform's Azure data sources for real state
5. **Document Tests**: Explain what each test validates and why
6. **Monitor Test Performance**: Keep tests fast and reliable

This approach gives you **enterprise-grade infrastructure testing** without external dependencies, fully integrated with your Terraform workflow and GitHub Actions pipeline!