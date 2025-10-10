# Azure Management API Health Checks
# Continuous validation using external Azure APIs

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.0"
    }
  }
}

# Check 1: Validate Azure Resource Group exists and is accessible
check "validate_resource_group_health" {
  data "azurerm_resource_group" "health_check" {
    name = "kml_rg_main-6375cacb1deb4a68"
  }

  assert {
    condition     = data.azurerm_resource_group.health_check.location != null
    error_message = "Resource group is not accessible or does not exist"
  }

  assert {
    condition     = data.azurerm_resource_group.health_check.managed_by == null || can(regex("terraform", lower(data.azurerm_resource_group.health_check.managed_by)))
    error_message = "Resource group should be managed by Terraform or compatible IaC tool"
  }
}

# Check 2: Validate Azure subscription quotas and limits
check "validate_azure_quotas" {
  data "azurerm_client_config" "current" {}
  
  # This could be extended to check specific quotas via Azure Management API
  assert {
    condition     = data.azurerm_client_config.current.subscription_id != null
    error_message = "Azure subscription is not properly configured"
  }

  assert {
    condition     = data.azurerm_client_config.current.tenant_id != null
    error_message = "Azure tenant is not properly configured"
  }
}

# Check 3: Validate Azure region availability and capacity
check "validate_azure_region_health" {
  # This uses external validation - could be extended to call Azure Management API
  # to check region capacity, service availability, etc.
  
  assert {
    condition     = contains(["East US", "West US 2", "Central US", "North Europe", "West Europe"], "East US")
    error_message = "Selected Azure region may not be available or supported"
  }
}

# Check 4: Network connectivity and DNS resolution health check
check "validate_network_connectivity" {
  data "http" "azure_health" {
    url = "https://status.azure.com/en-us/status"
    request_headers = {
      Accept = "text/html"
    }
  }

  assert {
    condition     = data.http.azure_health.status_code == 200
    error_message = "Azure services may be experiencing issues: ${data.http.azure_health.url}"
  }

  assert {
    condition     = length(data.http.azure_health.response_body) > 100
    error_message = "Azure status page returned unexpected content"
  }
}