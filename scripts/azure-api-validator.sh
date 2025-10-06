#!/bin/bash
# Azure API Validator Script
# This script uses Azure CLI and REST APIs to validate actual resource state
# beyond what Terraform can see

set -e

# Parse input JSON
eval "$(jq -r '@sh "RESOURCE_GROUP=\(.resource_group) SUBSCRIPTION_ID=\(.subscription_id)"')"

# Initialize result object
RESULT="{}"

# Function to add result
add_result() {
    local key=$1
    local value=$2
    RESULT=$(echo $RESULT | jq --arg k "$key" --arg v "$value" '. + {($k): $v}')
}

# Check if Azure CLI is logged in
if ! az account show &>/dev/null; then
    add_result "error" "Azure CLI not logged in"
    echo "$RESULT"
    exit 1
fi

# Set subscription context
az account set --subscription "$SUBSCRIPTION_ID" &>/dev/null

# 1. VNet State Validation
echo "Checking VNet state..." >&2
VNET_STATE=$(az network vnet show \
    --resource-group "$RESOURCE_GROUP" \
    --name "terraform-lab-dev-vnet" \
    --query "provisioningState" \
    --output tsv 2>/dev/null || echo "NotFound")
add_result "vnet_state" "$VNET_STATE"

# 2. VMSS Count and Configuration
echo "Checking VMSS resources..." >&2
VMSS_COUNT=$(az vmss list \
    --resource-group "$RESOURCE_GROUP" \
    --query "length(@)" \
    --output tsv 2>/dev/null || echo "0")
add_result "vmss_count" "$VMSS_COUNT"

# Check App VMSS name for policy compliance
APP_VMSS_NAME=$(az vmss list \
    --resource-group "$RESOURCE_GROUP" \
    --query "[?contains(name, 'app')].name | [0]" \
    --output tsv 2>/dev/null || echo "NotFound")
add_result "app_vmss_name" "$APP_VMSS_NAME"

# Check maximum instances across all VMSS
MAX_INSTANCES=$(az vmss list \
    --resource-group "$RESOURCE_GROUP" \
    --query "max([].sku.capacity)" \
    --output tsv 2>/dev/null || echo "0")
add_result "max_instances" "$MAX_INSTANCES"

# 3. Load Balancer Validation
echo "Checking Load Balancers..." >&2
LB_COUNT=$(az network lb list \
    --resource-group "$RESOURCE_GROUP" \
    --query "length(@)" \
    --output tsv 2>/dev/null || echo "0")
add_result "load_balancer_count" "$LB_COUNT"

# Check Load Balancer SKU
LB_SKU=$(az network lb list \
    --resource-group "$RESOURCE_GROUP" \
    --query "[0].sku.name" \
    --output tsv 2>/dev/null || echo "Basic")
add_result "load_balancer_sku" "$LB_SKU"

# 4. Load Balancer Backend Pool Health
echo "Checking Load Balancer health..." >&2
WEB_LB_NAME=$(az network lb list \
    --resource-group "$RESOURCE_GROUP" \
    --query "[?contains(name, 'web')].name | [0]" \
    --output tsv 2>/dev/null || echo "")

if [ -n "$WEB_LB_NAME" ]; then
    WEB_BACKEND_COUNT=$(az network lb address-pool list \
        --resource-group "$RESOURCE_GROUP" \
        --lb-name "$WEB_LB_NAME" \
        --query "[0].backendIpConfigurations | length(@)" \
        --output tsv 2>/dev/null || echo "0")
    add_result "web_lb_backend_pool_count" "$WEB_BACKEND_COUNT"
    
    # Check health probe status (simplified)
    WEB_PROBE_COUNT=$(az network lb probe list \
        --resource-group "$RESOURCE_GROUP" \
        --lb-name "$WEB_LB_NAME" \
        --query "length(@)" \
        --output tsv 2>/dev/null || echo "0")
    if [ "$WEB_PROBE_COUNT" -gt "0" ]; then
        add_result "web_lb_health_probe_status" "Up"
    else
        add_result "web_lb_health_probe_status" "Down"
    fi
else
    add_result "web_lb_backend_pool_count" "0"
    add_result "web_lb_health_probe_status" "NotFound"
