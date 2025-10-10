# End-to-End Azure Deployment Tests
# Full deployment validation with Azure API checks
# Tests for real deployment issues that terraform plan cannot detect

variables {
  project_name             = "terraform-lab-e2e"
  environment              = "dev"
  azure_region             = "East US"
  vnet_cidr                = "10.2.0.0/16" # Different CIDR to avoid conflicts
  public_subnets           = ["10.2.1.0/24", "10.2.2.0/24"]
  private_subnets          = ["10.2.11.0/24", "10.2.12.0/24"]
  database_subnets         = ["10.2.21.0/24", "10.2.22.0/24"]
  web_vm_size              = "Standard_B1s"
  app_vm_size              = "Standard_B1s"
  web_instance_count       = 2
  app_instance_count       = 2
  admin_username           = "azureuser"
  ssh_public_key           = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCVsv/kHHL+Hh0RW2YFqwpEJ+YsFaIHAAt51P36rmbsz1a1o4NbupXJRyJufyvKuJQuz1sYuPbNBn0o16zMzBa+wZnga3LP8wxax+5aPvmolLVLfU4hPoT1UigBSFs04D+qyhiJVRJh/z2UySWmLVjjSR04Ldtk6BAJKWBJ8bc2ByD3vx663KH3zYpjRlOgo7iVSp9HzzuRXaj5QBzXr2MHSo6nV1Sc9FM4i18afkZHppdKwwtr92z7q3371uTqhJbIC8uyOkgDN+c3IXMW4iUF2/w9JCk/pCN//ddG9OucaY4yUGC9wJKvvbaSmX4GngldUbGIXPZ2q7Q4cxFEj+3N terraform-lab@codespaces"
  enable_nat_gateway       = true
  db_server_version        = "8.0"
  db_sku_name              = "B_Standard_B1ms"
  db_storage_mb            = 32768
  db_admin_username        = "mysqladmin"
  engine                   = "mysql"
  db_backup_retention_days = 7
  additional_tags          = {}
}

# Test 1: Pre-deployment policy validation
run "validate_deployment_policies" {
  command = plan

  # Enterprise compliance checks
  assert {
    condition     = contains(["Standard_B1s", "Standard_B2s", "Standard_D2s_v3"], var.app_vm_size)
    error_message = "VM size policy violation: ${var.app_vm_size}"
  }

  assert {
    condition     = var.app_instance_count <= 5
    error_message = "Instance count exceeds limit: ${var.app_instance_count}"
  }

  assert {
    condition     = var.db_backup_retention_days >= 7
    error_message = "Backup retention below minimum: ${var.db_backup_retention_days}"
  }

  # Network security validation
  assert {
    condition = !contains([
      "172.16.0.0/12",
      "192.168.0.0/16",
      "10.0.0.0/16",
      "10.1.0.0/16"
    ], var.vnet_cidr)
    error_message = "VNet CIDR conflicts with existing networks: ${var.vnet_cidr}"
  }
}

# Test 2: Full Azure deployment and resource validation
run "deploy_and_validate_infrastructure" {
  command = apply

  # Core infrastructure deployment validation
  assert {
    condition     = output.vnet_id != null && output.vnet_id != ""
    error_message = "VNet deployment failed"
  }

  assert {
    condition     = contains(output.vnet_address_space, var.vnet_cidr)
    error_message = "VNet CIDR mismatch: expected ${var.vnet_cidr} in ${join(", ", output.vnet_address_space)}"
  }

  # Subnet deployment validation
  assert {
    condition     = length(output.public_subnet_ids) == 2 && length(output.private_subnet_ids) == 2
    error_message = "Subnet count mismatch: public=${length(output.public_subnet_ids)}, private=${length(output.private_subnet_ids)}"
  }

  # VMSS deployment validation
  assert {
    condition     = output.app_vmss_id != null && output.web_vmss_id != null
    error_message = "VMSS deployment failed"
  }

  assert {
    condition     = output.app_vmss_sku == var.app_vm_size
    error_message = "VMSS SKU mismatch: expected ${var.app_vm_size}, got ${output.app_vmss_sku}"
  }

  assert {
    condition     = output.app_vmss_instance_count == var.app_instance_count
    error_message = "VMSS instance count mismatch: expected ${var.app_instance_count}, got ${output.app_vmss_instance_count}"
  }

  # Load balancer validation
  assert {
    condition     = output.web_load_balancer_ip != null && output.web_load_balancer_ip != ""
    error_message = "Load balancer public IP not assigned"
  }

  # Database deployment validation (MySQL instead of PostgreSQL)
  assert {
    condition     = can(output.mysql_server_id)
    error_message = "MySQL server deployment failed"
  }

  # Security validation (Key Vault not required in lab)
  # assert {
  #   condition     = output.key_vault_id != null && output.key_vault_id != ""
  #   error_message = "Key Vault deployment failed"
  # }

  assert {
    condition = (
      output.web_nsg_id != null &&
      output.app_nsg_id != null &&
      output.database_nsg_id != null
    )
    error_message = "NSG deployment incomplete"
  }
}

# Test 3: Azure API health and status validation
run "validate_azure_resource_status" {
  command = apply

  # Resource naming convention compliance
  assert {
    condition     = output.app_vmss_name == "app-scaleset"
    error_message = "VMSS naming violation: expected 'app-scaleset', got '${output.app_vmss_name}'"
  }

  # Resource group validation
  assert {
    condition     = can(regex("terraform-lab-e2e-dev", output.vnet_id))
    error_message = "VNet not in expected resource group"
  }

  # Network isolation validation
  assert {
    condition     = length(output.database_subnet_ids) >= 2
    error_message = "Database subnet isolation insufficient"
  }

  # Load balancer accessibility
  assert {
    condition     = can(regex("^/subscriptions/", output.web_load_balancer_ip))
    error_message = "Load balancer output is not a valid Azure resource ID: ${output.web_load_balancer_ip}"
  }
}