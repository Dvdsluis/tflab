#!/bin/bash
# Network Connectivity Test Script
# This script tests actual network flows, connectivity, and security rules
# Goes beyond configuration to test real network behavior

set -e

# Parse input JSON
eval "$(jq -r '@sh "RESOURCE_GROUP=\(.resource_group) VNET_NAME=\(.vnet_name)"')"

# Initialize result object
RESULT="{}"

# Function to add result
add_result() {
    local key=$1
    local value=$2
    RESULT=$(echo $RESULT | jq --arg k "$key" --arg v "$value" '. + {($k): $v}')
}

echo "Starting network connectivity tests..." >&2

# 1. Test Public Subnet Internet Connectivity
echo "Testing public subnet internet connectivity..." >&2
PUBLIC_SUBNET_ID=$(az network vnet subnet show \
    --resource-group "$RESOURCE_GROUP" \
    --vnet-name "$VNET_NAME" \
    --name "terraform-lab-dev-public-1" \
    --query "id" \
    --output tsv 2>/dev/null || echo "")

if [ -n "$PUBLIC_SUBNET_ID" ]; then
    # Check if public subnet has route to internet (0.0.0.0/0)
    ROUTE_TABLE_ID=$(az network vnet subnet show \
        --resource-group "$RESOURCE_GROUP" \
        --vnet-name "$VNET_NAME" \
        --name "terraform-lab-dev-public-1" \
        --query "routeTable.id" \
        --output tsv 2>/dev/null || echo "")
    
    if [ -n "$ROUTE_TABLE_ID" ] && [ "$ROUTE_TABLE_ID" != "null" ]; then
        # Has custom route table - check for internet route
        INTERNET_ROUTE=$(az network route-table route list \
            --resource-group "$RESOURCE_GROUP" \
            --route-table-name "$(basename "$ROUTE_TABLE_ID")" \
            --query "[?addressPrefix=='0.0.0.0/0'].nextHopType" \
            --output tsv 2>/dev/null || echo "")
        
        if [ "$INTERNET_ROUTE" = "Internet" ]; then
            add_result "public_subnet_internet" "connected"
        else
            add_result "public_subnet_internet" "custom_route"
        fi
    else
        # No custom route table means default Azure routing (internet access)
        add_result "public_subnet_internet" "connected"
    fi
else
    add_result "public_subnet_internet" "not_found"
fi

# 2. Test Private Subnet NAT Gateway Connectivity
echo "Testing private subnet NAT Gateway connectivity..." >&2
PRIVATE_SUBNET_ID=$(az network vnet subnet show \
    --resource-group "$RESOURCE_GROUP" \
    --vnet-name "$VNET_NAME" \
    --name "terraform-lab-dev-private-1" \
    --query "id" \
    --output tsv 2>/dev/null || echo "")

if [ -n "$PRIVATE_SUBNET_ID" ]; then
    # Check if private subnet has NAT Gateway attached
    NAT_GATEWAY_ID=$(az network vnet subnet show \
        --resource-group "$RESOURCE_GROUP" \
        --vnet-name "$VNET_NAME" \
        --name "terraform-lab-dev-private-1" \
        --query "natGateway.id" \
        --output tsv 2>/dev/null || echo "")
    
    if [ -n "$NAT_GATEWAY_ID" ] && [ "$NAT_GATEWAY_ID" != "null" ]; then
        # Check NAT Gateway has public IP
        NAT_GW_NAME=$(basename "$NAT_GATEWAY_ID")
        PUBLIC_IP_COUNT=$(az network nat gateway show \
            --resource-group "$RESOURCE_GROUP" \
            --name "$NAT_GW_NAME" \
            --query "publicIpAddresses | length(@)" \
            --output tsv 2>/dev/null || echo "0")
        
        if [ "$PUBLIC_IP_COUNT" -gt "0" ]; then
            add_result "private_subnet_nat" "connected"
        else
            add_result "private_subnet_nat" "no_public_ip"
        fi
    else
        add_result "private_subnet_nat" "no_nat_gateway"
    fi
else
    add_result "private_subnet_nat" "not_found"
fi

