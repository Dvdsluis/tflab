#!/bin/bash

# Environment Detection Script
# Detects the Azure resource group and environment for the lab
# Usage: source ./scripts/detect-environment.sh [ENVIRONMENT]

detect_lab_environment() {
    local env=${1:-"dev"}
    
    # Try to get RG from Terraform state first
    if [ -f "./environments/$env/terraform.tfstate" ]; then
        local rg_from_state=$(grep -o '"resource_group_name":[^,]*' "./environments/$env/terraform.tfstate" | head -1 | cut -d'"' -f4)
        if [ ! -z "$rg_from_state" ]; then
            export LAB_RESOURCE_GROUP="$rg_from_state"
            export LAB_ENVIRONMENT="$env"
            return
        fi
    fi
    
    # Try to get RG from terraform.tfvars
    if [ -f "./environments/$env/terraform.tfvars" ]; then
        local rg_from_vars=$(grep "resource_group_name" "./environments/$env/terraform.tfvars" | cut -d'"' -f2)
        if [ ! -z "$rg_from_vars" ]; then
            export LAB_RESOURCE_GROUP="$rg_from_vars"
            export LAB_ENVIRONMENT="$env"
            return
        fi
    fi
    
    # Search for RGs with terraform-lab pattern
    local matching_rgs=$(az group list --query "[?contains(name, 'terraform-lab') || contains(name, 'kml_rg')].name" --output tsv 2>/dev/null)
    if [ ! -z "$matching_rgs" ]; then
        local rg_count=$(echo "$matching_rgs" | wc -l)
        if [ $rg_count -eq 1 ]; then
            export LAB_RESOURCE_GROUP="$matching_rgs"
            export LAB_ENVIRONMENT="$env"
            return
        fi
    fi
    
    # Fallback to current hardcoded RG for backwards compatibility
    export LAB_RESOURCE_GROUP="kml_rg_main-5ae9e84837c64352"
    export LAB_ENVIRONMENT="$env"
    
    echo "Warning: Using fallback resource group: $LAB_RESOURCE_GROUP"
}

# Auto-detect if script is called directly
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    detect_lab_environment "$1"
    echo "Resource Group: $LAB_RESOURCE_GROUP"
    echo "Environment: $LAB_ENVIRONMENT"
fi