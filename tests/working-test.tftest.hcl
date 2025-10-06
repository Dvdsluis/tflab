# Working test for the dev environment
# This test provides all required variables

run "test_dev_environment_plan" {
  command = plan

  variables {
    project_name = "test-lab"
    environment = "dev"
    azure_region = "East US"
    vnet_cidr = "10.0.0.0/16"
    public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
    private_subnets = ["10.0.11.0/24", "10.0.12.0/24"]
    database_subnets = ["10.0.21.0/24", "10.0.22.0/24"]
    web_vm_size = "Standard_B1s"
    app_vm_size = "Standard_B1s"
    web_instance_count = 2
    app_instance_count = 2
    admin_username = "azureuser"
    ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCtest test@test"
    enable_nat_gateway = true
    db_server_version = "13"
    db_sku_name = "B_Standard_B1ms"
    db_storage_mb = 32768
    db_admin_username = "dbadmin"
    db_backup_retention_days = 7
  }

  assert {
    condition     = var.project_name == "test-lab"
    error_message = "Project name should be test-lab"
  }

  assert {
    condition     = var.app_vm_size == "Standard_B1s"
    error_message = "App VM size should be Standard_B1s"
  }

  assert {
    condition     = var.app_instance_count <= 3
    error_message = "App instance count should not exceed 3"
  }
}