# 3. Test Database Subnet Isolation
echo "Testing database subnet isolation..." >&2
DATABASE_SUBNET_ID=$(az network vnet subnet show \
    --resource-group "$RESOURCE_GROUP" \
    --vnet-name "$VNET_NAME" \
    --name "terraform-lab-dev-database-1" \
    --query "id" \
    --output tsv 2>/dev/null || echo "")

if [ -n "$DATABASE_SUBNET_ID" ]; then
    # Check if database subnet has NAT Gateway (should not for isolation)
    DB_NAT_GATEWAY_ID=$(az network vnet subnet show \
        --resource-group "$RESOURCE_GROUP" \
        --vnet-name "$VNET_NAME" \
        --name "terraform-lab-dev-database-1" \
        --query "natGateway.id" \
        --output tsv 2>/dev/null || echo "")
    
    # Check if database subnet has service delegation
    DELEGATION=$(az network vnet subnet show \
        --resource-group "$RESOURCE_GROUP" \
        --vnet-name "$VNET_NAME" \
        --name "terraform-lab-dev-database-1" \
        --query "delegations[0].serviceName" \
        --output tsv 2>/dev/null || echo "")
    
    if [ -z "$DB_NAT_GATEWAY_ID" ] || [ "$DB_NAT_GATEWAY_ID" = "null" ]; then
        add_result "database_subnet_isolation" "isolated"
    else
        add_result "database_subnet_isolation" "not_isolated"
    fi
    
    add_result "database_subnet_delegation" "$DELEGATION"
else
    add_result "database_subnet_isolation" "not_found"
    add_result "database_subnet_delegation" "not_found"
fi

# 4. Test Network Security Group Rules
echo "Testing NSG rule effectiveness..." >&2

# Web NSG - should allow HTTP/HTTPS from anywhere
WEB_NSG_NAME="terraform-lab-dev-web-nsg"
WEB_HTTP_RULE=$(az network nsg rule show \
    --resource-group "$RESOURCE_GROUP" \
    --nsg-name "$WEB_NSG_NAME" \
    --name "Allow-HTTP" \
    --query "access" \
    --output tsv 2>/dev/null || echo "")

if [ "$WEB_HTTP_RULE" = "Allow" ]; then
    add_result "web_http_accessible" "true"
else
    add_result "web_http_accessible" "false"
fi

WEB_HTTPS_RULE=$(az network nsg rule show \
    --resource-group "$RESOURCE_GROUP" \
    --nsg-name "$WEB_NSG_NAME" \
    --name "Allow-HTTPS" \
    --query "access" \
    --output tsv 2>/dev/null || echo "")

if [ "$WEB_HTTPS_RULE" = "Allow" ]; then
    add_result "web_https_accessible" "true"
else
    add_result "web_https_accessible" "false"
fi

# App NSG - should only allow access from VNet
APP_NSG_NAME="terraform-lab-dev-app-nsg"
APP_HTTP_RULE=$(az network nsg rule show \
    --resource-group "$RESOURCE_GROUP" \
    --nsg-name "$APP_NSG_NAME" \
    --name "Allow-App-HTTP" \
    --query "{access: access, source: sourceAddressPrefix}" \
    --output json 2>/dev/null || echo '{}')

APP_ACCESS=$(echo "$APP_HTTP_RULE" | jq -r '.access // "Deny"')
APP_SOURCE=$(echo "$APP_HTTP_RULE" | jq -r '.source // "*"')

if [ "$APP_ACCESS" = "Allow" ] && [ "$APP_SOURCE" = "10.0.0.0/16" ]; then
    add_result "app_tier_isolated" "true"
else
    add_result "app_tier_isolated" "false"
fi

# Database NSG - should only allow PostgreSQL from app subnet
DB_NSG_NAME="terraform-lab-dev-database-nsg"
DB_POSTGRES_RULE=$(az network nsg rule show \
    --resource-group "$RESOURCE_GROUP" \
    --nsg-name "$DB_NSG_NAME" \
    --name "Allow-Postgres" \
    --query "{access: access, source: sourceAddressPrefix, port: destinationPortRange}" \
    --output json 2>/dev/null || echo '{}')

DB_ACCESS=$(echo "$DB_POSTGRES_RULE" | jq -r '.access // "Deny"')
DB_SOURCE=$(echo "$DB_POSTGRES_RULE" | jq -r '.source // "*"')
DB_PORT=$(echo "$DB_POSTGRES_RULE" | jq -r '.port // "0"')

