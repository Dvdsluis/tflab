output "web_nsg_id" {
  description = "ID of the web network security group"
  value       = azurerm_network_security_group.web.id
}

output "app_nsg_id" {
  description = "ID of the app network security group"
  value       = azurerm_network_security_group.app.id
}

output "web_vmss_id" {
  description = "ID of the web VM scale set"
  value       = azurerm_linux_virtual_machine_scale_set.web.id
}

output "app_vmss_id" {
  description = "ID of the app VM scale set"
  value       = azurerm_linux_virtual_machine_scale_set.app.id
}

output "web_lb_id" {
  description = "ID of the web load balancer"
  value       = azurerm_lb.web.id
}

output "app_lb_id" {
  description = "ID of the app load balancer"
  value       = azurerm_lb.app.id
}

output "web_lb_public_ip" {
  description = "Public IP of the web load balancer"
  value       = var.web_public_ip_id
}