# Production Environment Outputs

# Networking Outputs
output "vnet_id" {
  description = "ID of the Virtual Network"
  value       = module.networking.vnet_id
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

# NAT Gateway Outputs
output "nat_gateway_public_ip" {
  description = "Public IP address of the NAT Gateway"
  value       = module.networking.nat_gateway_public_ip
}

# Security Group Outputs
output "public_nsg_id" {
  description = "ID of the public network security group"
  value       = module.networking.public_nsg_id
}

output "private_nsg_id" {
  description = "ID of the private network security group"
  value       = module.networking.private_nsg_id
}

output "database_nsg_id" {
  description = "ID of the database network security group"
  value       = module.networking.database_nsg_id
}

# Resource Group Output
output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_location" {
  description = "Location of the resource group"
  value       = azurerm_resource_group.main.location
}

# Common Tags Output
output "common_tags" {
  description = "Common tags applied to all resources"
  value       = local.common_tags
}