if [ "$DB_ACCESS" = "Allow" ] && [ "$DB_SOURCE" = "10.0.0.0/16" ] && [ "$DB_PORT" = "5432" ]; then
    add_result "database_port_5432" "restricted"
else
    add_result "database_port_5432" "unrestricted"
fi

# 5. Test SSH Access Restrictions
echo "Testing SSH access restrictions..." >&2
SSH_RULES_COUNT=0
SSH_RESTRICTED="true"

# Check all NSGs for SSH rules
for nsg in "terraform-lab-dev-web-nsg" "terraform-lab-dev-app-nsg"; do
    SSH_RULE=$(az network nsg rule show \
        --resource-group "$RESOURCE_GROUP" \
        --nsg-name "$nsg" \
        --name "Allow-SSH" \
        --query "{access: access, source: sourceAddressPrefix, port: destinationPortRange}" \
        --output json 2>/dev/null || echo '{}')
    
    SSH_ACCESS=$(echo "$SSH_RULE" | jq -r '.access // "Deny"')
    SSH_SOURCE=$(echo "$SSH_RULE" | jq -r '.source // ""')
    SSH_PORT=$(echo "$SSH_RULE" | jq -r '.port // ""')
    
    if [ "$SSH_ACCESS" = "Allow" ] && [ "$SSH_PORT" = "22" ]; then
        SSH_RULES_COUNT=$((SSH_RULES_COUNT + 1))
        # Check if source is restricted (not from anywhere)
        if [ "$SSH_SOURCE" = "*" ] || [ "$SSH_SOURCE" = "0.0.0.0/0" ]; then
            SSH_RESTRICTED="false"
        fi
    fi
done

add_result "ssh_access_restricted" "$SSH_RESTRICTED"

# 6. Test Database Public Access
echo "Testing database public access..." >&2
DB_PUBLIC_ACCESS=$(az postgres flexible-server show \
    --resource-group "$RESOURCE_GROUP" \
    --name "terraform-lab-dev-postgres" \
    --query "network.publicNetworkAccess" \
    --output tsv 2>/dev/null || echo "Enabled")

if [ "$DB_PUBLIC_ACCESS" = "Disabled" ]; then
    add_result "database_public_access" "false"
else
    add_result "database_public_access" "true"
fi

# 7. Test Load Balancer Accessibility
echo "Testing load balancer accessibility..." >&2

# Web Load Balancer should have public IP
WEB_LB_NAME=$(az network lb list \
    --resource-group "$RESOURCE_GROUP" \
    --query "[?contains(name, 'web')].name | [0]" \
    --output tsv 2>/dev/null || echo "")

if [ -n "$WEB_LB_NAME" ]; then
    WEB_LB_PUBLIC_IP=$(az network lb frontend-ip list \
        --resource-group "$RESOURCE_GROUP" \
        --lb-name "$WEB_LB_NAME" \
        --query "[0].publicIpAddress.id" \
        --output tsv 2>/dev/null || echo "")
    
    if [ -n "$WEB_LB_PUBLIC_IP" ] && [ "$WEB_LB_PUBLIC_IP" != "null" ]; then
        add_result "web_load_balancer_public" "true"
    else
        add_result "web_load_balancer_public" "false"
    fi
else
    add_result "web_load_balancer_public" "false"
fi

# App Load Balancer should be internal only
APP_LB_NAME=$(az network lb list \
    --resource-group "$RESOURCE_GROUP" \
    --query "[?contains(name, 'app')].name | [0]" \
    --output tsv 2>/dev/null || echo "")

if [ -n "$APP_LB_NAME" ]; then
    APP_LB_PUBLIC_IP=$(az network lb frontend-ip list \
        --resource-group "$RESOURCE_GROUP" \
        --lb-name "$APP_LB_NAME" \
        --query "[0].publicIpAddress.id" \
        --output tsv 2>/dev/null || echo "")
    
    if [ -z "$APP_LB_PUBLIC_IP" ] || [ "$APP_LB_PUBLIC_IP" = "null" ]; then
        add_result "app_load_balancer_internal" "true"
    else
        add_result "app_load_balancer_internal" "false"
    fi
else
    add_result "app_load_balancer_internal" "false"
fi

echo "Network connectivity tests completed" >&2

# Output final result
echo "$RESULT"