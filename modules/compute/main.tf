
# Compute Module (Azure)
# This module creates web and app server infrastructure using Azure VMSS, Load Balancers, and NSGs

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# Web NSG
resource "azurerm_network_security_group" "web" {
  name                = "${var.name_prefix}-web-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    description                = "Allow HTTP from anywhere"
  }

  security_rule {
    name                       = "Allow-HTTPS"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    description                = "Allow HTTPS from anywhere"
  }

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.vnet_cidr
    destination_address_prefix = "*"
    description                = "Allow SSH from VNet"
  }

  tags = var.tags
}

# App NSG
resource "azurerm_network_security_group" "app" {
  name                = "${var.name_prefix}-app-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "Allow-App-HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = var.vnet_cidr
    destination_address_prefix = "*"
    description                = "Allow HTTP from Web subnet"
  }

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.vnet_cidr
    destination_address_prefix = "*"
    description                = "Allow SSH from VNet"
  }

  tags = var.tags
}

# Web VMSS
resource "azurerm_linux_virtual_machine_scale_set" "web" {
  name                            = "${var.name_prefix}-web-vmss"
  location                        = var.location
  resource_group_name             = var.resource_group_name
  sku                             = var.public_instance_config.instance_type
  instances                       = var.public_instance_config.desired_size
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  upgrade_mode = "Manual"

  network_interface {
    name                      = "web-nic"
    primary                   = true
    network_security_group_id = azurerm_network_security_group.web.id

    ip_configuration {
      name                                   = "internal"
      primary                                = true
      subnet_id                              = var.web_subnet_id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.web.id]
    }
  }

  custom_data = filebase64("${path.module}/user_data/web_server.sh")
  tags        = var.tags
}

# App VMSS
resource "azurerm_linux_virtual_machine_scale_set" "app" {
  name                            = "${var.name_prefix}-app-vmss"
  location                        = var.location
  resource_group_name             = var.resource_group_name
  sku                             = var.private_instance_config.instance_type
  instances                       = var.private_instance_config.desired_size
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  upgrade_mode = "Manual"

  network_interface {
    name                      = "app-nic"
    primary                   = true
    network_security_group_id = azurerm_network_security_group.app.id

    ip_configuration {
      name                                   = "internal"
      primary                                = true
      subnet_id                              = var.app_subnet_id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.app.id]
    }
  }

  custom_data = filebase64("${path.module}/user_data/app_server.sh")
  tags        = var.tags
}

# Public Load Balancer (Web)
resource "azurerm_lb" "web" {
  name                = "${var.name_prefix}-web-lb"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  frontend_ip_configuration {
    name                 = "Public"
    public_ip_address_id = var.web_public_ip_id
  }
  tags = var.tags
}

resource "azurerm_lb_backend_address_pool" "web" {
  name            = "web-backend-pool"
  loadbalancer_id = azurerm_lb.web.id
}

resource "azurerm_lb_probe" "web" {
  name            = "web-probe"
  loadbalancer_id = azurerm_lb.web.id
  protocol        = "Http"
  port            = 80
  request_path    = "/"
}

resource "azurerm_lb_rule" "web" {
  name                           = "web-rule"
  loadbalancer_id                = azurerm_lb.web.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "Public"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.web.id]
  probe_id                       = azurerm_lb_probe.web.id
}

# Internal Load Balancer (App)
resource "azurerm_lb" "app" {
  name                = "${var.name_prefix}-app-lb"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  frontend_ip_configuration {
    name                          = "Internal"
    subnet_id                     = var.app_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
  tags = var.tags
}

resource "azurerm_lb_backend_address_pool" "app" {
  name            = "app-backend-pool"
  loadbalancer_id = azurerm_lb.app.id
}

resource "azurerm_lb_probe" "app" {
  name            = "app-probe"
  loadbalancer_id = azurerm_lb.app.id
  protocol        = "Http"
  port            = 8080
  request_path    = "/health"
}

resource "azurerm_lb_rule" "app" {
  name                           = "app-rule"
  loadbalancer_id                = azurerm_lb.app.id
  protocol                       = "Tcp"
  frontend_port                  = 8080
  backend_port                   = 8080
  frontend_ip_configuration_name = "Internal"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.app.id]
  probe_id                       = azurerm_lb_probe.app.id
}