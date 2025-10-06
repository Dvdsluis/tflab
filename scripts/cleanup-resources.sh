#!/bin/bash

# Azure Resource Cleanup Script - Modular Version
# Cleans up resources in the correct order to avoid dependency issues
# Usage: ./cleanup-resources.sh [RESOURCE_GROUP_NAME] [ENVIRONMENT]

# Function to detect resource group from Terraform state or Azure CLI
detect_resource_group() {
    local env=${1:-"dev"}
    
    # Try to get RG from Terraform state first
    if [ -f "./environments/$env/terraform.tfstate" ]; then
        local rg_from_state=$(grep -o '"resource_group_name":[^,]*' "./environments/$env/terraform.tfstate" | head -1 | cut -d'"' -f4)
        if [ ! -z "$rg_from_state" ]; then
            echo "$rg_from_state"
            return
        fi
    fi
    
    # Try to get RG from terraform.tfvars
    if [ -f "./environments/$env/terraform.tfvars" ]; then
        local rg_from_vars=$(grep "resource_group_name" "./environments/$env/terraform.tfvars" | cut -d'"' -f2)
        if [ ! -z "$rg_from_vars" ]; then
            echo "$rg_from_vars"
            return
        fi
    fi
    
    # Search for RGs with terraform-lab pattern
    local matching_rgs=$(az group list --query "[?contains(name, 'terraform-lab') || contains(name, 'kml_rg')].name" --output tsv)
    if [ ! -z "$matching_rgs" ]; then
        local rg_count=$(echo "$matching_rgs" | wc -l)
        if [ $rg_count -eq 1 ]; then
            echo "$matching_rgs"
            return
        else
            echo "Multiple resource groups found:"
            echo "$matching_rgs"
            echo "Please specify the resource group name as first parameter."
            exit 1
        fi
    fi
    
    echo "ERROR: Could not detect resource group. Please specify it as first parameter."
    echo "Usage: $0 [RESOURCE_GROUP_NAME] [ENVIRONMENT]"
    exit 1
}

# Parse command line arguments
ENVIRONMENT=${2:-"dev"}
if [ ! -z "$1" ]; then
    RG_NAME="$1"
else
    RG_NAME=$(detect_resource_group "$ENVIRONMENT")
fi

echo "Azure Resource Cleanup Script"
echo "============================="
echo "Resource Group: $RG_NAME"
echo "Environment: $ENVIRONMENT"
echo "============================="

# Verify resource group exists
if ! az group show --name "$RG_NAME" &>/dev/null; then
    echo "ERROR: Resource group '$RG_NAME' does not exist."
    exit 1
fi

echo ""
echo "Cleaning up Azure resources in resource group: $RG_NAME"
echo ""

# Function to delete resource if it exists
delete_if_exists() {
    local resource_type=$1
    local resource_name=$2
    local extra_params=$3
    
    echo "Checking $resource_type: $resource_name"
    if az $resource_type show --name "$resource_name" --resource-group "$RG_NAME" &>/dev/null; then
        echo "  Deleting $resource_type: $resource_name"
        az $resource_type delete --name "$resource_name" --resource-group "$RG_NAME" --no-wait $extra_params
    else
        echo "  $resource_type $resource_name does not exist"
    fi
}

# Generate resource names based on environment
LB_WEB_NAME="terraform-lab-$ENVIRONMENT-web-lb"
LB_APP_NAME="terraform-lab-$ENVIRONMENT-app-lb"
NAT_GW_NAME="terraform-lab-$ENVIRONMENT-nat-gw"
PIP_NAT_NAME="terraform-lab-$ENVIRONMENT-nat-gw-ip"
PIP_LB_NAME="terraform-lab-$ENVIRONMENT-lb-ip"
RT_PRIVATE_NAME="terraform-lab-$ENVIRONMENT-private-rt"
NSG_PUBLIC_NAME="terraform-lab-$ENVIRONMENT-public-nsg"
NSG_PRIVATE_NAME="terraform-lab-$ENVIRONMENT-private-nsg"
NSG_DATABASE_NAME="terraform-lab-$ENVIRONMENT-database-nsg"
NSG_APP_NAME="terraform-lab-$ENVIRONMENT-app-nsg"
NSG_WEB_NAME="terraform-lab-$ENVIRONMENT-web-nsg"
VNET_NAME="terraform-lab-$ENVIRONMENT-vnet"

# 1. Delete Load Balancers first
echo "Step 1: Deleting Load Balancers..."
delete_if_exists "network lb" "$LB_WEB_NAME"
delete_if_exists "network lb" "$LB_APP_NAME"

# 2. Delete NAT Gateway associations
echo ""
echo "Step 2: Deleting NAT Gateway..."
delete_if_exists "network nat gateway" "$NAT_GW_NAME"

# 3. Delete Public IPs
echo ""
echo "Step 3: Deleting Public IPs..."
delete_if_exists "network public-ip" "$PIP_NAT_NAME"
delete_if_exists "network public-ip" "$PIP_LB_NAME"

# 4. Delete Route Tables
echo ""
echo "Step 4: Deleting Route Tables..."
delete_if_exists "network route-table" "$RT_PRIVATE_NAME"

# 5. Delete Network Security Groups
echo ""
echo "Step 5: Deleting Network Security Groups..."
delete_if_exists "network nsg" "$NSG_PUBLIC_NAME"
delete_if_exists "network nsg" "$NSG_PRIVATE_NAME"
delete_if_exists "network nsg" "$NSG_DATABASE_NAME"
delete_if_exists "network nsg" "$NSG_APP_NAME"
delete_if_exists "network nsg" "$NSG_WEB_NAME"

# 6. Delete Virtual Network (this should now work)
echo ""
echo "Step 6: Deleting Virtual Network..."
delete_if_exists "network vnet" "$VNET_NAME"

echo ""
echo "Cleanup completed! Resources should be deleted or in the process of being deleted."
echo "Note: Some resources may take a few minutes to fully delete."
echo "You can now re-run your Terraform deployment."
echo ""
echo "To check status: az group show --name $RG_NAME --query 'properties.provisioningState'"