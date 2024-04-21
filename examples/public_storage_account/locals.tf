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

locals {
  resource_group_name  = module.resource_names["resource_group"].minimal_random_suffix
  storage_account_name = module.resource_names["storage_account"].minimal_random_suffix_without_any_separators
  vnet_name            = module.resource_names["vnet"].minimal_random_suffix
  app_gtwy_subnet_id   = lookup(module.network.vnet_subnets_name_id, "app-gtw-subnet", null)

  appgw_backend_pools = [
    {
      name  = "backend_pool_static"
      fqdns = [replace(replace(module.storage_account.primary_web_endpoint, "https://", ""), "/", "")]
    }
  ]

  app_gateways = { for key, value in var.app_gateways : key => merge(value, {
    resource_group_name        = local.resource_group_name
    subnet_id                  = local.app_gtwy_subnet_id
    subnet_resource_group_name = local.resource_group_name
    virtual_network_name       = local.vnet_name
    subnet_cidr                = var.subnet_prefixes[index(var.subnet_names, "app-gtw-subnet")]
    location                   = var.location
    appgw_backend_pools        = local.appgw_backend_pools
  }) }

  default_tags = {
    provisioner = "Terraform"
  }

  tags = merge(local.default_tags, var.tags)
}
