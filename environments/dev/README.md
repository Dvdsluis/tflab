<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.117.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_compute"></a> [compute](#module\_compute) | ../../modules/compute | n/a |
| <a name="module_database"></a> [database](#module\_database) | ../../modules/database | n/a |
| <a name="module_networking"></a> [networking](#module\_networking) | ../../modules/networking | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tags"></a> [additional\_tags](#input\_additional\_tags) | Additional tags to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | Admin username for VMs | `string` | `"azureuser"` | no |
| <a name="input_app_instance_count"></a> [app\_instance\_count](#input\_app\_instance\_count) | Number of app server instances | `number` | `2` | no |
| <a name="input_app_vm_size"></a> [app\_vm\_size](#input\_app\_vm\_size) | VM size for app servers | `string` | `"Standard_B1s"` | no |
| <a name="input_azure_region"></a> [azure\_region](#input\_azure\_region) | Azure region | `string` | `"East US"` | no |
| <a name="input_database_subnets"></a> [database\_subnets](#input\_database\_subnets) | List of database subnet CIDR blocks | `list(string)` | <pre>[<br>  "10.0.21.0/24",<br>  "10.0.22.0/24",<br>  "10.0.23.0/24"<br>]</pre> | no |
| <a name="input_db_admin_username"></a> [db\_admin\_username](#input\_db\_admin\_username) | Database administrator username | `string` | `"sqladmin"` | no |
| <a name="input_db_backup_retention_days"></a> [db\_backup\_retention\_days](#input\_db\_backup\_retention\_days) | Database backup retention period in days | `number` | `7` | no |
| <a name="input_db_server_version"></a> [db\_server\_version](#input\_db\_server\_version) | Database server version | `string` | `"12"` | no |
| <a name="input_db_sku_name"></a> [db\_sku\_name](#input\_db\_sku\_name) | Database SKU name | `string` | `"B_Standard_B1ms"` | no |
| <a name="input_db_storage_mb"></a> [db\_storage\_mb](#input\_db\_storage\_mb) | Database storage in MB | `number` | `32768` | no |
| <a name="input_enable_nat_gateway"></a> [enable\_nat\_gateway](#input\_enable\_nat\_gateway) | Enable NAT Gateway for private subnets | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (dev, staging, prod) | `string` | `"dev"` | no |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | List of private subnet CIDR blocks | `list(string)` | <pre>[<br>  "10.0.11.0/24",<br>  "10.0.12.0/24",<br>  "10.0.13.0/24"<br>]</pre> | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the project | `string` | `"terraform-lab"` | no |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | List of public subnet CIDR blocks | `list(string)` | <pre>[<br>  "10.0.1.0/24",<br>  "10.0.2.0/24",<br>  "10.0.3.0/24"<br>]</pre> | no |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | SSH public key for VM admin access (in OpenSSH format) | `string` | n/a | yes |
| <a name="input_vnet_cidr"></a> [vnet\_cidr](#input\_vnet\_cidr) | CIDR block for VNet | `string` | `"10.0.0.0/16"` | no |
| <a name="input_web_instance_count"></a> [web\_instance\_count](#input\_web\_instance\_count) | Number of web server instances | `number` | `2` | no |
| <a name="input_web_vm_size"></a> [web\_vm\_size](#input\_web\_vm\_size) | VM size for web servers | `string` | `"Standard_B1s"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_nsg_id"></a> [app\_nsg\_id](#output\_app\_nsg\_id) | ID of the app network security group |
| <a name="output_app_vmss_id"></a> [app\_vmss\_id](#output\_app\_vmss\_id) | ID of the app VM scale set |
| <a name="output_app_vmss_instance_count"></a> [app\_vmss\_instance\_count](#output\_app\_vmss\_instance\_count) | Instance count of the app VM scale set |
| <a name="output_app_vmss_name"></a> [app\_vmss\_name](#output\_app\_vmss\_name) | Name of the app VM scale set |
| <a name="output_app_vmss_sku"></a> [app\_vmss\_sku](#output\_app\_vmss\_sku) | SKU of the app VM scale set |
| <a name="output_database_nsg_id"></a> [database\_nsg\_id](#output\_database\_nsg\_id) | ID of the database network security group |
| <a name="output_database_subnet_ids"></a> [database\_subnet\_ids](#output\_database\_subnet\_ids) | IDs of the database subnets |
| <a name="output_key_vault_id"></a> [key\_vault\_id](#output\_key\_vault\_id) | ID of the Key Vault for database secrets |
| <a name="output_mysql_server_id"></a> [mysql\_server\_id](#output\_mysql\_server\_id) | ID of the MySQL Flexible Server |
| <a name="output_postgres_server_id"></a> [postgres\_server\_id](#output\_postgres\_server\_id) | ID of the PostgreSQL Flexible Server |
| <a name="output_private_subnet_ids"></a> [private\_subnet\_ids](#output\_private\_subnet\_ids) | IDs of the private subnets |
| <a name="output_public_subnet_ids"></a> [public\_subnet\_ids](#output\_public\_subnet\_ids) | IDs of the public subnets |
| <a name="output_vnet_address_space"></a> [vnet\_address\_space](#output\_vnet\_address\_space) | Address space of the Virtual Network |
| <a name="output_vnet_id"></a> [vnet\_id](#output\_vnet\_id) | ID of the Virtual Network |
| <a name="output_web_load_balancer_id"></a> [web\_load\_balancer\_id](#output\_web\_load\_balancer\_id) | ID of the web load balancer |
| <a name="output_web_load_balancer_ip"></a> [web\_load\_balancer\_ip](#output\_web\_load\_balancer\_ip) | Public IP of the web load balancer |
| <a name="output_web_nsg_id"></a> [web\_nsg\_id](#output\_web\_nsg\_id) | ID of the web network security group |
| <a name="output_web_vmss_id"></a> [web\_vmss\_id](#output\_web\_vmss\_id) | ID of the web VM scale set |
<!-- END_TF_DOCS -->