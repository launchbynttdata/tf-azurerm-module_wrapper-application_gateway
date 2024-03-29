# tf-azurerm-module_collection-application_gateway
In this example, we deploy an application gateway with a backend pool that contains two web applications. The `deployment` folder contains `deployment.md` file to demonstrate how a sample application can be deployed to web apps. The file also contains instructions for testing web applications using app gateway service url. The example demonstrates how layer 7 load balancing can be achieved via app gateway.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | <= 1.5.5 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=3.77.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.97.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_app-gateway"></a> [app-gateway](#module\_app-gateway) | ../.. | n/a |
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | git::https://github.com/launchbynttdata/tf-azurerm-module_primitive-resource_group.git | 1.0.0 |
| <a name="module_resource_names"></a> [resource\_names](#module\_resource\_names) | git::https://github.com/launchbynttdata/tf-launch-module_library-resource_name.git | 1.0.0 |
| <a name="module_network"></a> [network](#module\_network) | Azure/vnet/azurerm | 4.1.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_service_plan.app_service_plan](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan) | resource |
| [azurerm_windows_web_app.windows_web_app_images](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_web_app) | resource |
| [azurerm_windows_web_app.windows_web_app_videos](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_web_app) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_gateways"></a> [app\_gateways](#input\_app\_gateways) | n/a | <pre>map(object({<br>    appgw_backend_http_settings = list(object({<br>      name                                = string<br>      port                                = optional(number, 443)<br>      protocol                            = optional(string, "Https")<br>      path                                = optional(string)<br>      probe_name                          = optional(string)<br>      cookie_based_affinity               = optional(string, "Disabled")<br>      affinity_cookie_name                = optional(string, "ApplicationGatewayAffinity")<br>      request_timeout                     = optional(number, 20)<br>      host_name                           = optional(string)<br>      pick_host_name_from_backend_address = optional(bool, true)<br>      trusted_root_certificate_names      = optional(list(string), [])<br>      authentication_certificate          = optional(string)<br>      connection_draining_timeout_sec     = optional(number)<br>    })),<br>    appgw_http_listeners = list(object({<br>      name                           = string<br>      frontend_ip_configuration_name = optional(string)<br>      frontend_port_name             = optional(string)<br>      host_name                      = optional(string)<br>      host_names                     = optional(list(string))<br>      protocol                       = optional(string, "Https")<br>      require_sni                    = optional(bool, false)<br>      ssl_certificate_name           = optional(string)<br>      ssl_profile_name               = optional(string)<br>      firewall_policy_id             = optional(string)<br>      custom_error_configuration = optional(list(object({<br>        status_code           = string<br>        custom_error_page_url = string<br>      })), [])<br>    })),<br>    appgw_routings = list(object({ name = string<br>      rule_type                   = optional(string, "Basic")<br>      http_listener_name          = optional(string)<br>      backend_address_pool_name   = optional(string)<br>      backend_http_settings_name  = optional(string)<br>      url_path_map_name           = optional(string)<br>      redirect_configuration_name = optional(string)<br>      rewrite_rule_set_name       = optional(string)<br>      priority                    = optional(number)<br>    })),<br>    appgw_url_path_map = optional(list(object({<br>      name                                = string<br>      default_backend_address_pool_name   = optional(string)<br>      default_redirect_configuration_name = optional(string)<br>      default_backend_http_settings_name  = optional(string)<br>      default_rewrite_rule_set_name       = optional(string)<br>      path_rules = list(object({<br>        name                        = string<br>        backend_address_pool_name   = optional(string)<br>        backend_http_settings_name  = optional(string)<br>        rewrite_rule_set_name       = optional(string)<br>        redirect_configuration_name = optional(string)<br>        paths                       = optional(list(string), [])<br>      }))<br>    })), []),<br>    client_name           = string,<br>    environment           = string,<br>    location_short        = optional(string, ""),<br>    logs_destinations_ids = list(string),<br>    stack                 = string,<br>    app_gateway_tags      = optional(map(string), {}),<br>    custom_appgw_name     = optional(string, ""),<br>    create_subnet         = bool,<br>    appgw_rewrite_rule_set = optional(list(object({<br>      name = string<br>      rewrite_rules = list(object({<br>        name          = string<br>        rule_sequence = string<br>        conditions = optional(list(object({<br>          variable    = string<br>          pattern     = string<br>          ignore_case = optional(bool, false)<br>          negate      = optional(bool, false)<br>          })),<br>        [])<br>        response_header_configurations = optional(list(object({<br>          header_name = string<br>          header_value = string })),<br>        [])<br>        request_header_configurations = optional(list(object({<br>          header_name = string<br>          header_value = string })),<br>        [])<br>        url_reroute = optional(object({<br>          path         = optional(string)<br>          query_string = optional(string)<br>          components   = optional(string)<br>          reroute      = optional(bool)<br>        }))<br>      }))<br>    })), []),<br>    appgw_probes = optional(list(object({<br>      name                                      = string<br>      host                                      = optional(string)<br>      port                                      = optional(number, null)<br>      interval                                  = optional(number, 30)<br>      path                                      = optional(string, "/")<br>      protocol                                  = optional(string, "Https")<br>      timeout                                   = optional(number, 30)<br>      unhealthy_threshold                       = optional(number, 3)<br>      pick_host_name_from_backend_http_settings = optional(bool, false)<br>      minimum_servers                           = optional(number, 0)<br>      match = optional(object(<br>        {<br>          body        = optional(string, "")<br>          status_code = optional(list(string), ["200-399"])<br>      }), {})<br>    })), []),<br>    frontend_port_settings = list(object({<br>      name = string<br>      port = number<br>    }))<br>    custom_ip_name                        = optional(string, "")<br>    custom_ip_label                       = optional(string, "")<br>    custom_frontend_ip_configuration_name = optional(string, "")<br>  }))</pre> | n/a | yes |
| <a name="input_resource_names_map"></a> [resource\_names\_map](#input\_resource\_names\_map) | A map of key to resource\_name that will be used by tf-launch-module\_library-resource\_name to generate resource names | <pre>map(object({<br>    name       = string<br>    max_length = optional(number, 60)<br>  }))</pre> | <pre>{<br>  "app_gateway": {<br>    "max_length": 80,<br>    "name": "appgw"<br>  },<br>  "app_service": {<br>    "max_length": 80,<br>    "name": "appsvc"<br>  },<br>  "resource_group": {<br>    "max_length": 90,<br>    "name": "rg"<br>  },<br>  "vnet": {<br>    "max_length": 80,<br>    "name": "vnet"<br>  },<br>  "web_app_images": {<br>    "max_length": 80,<br>    "name": "webapp"<br>  },<br>  "web_app_videos": {<br>    "max_length": 80,<br>    "name": "webapp"<br>  }<br>}</pre> | no |
| <a name="input_environment_number"></a> [environment\_number](#input\_environment\_number) | The environment count for the respective environment. Defaults to 000. Increments in value of 1 | `string` | `"000"` | no |
| <a name="input_resource_number"></a> [resource\_number](#input\_resource\_number) | The resource count for the respective resource. Defaults to 000. Increments in value of 1 | `string` | `"000"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region in which the infra needs to be provisioned | `string` | `"eastus2"` | no |
| <a name="input_logical_product_family"></a> [logical\_product\_family](#input\_logical\_product\_family) | (Required) Name of the product family for which the resource is created.<br>    Example: org\_name, department\_name. | `string` | `"launch"` | no |
| <a name="input_logical_product_service"></a> [logical\_product\_service](#input\_logical\_product\_service) | (Required) Name of the product service for which the resource is created.<br>    For example, backend, frontend, middleware etc. | `string` | `"network"` | no |
| <a name="input_subnet_prefixes"></a> [subnet\_prefixes](#input\_subnet\_prefixes) | (Required) The address prefix to use for the subnet. | `list(string)` | n/a | yes |
| <a name="input_address_space"></a> [address\_space](#input\_address\_space) | (Required)The address space that is used by the virtual network. | `list(string)` | n/a | yes |
| <a name="input_subnet_names"></a> [subnet\_names](#input\_subnet\_names) | (Required) The names of the subnets to be created. | `list(string)` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | (Required) Project environment. | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | (Required) Azure location. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_appgw_backend_address_pool_ids"></a> [appgw\_backend\_address\_pool\_ids](#output\_appgw\_backend\_address\_pool\_ids) | List of backend address pool Ids. |
| <a name="output_appgw_backend_http_settings_ids"></a> [appgw\_backend\_http\_settings\_ids](#output\_appgw\_backend\_http\_settings\_ids) | List of backend HTTP settings Ids. |
| <a name="output_appgw_backend_http_settings_probe_ids"></a> [appgw\_backend\_http\_settings\_probe\_ids](#output\_appgw\_backend\_http\_settings\_probe\_ids) | List of probe Ids from backend HTTP settings. |
| <a name="output_appgw_custom_error_configuration_ids"></a> [appgw\_custom\_error\_configuration\_ids](#output\_appgw\_custom\_error\_configuration\_ids) | List of custom error configuration Ids. |
| <a name="output_appgw_frontend_ip_configuration_ids"></a> [appgw\_frontend\_ip\_configuration\_ids](#output\_appgw\_frontend\_ip\_configuration\_ids) | List of frontend IP configuration Ids. |
| <a name="output_appgw_frontend_port_ids"></a> [appgw\_frontend\_port\_ids](#output\_appgw\_frontend\_port\_ids) | List of frontend port Ids. |
| <a name="output_appgw_gateway_ip_configuration_ids"></a> [appgw\_gateway\_ip\_configuration\_ids](#output\_appgw\_gateway\_ip\_configuration\_ids) | List of IP configuration Ids. |
| <a name="output_appgw_http_listener_frontend_ip_configuration_ids"></a> [appgw\_http\_listener\_frontend\_ip\_configuration\_ids](#output\_appgw\_http\_listener\_frontend\_ip\_configuration\_ids) | List of frontend IP configuration Ids from HTTP listeners. |
| <a name="output_appgw_http_listener_frontend_port_ids"></a> [appgw\_http\_listener\_frontend\_port\_ids](#output\_appgw\_http\_listener\_frontend\_port\_ids) | List of frontend port Ids from HTTP listeners. |
| <a name="output_appgw_http_listener_ids"></a> [appgw\_http\_listener\_ids](#output\_appgw\_http\_listener\_ids) | List of HTTP listener Ids. |
| <a name="output_appgw_id"></a> [appgw\_id](#output\_appgw\_id) | The ID of the Application Gateway. |
| <a name="output_appgw_name"></a> [appgw\_name](#output\_appgw\_name) | The name of the Application Gateway. |
| <a name="output_appgw_nsg_id"></a> [appgw\_nsg\_id](#output\_appgw\_nsg\_id) | The ID of the network security group from the subnet where the Application Gateway is attached. |
| <a name="output_appgw_nsg_name"></a> [appgw\_nsg\_name](#output\_appgw\_nsg\_name) | The name of the network security group from the subnet where the Application Gateway is attached. |
| <a name="output_appgw_public_ip_address"></a> [appgw\_public\_ip\_address](#output\_appgw\_public\_ip\_address) | The public IP address of Application Gateway. |
| <a name="output_appgw_public_ip_domain_name"></a> [appgw\_public\_ip\_domain\_name](#output\_appgw\_public\_ip\_domain\_name) | Domain Name part from FQDN of the A DNS record associated with the public IP. |
| <a name="output_appgw_public_ip_fqdn"></a> [appgw\_public\_ip\_fqdn](#output\_appgw\_public\_ip\_fqdn) | Fully qualified domain name of the A DNS record associated with the public IP. |
| <a name="output_appgw_redirect_configuration_ids"></a> [appgw\_redirect\_configuration\_ids](#output\_appgw\_redirect\_configuration\_ids) | List of redirect configuration Ids. |
| <a name="output_appgw_request_routing_rule_backend_address_pool_ids"></a> [appgw\_request\_routing\_rule\_backend\_address\_pool\_ids](#output\_appgw\_request\_routing\_rule\_backend\_address\_pool\_ids) | List of backend address pool Ids attached to request routing rules. |
| <a name="output_appgw_request_routing_rule_backend_http_settings_ids"></a> [appgw\_request\_routing\_rule\_backend\_http\_settings\_ids](#output\_appgw\_request\_routing\_rule\_backend\_http\_settings\_ids) | List of HTTP settings Ids attached to request routing rules. |
| <a name="output_appgw_request_routing_rule_http_listener_ids"></a> [appgw\_request\_routing\_rule\_http\_listener\_ids](#output\_appgw\_request\_routing\_rule\_http\_listener\_ids) | List of HTTP listener Ids attached to request routing rules. |
| <a name="output_appgw_request_routing_rule_ids"></a> [appgw\_request\_routing\_rule\_ids](#output\_appgw\_request\_routing\_rule\_ids) | List of request routing rules Ids. |
| <a name="output_appgw_request_routing_rule_redirect_configuration_ids"></a> [appgw\_request\_routing\_rule\_redirect\_configuration\_ids](#output\_appgw\_request\_routing\_rule\_redirect\_configuration\_ids) | List of redirect configuration Ids attached to request routing rules. |
| <a name="output_appgw_request_routing_rule_rewrite_rule_set_ids"></a> [appgw\_request\_routing\_rule\_rewrite\_rule\_set\_ids](#output\_appgw\_request\_routing\_rule\_rewrite\_rule\_set\_ids) | List of rewrite rule set Ids attached to request routing rules. |
| <a name="output_appgw_request_routing_rule_url_path_map_ids"></a> [appgw\_request\_routing\_rule\_url\_path\_map\_ids](#output\_appgw\_request\_routing\_rule\_url\_path\_map\_ids) | List of URL path map Ids attached to request routing rules. |
| <a name="output_appgw_ssl_certificate_ids"></a> [appgw\_ssl\_certificate\_ids](#output\_appgw\_ssl\_certificate\_ids) | List of SSL certificate Ids. |
| <a name="output_appgw_subnet_id"></a> [appgw\_subnet\_id](#output\_appgw\_subnet\_id) | The ID of the subnet where the Application Gateway is attached. |
| <a name="output_appgw_subnet_name"></a> [appgw\_subnet\_name](#output\_appgw\_subnet\_name) | The name of the subnet where the Application Gateway is attached. |
| <a name="output_appgw_url_path_map_default_backend_address_pool_ids"></a> [appgw\_url\_path\_map\_default\_backend\_address\_pool\_ids](#output\_appgw\_url\_path\_map\_default\_backend\_address\_pool\_ids) | List of default backend address pool Ids attached to URL path maps. |
| <a name="output_appgw_url_path_map_default_backend_http_settings_ids"></a> [appgw\_url\_path\_map\_default\_backend\_http\_settings\_ids](#output\_appgw\_url\_path\_map\_default\_backend\_http\_settings\_ids) | List of default backend HTTP settings Ids attached to URL path maps. |
| <a name="output_appgw_url_path_map_default_redirect_configuration_ids"></a> [appgw\_url\_path\_map\_default\_redirect\_configuration\_ids](#output\_appgw\_url\_path\_map\_default\_redirect\_configuration\_ids) | List of default redirect configuration Ids attached to URL path maps. |
| <a name="output_appgw_url_path_map_ids"></a> [appgw\_url\_path\_map\_ids](#output\_appgw\_url\_path\_map\_ids) | List of URL path map Ids. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Resource group name |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
