# Basic Unit Tests for Infrastructure Validation
# Fast plan-time validation of configuration policies

variables {
  project_name             = "terraform-lab"
  environment              = "dev"
  azure_region             = "East US"
  vnet_cidr                = "10.0.0.0/16"
  public_subnets           = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets          = ["10.0.11.0/24", "10.0.12.0/24"]
  database_subnets         = ["10.0.21.0/24", "10.0.22.0/24"]
  web_vm_size              = "Standard_B1s"
  app_vm_size              = "Standard_B1s"
  web_instance_count       = 2
  app_instance_count       = 2
  admin_username           = "azureuser"
  ssh_public_key           = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCVsv/kHHL+Hh0RW2YFqwpEJ+YsFaIHAAt51P36rmbsz1a1o4NbupXJRyJufyvKuJQuz1sYuPbNBn0o16zMzBa+wZnga3LP8wxax+5aPvmolLVLfU4hPoT1UigBSFs04D+qyhiJVRJh/z2UySWmLVjjSR04Ldtk6BAJKWBJ8bc2ByD3vx663KH3zYpjRlOgo7iVSp9HzzuRXaj5QBzXr2MHSo6nV1Sc9FM4i18afkZHppdKwwtr92z7q3371uTqhJbIC8uyOkgDN+c3IXMW4iUF2/w9JCk/pCN//ddG9OucaY4yUGC9wJKvvbaSmX4GngldUbGIXPZ2q7Q4cxFEj+3N terraform-lab@codespaces"
  enable_nat_gateway       = true
  db_server_version        = "13"
  db_sku_name              = "B_Standard_B1ms"
  db_storage_mb            = 32768
  db_admin_username        = "dbadmin"
  db_backup_retention_days = 7
  additional_tags          = {}
}

# Test 1: Configuration syntax and variable validation
run "validate_configuration_syntax" {
  command = plan

  # Validate project naming convention
  assert {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens: ${var.project_name}"
  }

  # Validate environment is from allowed list
  assert {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod. Got: ${var.environment}"
  }

  # Validate Azure region format
  assert {
    condition     = can(regex("^[A-Za-z]+ [A-Z][A-Za-z]+$", var.azure_region))
    error_message = "Azure region format invalid: ${var.azure_region}"
  }

  # Validate CIDR format
  assert {
    condition     = can(cidrhost(var.vnet_cidr, 0))
    error_message = "Invalid VNet CIDR format: ${var.vnet_cidr}"
  }
}

# Test 2: Infrastructure policy compliance
run "validate_infrastructure_policies" {
  command = plan

  # VM size compliance with enterprise policy
  assert {
    condition     = contains(["Standard_B1s", "Standard_B2s", "Standard_D2s_v3", "Standard_D4s_v3"], var.app_vm_size)
    error_message = "App VM size violates enterprise policy: ${var.app_vm_size}"
  }

  assert {
    condition     = contains(["Standard_B1s", "Standard_B2s", "Standard_D2s_v3", "Standard_D4s_v3"], var.web_vm_size)
    error_message = "Web VM size violates enterprise policy: ${var.web_vm_size}"
  }

  # Instance count limits
  assert {
    condition     = var.app_instance_count >= 1 && var.app_instance_count <= 5
    error_message = "App instance count must be 1-5: ${var.app_instance_count}"
  }

  assert {
    condition     = var.web_instance_count >= 1 && var.web_instance_count <= 5
    error_message = "Web instance count must be 1-5: ${var.web_instance_count}"
  }

  # Database backup policy compliance
  assert {
    condition     = var.db_backup_retention_days >= 7
    error_message = "Database backup retention must be at least 7 days: ${var.db_backup_retention_days}"
  }

  # Database version compliance
  assert {
    condition     = contains(["11", "12", "13", "14"], var.db_server_version)
    error_message = "Database version must be supported: ${var.db_server_version}"
  }
}

# Test 3: Network configuration validation
run "validate_network_configuration" {
  command = plan

  # Subnet count requirements
  assert {
    condition     = length(var.public_subnets) >= 2
    error_message = "Must have at least 2 public subnets for HA: ${length(var.public_subnets)}"
  }

  assert {
    condition     = length(var.private_subnets) >= 2
    error_message = "Must have at least 2 private subnets for HA: ${length(var.private_subnets)}"
  }

  assert {
    condition     = length(var.database_subnets) >= 2
    error_message = "Must have at least 2 database subnets for HA: ${length(var.database_subnets)}"
  }

  # CIDR overlap prevention with common ranges
  assert {
    condition = !contains([
      "172.16.0.0/12",
      "192.168.0.0/16",
      "10.1.0.0/16",
      "10.10.0.0/16"
    ], var.vnet_cidr)
    error_message = "VNet CIDR conflicts with reserved ranges: ${var.vnet_cidr}"
  }

  # Validate subnets are within VNet CIDR
  assert {
    condition = alltrue([
      for subnet in var.public_subnets :
      can(cidrsubnet(var.vnet_cidr, 8, 0)) &&
      cidrsubnet(var.vnet_cidr, 8, tonumber(split(".", split("/", subnet)[0])[2])) == subnet
    ])
    error_message = "Public subnets must be within VNet CIDR range"
  }
}

# Test 4: Security configuration validation
run "validate_security_configuration" {
  command = plan

  # SSH key format validation
  assert {
    condition     = can(regex("^ssh-rsa AAAA[0-9A-Za-z+/]+[=]{0,3}", var.ssh_public_key))
    error_message = "Invalid SSH public key format"
  }

  # Admin username policy
  assert {
    condition     = var.admin_username != "admin" && var.admin_username != "root" && var.admin_username != "administrator"
    error_message = "Admin username cannot be common names: ${var.admin_username}"
  }

  # Database admin username policy
  assert {
    condition     = var.db_admin_username != "admin" && var.db_admin_username != "root" && var.db_admin_username != "postgres"
    error_message = "Database admin username cannot be common names: ${var.db_admin_username}"
  }

  # NAT Gateway requirement for private subnets
  assert {
    condition     = var.enable_nat_gateway == true
    error_message = "NAT Gateway must be enabled for private subnet internet access"
  }
}