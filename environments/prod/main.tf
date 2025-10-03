
# Production Environment (Azure)
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
}

locals {
  name_prefix = "${var.project_name}-${var.environment}"
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
    Compliance  = "required"
    BackupPolicy = "daily"
  }
}

# Networking Module
module "networking" {
  source = "../../modules/networking"
  name_prefix         = local.name_prefix
  resource_group_name = azurerm_resource_group.main.name
  location            = var.azure_region
  vnet_cidr           = var.vpc_cidr
  public_subnets      = var.public_subnets
  private_subnets     = var.private_subnets
  database_subnets    = var.database_subnets
  tags                = local.common_tags
}

# Compute Module
module "compute" {
  source = "../../modules/compute"
  name_prefix         = local.name_prefix
  resource_group_name = azurerm_resource_group.main.name
  location            = var.azure_region
  vnet_cidr           = var.vnet_cidr
  web_subnet_id       = module.networking.public_subnet_ids[0]
  app_subnet_id       = module.networking.private_subnet_ids[0]
  web_public_ip_id    = module.networking.nat_gateway_public_ip
  public_instance_config = {
    instance_type = var.web_instance_type
    desired_size  = 3
  }
  private_instance_config = {
    instance_type = var.app_instance_type
    desired_size  = 3
  }
  admin_username = var.db_username
  admin_password = "REPLACE_WITH_SECURE_PASSWORD"
  tags = local.common_tags
  depends_on = [module.networking]
}

# Database Module
module "database" {
  source = "../../modules/database"
  name_prefix         = local.name_prefix
  resource_group_name = azurerm_resource_group.main.name
  location            = var.azure_region
  allowed_cidr        = var.vnet_cidr
  engine              = var.db_engine
  engine_version      = var.db_engine_version
  sku_name            = var.db_instance_class
  allocated_storage   = var.db_allocated_storage
  zone                = null
  db_subnet_id        = module.networking.database_subnet_ids[0]
  username            = var.db_username
  backup_retention_period = var.db_backup_retention_period
  high_availability   = "ZoneRedundant"
  tags                = local.common_tags
  depends_on = [module.networking, module.compute]
}