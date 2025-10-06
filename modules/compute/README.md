<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_lb.app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb) | resource |
| [azurerm_lb.web](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb) | resource |
| [azurerm_lb_backend_address_pool.app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_backend_address_pool) | resource |
| [azurerm_lb_backend_address_pool.web](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_backend_address_pool) | resource |
| [azurerm_lb_probe.app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_probe) | resource |
| [azurerm_lb_probe.web](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_probe) | resource |
| [azurerm_lb_rule.app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_rule) | resource |
| [azurerm_lb_rule.web](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_rule) | resource |
| [azurerm_linux_virtual_machine_scale_set.app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set) | resource |
| [azurerm_linux_virtual_machine_scale_set.web](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set) | resource |
| [azurerm_network_security_group.app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_group.web](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | Admin username for VMs | `string` | n/a | yes |
| <a name="input_allowed_vm_skus"></a> [allowed\_vm\_skus](#input\_allowed\_vm\_skus) | List of allowed VM SKUs for policy compliance | `list(string)` | <pre>[<br>  "Standard_D2s_v3",<br>  "Standard_K8S2_v1",<br>  "Standard_K8S_v1",<br>  "Standard_B2s",<br>  "Standard_B1s",<br>  "Standard_DS1_v2",<br>  "Standard_B4ms"<br>]</pre> | no |
| <a name="input_app_subnet_id"></a> [app\_subnet\_id](#input\_app\_subnet\_id) | ID of the app subnet | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Azure region for resources | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix for resource names | `string` | n/a | yes |
| <a name="input_private_instance_config"></a> [private\_instance\_config](#input\_private\_instance\_config) | Configuration for private VMSS instances | <pre>object({<br>    instance_type = string<br>    desired_size  = number<br>  })</pre> | n/a | yes |
| <a name="input_public_instance_config"></a> [public\_instance\_config](#input\_public\_instance\_config) | Configuration for public VMSS instances | <pre>object({<br>    instance_type = string<br>    desired_size  = number<br>  })</pre> | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group | `string` | n/a | yes |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | SSH public key for VM admin user (enterprise: use secure key management) | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the resource | `map(string)` | `{}` | no |
| <a name="input_vnet_cidr"></a> [vnet\_cidr](#input\_vnet\_cidr) | CIDR block of the VNet | `string` | n/a | yes |
| <a name="input_web_public_ip_id"></a> [web\_public\_ip\_id](#input\_web\_public\_ip\_id) | ID of the public IP for the web load balancer | `string` | n/a | yes |
| <a name="input_web_subnet_id"></a> [web\_subnet\_id](#input\_web\_subnet\_id) | ID of the web subnet | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_lb_id"></a> [app\_lb\_id](#output\_app\_lb\_id) | ID of the app load balancer |
| <a name="output_app_nsg_id"></a> [app\_nsg\_id](#output\_app\_nsg\_id) | ID of the app network security group |
| <a name="output_app_vmss_id"></a> [app\_vmss\_id](#output\_app\_vmss\_id) | ID of the app VM scale set |
| <a name="output_app_vmss_instance_count"></a> [app\_vmss\_instance\_count](#output\_app\_vmss\_instance\_count) | Instance count of the app VM scale set |
| <a name="output_app_vmss_name"></a> [app\_vmss\_name](#output\_app\_vmss\_name) | Name of the app VM scale set |
| <a name="output_app_vmss_sku"></a> [app\_vmss\_sku](#output\_app\_vmss\_sku) | SKU of the app VM scale set |
| <a name="output_web_lb_id"></a> [web\_lb\_id](#output\_web\_lb\_id) | ID of the web load balancer |
| <a name="output_web_lb_public_ip"></a> [web\_lb\_public\_ip](#output\_web\_lb\_public\_ip) | Public IP of the web load balancer |
| <a name="output_web_nsg_id"></a> [web\_nsg\_id](#output\_web\_nsg\_id) | ID of the web network security group |
| <a name="output_web_vmss_id"></a> [web\_vmss\_id](#output\_web\_vmss\_id) | ID of the web VM scale set |
<!-- END_TF_DOCS -->