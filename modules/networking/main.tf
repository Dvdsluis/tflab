# Networking Module for Azure
# This module creates a VNet with public, private, and database subnets
# with proper routing and security for Azure

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "${var.name_prefix}-vnet"
  address_space       = [var.vnet_cidr]
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-vnet"
    Type = "VirtualNetwork"
  })
}

# Public Subnets
resource "azurerm_subnet" "public" {
  count = length(var.public_subnets)

  name                 = "${var.name_prefix}-public-${count.index + 1}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.public_subnets[count.index]]
}

# Private Subnets
resource "azurerm_subnet" "private" {
  count = length(var.private_subnets)

  name                 = "${var.name_prefix}-private-${count.index + 1}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.private_subnets[count.index]]
}

# Database Subnets
resource "azurerm_subnet" "database" {
  count = length(var.database_subnets)

  name                 = "${var.name_prefix}-database-${count.index + 1}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.database_subnets[count.index]]

  # Delegate subnet to Azure Database for PostgreSQL/MySQL
  delegation {
    name = "database-delegation"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

# Public IP for NAT Gateway
resource "azurerm_public_ip" "nat_gateway" {
  count = var.enable_nat_gateway ? 1 : 0

  name                = "${var.name_prefix}-nat-gw-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-nat-gw-ip"
    Type = "PublicIP"
  })
}

# NAT Gateway
resource "azurerm_nat_gateway" "main" {
  count = var.enable_nat_gateway ? 1 : 0

  name                = "${var.name_prefix}-nat-gw"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "Standard"

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-nat-gw"
    Type = "NATGateway"
  })
}

# Associate Public IP with NAT Gateway
resource "azurerm_nat_gateway_public_ip_association" "main" {
  count = var.enable_nat_gateway ? 1 : 0

  nat_gateway_id       = azurerm_nat_gateway.main[0].id
  public_ip_address_id = azurerm_public_ip.nat_gateway[0].id
}

# Route Tables
resource "azurerm_route_table" "private" {
  count = var.enable_nat_gateway ? 1 : 0

  name                = "${var.name_prefix}-private-rt"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-private-rt"
    Type = "RouteTable"
  })
}

# Associate NAT Gateway with private subnets
resource "azurerm_subnet_nat_gateway_association" "private" {
  count = var.enable_nat_gateway ? length(var.private_subnets) : 0

  subnet_id      = azurerm_subnet.private[count.index].id
  nat_gateway_id = azurerm_nat_gateway.main[0].id
}

# Network Security Groups
resource "azurerm_network_security_group" "public" {
  name                = "${var.name_prefix}-public-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  # Allow HTTP
  security_rule {
    name                       = "HTTP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow HTTPS
  security_rule {
    name                       = "HTTPS"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow SSH from VNet
  security_rule {
    name                       = "SSH"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.vnet_cidr
    destination_address_prefix = "*"
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-public-nsg"
    Type = "NetworkSecurityGroup"
    Tier = "Public"
  })
}

resource "azurerm_network_security_group" "private" {
  name                = "${var.name_prefix}-private-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  # Allow traffic from VNet
  security_rule {
    name                       = "VNetInbound"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.vnet_cidr
    destination_address_prefix = "*"
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-private-nsg"
    Type = "NetworkSecurityGroup"
    Tier = "Private"
  })
}

resource "azurerm_network_security_group" "database" {
  name                = "${var.name_prefix}-database-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  # Allow PostgreSQL from private subnets
  security_rule {
    name                       = "PostgreSQL"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5432"
    source_address_prefixes    = var.private_subnets
    destination_address_prefix = "*"
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-database-nsg"
    Type = "NetworkSecurityGroup"
    Tier = "Database"
  })
}

# Associate NSGs with Subnets
resource "azurerm_subnet_network_security_group_association" "public" {
  count = length(var.public_subnets)

  subnet_id                 = azurerm_subnet.public[count.index].id
  network_security_group_id = azurerm_network_security_group.public.id
}

resource "azurerm_subnet_network_security_group_association" "private" {
  count = length(var.private_subnets)

  subnet_id                 = azurerm_subnet.private[count.index].id
  network_security_group_id = azurerm_network_security_group.private.id
}

resource "azurerm_subnet_network_security_group_association" "database" {
  count = length(var.database_subnets)

  subnet_id                 = azurerm_subnet.database[count.index].id
  network_security_group_id = azurerm_network_security_group.database.id
}