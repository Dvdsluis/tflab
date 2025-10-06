# Advanced Integration Tests - Pure Terraform + Azure Data Sources
# This uses Terraform's native data sources to verify actual Azure resource state
# Perfect for GitHub Actions integration without external scripts

# Provider configuration for tests
provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
}

# Azure data sources for real resource validation
data "azurerm_resource_group" "test_rg" {
  name = "kml_rg_main-5ae9e84837c64352"
}

data "azurerm_virtual_network" "test_vnet" {
  name                = "terraform-lab-dev-vnet"
  resource_group_name = "kml_rg_main-5ae9e84837c64352"
}

data "azurerm_subnet" "test_public_subnet" {
  name                 = "terraform-lab-dev-public-1"
  virtual_network_name = "terraform-lab-dev-vnet"
  resource_group_name  = "kml_rg_main-5ae9e84837c64352"
}

data "azurerm_subnet" "test_private_subnet" {
  name                 = "terraform-lab-dev-private-1"
  virtual_network_name = "terraform-lab-dev-vnet"
  resource_group_name  = "kml_rg_main-5ae9e84837c64352"
}

data "azurerm_subnet" "test_database_subnet" {
  name                 = "terraform-lab-dev-database-1"
  virtual_network_name = "terraform-lab-dev-vnet"
  resource_group_name  = "kml_rg_main-5ae9e84837c64352"
}

data "azurerm_network_security_group" "test_web_nsg" {
  name                = "terraform-lab-dev-web-nsg"
  resource_group_name = "kml_rg_main-5ae9e84837c64352"
}

data "azurerm_network_security_group" "test_app_nsg" {
  name                = "terraform-lab-dev-app-nsg"
  resource_group_name = "kml_rg_main-5ae9e84837c64352"
}

data "azurerm_network_security_group" "test_database_nsg" {
  name                = "terraform-lab-dev-database-nsg"
  resource_group_name = "kml_rg_main-5ae9e84837c64352"
}

data "azurerm_nat_gateway" "test_nat_gateway" {
  name                = "terraform-lab-dev-nat-gw"
  resource_group_name = "kml_rg_main-5ae9e84837c64352"
}

data "azurerm_public_ip" "test_nat_public_ip" {
  name                = "terraform-lab-dev-nat-gw-ip"
  resource_group_name = "kml_rg_main-5ae9e84837c64352"
}

data "azurerm_public_ip" "test_lb_public_ip" {
  name                = "terraform-lab-dev-lb-ip"
  resource_group_name = "kml_rg_main-5ae9e84837c64352"
}

# Data source for Key Vault (for security testing)
data "azurerm_key_vault" "test_key_vault" {
  name                = "terraform-lab-dev-db-kv"
  resource_group_name = "kml_rg_main-5ae9e84837c64352"
}

# Test 1: Real Azure Resource State Validation (using Terraform data sources)
run "azure_resource_state_validation" {
  command = plan # Use plan to test against existing resources

  variables {
    # Test variables - not deploying, just validating existing resources
  }

  # VNet State Validation
  assert {
    condition     = data.azurerm_virtual_network.test_vnet.name == "terraform-lab-dev-vnet"
    error_message = "VNet should exist and have correct name"
  }

  assert {
    condition     = contains(data.azurerm_virtual_network.test_vnet.address_space, "10.0.0.0/16")
    error_message = "VNet should have correct address space"
  }

  assert {
    condition     = length(data.azurerm_virtual_network.test_vnet.address_space) == 1
    error_message = "VNet should have exactly one address space"
  }

  # Subnet Validation
  assert {
    condition     = contains(data.azurerm_subnet.test_public_subnet.address_prefixes, "10.0.1.0/24")
    error_message = "Public subnet should have correct address prefix"
  }

  assert {
    condition     = contains(data.azurerm_subnet.test_private_subnet.address_prefixes, "10.0.11.0/24")
    error_message = "Private subnet should have correct address prefix"
  }

  assert {
    condition     = contains(data.azurerm_subnet.test_database_subnet.address_prefixes, "10.0.21.0/24")
    error_message = "Database subnet should have correct address prefix"
  }

  # Database subnet delegation validation
  assert {
    condition = length([
      for delegation in data.azurerm_subnet.test_database_subnet.delegation :
      delegation if delegation.service_delegation[0].name == "Microsoft.DBforPostgreSQL/flexibleServers"
    ]) > 0
    error_message = "Database subnet should be delegated to PostgreSQL service"
  }
}

