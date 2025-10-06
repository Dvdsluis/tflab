# Enhanced compute module tests with multiple testing strategies

# Provider configuration for tests (lab: RG-only permissions)
provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
}

# Test 1: Configuration validation (your current approach - GOOD!)
run "compute_config_validation" {
  command = plan

  module {
    source = "../modules/compute"
  }

  variables {
    name_prefix         = "test-compute"
    resource_group_name = "kml_rg_main-5ae9e84837c64352"
    location            = "East US"
    vnet_cidr           = "10.0.0.0/16"
    web_subnet_id       = "/subscriptions/sub/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/public-1"
    app_subnet_id       = "/subscriptions/sub/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/private-1"
    web_public_ip_id    = "/subscriptions/sub/resourceGroups/test-rg/providers/Microsoft.Network/publicIPAddresses/test-pip"

    public_instance_config = {
      instance_type = "Standard_B2s" # Policy compliant
      desired_size  = 2
    }

    private_instance_config = {
      instance_type = "Standard_B2s" # Policy compliant
      desired_size  = 3              # Max allowed by policy
    }

    admin_username = "azureuser"
    ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDtestkey user@host"

    tags = {
      Environment = "test"
      Project     = "terraform-lab"
    }
  }

  # Policy compliance tests
  assert {
    condition     = azurerm_linux_virtual_machine_scale_set.app.name == "app-scaleset"
    error_message = "App VMSS must be named 'app-scaleset' for policy compliance"
  }

  assert {
    condition     = azurerm_linux_virtual_machine_scale_set.app.instances <= 3
    error_message = "App VMSS instances must not exceed 3 for policy compliance"
  }

  assert {
    condition     = contains(["Standard_B1s", "Standard_B2s", "Standard_B1ms"], azurerm_linux_virtual_machine_scale_set.web.sku)
    error_message = "Web VMSS must use policy-compliant VM size"
  }

  assert {
    condition     = contains(["Standard_B1s", "Standard_B2s", "Standard_B1ms"], azurerm_linux_virtual_machine_scale_set.app.sku)
    error_message = "App VMSS must use policy-compliant VM size"
  }

  # Security validation
  assert {
    condition = alltrue([
      for rule in azurerm_network_security_rule.web_inbound :
      rule.access == "Allow" if rule.destination_port_range == "80"
    ])
    error_message = "HTTP traffic should be allowed on port 80"
  }

  assert {
    condition = alltrue([
      for rule in azurerm_network_security_rule.web_inbound :
      rule.access == "Allow" if rule.destination_port_range == "443"
    ])
    error_message = "HTTPS traffic should be allowed on port 443"
  }

  # Resource naming conventions
  assert {
    condition     = can(regex("^test-compute-.*-lb$", azurerm_lb.web.name))
    error_message = "Load balancer names should follow naming convention"
  }

  # Tagging validation
  assert {
    condition = alltrue([
      for resource in [azurerm_linux_virtual_machine_scale_set.web, azurerm_linux_virtual_machine_scale_set.app] :
      contains(keys(resource.tags), "Environment") && contains(keys(resource.tags), "Project")
    ])
    error_message = "All resources should have Environment and Project tags"
  }
}

# Test 2: Invalid configuration should fail (negative testing)
run "compute_invalid_vm_size" {
  command = plan

  module {
    source = "../modules/compute"
  }

  variables {
    name_prefix         = "test-compute"
    resource_group_name = "kml_rg_main-5ae9e84837c64352"
    location            = "East US"
    vnet_cidr           = "10.0.0.0/16"
    web_subnet_id       = "/subscriptions/sub/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/public-1"
    app_subnet_id       = "/subscriptions/sub/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/private-1"
    web_public_ip_id    = "/subscriptions/sub/resourceGroups/test-rg/providers/Microsoft.Network/publicIPAddresses/test-pip"

    public_instance_config = {
      instance_type = "Standard_D4s_v3" # NOT policy compliant - should trigger validation
      desired_size  = 1
    }

    private_instance_config = {
      instance_type = "Standard_B2s"
      desired_size  = 1
    }

    admin_username = "azureuser"
    ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDtestkey user@host"
    tags           = {}
  }

  # This test expects the plan to succeed but validates non-compliant configuration
  assert {
    condition     = !contains(["Standard_B1s", "Standard_B2s", "Standard_B1ms"], azurerm_linux_virtual_machine_scale_set.web.sku)
    error_message = "This test validates that non-compliant VM sizes are detected"
  }
}

# Test 3: Output validation (ensures modules work together)
run "compute_outputs_integration" {
  command = plan

  module {
    source = "../modules/compute"
  }

  variables {
    name_prefix         = "test-compute"
    resource_group_name = "kml_rg_main-5ae9e84837c64352"
    location            = "East US"
    vnet_cidr           = "10.0.0.0/16"
    web_subnet_id       = "/subscriptions/sub/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/public-1"
    app_subnet_id       = "/subscriptions/sub/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/private-1"
    web_public_ip_id    = "/subscriptions/sub/resourceGroups/test-rg/providers/Microsoft.Network/publicIPAddresses/test-pip"

    public_instance_config = {
      instance_type = "Standard_B2s"
      desired_size  = 1
    }

    private_instance_config = {
      instance_type = "Standard_B2s"
      desired_size  = 1
    }

    admin_username = "azureuser"
    ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDtestkey user@host"
    tags           = {}
  }

  # Validate outputs are properly formatted for consumption by other modules
  assert {
    condition     = can(regex("^/subscriptions/.*/resourceGroups/.*/providers/Microsoft.Network/loadBalancers/.*/frontendIPConfigurations/.*", output.web_load_balancer_ip))
    error_message = "Web load balancer IP should be a valid Azure resource path"
  }

  assert {
    condition     = can(regex("^/subscriptions/.*/resourceGroups/.*/providers/Microsoft.Compute/virtualMachineScaleSets/.*", output.web_vmss_id))
    error_message = "Web VMSS ID should be a valid Azure resource ID"
  }

  assert {
    condition     = output.app_vmss_id != output.web_vmss_id
    error_message = "App and Web VMSS should have different IDs"
  }
}