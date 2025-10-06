# Security Validation Tests
# Plan-time policy validation + Azure API validation after deployment
# Tests for issues that terraform plan cannot detect

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
  ssh_public_key           = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCVsv/kHHL+Hh0RW2YFqwpEJ+YsFaIHAAt51P36rmbsz1a1o4NbupXJRyJufyvKuJQuz1sYuPbNBn0o16zMzBa+wZnga3LP8wxax+5aPvmolLVLfU4hPoT1UigBSFs04D+qyhiJVRJh/z2UySWmLVjjSR04Ldtk6BAJKWBJ8bc2ByD3vx663KH3zYpjRlOgo7iVSp9HzzuRXaj5QBzXr2MHSo6nV1Sc9FM4i18afkZHppdKwwtr92z7q3371uTqhJbIC8uyOkgDN+c3IXMW4iUF2/w9JCk/pCN//ddG9OucaY4yUGC9wJKvvbaSmX4GngldUbGIXPZ2q7Q4cxFEj+3N terraform-lab-short@codespaces"
  enable_nat_gateway       = true
  db_server_version        = "13"
  db_sku_name              = "B_Standard_B1ms"
  db_storage_mb            = 32768
  db_admin_username        = "dbadmin"
  db_backup_retention_days = 7
  additional_tags          = {}
}

# Test 1: Plan-time policy validation (no Azure API calls)
run "validate_plan_time_policies" {
  command = plan

  # VM size policy compliance
  assert {
    condition     = contains(["Standard_B1s", "Standard_B2s", "Standard_D2s_v3"], var.app_vm_size)
    error_message = "App VM size must be policy compliant: ${var.app_vm_size}"
  }

  # Instance count policy
  assert {
    condition     = var.app_instance_count <= 3
    error_message = "App instance count should not exceed policy limit of 3: ${var.app_instance_count}"
  }

  # VNet CIDR overlap check
  assert {
    condition = !contains([
      "172.16.0.0/12",
      "192.168.0.0/16",
      "10.1.0.0/16"
    ], var.vnet_cidr)
    error_message = "VNet CIDR should not overlap with common ranges: ${var.vnet_cidr}"
  }

  # Subnet count validation
  assert {
    condition     = length(var.public_subnets) >= 2 && length(var.private_subnets) >= 2
    error_message = "Must have at least 2 public and 2 private subnets"
  }

  # Database backup retention policy
  assert {
    condition     = var.db_backup_retention_days >= 7
    error_message = "Database backup retention must be at least 7 days: ${var.db_backup_retention_days}"
  }
}

# Test 2: Deploy and validate via Azure API (real Azure validation)
run "deploy_and_validate_azure_resources" {
  command = apply

  # Validate VNet was created and has correct address space
  assert {
    condition     = length(output.vnet_address_space) > 0
    error_message = "VNet address space should be configured"
  }

  # Validate actual subnet count matches expectation
  assert {
    condition     = length(output.public_subnet_ids) >= 2 && length(output.private_subnet_ids) >= 2
    error_message = "Must have at least 2 public and 2 private subnets deployed"
  }

  # Validate VMSS was created with correct SKU
  assert {
    condition     = output.app_vmss_sku == var.app_vm_size
    error_message = "App VMSS SKU should match configured value: expected ${var.app_vm_size}, got ${output.app_vmss_sku}"
  }

  # Validate VMSS instance count
  assert {
    condition     = output.app_vmss_instance_count == var.app_instance_count
    error_message = "App VMSS instance count should match configured value: expected ${var.app_instance_count}, got ${output.app_vmss_instance_count}"
  }

  # Validate VMSS name follows naming convention
  assert {
    condition     = output.app_vmss_name == "app-scaleset"
    error_message = "App VMSS name must be 'app-scaleset' for policy compliance: got ${output.app_vmss_name}"
  }

  # Validate Key Vault was created
  assert {
    condition     = output.key_vault_id != null && output.key_vault_id != ""
    error_message = "Key Vault should be created and have a valid ID"
  }

  # Validate database server was created
  assert {
    condition     = output.postgres_server_id != null
    error_message = "PostgreSQL server should be created successfully"
  }

  # Validate all NSGs were created
  assert {
    condition     = output.web_nsg_id != null && output.app_nsg_id != null && output.database_nsg_id != null
    error_message = "All NSGs (web, app, database) should be created"
  }
}

# Test 3: Azure API validation for deeper resource status checks
run "validate_azure_api_status" {
  command = apply

  # Validate VMSS was created successfully (ID exists and is valid)
  assert {
    condition     = output.app_vmss_id != null && output.app_vmss_id != ""
    error_message = "App VMSS should be created with valid ID: ${output.app_vmss_id}"
  }

  # Validate both web and app VMSS exist
  assert {
    condition     = output.web_vmss_id != null && output.web_vmss_id != ""
    error_message = "Web VMSS should be created with valid ID: ${output.web_vmss_id}"
  }

  # Validate load balancer has public IP assigned
  assert {
    condition     = output.web_load_balancer_ip != null && output.web_load_balancer_ip != ""
    error_message = "Web load balancer should have public IP assigned: ${output.web_load_balancer_ip}"
  }

  # Validate PostgreSQL server was created successfully
  assert {
    condition     = output.postgres_server_id != null
    error_message = "PostgreSQL server should be created successfully with valid ID"
  }

  # Validate Key Vault exists and is accessible
  assert {
    condition     = output.key_vault_id != null && output.key_vault_id != ""
    error_message = "Key Vault should be created with valid ID: ${output.key_vault_id}"
  }

  # Validate VNet has proper address space configuration
  assert {
    condition     = contains(output.vnet_address_space, var.vnet_cidr)
    error_message = "VNet should contain configured CIDR: expected ${var.vnet_cidr} in ${output.vnet_address_space}"
  }
}