# Basic Example Configuration

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  name_prefix = "${var.project_name}-basic"
  
  tags = {
    Environment = "example"
    Project     = var.project_name
    Example     = "basic"
    ManagedBy   = "terraform"
  }
}

# Networking Module - Simplified
module "networking" {
  source = "../../modules/networking"
  
  name_prefix         = local.name_prefix
  vpc_cidr           = "10.1.0.0/16"
  availability_zones = ["${var.aws_region}a", "${var.aws_region}b"]
  public_subnets     = ["10.1.1.0/24", "10.1.2.0/24"]
  private_subnets    = ["10.1.11.0/24", "10.1.12.0/24"]
  database_subnets   = ["10.1.21.0/24", "10.1.22.0/24"]
  
  # Simplified for basic example
  enable_nat_gateway = false
  enable_vpn_gateway = false
  
  tags = local.tags
}

# Compute Module - Web servers only
module "compute" {
  source = "../../modules/compute"
  
  name_prefix = local.name_prefix
  vpc_id      = module.networking.vpc_id
  
  # Only public instances for this example
  public_subnet_ids = module.networking.public_subnet_ids
  public_instance_config = {
    instance_type = "t3.micro"
    min_size      = 1
    max_size      = 2
    desired_size  = 1
  }
  
  # Minimal private instances (set to 0 for cost savings)
  private_subnet_ids = module.networking.private_subnet_ids
  private_instance_config = {
    instance_type = "t3.micro"
    min_size      = 0
    max_size      = 1
    desired_size  = 0
  }
  
  tags = local.tags
  
  depends_on = [module.networking]
}