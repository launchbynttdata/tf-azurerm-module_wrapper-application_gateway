// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

module "app-gateway" {
  source  = "claranet/app-gateway/azurerm"
  version = "7.7.1"

  for_each                              = var.app_gateways
  appgw_backend_http_settings           = each.value.appgw_backend_http_settings
  appgw_backend_pools                   = each.value.appgw_backend_pools
  appgw_http_listeners                  = each.value.appgw_http_listeners
  appgw_routings                        = each.value.appgw_routings
  appgw_url_path_map                    = each.value.appgw_url_path_map
  appgw_probes                          = each.value.appgw_probes
  appgw_rewrite_rule_set                = each.value.appgw_rewrite_rule_set
  app_gateway_tags                      = each.value.app_gateway_tags
  custom_appgw_name                     = each.value.custom_appgw_name
  custom_ip_name                        = each.value.custom_ip_name
  custom_ip_label                       = each.value.custom_ip_label
  custom_frontend_ip_configuration_name = each.value.custom_ip_label

  client_name                = each.value.client_name
  environment                = each.value.environment
  frontend_port_settings     = each.value.frontend_port_settings
  location                   = each.value.location
  location_short             = each.value.location_short
  logs_destinations_ids      = each.value.logs_destinations_ids
  resource_group_name        = each.value.resource_group_name
  stack                      = each.value.stack
  subnet_cidr                = each.value.subnet_cidr
  virtual_network_name       = each.value.virtual_network_name
  create_subnet              = each.value.create_subnet
  subnet_id                  = each.value.subnet_id
  subnet_resource_group_name = each.value.resource_group_name
}
