# Root Module - Development Environment

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
}

# Local values for computed configurations
locals {
  name_prefix = "${var.project_name}-${var.environment}"

  # Merge common tags with additional tags from tfvars
  common_tags = merge(
    {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "terraform"
    },
    var.additional_tags
  )
}

# Data source to reference existing resource group (lab environment)
data "azurerm_resource_group" "main" {
  name = "kml_rg_main-5ae9e84837c64352"
}

# Networking Module
module "networking" {
  source = "../../modules/networking"

  name_prefix         = local.name_prefix
  resource_group_name = data.azurerm_resource_group.main.name
  location            = var.azure_region
  vnet_cidr           = var.vnet_cidr
  public_subnets      = var.public_subnets
  private_subnets     = var.private_subnets
  database_subnets    = var.database_subnets
  enable_nat_gateway  = var.enable_nat_gateway

  tags = local.common_tags
}


# Compute Module (Azure)
module "compute" {
  source = "../../modules/compute"

  name_prefix         = local.name_prefix
  resource_group_name = data.azurerm_resource_group.main.name
  location            = var.azure_region
  vnet_cidr           = var.vnet_cidr
  web_subnet_id       = module.networking.public_subnet_ids[0]
  app_subnet_id       = module.networking.private_subnet_ids[0]
  web_public_ip_id    = module.networking.nat_gateway_public_ip_id

  public_instance_config = {
    instance_type = var.web_vm_size
    desired_size  = var.web_instance_count
  }
  private_instance_config = {
    instance_type = var.app_vm_size
    desired_size  = var.app_instance_count
  }
  admin_username = var.admin_username
  ssh_public_key = var.ssh_public_key
  tags           = local.common_tags

  depends_on = [module.networking]
}


# Database Module (Azure)
module "database" {
  source = "../../modules/database"

  name_prefix             = local.name_prefix
  resource_group_name     = data.azurerm_resource_group.main.name
  location                = var.azure_region
  allowed_cidr            = var.vnet_cidr
  engine                  = "postgres"
  engine_version          = var.db_server_version
  sku_name                = var.db_sku_name
  allocated_storage       = var.db_storage_mb / 1024
  zone                    = null
  db_subnet_id            = module.networking.database_subnet_ids[0]
  username                = var.db_admin_username
  backup_retention_period = var.db_backup_retention_days
  high_availability       = "Disabled"
  tags                    = local.common_tags

  depends_on = [module.networking, module.compute]
}