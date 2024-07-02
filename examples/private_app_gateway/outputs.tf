# // Licensed under the Apache License, Version 2.0 (the "License");
# // you may not use this file except in compliance with the License.
# // You may obtain a copy of the License at
# //
# //     http://www.apache.org/licenses/LICENSE-2.0
# //
# // Unless required by applicable law or agreed to in writing, software
# // distributed under the License is distributed on an "AS IS" BASIS,
# // WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# // See the License for the specific language governing permissions and
# // limitations under the License.

output "appgw_backend_address_pool_ids" {
  value       = module.app_gateway.appgw_backend_address_pool_ids
  description = "List of backend address pool Ids."
}

output "appgw_backend_http_settings_ids" {
  value       = module.app_gateway.appgw_backend_http_settings_ids
  description = "List of backend HTTP settings Ids."
}

output "appgw_backend_http_settings_probe_ids" {
  value       = module.app_gateway.appgw_backend_http_settings_probe_ids
  description = "List of probe Ids from backend HTTP settings."
}

output "appgw_custom_error_configuration_ids" {
  value       = module.app_gateway.appgw_custom_error_configuration_ids
  description = "List of custom error configuration Ids."
}

output "appgw_frontend_ip_configuration_ids" {
  value       = module.app_gateway.appgw_frontend_ip_configuration_ids
  description = "List of frontend IP configuration Ids."
}

output "appgw_frontend_port_ids" {
  value       = module.app_gateway.appgw_frontend_port_ids
  description = "List of frontend port Ids."
}

output "appgw_gateway_ip_configuration_ids" {
  value       = module.app_gateway.appgw_gateway_ip_configuration_ids
  description = "List of IP configuration Ids."
}

output "appgw_http_listener_frontend_ip_configuration_ids" {
  value       = module.app_gateway.appgw_http_listener_frontend_ip_configuration_ids
  description = "List of frontend IP configuration Ids from HTTP listeners."
}

output "appgw_http_listener_frontend_port_ids" {
  value       = module.app_gateway.appgw_http_listener_frontend_port_ids
  description = "List of frontend port Ids from HTTP listeners."
}

output "appgw_http_listener_ids" {
  value       = module.app_gateway.appgw_http_listener_ids
  description = "List of HTTP listener Ids."
}

output "appgw_id" {
  value       = module.app_gateway.appgw_id
  description = "The ID of the Application Gateway."
}

output "appgw_name" {
  value       = module.app_gateway.appgw_name
  description = "The name of the Application Gateway."
}

output "appgw_nsg_id" {
  value       = module.app_gateway.appgw_nsg_id
  description = "The ID of the network security group from the subnet where the Application Gateway is attached."
}

output "appgw_nsg_name" {
  value       = module.app_gateway.appgw_nsg_name
  description = "The name of the network security group from the subnet where the Application Gateway is attached."
}

output "appgw_public_ip_address" {
  value       = module.app_gateway.appgw_public_ip_address
  description = "The public IP address of Application Gateway."
}

output "appgw_public_ip_domain_name" {
  value       = module.app_gateway.appgw_public_ip_domain_name
  description = "Domain Name part from FQDN of the A DNS record associated with the public IP."
}

output "appgw_public_ip_fqdn" {
  value       = module.app_gateway.appgw_public_ip_fqdn
  description = "Fully qualified domain name of the A DNS record associated with the public IP."
}

output "appgw_redirect_configuration_ids" {
  value       = module.app_gateway.appgw_redirect_configuration_ids
  description = "List of redirect configuration Ids."
}

output "appgw_request_routing_rule_backend_address_pool_ids" {
  value       = module.app_gateway.appgw_request_routing_rule_backend_address_pool_ids
  description = "List of backend address pool Ids attached to request routing rules."
}

output "appgw_request_routing_rule_backend_http_settings_ids" {
  value       = module.app_gateway.appgw_request_routing_rule_backend_http_settings_ids
  description = "List of HTTP settings Ids attached to request routing rules."
}

output "appgw_request_routing_rule_http_listener_ids" {
  value       = module.app_gateway.appgw_request_routing_rule_http_listener_ids
  description = "List of HTTP listener Ids attached to request routing rules."
}

output "appgw_request_routing_rule_ids" {
  value       = module.app_gateway.appgw_request_routing_rule_ids
  description = "List of request routing rules Ids."
}

output "appgw_request_routing_rule_redirect_configuration_ids" {
  value       = module.app_gateway.appgw_request_routing_rule_redirect_configuration_ids
  description = "List of redirect configuration Ids attached to request routing rules."
}

output "appgw_request_routing_rule_rewrite_rule_set_ids" {
  value       = module.app_gateway.appgw_request_routing_rule_rewrite_rule_set_ids
  description = "List of rewrite rule set Ids attached to request routing rules."
}

output "appgw_request_routing_rule_url_path_map_ids" {
  value       = module.app_gateway.appgw_request_routing_rule_url_path_map_ids
  description = "List of URL path map Ids attached to request routing rules."
}

output "appgw_ssl_certificate_ids" {
  value       = module.app_gateway.appgw_ssl_certificate_ids
  description = "List of SSL certificate Ids."
  sensitive   = true
}

output "appgw_subnet_id" {
  value       = module.app_gateway.appgw_subnet_id
  description = "The ID of the subnet where the Application Gateway is attached."
}

output "appgw_subnet_name" {
  value       = module.app_gateway.appgw_subnet_name
  description = "The name of the subnet where the Application Gateway is attached."
}

output "appgw_url_path_map_default_backend_address_pool_ids" {
  value       = module.app_gateway.appgw_url_path_map_default_backend_address_pool_ids
  description = "List of default backend address pool Ids attached to URL path maps."
}

output "appgw_url_path_map_default_backend_http_settings_ids" {
  value       = module.app_gateway.appgw_url_path_map_default_backend_http_settings_ids
  description = "List of default backend HTTP settings Ids attached to URL path maps."
}

output "appgw_url_path_map_default_redirect_configuration_ids" {
  value       = module.app_gateway.appgw_url_path_map_default_backend_http_settings_ids
  description = "List of default redirect configuration Ids attached to URL path maps."
}

output "appgw_url_path_map_ids" {
  value       = module.app_gateway.appgw_url_path_map_ids
  description = "List of URL path map Ids."
}

output "resource_group_name" {
  value       = module.resource_group.name
  description = "Resource group name"
}

output "password" {
  value       = local.password
  description = "Password used for certificate generation, key vault certificate upload and VMs."
  sensitive   = false
}
