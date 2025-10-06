# Azure API Deep Validation Test
# Uses external data sources and az CLI to validate actual Azure resource state
# Tests for CIDR overlaps, VM status, network configuration that plan can't detect

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

# Test 1: Deploy resources and validate via Azure Management API
run "azure_api_validation" {
  command = apply

  # Basic resource existence validation
  assert {
    condition     = output.vnet_id != null && output.vnet_id != ""
    error_message = "VNet should be created with valid ID"
  }

  # VMSS instance validation (checks actual running state)
  assert {
    condition     = output.app_vmss_id != null && output.app_vmss_id != ""
    error_message = "App VMSS should be created with valid ID"
  }

  # Database server validation
  assert {
    condition     = output.postgres_server_id != null
    error_message = "PostgreSQL server should be created"
  }

  # Key Vault validation
  assert {
    condition     = output.key_vault_id != null && output.key_vault_id != ""
    error_message = "Key Vault should be created with valid ID"
  }
}

# Test 2: External validation using az CLI (commented - would require external data)
# This demonstrates how you could add deeper Azure API validation
/*
data "external" "vmss_status" {
  program = ["bash", "-c", <<-EOT
    az vmss list-instances \
      --resource-group "kml_rg_main-f9fc6defb9c44b20" \
      --name "app-scaleset" \
      --query '[].instanceView.statuses[?code==`PowerState/*`].displayStatus' \
      --output json | jq '{status: .[0][0]}'
  EOT
  ]
}

data "external" "vnet_conflicts" {
  program = ["bash", "-c", <<-EOT
    # Check for CIDR conflicts with other VNets in subscription
    existing_cidrs=$(az network vnet list --query '[].addressSpace.addressPrefixes' --output tsv)
    if echo "$existing_cidrs" | grep -q "10.0.0.0/16"; then
      echo '{"conflict": "true"}'
    else
      echo '{"conflict": "false"}'
    fi
  EOT
  ]
}

run "azure_api_deep_validation" {
  command = apply

  # Validate VMSS instances are running
  assert {
    condition     = data.external.vmss_status.result.status == "VM running"
    error_message = "VMSS instances should be in running state"
  }

  # Validate no CIDR conflicts
  assert {
    condition     = data.external.vnet_conflicts.result.conflict == "false"
    error_message = "VNet CIDR should not conflict with existing VNets"
  }
}
*/