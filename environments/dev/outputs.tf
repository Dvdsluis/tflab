# VMSS Policy Outputs (for enterprise compliance)
output "app_vmss_sku" {
  description = "SKU of the app VM scale set"
  value       = module.compute.app_vmss_sku
  
  precondition {
    condition     = contains(["Standard_B1s", "Standard_B1ms", "Standard_B2s"], module.compute.app_vmss_sku)
    error_message = "App VMSS SKU must be an approved size for cost control"
  }
}

output "app_vmss_name" {
  description = "Name of the app VM scale set"
  value       = module.compute.app_vmss_name
  
  precondition {
    condition     = can(regex("^[a-zA-Z0-9-]+$", module.compute.app_vmss_name))
    error_message = "App VMSS name must follow naming conventions (alphanumeric and hyphens only)"
  }
}

output "app_vmss_instance_count" {
  description = "Instance count of the app VM scale set"
  value       = module.compute.app_vmss_instance_count
  
  precondition {
    condition     = module.compute.app_vmss_instance_count >= 2 && module.compute.app_vmss_instance_count <= 10
    error_message = "App VMSS instance count must be between 2-10 for operational requirements"
  }
}

# VNet Outputs (Azure Virtual Network)
output "vnet_id" {
  description = "ID of the Virtual Network"
  value       = module.networking.vnet_id
  
  precondition {
    condition     = can(regex("^/subscriptions/.*/resourceGroups/.*/providers/Microsoft.Network/virtualNetworks/.*", module.networking.vnet_id))
    error_message = "VNet ID must be a valid Azure resource identifier"
  }
}

output "vnet_address_space" {
  description = "Address space of the Virtual Network"
  value       = module.networking.vnet_address_space
}

# Subnet Outputs
output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.networking.private_subnet_ids
}

output "database_subnet_ids" {
  description = "IDs of the database subnets"
  value       = module.networking.database_subnet_ids
}

# Compute Outputs (Azure VMSS and Load Balancers)
output "web_load_balancer_id" {
  description = "ID of the web load balancer"
  value       = module.compute.web_lb_id
}

output "web_load_balancer_ip" {
  description = "Public IP of the web load balancer"
  value       = module.compute.web_lb_public_ip
}

output "web_vmss_id" {
  description = "ID of the web VM scale set"
  value       = module.compute.web_vmss_id
}

output "app_vmss_id" {
  description = "ID of the app VM scale set"
  value       = module.compute.app_vmss_id
}

# Database Outputs (Azure Database Flexible Server)
output "key_vault_id" {
  description = "ID of the Key Vault for database secrets"
  value       = module.database.key_vault_id
}

output "postgres_server_id" {
  description = "ID of the PostgreSQL Flexible Server"
  value       = module.database.postgres_server_id
  sensitive   = true
}

# Security Group Outputs (Azure NSGs)
output "web_nsg_id" {
  description = "ID of the web network security group"
  value       = module.compute.web_nsg_id
}

output "app_nsg_id" {
  description = "ID of the app network security group"
  value       = module.compute.app_nsg_id
}

output "database_nsg_id" {
  description = "ID of the database network security group"
  value       = module.database.database_nsg_id
}