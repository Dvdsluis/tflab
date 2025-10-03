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

variable "vnet_cidr" {
  description = "CIDR block of the VNet"
  type        = string
}

variable "web_subnet_id" {
  description = "ID of the web subnet"
  type        = string
}

variable "app_subnet_id" {
  description = "ID of the app subnet"
  type        = string
}

variable "web_public_ip_id" {
  description = "ID of the public IP for the web load balancer"
  type        = string
}

variable "public_instance_config" {
  description = "Configuration for public VMSS instances"
  type = object({
    instance_type = string
    desired_size  = number
  })
}

variable "private_instance_config" {
  description = "Configuration for private VMSS instances"
  type = object({
    instance_type = string
    desired_size  = number
  })
}

variable "admin_username" {
  description = "Admin username for VMs"
  type        = string
}


variable "ssh_public_key" {
  description = "SSH public key for VM admin user (enterprise: use secure key management)"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}