fi

# App Load Balancer
APP_LB_NAME=$(az network lb list \
    --resource-group "$RESOURCE_GROUP" \
    --query "[?contains(name, 'app')].name | [0]" \
    --output tsv 2>/dev/null || echo "")

if [ -n "$APP_LB_NAME" ]; then
    APP_BACKEND_COUNT=$(az network lb address-pool list \
        --resource-group "$RESOURCE_GROUP" \
        --lb-name "$APP_LB_NAME" \
        --query "[0].backendIpConfigurations | length(@)" \
        --output tsv 2>/dev/null || echo "0")
    add_result "app_lb_backend_pool_count" "$APP_BACKEND_COUNT"
    
    APP_PROBE_COUNT=$(az network lb probe list \
        --resource-group "$RESOURCE_GROUP" \
        --lb-name "$APP_LB_NAME" \
        --query "length(@)" \
        --output tsv 2>/dev/null || echo "0")
    if [ "$APP_PROBE_COUNT" -gt "0" ]; then
        add_result "app_lb_health_probe_status" "Up"
    else
        add_result "app_lb_health_probe_status" "Down"
    fi
else
    add_result "app_lb_backend_pool_count" "0"
    add_result "app_lb_health_probe_status" "NotFound"
fi

# 5. PostgreSQL Server Validation
echo "Checking PostgreSQL server..." >&2
POSTGRES_STATE=$(az postgres flexible-server show \
    --resource-group "$RESOURCE_GROUP" \
    --name "terraform-lab-dev-postgres" \
    --query "state" \
    --output tsv 2>/dev/null || echo "NotFound")
add_result "postgres_server_state" "$POSTGRES_STATE"

POSTGRES_VERSION=$(az postgres flexible-server show \
    --resource-group "$RESOURCE_GROUP" \
    --name "terraform-lab-dev-postgres" \
    --query "version" \
    --output tsv 2>/dev/null || echo "Unknown")
add_result "postgres_version" "$POSTGRES_VERSION"

POSTGRES_SKU=$(az postgres flexible-server show \
    --resource-group "$RESOURCE_GROUP" \
    --name "terraform-lab-dev-postgres" \
    --query "sku.tier" \
    --output tsv 2>/dev/null || echo "Unknown")
add_result "postgres_sku_family" "$POSTGRES_SKU"

# 6. Key Vault Validation
echo "Checking Key Vault..." >&2
KV_NAME=$(az keyvault list \
    --resource-group "$RESOURCE_GROUP" \
    --query "[0].name" \
    --output tsv 2>/dev/null || echo "")

