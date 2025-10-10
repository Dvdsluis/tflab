# Database Module (Azure)
# This module creates an Azure Database for MySQL or PostgreSQL with proper security and backup configurations

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

# Data source to get current Azure client configuration
data "azurerm_client_config" "current" {}

# Key Vault for secure password storage (compliant with Azure policies)
resource "azurerm_key_vault" "database" {
  name                       = "${substr(replace(var.name_prefix, "-", ""), 0, 15)}-kv"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard" # Policy requirement: Standard tier
  soft_delete_retention_days = 7          # Policy requirement: 7 days retention
  purge_protection_enabled   = false      # Policy requirement: Purge protection must be disabled

  # Access policy for Terraform service principal
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete",
      "Recover",
      "Backup",
      "Restore"
    ]
  }

  lifecycle {
    precondition {
      condition     = length("${substr(replace(var.name_prefix, "-", ""), 0, 15)}-kv") <= 24
      error_message = "Key Vault name must be 24 characters of less: ${substr(replace(var.name_prefix, "-", ""), 0, 15)}-kv"
    }

    postcondition {
      condition     = self.purge_protection_enabled == false
      error_message = "Key Vault purge protection moet uitgeschakeld zijn volgens policy."
    }
  }

  tags = var.tags
}

# Generate random password for DB admin
resource "random_password" "db_password" {
  length  = 16
  special = true
}

# Store password in Azure Key Vault
resource "azurerm_key_vault_secret" "db_password" {
  name            = "${var.name_prefix}-db-password"
  value           = random_password.db_password.result
  key_vault_id    = azurerm_key_vault.database.id
  expiration_date = timeadd(timestamp(), "${var.secret_expiration_hours}h")

  tags = var.tags
}

# Network Security Group for DB
resource "azurerm_network_security_group" "database" {
  name                = "${var.name_prefix}-db-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = var.engine == "mysql" ? "Allow-MySQL" : "Allow-Postgres"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = var.engine == "mysql" ? "3306" : "5432"
    source_address_prefix      = var.allowed_cidr
    destination_address_prefix = "*"
    description                = var.engine == "mysql" ? "Allow MySQL from app subnet" : "Allow PostgreSQL from app subnet"
  }

  tags = var.tags
}

# Azure Database for MySQL Flexible Server
resource "azurerm_mysql_flexible_server" "main" {
  count                  = var.engine == "mysql" ? 1 : 0
  name                   = "${var.name_prefix}-mysql"
  resource_group_name    = var.resource_group_name
  location               = var.location
  administrator_login    = var.username
  administrator_password = random_password.db_password.result
  sku_name               = var.sku_name
  version                = var.engine_version
  storage {
    size_gb = var.allocated_storage
  }
  backup_retention_days = var.backup_retention_period
  zone                  = var.zone
  delegated_subnet_id   = var.db_subnet_id

  # High availability disabled per policy requirements
  dynamic "high_availability" {
    for_each = var.high_availability == "Enabled" ? [1] : []
    content {
      mode = "ZoneRedundant"
    }
  }

  tags = var.tags
}

# Azure Database for PostgreSQL Flexible Server
resource "azurerm_postgresql_flexible_server" "main" {
  count                  = 0
  name                   = "${var.name_prefix}-postgres"
  resource_group_name    = var.resource_group_name
  location               = var.location
  administrator_login    = var.username
  administrator_password = random_password.db_password.result
  sku_name               = var.sku_name
  version                = var.engine_version
  storage_mb             = var.allocated_storage * 1024
  backup_retention_days  = var.backup_retention_period
  zone                   = var.zone
  delegated_subnet_id    = var.db_subnet_id

  # High availability disabled per policy requirements
  dynamic "high_availability" {
    for_each = var.high_availability == "Enabled" ? [1] : []
    content {
      mode = "ZoneRedundant"
    }
  }

  tags = var.tags
}