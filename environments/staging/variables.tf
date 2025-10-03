# Staging environment variables - inherits from dev but with production-like settings

# Project Configuration
variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "terraform-lab"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "staging"
}


variable "azure_region" {
  description = "Azure region"
  type        = string
  default     = "East US"
}

variable "vnet_cidr" {
  description = "CIDR block for VNet"
  type        = string
  default     = "10.1.0.0/16"
}

# Networking Variables - Staging uses different CIDR
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.1.0.0/16"  # Different from dev
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.1.11.0/24", "10.1.12.0/24", "10.1.13.0/24"]
}

variable "database_subnets" {
  description = "List of database subnet CIDR blocks"
  type        = list(string)
  default     = ["10.1.21.0/24", "10.1.22.0/24", "10.1.23.0/24"]
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "enable_vpn_gateway" {
  description = "Enable VPN Gateway"
  type        = bool
  default     = false
}

# Compute Variables - Staging uses larger instances
variable "web_instance_type" {
  description = "Instance type for web servers"
  type        = string
  default     = "t3.small"  # Larger than dev
}

variable "app_instance_type" {
  description = "Instance type for app servers"
  type        = string
  default     = "t3.medium"  # Larger than dev
}

# Database Variables - Staging uses more resources
variable "db_engine" {
  description = "Database engine"
  type        = string
  default     = "mysql"
}

variable "db_engine_version" {
  description = "Database engine version"
  type        = string
  default     = "8.0"
}

variable "db_instance_class" {
  description = "Database instance class"
  type        = string
  default     = "db.t3.small"  # Larger than dev
}

variable "db_allocated_storage" {
  description = "Database allocated storage in GB"
  type        = number
  default     = 50  # More storage than dev
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "stagingdb"
}

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "admin"
}

variable "db_backup_retention_period" {
  description = "Database backup retention period in days"
  type        = number
  default     = 14  # Longer retention than dev
}

variable "db_backup_window" {
  description = "Database backup window"
  type        = string
  default     = "02:00-03:00"  # Different time than dev
}

variable "db_maintenance_window" {
  description = "Database maintenance window"
  type        = string
  default     = "sat:03:00-sat:04:00"  # Different day than dev
}