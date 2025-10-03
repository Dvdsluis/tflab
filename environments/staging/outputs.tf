# Staging Environment Outputs

# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = module.networking.vpc_cidr_block
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

# Compute Outputs
output "web_load_balancer_dns" {
  description = "DNS name of the web load balancer"
  value       = module.compute.web_load_balancer_dns
}

output "web_url" {
  description = "URL of the web application"
  value       = "http://${module.compute.web_load_balancer_dns}"
}

output "app_load_balancer_dns" {
  description = "DNS name of the app load balancer"
  value       = module.compute.app_load_balancer_dns
}

# Database Outputs
output "database_endpoint" {
  description = "Database endpoint"
  value       = module.database.database_endpoint
  sensitive   = true
}

output "database_read_replica_endpoint" {
  description = "Database read replica endpoint"
  value       = module.database.read_replica_endpoint
  sensitive   = true
}

output "database_port" {
  description = "Database port"
  value       = module.database.database_port
}

output "database_name" {
  description = "Database name"
  value       = module.database.database_name
}

# Security Group Outputs
output "web_security_group_id" {
  description = "ID of the web security group"
  value       = module.compute.web_security_group_id
}

output "app_security_group_id" {
  description = "ID of the app security group"
  value       = module.compute.app_security_group_id
}

output "database_security_group_id" {
  description = "ID of the database security group"
  value       = module.database.database_security_group_id
}