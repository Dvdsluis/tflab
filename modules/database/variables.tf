variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "allowed_cidr" {
  description = "CIDR block allowed to access the database (e.g., app subnet)"
  type        = string
}

variable "engine" {
  description = "Database engine (mysql or postgres)"
  type        = string
  default     = "mysql"
  validation {
    condition     = contains(["mysql", "postgres"], var.engine)
    error_message = "Engine must be either 'mysql' or 'postgres'."
  }
}

variable "engine_version" {
  description = "Database engine version"
  type        = string
  default     = "8.0"
}

variable "sku_name" {
  description = "Azure DB SKU name (e.g., Standard_D2ds_v4)"
  type        = string
  default     = "Standard_D2ds_v4"
}

variable "allocated_storage" {
  description = "Initial allocated storage in GB"
  type        = number
  default     = 20
}

variable "zone" {
  description = "Availability zone for the DB server"
  type        = string
  default     = null
}

variable "db_subnet_id" {
  description = "Delegated subnet ID for the DB server"
  type        = string
}

variable "username" {
  description = "Admin username for the database"
  type        = string
}

variable "backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
  default     = 7
}

variable "high_availability" {
  description = "High availability mode (e.g., ZoneRedundant, Disabled)"
  type        = string
  default     = "Disabled"
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

variable "secret_expiration_hours" {
  description = "Number of hours until Key Vault secret expires (default: 8760 = 1 year)"
  type        = number
  default     = 8760 # 1 year

  validation {
    condition     = var.secret_expiration_hours > 0 && var.secret_expiration_hours <= 17520 # Max 2 years
    error_message = "Secret expiration must be between 1 hour and 17520 hours (2 years)."
  }
}