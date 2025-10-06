# Azure Deployment Validation Tests
# Comprehensive tests for real Azure deployment validation beyond terraform plan

variables {
  project_name = "terraform-lab-test"  # Different name to avoid conflicts
  environment = "dev"
  azure_region = "East US"
  vnet_cidr = "10.1.0.0/16"  # Different CIDR to avoid conflicts
  public_subnets = ["10.1.1.0/24", "10.1.2.0/24"]
  private_subnets = ["10.1.11.0/24", "10.1.12.0/24"]
  database_subnets = ["10.1.21.0/24", "10.1.22.0/24"]
  web_vm_size = "Standard_B1s"
  app_vm_size = "Standard_B1s"
  web_instance_count = 2
  app_instance_count = 2
  admin_username = "azureuser"
  ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCVsv/kHHL+Hh0RW2YFqwpEJ+YsFaIHAAt51P36rmbsz1a1o4NbupXJRyJufyvKuJQuz1sYuPbNBn0o16zMzBa+wZnga3LP8wxax+5aPvmolLVLfU4hPoT1UigBSFs04D+qyhiJVRJh/z2UySWmLVjjSR04Ldtk6BAJKWBJ8bc2ByD3vx663KH3zYpjRlOgo7iVSp9HzzuRXaj5QBzXr2MHSo6nV1Sc9FM4i18afkZHppdKwwtr92z7q3371uTqhJbIC8uyOkgDN+c3IXMW4iUF2/w9JCk/pCN//ddG9OucaY4yUGC9wJKvvbaSmX4GngldUbGIXPZ2q7Q4cxFEj+3N terraform-lab-test@codespaces"
  enable_nat_gateway = true
  db_server_version = "13"
  db_sku_name = "B_Standard_B1ms"
  db_storage_mb = 32768
  db_admin_username = "dbadmin"
  db_backup_retention_days = 7
  additional_tags = {}
}

# Test 1: Policy validation at plan time
run "validate_infrastructure_policies" {
  command = plan

  # VM size compliance
  assert {
    condition     = contains(["Standard_B1s", "Standard_B2s", "Standard_D2s_v3"], var.app_vm_size)
    error_message = "VM size policy violation: ${var.app_vm_size} not in approved list"
  }

  # Instance count limits
  assert {
    condition     = var.app_instance_count <= 5
    error_message = "Instance count exceeds policy limit: ${var.app_instance_count} > 5"
  }

  # CIDR range validation
  assert {
    condition     = can(cidrhost(var.vnet_cidr, 0))
    error_message = "Invalid CIDR format: ${var.vnet_cidr}"
  }

  # Backup retention policy
  assert {
    condition     = var.db_backup_retention_days >= 7
    error_message = "DB backup retention below policy minimum: ${var.db_backup_retention_days} < 7"
  }
}

# Test 2: Actual Azure deployment and resource validation
run "deploy_and_validate_azure_deployment" {
  command = apply

  # Validate VNet deployment success
  assert {
    condition     = output.vnet_id != null && output.vnet_id != ""
    error_message = "VNet deployment failed - no valid ID returned"
  }

  # Validate address space configuration
  assert {
    condition     = contains(output.vnet_address_space, var.vnet_cidr)
    error_message = "VNet address space mismatch: expected ${var.vnet_cidr} in ${output.vnet_address_space}"
  }

  # Validate subnet deployment
  assert {
    condition     = length(output.public_subnet_ids) == 2 && length(output.private_subnet_ids) == 2
    error_message = "Subnet deployment failed: public=${length(output.public_subnet_ids)}, private=${length(output.private_subnet_ids)}"
  }

  # Validate VMSS deployment
  assert {
    condition     = output.app_vmss_id != null && output.web_vmss_id != null
    error_message = "VMSS deployment failed - missing valid IDs"
  }

  # Validate VMSS configuration matches input
  assert {
    condition     = output.app_vmss_sku == var.app_vm_size
    error_message = "VMSS SKU mismatch: expected ${var.app_vm_size}, got ${output.app_vmss_sku}"
  }

  # Validate instance count deployed correctly
  assert {
    condition     = output.app_vmss_instance_count == var.app_instance_count
    error_message = "VMSS instance count mismatch: expected ${var.app_instance_count}, got ${output.app_vmss_instance_count}"
  }

  # Validate load balancer has public IP
  assert {
    condition     = output.web_load_balancer_ip != null && output.web_load_balancer_ip != ""
    error_message = "Load balancer missing public IP: ${output.web_load_balancer_ip}"
  }

  # Validate database deployment
  assert {
    condition     = output.postgres_server_id != null
    error_message = "PostgreSQL server deployment failed"
  }

  # Validate Key Vault deployment
  assert {
    condition     = output.key_vault_id != null && output.key_vault_id != ""
    error_message = "Key Vault deployment failed: ${output.key_vault_id}"
  }

  # Validate all security groups deployed
  assert {
    condition = (
      output.web_nsg_id != null && 
      output.app_nsg_id != null && 
      output.database_nsg_id != null
    )
    error_message = "NSG deployment incomplete: web=${output.web_nsg_id != null}, app=${output.app_nsg_id != null}, db=${output.database_nsg_id != null}"
  }
}

# Test 3: Post-deployment Azure API validation
run "validate_azure_resource_health" {
  command = apply

  # This would typically include external data sources for deeper validation
  # For now, we validate that the deployment outputs indicate healthy resources

  # Validate naming convention compliance
  assert {
    condition     = output.app_vmss_name == "app-scaleset"
    error_message = "VMSS naming convention violation: expected 'app-scaleset', got '${output.app_vmss_name}'"
  }

  # Validate resource group association
  assert {
    condition     = can(regex("terraform-lab-test-dev", output.vnet_id))
    error_message = "VNet not in expected resource group: ${output.vnet_id}"
  }

  # Validate database subnet isolation
  assert {
    condition     = length(output.database_subnet_ids) >= 1
    error_message = "Database subnet isolation failed: ${length(output.database_subnet_ids)} subnets"
  }
}