if [ -n "$KV_NAME" ]; then
    SECRET_COUNT=$(az keyvault secret list \
        --vault-name "$KV_NAME" \
        --query "length(@)" \
        --output tsv 2>/dev/null || echo "0")
    add_result "key_vault_secret_count" "$SECRET_COUNT"
    
    # Check Key Vault properties
    KV_SOFT_DELETE=$(az keyvault show \
        --name "$KV_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --query "properties.enableSoftDelete" \
        --output tsv 2>/dev/null || echo "false")
    add_result "key_vault_soft_delete" "$KV_SOFT_DELETE"
    
    KV_PURGE_PROTECTION=$(az keyvault show \
        --name "$KV_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --query "properties.enablePurgeProtection" \
        --output tsv 2>/dev/null || echo "false")
    add_result "key_vault_purge_protection" "$KV_PURGE_PROTECTION"
    
    # Access policies count
    ACCESS_POLICY_COUNT=$(az keyvault show \
        --name "$KV_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --query "properties.accessPolicies | length(@)" \
        --output tsv 2>/dev/null || echo "0")
    add_result "key_vault_access_policy_count" "$ACCESS_POLICY_COUNT"
else
    add_result "key_vault_secret_count" "0"
    add_result "key_vault_soft_delete" "false"
    add_result "key_vault_purge_protection" "false"
    add_result "key_vault_access_policy_count" "0"
fi

# 7. Resource Tagging Compliance
echo "Checking resource tagging..." >&2
ALL_RESOURCES=$(az resource list \
    --resource-group "$RESOURCE_GROUP" \
    --query "[].{id:id,tags:tags}" \
    --output json 2>/dev/null || echo "[]")

# Check if all resources have required tags
REQUIRED_TAGS=("Environment" "Project" "ManagedBy" "CostCenter" "Owner")
ALL_TAGGED="true"
COST_CENTER_TAG=""
ENVIRONMENT_TAG=""
MANAGED_BY_TAG=""

if [ "$ALL_RESOURCES" != "[]" ]; then
    for tag in "${REQUIRED_TAGS[@]}"; do
        MISSING_TAG_COUNT=$(echo "$ALL_RESOURCES" | jq -r --arg tag "$tag" '
            [.[] | select(.tags[$tag] == null or .tags[$tag] == "")] | length
        ')
        if [ "$MISSING_TAG_COUNT" -gt "0" ]; then
            ALL_TAGGED="false"
            break
        fi
    done
    
    # Get specific tag values
    COST_CENTER_TAG=$(echo "$ALL_RESOURCES" | jq -r '.[0].tags.CostCenter // "missing"')
    ENVIRONMENT_TAG=$(echo "$ALL_RESOURCES" | jq -r '.[0].tags.Environment // "missing"')
    MANAGED_BY_TAG=$(echo "$ALL_RESOURCES" | jq -r '.[0].tags.ManagedBy // "missing"')
fi

add_result "all_resources_tagged" "$ALL_TAGGED"
add_result "cost_center_tag" "$COST_CENTER_TAG"
add_result "environment_tag" "$ENVIRONMENT_TAG"
add_result "managed_by_tag" "$MANAGED_BY_TAG"

# 8. Network Security Group Validation
echo "Checking NSG rules..." >&2
NSG_LIST=$(az network nsg list \
    --resource-group "$RESOURCE_GROUP" \
    --query "[].name" \
    --output tsv 2>/dev/null || echo "")

DEFAULT_DENY_ALL="false"
if [ -n "$NSG_LIST" ]; then
    # Check if NSGs have default deny all rules
    for nsg in $NSG_LIST; do
        DENY_RULE_COUNT=$(az network nsg rule list \
            --resource-group "$RESOURCE_GROUP" \
            --nsg-name "$nsg" \
            --query "[?access=='Deny' && priority>=4000] | length(@)" \
            --output tsv 2>/dev/null || echo "0")
        if [ "$DENY_RULE_COUNT" -gt "0" ]; then
            DEFAULT_DENY_ALL="true"
            break
        fi
    done
fi
add_result "nsg_default_deny_all" "$DEFAULT_DENY_ALL"

# 9. VMSS Instance Counts
echo "Checking VMSS instance counts..." >&2
WEB_VMSS_NAME=$(az vmss list \
    --resource-group "$RESOURCE_GROUP" \
    --query "[?contains(name, 'web')].name | [0]" \
    --output tsv 2>/dev/null || echo "")

if [ -n "$WEB_VMSS_NAME" ]; then
    WEB_INSTANCE_COUNT=$(az vmss show \
        --resource-group "$RESOURCE_GROUP" \
        --name "$WEB_VMSS_NAME" \
        --query "sku.capacity" \
        --output tsv 2>/dev/null || echo "0")
    add_result "web_vmss_instance_count" "$WEB_INSTANCE_COUNT"
else
    add_result "web_vmss_instance_count" "0"
fi

APP_VMSS_NAME_FULL=$(az vmss list \
    --resource-group "$RESOURCE_GROUP" \
    --query "[?contains(name, 'app')].name | [0]" \
    --output tsv 2>/dev/null || echo "")

if [ -n "$APP_VMSS_NAME_FULL" ]; then
    APP_INSTANCE_COUNT=$(az vmss show \
        --resource-group "$RESOURCE_GROUP" \
        --name "$APP_VMSS_NAME_FULL" \
        --query "sku.capacity" \
        --output tsv 2>/dev/null || echo "0")
    add_result "app_vmss_instance_count" "$APP_INSTANCE_COUNT"
else
    add_result "app_vmss_instance_count" "0"
fi

echo "Azure API validation completed" >&2

# Output final result
echo "$RESULT"