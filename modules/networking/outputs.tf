output "vnet_id" {
  description = "ID of the Virtual Network"
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "Name of the Virtual Network"
  value       = azurerm_virtual_network.main.name
}

output "vnet_address_space" {
  description = "Address space of the Virtual Network"
  value       = azurerm_virtual_network.main.address_space
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = azurerm_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = azurerm_subnet.private[*].id
}

output "database_subnet_ids" {
  description = "IDs of the database subnets"
  value       = azurerm_subnet.database[*].id
}

output "public_subnet_names" {
  description = "Names of the public subnets"
  value       = azurerm_subnet.public[*].name
}

output "private_subnet_names" {
  description = "Names of the private subnets"
  value       = azurerm_subnet.private[*].name
}

output "database_subnet_names" {
  description = "Names of the database subnets"
  value       = azurerm_subnet.database[*].name
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = var.enable_nat_gateway ? azurerm_nat_gateway.main[0].id : null
}

output "nat_gateway_public_ip" {
  description = "Public IP address of the NAT Gateway"
  value       = var.enable_nat_gateway ? azurerm_public_ip.nat_gateway[0].ip_address : null
}

output "nat_gateway_public_ip_id" {
  description = "Resource ID of the NAT Gateway Public IP"
  value       = var.enable_nat_gateway ? azurerm_public_ip.nat_gateway[0].id : null
}

output "public_nsg_id" {
  description = "ID of the public network security group"
  value       = azurerm_network_security_group.public.id
}

output "private_nsg_id" {
  description = "ID of the private network security group"
  value       = azurerm_network_security_group.private.id
}

output "database_nsg_id" {
  description = "ID of the database network security group"
  value       = azurerm_network_security_group.database.id
}