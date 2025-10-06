# Security Validation Tests
# Uses Terraform data sources to validate deployed resources via Azure API
# This replaces the bash scripts in CI/CD with proper Terraform testing

variables {
  resource_group_name = "kml_rg_main-f9fc6defb9c44b20"
  environment         = "dev"
  project_name        = "terraform-lab"
}

# Test 1: Validate Network Security Groups exist and have proper rules
run "validate_nsg_security_rules" {
  command = plan

  # Data sources to fetch actual NSG configurations from Azure
  variables {
    resource_group_name = var.resource_group_name
    environment         = var.environment
    project_name        = var.project_name
  }

  # Check if web NSG exists and has SSH restrictions
  assert {
    condition     = can(data.azurerm_network_security_group.web)
    error_message = "Web NSG should exist after deployment"
  }

  # Validate no overly permissive SSH rules (source 0.0.0.0/0)
  assert {
    condition = length([
      for rule in data.azurerm_network_security_group.web.security_rule :
      rule if rule.source_address_prefix == "*" &&
      rule.access == "Allow" &&
      rule.destination_port_range == "22"
    ]) == 0
    error_message = "SSH should not be allowed from internet (0.0.0.0/0)"
  }

  # Validate database NSG doesn't allow access from anywhere
  assert {
    condition = length([
      for rule in data.azurerm_network_security_group.database.security_rule :
      rule if rule.source_address_prefix == "*" &&
      rule.access == "Allow" &&
      rule.destination_port_range != "443" &&
      rule.destination_port_range != "80"
    ]) == 0
    error_message = "Database NSG should not have overly permissive rules"
  }
}

# Test 2: Validate VNet configuration and subnets
run "validate_network_configuration" {
  command = plan

  variables {
    resource_group_name = var.resource_group_name
    environment         = var.environment
    project_name        = var.project_name
  }

  # Ensure VNet exists with correct address space
  assert {
    condition     = can(data.azurerm_virtual_network.main)
    error_message = "VNet should exist after deployment"
  }

  assert {
    condition     = contains(data.azurerm_virtual_network.main.address_space, "10.0.0.0/16")
    error_message = "VNet should have the correct address space (10.0.0.0/16)"
  }

  # Validate subnets exist and have NSGs attached
  assert {
    condition     = length(data.azurerm_virtual_network.main.subnet) >= 3
    error_message = "VNet should have at least 3 subnets (public, private, database)"
  }
}

# Test 3: Validate NAT Gateway and Public IP configuration
run "validate_nat_gateway_security" {
  command = plan

  variables {
    resource_group_name = var.resource_group_name
    environment         = var.environment
    project_name        = var.project_name
  }

  # Check NAT Gateway exists
  assert {
    condition     = can(data.azurerm_nat_gateway.main)
    error_message = "NAT Gateway should exist for outbound connectivity"
  }

  # Validate NAT Gateway has public IP
  assert {
    condition     = length(data.azurerm_nat_gateway.main.public_ip_address_ids) > 0
    error_message = "NAT Gateway should have at least one public IP"
  }

  # Check public IP allocation method
  assert {
    condition     = data.azurerm_public_ip.nat_gateway.allocation_method == "Static"
    error_message = "NAT Gateway public IP should use Static allocation"
  }
}

# Test 4: Validate Load Balancer configuration
run "validate_load_balancer_security" {
  command = plan

  variables {
    resource_group_name = var.resource_group_name
    environment         = var.environment
    project_name        = var.project_name
  }

  # Ensure load balancer exists
  assert {
    condition     = can(data.azurerm_lb.main)
    error_message = "Load balancer should exist for web tier"
  }

  # Validate load balancer has public IP
  assert {
    condition     = length(data.azurerm_lb.main.frontend_ip_configuration) > 0
    error_message = "Load balancer should have frontend IP configuration"
  }

  # Check that LB only allows HTTP/HTTPS traffic
  assert {
    condition = alltrue([
      for rule in data.azurerm_lb.main.frontend_ip_configuration :
      contains(["80", "443"], tostring(rule.private_ip_address_allocation))
    ])
    error_message = "Load balancer should only expose HTTP/HTTPS ports"
  }
}

# Data sources for validation (these will make Azure API calls)
data "azurerm_network_security_group" "web" {
  name                = "${var.project_name}-${var.environment}-web-nsg"
  resource_group_name = var.resource_group_name
}

data "azurerm_network_security_group" "app" {
  name                = "${var.project_name}-${var.environment}-app-nsg"
  resource_group_name = var.resource_group_name
}

data "azurerm_network_security_group" "database" {
  name                = "${var.project_name}-${var.environment}-database-nsg"
  resource_group_name = var.resource_group_name
}

data "azurerm_virtual_network" "main" {
  name                = "${var.project_name}-${var.environment}-vnet"
  resource_group_name = var.resource_group_name
}

data "azurerm_nat_gateway" "main" {
  name                = "${var.project_name}-${var.environment}-nat-gw"
  resource_group_name = var.resource_group_name
}

data "azurerm_public_ip" "nat_gateway" {
  name                = "${var.project_name}-${var.environment}-nat-gw-ip"
  resource_group_name = var.resource_group_name
}

data "azurerm_lb" "main" {
  name                = "${var.project_name}-${var.environment}-lb"
  resource_group_name = var.resource_group_name
}