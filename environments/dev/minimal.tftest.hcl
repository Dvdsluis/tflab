# Minimal Test for Development Environment
# Lightweight test for quick validation during development

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
  web_instance_count       = 1
  app_instance_count       = 1
  admin_username           = "azureuser"
  ssh_public_key           = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCVsv/kHHL+Hh0RW2YFqwpEJ+YsFaIHAAt51P36rmbsz1a1o4NbupXJRyJufyvKuJQuz1sYuPbNBn0o16zMzBa+wZnga3LP8wxax+5aPvmolLVLfU4hPoT1UigBSFs04D+qyhiJVRJh/z2UySWmLVjjSR04Ldtk6BAJKWBJ8bc2ByD3vx663KH3zYpjRlOgo7iVSp9HzzuRXaj5QBzXr2MHSo6nV1Sc9FM4i18afkZHppdKwwtr92z7q3371uTqhJbIC8uyOkgDN+c3IXMW4iUF2Sc9FM4i18afkZHppdKwwtr92z7q3371uTqhJbIC8uyOkgDN+c3IXMW4iUF2/w9JCk/pCN//ddG9OucaY4yUGC9wJKvvbaSmX4GngldUbGIXPZ2q7Q4cxFEj+3N terraform-lab@codespaces"
  enable_nat_gateway       = true
  engine                   = "mysql"
  db_server_version        = "8.0"
  db_sku_name              = "B_Standard_B1ms"
  db_storage_mb            = 32768
  db_admin_username        = "mysqladmin"
  db_backup_retention_days = 7
  additional_tags          = {}
}

# Minimal validation test - just check configuration syntax
run "validate_minimal_configuration" {
  command = plan

  # Basic configuration validation
  assert {
    condition     = var.project_name != null && var.project_name != ""
    error_message = "Project name must be defined"
  }

  assert {
    condition     = var.environment == "dev"
    error_message = "Environment must be 'dev' for this test"
  }

  assert {
    condition     = length(var.public_subnets) > 0 && length(var.private_subnets) > 0
    error_message = "Must have at least one public and private subnet defined"
  }

  # Resource count validation (minimal for dev)
  assert {
    condition     = var.web_instance_count >= 1 && var.app_instance_count >= 1
    error_message = "Must have at least 1 instance for web and app tiers"
  }
}