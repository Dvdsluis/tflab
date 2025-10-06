# Security Validation Tests - Plan Time
# Tests variables and plan-time validation
# For testing infrastructure policies without deployment

variables {
  project_name = "terraform-lab"
  environment = "dev"
  azure_region = "East US"
  vnet_cidr = "10.0.0.0/16"
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.11.0/24", "10.0.12.0/24"]
  database_subnets = ["10.0.21.0/24", "10.0.22.0/24"]
  web_vm_size = "Standard_B1s"
  app_vm_size = "Standard_B1s"
  web_instance_count = 2
  app_instance_count = 2
  admin_username = "azureuser"
  ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCVsv/kHHL+Hh0RW2YFqwpEJ+YsFaIHAAt51P36rmbsz1a1o4NbupXJRyJufyvKuJQuz1sYuPbNBn0o16zMzBa+wZnga3LP8wxax+5aPvmolLVLfU4hPoT1UigBSFs04D+qyhiJVRJh/z2UySWmLVjjSR04Ldtk6BAJKWBJ8bc2ByD3vx663KH3zYpjRlOgo7iVSp9HzzuRXaj5QBzXr2MHSo6nV1Sc9FM4i18afkZHppdKwwtr92z7q3371uTqhJbIC8uyOkgDN+c3IXMW4iUF2/w9JCk/pCN//ddG9OucaY4yUGC9wJKvvbaSmX4GngldUbGIXPZ2q7Q4cxFEj+3N terraform-lab-short@codespaces"
  enable_nat_gateway = true
  db_server_version = "13"
  db_sku_name = "B_Standard_B1ms"
  db_storage_mb = 32768
  db_admin_username = "dbadmin"
  db_backup_retention_days = 7
  additional_tags = {}
}

# Test 1: Variable and policy validation
run "validate_variables_and_policies" {
  command = plan

  # Test VM size policy compliance
  assert {
    condition     = contains(["Standard_B1s", "Standard_B2s", "Standard_D2s_v3"], var.app_vm_size)
    error_message = "App VM size must be policy compliant"
  }

  # Test instance count policy
  assert {
    condition     = var.app_instance_count <= 3
    error_message = "App instance count should not exceed policy limit of 3"
  }

  # Test VNet CIDR validation
  assert {
    condition = !contains([
      "172.16.0.0/12",
      "192.168.0.0/16", 
      "10.1.0.0/16"
    ], var.vnet_cidr)
    error_message = "VNet CIDR should not overlap with common ranges"
  }

  # Test subnet count
  assert {
    condition     = length(var.public_subnets) >= 2 && length(var.private_subnets) >= 2
    error_message = "Must have at least 2 public and 2 private subnets"
  }

  # Test database configuration
  assert {
    condition     = var.db_backup_retention_days >= 7
    error_message = "Database backup retention must be at least 7 days"
  }
}