# Test for the database module

# Provider configuration for tests (lab: RG-only permissions)
provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
}

run "database_plan_test" {
  command = plan

  module {
    source = "../modules/database"
  }

  variables {
    name_prefix             = "test-db"
    resource_group_name     = "kml_rg_main-f9fc6defb9c44b20"
    location                = "East US"
    allowed_cidr            = "10.0.0.0/16"
    engine                  = "postgres"
    engine_version          = "13"
    sku_name                = "Standard_D2ds_v4"
    allocated_storage       = 32
    zone                    = null
    db_subnet_id            = "/subscriptions/sub/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/database-1"
    username                = "dbadmin"
    backup_retention_period = 7
    high_availability       = "Disabled"

    tags = {
      Environment = "test"
      Project     = "terraform-lab"
    }
    ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDtestkey user@host"
  }

  assert {
    condition     = azurerm_key_vault.database.sku_name == "standard"
    error_message = "Key Vault should use Standard tier for policy compliance"
  }

  assert {
    condition     = azurerm_key_vault.database.soft_delete_retention_days == 7
    error_message = "Key Vault should retain soft deletes for 7 days for policy compliance"
  }

  assert {
    condition     = azurerm_key_vault.database.purge_protection_enabled == false
    error_message = "Key Vault should have purge protection disabled for policy compliance"
  }

  assert {
    condition     = azurerm_postgresql_flexible_server.main[0].sku_name == "Standard_D2ds_v4"
    error_message = "PostgreSQL server should use correct SKU"
  }

  assert {
    condition     = azurerm_postgresql_flexible_server.main[0].version == "13"
    error_message = "PostgreSQL server should use correct version"
  }

  assert {
    condition     = azurerm_postgresql_flexible_server.main[0].administrator_login == "dbadmin"
    error_message = "PostgreSQL server should use correct admin username"
  }

  assert {
    condition     = random_password.db_password.length == 16
    error_message = "Database password should be 16 characters long"
  }

  # Security compliance: Key Vault secret should have expiration date
  assert {
    condition     = azurerm_key_vault_secret.db_password.expiration_date != null
    error_message = "Key Vault secret should have an expiration date for security compliance"
  }

  # Validate expiration is in the future
  assert {
    condition     = can(timeadd(timestamp(), "1h")) && timeadd(timestamp(), "1h") < azurerm_key_vault_secret.db_password.expiration_date
    error_message = "Key Vault secret expiration should be in the future"
  }

  assert {
    condition = length([
      for rule in azurerm_network_security_rule.database_inbound :
      rule if rule.destination_port_range == "5432"
    ]) >= 1
    error_message = "Database NSG should allow PostgreSQL traffic on port 5432"
  }
}

run "database_mysql_test" {
  command = plan

  module {
    source = "../modules/database"
  }

  variables {
    name_prefix             = "test-mysql"
    resource_group_name     = "kml_rg_main-f9fc6defb9c44b20"
    location                = "East US"
    allowed_cidr            = "10.0.0.0/16"
    engine                  = "mysql"
    engine_version          = "8.0"
    sku_name                = "Standard_D2ds_v4"
    allocated_storage       = 32
    zone                    = null
    db_subnet_id            = "/subscriptions/sub/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/database-1"
    username                = "dbadmin"
    backup_retention_period = 7
    high_availability       = "Disabled"
    tags                    = {}
    ssh_public_key          = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDtestkey user@host"
  }

  assert {
    condition     = azurerm_mysql_flexible_server.main[0].sku_name == "Standard_D2ds_v4"
    error_message = "MySQL server should use correct SKU"
  }

  assert {
    condition     = azurerm_mysql_flexible_server.main[0].version == "8.0"
    error_message = "MySQL server should use correct version"
  }

  assert {
    condition = length([
      for rule in azurerm_network_security_rule.database_inbound :
      rule if rule.destination_port_range == "3306"
    ]) >= 1
    error_message = "Database NSG should allow MySQL traffic on port 3306"
  }
}

run "database_validate_outputs" {
  command = plan

  module {
    source = "../modules/database"
  }

  variables {
    name_prefix             = "test-db"
    resource_group_name     = "kml_rg_main-f9fc6defb9c44b20"
    location                = "East US"
    allowed_cidr            = "10.0.0.0/16"
    engine                  = "postgres"
    engine_version          = "13"
    sku_name                = "Standard_D2ds_v4"
    allocated_storage       = 32
    zone                    = null
    db_subnet_id            = "/subscriptions/sub/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/database-1"
    username                = "dbadmin"
    backup_retention_period = 7
    high_availability       = "Disabled"
    tags                    = {}
    ssh_public_key          = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDtestkey user@host"
  }

  assert {
    condition     = output.key_vault_id != ""
    error_message = "Key Vault ID should not be empty"
  }

  assert {
    condition     = output.postgres_server_id != ""
    error_message = "PostgreSQL server ID should not be empty"
  }

  assert {
    condition     = output.database_nsg_id != ""
    error_message = "Database NSG ID should not be empty"
  }
}