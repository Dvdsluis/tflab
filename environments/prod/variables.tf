# Production environment variables - enterprise-grade settings

# Project Configuration
variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "terraform-lab"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}


variable "azure_region" {
  description = "Azure region"
  type        = string
  default     = "East US"
}

variable "vnet_cidr" {
  description = "CIDR block for VNet"
  type        = string
  default     = "10.2.0.0/16"
}

# Networking Variables - Production uses isolated CIDR
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.2.0.0/16"  # Isolated from dev and staging
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.2.1.0/24", "10.2.2.0/24", "10.2.3.0/24"]
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.2.11.0/24", "10.2.12.0/24", "10.2.13.0/24"]
}

variable "database_subnets" {
  description = "List of database subnet CIDR blocks"
  type        = list(string)
  default     = ["10.2.21.0/24", "10.2.22.0/24", "10.2.23.0/24"]
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true  # Always enabled for production
}

variable "enable_vpn_gateway" {
  description = "Enable VPN Gateway"
  type        = bool
  default     = true  # Enabled for production secure access
}

# Compute Variables - Production uses performant instances
variable "web_instance_type" {
  description = "Instance type for web servers"
  type        = string
  default     = "t3.medium"  # Production-grade
}

variable "app_instance_type" {
  description = "Instance type for app servers"
  type        = string
  default     = "t3.large"   # Production-grade
}

# Database Variables - Production uses high-performance configuration
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
  default     = "db.t3.medium"  # Production-grade
}

variable "db_allocated_storage" {
  description = "Database allocated storage in GB"
  type        = number
  default     = 100  # Production storage
}

variable "db_max_allocated_storage" {
  description = "Maximum allocated storage for autoscaling in GB"
  type        = number
  default     = 500  # Allow autoscaling in production
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "proddb"
}

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "admin"
}

variable "db_backup_retention_period" {
  description = "Database backup retention period in days"
  type        = number
  default     = 30  # Long retention for production
}

variable "db_backup_window" {
  description = "Database backup window"
  type        = string
  default     = "01:00-02:00"  # Off-peak hours
}

variable "db_maintenance_window" {
  description = "Database maintenance window"
  type        = string
  default     = "sun:02:00-sun:03:00"  # Off-peak maintenance
}