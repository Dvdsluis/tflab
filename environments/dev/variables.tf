# SSH Public Key for VM access
variable "ssh_public_key" {
  description = "SSH public key for VM admin access (in OpenSSH format)"
  type        = string
}
# Project Configuration
variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "terraform-lab"

  validation {
    condition     = length(var.project_name) > 0 && length(var.project_name) <= 20
    error_message = "Project name must be between 1 and 20 characters."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "azure_region" {
  description = "Azure region"
  type        = string
  default     = "East US"
}

# Networking Variables
variable "vnet_cidr" {
  description = "CIDR block for VNet"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vnet_cidr, 0))
    error_message = "VNet CIDR must be a valid IPv4 CIDR block."
  }
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}

variable "database_subnets" {
  description = "List of database subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]
}

# Compute Variables
variable "web_vm_size" {
  description = "VM size for web servers"
  type        = string
  default     = "Standard_B1s"
}

variable "app_vm_size" {
  description = "VM size for app servers"
  type        = string
  default     = "Standard_B1ms"
}

variable "web_instance_count" {
  description = "Number of web server instances"
  type        = number
  default     = 2
}

variable "app_instance_count" {
  description = "Number of app server instances"
  type        = number
  default     = 2
}

variable "admin_username" {
  description = "Admin username for VMs"
  type        = string
  default     = "azureuser"
}


variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "additional_tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# Database Variables
variable "db_server_version" {
  description = "Database server version"
  type        = string
  default     = "12"
}

variable "db_sku_name" {
  description = "Database SKU name"
  type        = string
  default     = "B_Standard_B1ms"
}

variable "db_storage_mb" {
  description = "Database storage in MB"
  type        = number
  default     = 32768 # 32GB minimum for PostgreSQL Flexible Server

  validation {
    condition     = var.db_storage_mb >= 32768 && var.db_storage_mb <= 1048576
    error_message = "Database storage must be between 32768 MB (32 GB) and 1048576 MB (1 TB)."
  }
}

variable "db_admin_username" {
  description = "Database administrator username"
  type        = string
  default     = "sqladmin"

  validation {
    condition     = length(var.db_admin_username) >= 4 && length(var.db_admin_username) <= 16
    error_message = "Database admin username must be between 4 and 16 characters."
  }
}

variable "db_backup_retention_days" {
  description = "Database backup retention period in days"
  type        = number
  default     = 7

  validation {
    condition     = var.db_backup_retention_days >= 7 && var.db_backup_retention_days <= 35
    error_message = "Backup retention period must be between 7 and 35 days."
  }
}