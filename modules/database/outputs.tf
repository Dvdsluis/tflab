output "database_nsg_id" {
  description = "ID of the database network security group"
  value       = azurerm_network_security_group.database.id
}

output "key_vault_id" {
  description = "ID of the Key Vault created for database secrets"
  value       = azurerm_key_vault.database.id
}

output "key_vault_uri" {
  description = "URI of the Key Vault created for database secrets"
  value       = azurerm_key_vault.database.vault_uri
}

output "database_password_secret_id" {
  description = "ID of the Key Vault secret containing the database password"
  value       = azurerm_key_vault_secret.db_password.id
  sensitive   = true
}

output "mysql_server_id" {
  description = "ID of the Azure MySQL Flexible Server (if MySQL)"
  value       = try(azurerm_mysql_flexible_server.main[0].id, null)
}

output "postgres_server_id" {
  description = "ID of the Azure PostgreSQL Flexible Server (if Postgres)"
  value       = try(azurerm_postgresql_flexible_server.main[0].id, null)
}