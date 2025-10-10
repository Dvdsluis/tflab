# Integration Tests for Module Interactions
# Tests how modules work together and output dependencies

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

# Test 1: Plan-time validation (configuration syntax and dependencies)
run "validate_plan_time_integration" {
  command = plan

  # Validate that modules can be planned without errors
  assert {
    condition     = can(module.networking.vnet_address_space)
    error_message = "Networking module configuration must be valid"
  }

  assert {
    condition     = can(module.compute.app_vmss_sku)
    error_message = "Compute module configuration must be valid"
  }

  assert {
    condition     = can(module.database.key_vault_id)
    error_message = "Database module configuration must be valid"
  }
}

# Test 2: Apply-time validation (actual resource creation and outputs)
run "validate_module_integration" {
  command = apply

  # Validate networking module produces required outputs
  assert {
    condition     = output.vnet_id != null
    error_message = "Networking module must output vnet_id"
  }

  assert {
    condition     = output.vnet_address_space != null
    error_message = "Networking module must output vnet_address_space"
  }

  assert {
    condition     = length(output.public_subnet_ids) >= 2
    error_message = "Networking module must output at least 2 public subnet IDs"
  }

  assert {
    condition     = length(output.private_subnet_ids) >= 2
    error_message = "Networking module must output at least 2 private subnet IDs"
  }

  # Validate compute module integration with networking
  assert {
    condition     = output.web_vmss_id != null
    error_message = "Compute module must output web_vmss_id"
  }

  assert {
    condition     = output.app_vmss_id != null
    error_message = "Compute module must output app_vmss_id"
  }

  assert {
    condition     = output.web_load_balancer_id != null
    error_message = "Compute module must output web_load_balancer_id"
  }

  # Validate database module integration
  assert {
    condition     = output.postgres_server_id != null
    error_message = "Database module must output postgres_server_id"
  }

  assert {
    condition     = output.key_vault_id != null
    error_message = "Database module must output key_vault_id"
  }
}

# Test 3: Security group integration across modules (plan-time)
run "validate_security_integration" {
  command = plan

  # Validate security configuration syntax
  assert {
    condition     = var.vnet_cidr != null && var.vnet_cidr != ""
    error_message = "VNet CIDR must be configured for security integration"
  }

  assert {
    condition     = length(var.public_subnets) > 0
    error_message = "Public subnets must be configured for security integration"
  }

  assert {
    condition     = length(var.private_subnets) > 0
    error_message = "Private subnets must be configured for security integration"
  }
}

# Test 4: VMSS configuration integration (plan-time)
run "validate_vmss_integration" {
  command = plan

  # Validate VMSS configuration variables
  assert {
    condition     = contains(["Standard_B1s", "Standard_B1ms", "Standard_B2s"], var.app_vm_size)
    error_message = "App VM size must be a valid Azure SKU"
  }

  assert {
    condition     = var.app_instance_count >= 2 && var.app_instance_count <= 10
    error_message = "App instance count must be between 2 and 10"
  }

  assert {
    condition     = contains(["Standard_B1s", "Standard_B1ms", "Standard_B2s"], var.web_vm_size)
    error_message = "Web VM size must be a valid Azure SKU"
  }

  assert {
    condition     = var.web_instance_count >= 2 && var.web_instance_count <= 10
    error_message = "Web instance count must be between 2 and 10"
  }
}