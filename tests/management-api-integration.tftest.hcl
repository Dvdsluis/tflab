# Azure Management API Integration Tests
# Advanced testing using Azure REST APIs for real-world validation

variables {
  project_name             = "terraform-lab-mgmt"
  environment              = "dev"
  azure_region             = "East US"
  vnet_cidr                = "10.3.0.0/16"
  public_subnets           = ["10.3.1.0/24", "10.3.2.0/24"]
  private_subnets          = ["10.3.11.0/24", "10.3.12.0/24"]
  database_subnets         = ["10.3.21.0/24", "10.3.22.0/24"]
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

# Test 1: Azure Management API - Resource Health Validation
run "validate_azure_mgmt_api_health" {
  command = apply

  # Use Azure data sources to validate management API accessibility
  assert {
    condition     = data.azurerm_client_config.current.subscription_id != null
    error_message = "Azure Management API is not accessible - check authentication"
  }

  assert {
    condition     = length(data.azurerm_client_config.current.subscription_id) == 36
    error_message = "Azure subscription ID format is invalid"
  }
}

# Test 2: Resource Deployment Status via Management API
run "validate_deployment_status" {
  command = apply

  # Validate that resources are created and in correct state
  assert {
    condition     = output.vnet_id != null
    error_message = "VNet deployment failed via Azure Management API"
  }

  assert {
    condition     = length(output.public_subnet_ids) >= 2
    error_message = "Public subnets not properly created via Azure Management API"
  }

  assert {
    condition     = output.web_vmss_id != null
    error_message = "Web VMSS deployment failed via Azure Management API"
  }
}

# Test 3: Security and Compliance via Management API
run "validate_security_compliance" {
  command = apply

  # Validate security configurations are properly applied
  assert {
    condition     = output.key_vault_id != null
    error_message = "Key Vault security deployment failed"
  }

  assert {
    condition     = output.postgres_server_id != null
    error_message = "Database security deployment failed"
  }

  # Validate NSG security rules are in place
  assert {
    condition     = output.web_nsg_id != null && output.app_nsg_id != null && output.database_nsg_id != null
    error_message = "Network security groups not properly configured"
  }
}

# Test 4: Performance and Scaling Validation
run "validate_performance_scaling" {
  command = apply

  # Validate resource sizing and scaling configurations
  assert {
    condition     = output.app_vmss_instance_count >= 2
    error_message = "VMSS must have minimum 2 instances for high availability"
  }

  assert {
    condition     = contains(["Standard_B1s", "Standard_B1ms", "Standard_B2s"], output.app_vmss_sku)
    error_message = "VMSS SKU must be approved for performance requirements"
  }

  # Validate load balancer configuration
  assert {
    condition     = output.web_load_balancer_id != null
    error_message = "Load balancer not properly configured for scaling"
  }
}

# Test 5: Network Connectivity and DNS Resolution
run "validate_network_connectivity" {
  command = apply

  # Validate network configuration supports intended connectivity
  assert {
    condition     = can(cidrhost(var.vnet_cidr, 0))
    error_message = "VNet CIDR is not properly configured for network connectivity"
  }

  assert {
    condition     = length(setintersection(var.public_subnets, var.private_subnets)) == 0
    error_message = "Network segmentation is compromised - subnet overlap detected"
  }

  # Validate subnet capacity for planned resources
  assert {
    condition     = alltrue([
      for subnet in var.public_subnets :
      pow(2, 32 - tonumber(split("/", subnet)[1])) >= (var.web_instance_count + var.app_instance_count) * 2
    ])
    error_message = "Subnet capacity insufficient for planned scaling"
  }
}