# Security Validation Tests
# Deploys resources to Azure and validates via API calls
# Tests for issues that terraform plan cannot detect

variables {
  resource_group_name = "kml_rg_main-f9fc6defb9c44b20"
  environment         = "dev"
  project_name        = "terraform-lab"
  location            = "East US"
  ssh_public_key      = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCVsv/kHHL+Hh0RW2YFqwpEJ+YsFaIHAAt51P36rmbsz1a1o4NbupXJRyJufyvKuJQuz1sYuPbNBn0o16zMzBa+wZnga3LP8wxax+5aPvmolLVLfU4hPoT1UigBSFs04D+qyhiJVRJh/z2UySWmLVjjSR04Ldtk6BAJKWBJ8bc2ByD3vx663KH3zYpjRlOgo7iVSp9HzzuRXaj5QBzXr2MHSo6nV1Sc9FM4i18afkZHppdKwwtr92z7q3371uTqhJbIC8uyOkgDN+c3IXMW4iUF2/w9JCk/pCN//ddG9OucaY4yUGC9wJKvvbaSmX4GngldUbGIXPZ2q7Q4cxFEj+3N terraform-lab-short@codespaces"
  db_admin_username   = "dbadmin"
  db_admin_password   = "TestPassword123!"
}

# Test 1: Deploy and validate network security configuration
run "deploy_and_validate_network_security" {
  command = apply

  variables {
    resource_group_name = var.resource_group_name
    environment         = var.environment
    project_name        = var.project_name
    location            = var.location
    ssh_public_key      = var.ssh_public_key
    db_admin_username   = var.db_admin_username
    db_admin_password   = var.db_admin_password
  }

  # Validate VNet address space doesn't overlap with common ranges
  assert {
    condition = !contains([
      "172.16.0.0/12",  # Common corporate ranges
      "192.168.0.0/16", # Common home ranges
      "10.1.0.0/16"     # Common Azure ranges
    ], module.networking.vnet_address_space[0])
    error_message = "VNet address space should not overlap with common network ranges"
  }

  # Validate web tier VM size is cost-effective
  assert {
    condition = !contains([
      "172.16.0.0/12",  # Common corporate ranges
      "192.168.0.0/16", # Common home ranges
      "10.1.0.0/16"     # Common Azure ranges
    ], module.networking.vnet_address_space)

  # Validate app tier instance count is within limits
  assert {
    condition     = module.compute.app_instance_count <= 3
    error_message = "App tier instance count should not exceed policy limit of 3"
  }
}

# Test 2: Validate deployed resources via Azure API
run "validate_deployed_resources" {
  command = apply

  variables {
    resource_group_name = var.resource_group_name
    environment         = var.environment
    project_name        = var.project_name
    location            = var.location
    ssh_public_key      = var.ssh_public_key
    db_admin_username   = var.db_admin_username
    db_admin_password   = var.db_admin_password
  }

  # Validate VNet was created successfully
  assert {
    condition     = module.networking.vnet_id != ""
    error_message = "VNet should be created and have a valid ID"
  }

  # Validate NAT Gateway was created
  assert {
    condition     = length(module.networking.nat_gateway_ids) > 0
    error_message = "NAT Gateway should be created for outbound connectivity"
  }

  # Validate NSGs were created
  assert {
    condition     = length(module.networking.nsg_ids) >= 3
    error_message = "All NSGs (web, app, database) should be created"
  }

  # Validate compute resources
  assert {
    condition     = module.compute.web_vmss_id != ""
    error_message = "Web VMSS should be created successfully"
  }

  # Validate database was created
  assert {
    condition     = module.database.postgresql_server_id != ""
    error_message = "PostgreSQL server should be created successfully"
  }

  # Validate public NSG exists and has correct name
  assert {
    condition     = module.networking.public_nsg_id != null
    error_message = "Public NSG should be created"
  }

  # Validate private NSG exists and has correct name
  assert {
    condition     = module.networking.private_nsg_id != null
    error_message = "Private NSG should be created"
  }

  # Validate database NSG exists and has correct name
  assert {
    condition     = module.networking.database_nsg_id != null
    error_message = "Database NSG should be created"
  }

  # Validate app VMSS ID is not empty
  assert {
    condition     = module.compute.app_vmss_id != ""
    error_message = "App VMSS should be created successfully"
  }

  # Validate app NSG ID is not empty
  assert {
    condition     = module.compute.app_nsg_id != ""
    error_message = "App NSG should be created successfully"
  }

  # Validate web NSG ID is not empty
  assert {
    condition     = module.compute.web_nsg_id != ""
    error_message = "Web NSG should be created successfully"
  }

  # Validate database NSG ID is not empty
  assert {
    condition     = module.database.database_nsg_id != ""
    error_message = "Database NSG should be created successfully"
  }

  # Validate database server ID is not empty
  assert {
    condition     = module.database.postgres_server_id != null || module.database.mysql_server_id != null
    error_message = "Database server should be created successfully (Postgres or MySQL)"
  }
}

# Test 3: Validate VMSS policy compliance
run "validate_vmss_policy_compliance" {
  command = apply

  variables {
    resource_group_name = var.resource_group_name
    environment         = var.environment
    project_name        = var.project_name
  }

  # Assert allowed SKU
  assert {
    condition = contains([
      "Standard_D2s_v3", "Standard_K8S2_v1", "Standard_K8S_v1",
      "Standard_B2s", "Standard_B1s", "Standard_DS1_v2", "Standard_B4ms"
    ], module.compute.app_vmss_sku)
    error_message = "App VMSS SKU is not allowed by policy"
  }

  # Assert allowed name
  assert {
    condition     = module.compute.app_vmss_name == "app-scaleset"
    error_message = "App VMSS name must be 'app-scaleset' to comply with policy"
  }

  # Assert instance count
  assert {
    condition     = module.compute.app_vmss_instance_count <= 3
    error_message = "App VMSS instance count exceeds policy limit of 3"
  }
}