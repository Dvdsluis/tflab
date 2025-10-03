# Integration test for the dev environment
run "dev_environment_plan_test" {
  command = plan

  module {
    source = "../environments/dev"
  }

  variables {
    project_name        = "test-lab"
    environment         = "test"
    azure_region        = "East US"
    resource_group_name = "kml_rg_main-b61755695aad4019"
    vnet_cidr           = "10.0.0.0/16"
    public_subnets      = ["10.0.1.0/24", "10.0.2.0/24"]
    private_subnets     = ["10.0.11.0/24", "10.0.12.0/24"]
    database_subnets    = ["10.0.21.0/24", "10.0.22.0/24"]

    # VM configurations
    web_vm_size    = "Standard_B1s"
    app_vm_size    = "Standard_B1s"
    ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDtestkey user@host"

    # Database configurations
    db_admin_username        = "dbadmin"
    db_server_version        = "13"
    db_sku_name              = "Standard_D2ds_v4"
    db_storage_mb            = 20480 # 20GB
    db_backup_retention_days = 7
  }

  assert {
    condition     = azurerm_resource_group.main.name == "test-lab-test-rg"
    error_message = "Resource group should have correct name"
  }

  assert {
    condition     = azurerm_resource_group.main.location == "East US"
    error_message = "Resource group should be in correct location"
  }

  # Test that all modules are properly configured
  assert {
    condition = length([
      for k, v in module.networking : v
    ]) > 0
    error_message = "Networking module should be instantiated"
  }

  assert {
    condition = length([
      for k, v in module.compute : v
    ]) > 0
    error_message = "Compute module should be instantiated"
  }

  assert {
    condition = length([
      for k, v in module.database : v
    ]) > 0
    error_message = "Database module should be instantiated"
  }
}

run "dev_environment_validate_tags" {
  command = plan

  module {
    source = "../environments/dev"
  }

  variables {
    project_name             = "test-lab"
    environment              = "test"
    azure_region             = "East US"
    resource_group_name      = "kml_rg_main-b61755695aad4019"
    vnet_cidr                = "10.0.0.0/16"
    public_subnets           = ["10.0.1.0/24"]
    private_subnets          = ["10.0.11.0/24"]
    database_subnets         = ["10.0.21.0/24"]
    web_vm_size              = "Standard_B1s"
    app_vm_size              = "Standard_B1s"
    ssh_public_key           = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDtestkey user@host"
    db_admin_username        = "dbadmin"
    db_server_version        = "13"
    db_sku_name              = "Standard_D2ds_v4"
    db_storage_mb            = 20480
    db_backup_retention_days = 7
  }

  assert {
    condition     = azurerm_resource_group.main.tags["Environment"] == "test"
    error_message = "Resource group should have correct Environment tag"
  }

  assert {
    condition     = azurerm_resource_group.main.tags["Project"] == "test-lab"
    error_message = "Resource group should have correct Project tag"
  }

  assert {
    condition     = azurerm_resource_group.main.tags["ManagedBy"] == "terraform"
    error_message = "Resource group should have correct ManagedBy tag"
  }
}