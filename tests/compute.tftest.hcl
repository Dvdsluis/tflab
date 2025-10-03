# Test for the compute module
run "compute_plan_test" {
  command = plan

  module {
    source = "../modules/compute"
  }

  variables {
    name_prefix         = "test-compute"
  resource_group_name = "kml_rg_main-b61755695aad4019"
    location            = "East US"
    vnet_cidr           = "10.0.0.0/16"
    web_subnet_id       = "/subscriptions/sub/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/public-1"
    app_subnet_id       = "/subscriptions/sub/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/private-1"
    web_public_ip_id    = "/subscriptions/sub/resourceGroups/test-rg/providers/Microsoft.Network/publicIPAddresses/test-pip"

    public_instance_config = {
      instance_type = "Standard_B1s"
      desired_size  = 1
    }

    private_instance_config = {
      instance_type = "Standard_B1s"
      desired_size  = 1
    }

    admin_username = "azureuser"
    ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDtestkey user@host"

    tags = {
      Environment = "test"
      Project     = "terraform-lab"
    }
  }

  assert {
    condition     = azurerm_linux_virtual_machine_scale_set.web.sku == "Standard_B1s"
    error_message = "Web VMSS should use correct VM size"
  }

  assert {
    condition     = azurerm_linux_virtual_machine_scale_set.app.sku == "Standard_B1s"
    error_message = "App VMSS should use correct VM size"
  }

  assert {
    condition     = azurerm_lb.web.name == "test-compute-web-lb"
    error_message = "Web load balancer should have correct name"
  }

  assert {
    condition     = azurerm_lb.app.name == "test-compute-app-lb"
    error_message = "App load balancer should have correct name"
  }

  assert {
    condition = length([
      for rule in azurerm_network_security_rule.web_inbound :
      rule if rule.destination_port_range == "80"
    ]) >= 1
    error_message = "Web NSG should allow HTTP traffic on port 80"
  }

  assert {
    condition = length([
      for rule in azurerm_network_security_rule.web_inbound :
      rule if rule.destination_port_range == "443"
    ]) >= 1
    error_message = "Web NSG should allow HTTPS traffic on port 443"
  }
}

run "compute_validate_outputs" {
  command = plan

  module {
    source = "../modules/compute"
  }

  variables {
    name_prefix         = "test-compute"
  resource_group_name = "kml_rg_main-b61755695aad4019"
    location            = "East US"
    vnet_cidr           = "10.0.0.0/16"
    web_subnet_id       = "/subscriptions/sub/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/public-1"
    app_subnet_id       = "/subscriptions/sub/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/private-1"
    web_public_ip_id    = "/subscriptions/sub/resourceGroups/test-rg/providers/Microsoft.Network/publicIPAddresses/test-pip"

    public_instance_config = {
      instance_type = "Standard_B1s"
      desired_size  = 1
    }

    private_instance_config = {
      instance_type = "Standard_B1s"
      desired_size  = 1
    }

    admin_username = "azureuser"
    ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDtestkey user@host"
    tags           = {}
  }

  assert {
    condition     = output.web_load_balancer_ip != ""
    error_message = "Web load balancer IP should not be empty"
  }

  assert {
    condition     = output.app_load_balancer_ip != ""
    error_message = "App load balancer IP should not be empty"
  }

  assert {
    condition     = output.web_vmss_id != ""
    error_message = "Web VMSS ID should not be empty"
  }

  assert {
    condition     = output.app_vmss_id != ""
    error_message = "App VMSS ID should not be empty"
  }
}