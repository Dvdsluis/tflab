output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}

output "web_url" {
  description = "URL of the web application"
  value       = "http://${module.compute.web_load_balancer_dns}"
}

output "web_load_balancer_dns" {
  description = "DNS name of the web load balancer"
  value       = module.compute.web_load_balancer_dns
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.networking.public_subnet_ids
}