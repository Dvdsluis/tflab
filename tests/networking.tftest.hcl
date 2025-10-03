# Test for the networking module

# Provider configuration for tests
provider "azurerm" {
  features {}
}

run "networking_plan_test" {
  command = plan

  module {
    source = "../modules/networking"
  }

  variables {
    name_prefix         = "test-net"
  resource_group_name = "kml_rg_main-b61755695aad4019"
    location            = "East US"
    vnet_cidr           = "10.0.0.0/16"
    public_subnets      = ["10.0.1.0/24", "10.0.2.0/24"]
    private_subnets     = ["10.0.11.0/24", "10.0.12.0/24"]
    database_subnets    = ["10.0.21.0/24", "10.0.22.0/24"]
    tags = {
      Environment = "test"
      Project     = "terraform-lab"
    }
    ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDtestkey user@host"
  }

  assert {
    condition     = azurerm_virtual_network.main.address_space[0] == "10.0.0.0/16"
    error_message = "VNet should have correct CIDR block"
  }

  assert {
    condition     = length(azurerm_subnet.public) == 2
    error_message = "Should create 2 public subnets"
  }

  assert {
    condition     = length(azurerm_subnet.private) == 2
    error_message = "Should create 2 private subnets"
  }

  assert {
    condition     = length(azurerm_subnet.database) == 2
    error_message = "Should create 2 database subnets"
  }

  assert {
    condition     = azurerm_network_security_group.public.name == "test-net-public-nsg"
    error_message = "Public NSG should have correct name"
  }

  assert {
    condition     = azurerm_network_security_group.private.name == "test-net-private-nsg"
    error_message = "Private NSG should have correct name"
  }
}

run "networking_validate_outputs" {
  command = plan

  module {
    source = "../modules/networking"
  }

  variables {
    name_prefix         = "test-net"
  resource_group_name = "kml_rg_main-b61755695aad4019"
    location            = "East US"
    vnet_cidr           = "10.0.0.0/16"
    public_subnets      = ["10.0.1.0/24", "10.0.2.0/24"]
    private_subnets     = ["10.0.11.0/24", "10.0.12.0/24"]
    database_subnets    = ["10.0.21.0/24", "10.0.22.0/24"]
    tags                = {}
    ssh_public_key      = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDtestkey user@host"
  }

  assert {
    condition     = output.vnet_id != ""
    error_message = "VNet ID output should not be empty"
  }

  assert {
    condition     = length(output.public_subnet_ids) == 2
    error_message = "Should output 2 public subnet IDs"
  }

  assert {
    condition     = length(output.private_subnet_ids) == 2
    error_message = "Should output 2 private subnet IDs"
  }

  assert {
    condition     = length(output.database_subnet_ids) == 2
    error_message = "Should output 2 database subnet IDs"
  }
}