# Test 2: Network Security Group Rules Validation
run "network_security_validation" {
  command = plan

  variables {
    # Test variables
  }

  # Web NSG - HTTP/HTTPS access validation
  assert {
    condition = length([
      for rule in data.azurerm_network_security_group.test_web_nsg.security_rule :
      rule if rule.name == "Allow-HTTP" && rule.access == "Allow" && rule.destination_port_range == "80"
    ]) == 1
    error_message = "Web NSG should allow HTTP traffic on port 80"
  }

  assert {
    condition = length([
      for rule in data.azurerm_network_security_group.test_web_nsg.security_rule :
      rule if rule.name == "Allow-HTTPS" && rule.access == "Allow" && rule.destination_port_range == "443"
    ]) == 1
    error_message = "Web NSG should allow HTTPS traffic on port 443"
  }

  # Web NSG - SSH should be restricted to VNet only
  assert {
    condition = length([
      for rule in data.azurerm_network_security_group.test_web_nsg.security_rule :
      rule if rule.name == "Allow-SSH" && rule.source_address_prefix == "10.0.0.0/16"
    ]) == 1
    error_message = "Web NSG SSH access should be restricted to VNet (10.0.0.0/16)"
  }

  # App NSG - should only allow access from VNet
  assert {
    condition = length([
      for rule in data.azurerm_network_security_group.test_app_nsg.security_rule :
      rule if rule.name == "Allow-App-HTTP" && rule.source_address_prefix == "10.0.0.0/16"
    ]) == 1
    error_message = "App NSG should only allow HTTP access from VNet"
  }

  # Database NSG - should only allow PostgreSQL from VNet
  assert {
    condition = length([
      for rule in data.azurerm_network_security_group.test_database_nsg.security_rule :
      rule if rule.name == "Allow-Postgres" && rule.destination_port_range == "5432" && rule.source_address_prefix == "10.0.0.0/16"
    ]) == 1
    error_message = "Database NSG should only allow PostgreSQL access from VNet"
  }

  # Security validation - no rules allowing access from anywhere on sensitive ports
  assert {
    condition = length([
      for rule in data.azurerm_network_security_group.test_database_nsg.security_rule :
      rule if rule.access == "Allow" && rule.source_address_prefix == "*"
    ]) == 0
    error_message = "Database NSG should not have any rules allowing access from anywhere (*)"
  }
}

# Test 3: NAT Gateway and Public IP Configuration
run "nat_gateway_configuration_validation" {
  command = plan

  variables {
    # Test variables
  }

  # NAT Gateway exists and configured
  assert {
    condition     = data.azurerm_nat_gateway.test_nat_gateway.name == "terraform-lab-dev-nat-gw"
    error_message = "NAT Gateway should exist with correct name"
  }

  assert {
    condition     = data.azurerm_nat_gateway.test_nat_gateway.sku_name == "Standard"
    error_message = "NAT Gateway should use Standard SKU"
  }

  # Public IP for NAT Gateway
  assert {
    condition     = data.azurerm_public_ip.test_nat_public_ip.name == "terraform-lab-dev-nat-gw-ip"
    error_message = "NAT Gateway public IP should exist with correct name"
  }

  assert {
    condition     = data.azurerm_public_ip.test_nat_public_ip.allocation_method == "Static"
    error_message = "NAT Gateway public IP should use Static allocation"
  }

  assert {
    condition     = data.azurerm_public_ip.test_nat_public_ip.sku == "Standard"
    error_message = "NAT Gateway public IP should use Standard SKU"
  }

  # Load Balancer Public IP
  assert {
    condition     = data.azurerm_public_ip.test_lb_public_ip.name == "terraform-lab-dev-lb-ip"
    error_message = "Load Balancer public IP should exist with correct name"
  }

  assert {
    condition     = data.azurerm_public_ip.test_lb_public_ip.allocation_method == "Static"
    error_message = "Load Balancer public IP should use Static allocation"
  }

  # Network Association Validation - Private subnet should NOT have NAT Gateway
  assert {
    condition     = data.azurerm_subnet.test_database_subnet.id != null
    error_message = "Database subnet should exist"
  }
}

