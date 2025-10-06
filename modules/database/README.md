<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 3.0 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_key_vault.database](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_key_vault_secret.db_password](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_mysql_flexible_server.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mysql_flexible_server) | resource |
| [azurerm_network_security_group.database](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_postgresql_flexible_server.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server) | resource |
| [random_password.db_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allocated_storage"></a> [allocated\_storage](#input\_allocated\_storage) | Initial allocated storage in GB | `number` | `20` | no |
| <a name="input_allowed_cidr"></a> [allowed\_cidr](#input\_allowed\_cidr) | CIDR block allowed to access the database (e.g., app subnet) | `string` | n/a | yes |
| <a name="input_backup_retention_period"></a> [backup\_retention\_period](#input\_backup\_retention\_period) | Backup retention period in days | `number` | `7` | no |
| <a name="input_db_subnet_id"></a> [db\_subnet\_id](#input\_db\_subnet\_id) | Delegated subnet ID for the DB server | `string` | n/a | yes |
| <a name="input_engine"></a> [engine](#input\_engine) | Database engine (mysql or postgres) | `string` | `"mysql"` | no |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | Database engine version | `string` | `"8.0"` | no |
| <a name="input_high_availability"></a> [high\_availability](#input\_high\_availability) | High availability mode (e.g., ZoneRedundant, Disabled) | `string` | `"Disabled"` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region for resources | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix for resource names | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group | `string` | n/a | yes |
| <a name="input_secret_expiration_hours"></a> [secret\_expiration\_hours](#input\_secret\_expiration\_hours) | Number of hours until Key Vault secret expires (default: 8760 = 1 year) | `number` | `8760` | no |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | Azure DB SKU name (e.g., Standard\_D2ds\_v4) | `string` | `"Standard_D2ds_v4"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the resource | `map(string)` | `{}` | no |
| <a name="input_username"></a> [username](#input\_username) | Admin username for the database | `string` | n/a | yes |
| <a name="input_zone"></a> [zone](#input\_zone) | Availability zone for the DB server | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_database_nsg_id"></a> [database\_nsg\_id](#output\_database\_nsg\_id) | ID of the database network security group |
| <a name="output_database_password_secret_id"></a> [database\_password\_secret\_id](#output\_database\_password\_secret\_id) | ID of the Key Vault secret containing the database password |
| <a name="output_key_vault_id"></a> [key\_vault\_id](#output\_key\_vault\_id) | ID of the Key Vault created for database secrets |
| <a name="output_key_vault_uri"></a> [key\_vault\_uri](#output\_key\_vault\_uri) | URI of the Key Vault created for database secrets |
| <a name="output_mysql_server_id"></a> [mysql\_server\_id](#output\_mysql\_server\_id) | ID of the Azure MySQL Flexible Server (if MySQL) |
| <a name="output_postgres_server_id"></a> [postgres\_server\_id](#output\_postgres\_server\_id) | ID of the Azure PostgreSQL Flexible Server (if Postgres) |
<!-- END_TF_DOCS -->
<!-- END_TF_DOCS -->