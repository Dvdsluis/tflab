#!/bin/bash

# Azure Resource Cleanup Script
# Cleans up resources in the correct order to avoid dependency issues

RG_NAME="kml_rg_main-5ae9e84837c64352"

echo "🧹 Cleaning up Azure resources in resource group: $RG_NAME"

# Function to delete resource if it exists
delete_if_exists() {
    local resource_type=$1
    local resource_name=$2
    local extra_params=$3
    
    echo "Checking $resource_type: $resource_name"
    if az $resource_type show --name "$resource_name" --resource-group "$RG_NAME" &>/dev/null; then
        echo "  ⏳ Deleting $resource_type: $resource_name"
        az $resource_type delete --name "$resource_name" --resource-group "$RG_NAME" --yes --no-wait $extra_params
    else
        echo "  ✅ $resource_type $resource_name does not exist"
    fi
}

# 1. Delete Load Balancers first
echo "🎯 Step 1: Deleting Load Balancers..."
delete_if_exists "network lb" "terraform-lab-dev-web-lb"
delete_if_exists "network lb" "terraform-lab-dev-app-lb"

# Wait a bit for load balancers to be deleted
echo "⏰ Waiting 30 seconds for load balancers to be deleted..."
sleep 30

# 2. Delete NAT Gateway associations
echo "🎯 Step 2: Deleting NAT Gateway..."
delete_if_exists "network nat gateway" "terraform-lab-dev-nat-gw"

# 3. Delete Public IPs
echo "🎯 Step 3: Deleting Public IPs..."
delete_if_exists "network public-ip" "terraform-lab-dev-nat-gw-ip"
delete_if_exists "network public-ip" "terraform-lab-dev-lb-ip"

# 4. Delete Route Tables
echo "🎯 Step 4: Deleting Route Tables..."
delete_if_exists "network route-table" "terraform-lab-dev-private-rt"

# 5. Delete Network Security Groups
echo "🎯 Step 5: Deleting Network Security Groups..."
delete_if_exists "network nsg" "terraform-lab-dev-public-nsg"
delete_if_exists "network nsg" "terraform-lab-dev-private-nsg"
delete_if_exists "network nsg" "terraform-lab-dev-database-nsg"
delete_if_exists "network nsg" "terraform-lab-dev-app-nsg"
delete_if_exists "network nsg" "terraform-lab-dev-web-nsg"

# Wait for NSGs to be deleted
echo "⏰ Waiting 30 seconds for NSGs to be deleted..."
sleep 30

# 6. Delete Virtual Network (this should now work)
echo "🎯 Step 6: Deleting Virtual Network..."
delete_if_exists "network vnet" "terraform-lab-dev-vnet"

echo "✅ Cleanup completed! Resources should be deleted or in the process of being deleted."
echo "⏰ Note: Some resources may take a few minutes to fully delete."
echo "🔄 You can now re-run your Terraform deployment."