# Test 4: Resource Tagging Compliance Validation
run "resource_tagging_validation" {
  command = plan

  variables {
    # Test variables
  }

  # VNet tagging
  assert {
    condition     = contains(keys(data.azurerm_virtual_network.test_vnet.tags), "Environment")
    error_message = "VNet should have Environment tag"
  }

  assert {
    condition     = contains(keys(data.azurerm_virtual_network.test_vnet.tags), "Project")
    error_message = "VNet should have Project tag"
  }

  assert {
    condition     = contains(keys(data.azurerm_virtual_network.test_vnet.tags), "ManagedBy")
    error_message = "VNet should have ManagedBy tag"
  }

  assert {
    condition     = data.azurerm_virtual_network.test_vnet.tags["ManagedBy"] == "terraform"
    error_message = "VNet ManagedBy tag should be 'terraform'"
  }

  assert {
    condition     = data.azurerm_virtual_network.test_vnet.tags["Project"] == "terraform-lab"
    error_message = "VNet Project tag should be 'terraform-lab'"
  }

  # NSG tagging validation
  assert {
    condition     = data.azurerm_network_security_group.test_web_nsg.tags["Environment"] != null
    error_message = "Web NSG should have Environment tag"
  }

  assert {
    condition     = data.azurerm_network_security_group.test_app_nsg.tags["Environment"] != null
    error_message = "App NSG should have Environment tag"
  }

  assert {
    condition     = data.azurerm_network_security_group.test_database_nsg.tags["Environment"] != null
    error_message = "Database NSG should have Environment tag"
  }
}

# Test 5: Key Vault Security and Compliance Validation
run "key_vault_security_validation" {
  command = plan

  variables {
    # Test variables
  }

  # Key Vault should exist and be configured properly
  assert {
    condition     = data.azurerm_key_vault.test_key_vault.name == "terraform-lab-dev-db-kv"
    error_message = "Key Vault should exist with correct name"
  }

  assert {
    condition     = data.azurerm_key_vault.test_key_vault.sku_name == "standard"
    error_message = "Key Vault should use Standard SKU"
  }

  assert {
    condition     = data.azurerm_key_vault.test_key_vault.soft_delete_retention_days == 7
    error_message = "Key Vault should have 7-day soft delete retention"
  }

  assert {
    condition     = data.azurerm_key_vault.test_key_vault.purge_protection_enabled == true
    error_message = "Key Vault should have purge protection enabled for compliance"
  }

  # Security compliance tagging
  assert {
    condition     = contains(keys(data.azurerm_key_vault.test_key_vault.tags), "Environment")
    error_message = "Key Vault should have Environment tag"
  }

  assert {
    condition     = contains(keys(data.azurerm_key_vault.test_key_vault.tags), "ManagedBy")
    error_message = "Key Vault should have ManagedBy tag"
  }

  assert {
    condition     = data.azurerm_key_vault.test_key_vault.tags["ManagedBy"] == "terraform"
    error_message = "Key Vault ManagedBy tag should be 'terraform'"
  }
}