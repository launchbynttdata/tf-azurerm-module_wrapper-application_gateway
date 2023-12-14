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
  source = "../.."

  app_gateways = local.app_gateways

  depends_on = [module.resource_group, module.network]
}

module "resource_group" {
  source = "git::https://github.com/nexient-llc/tf-azurerm-module-resource_group.git?ref=0.2.0"

  name     = local.resource_group_name
  location = var.region
  tags = {
    resource_name = local.resource_group_name
  }
}

# This module generates the resource-name of resources based on resource_type, naming_prefix, env etc.
module "resource_names" {
  source = "git::https://github.com/nexient-llc/tf-module-resource_name.git?ref=1.0.0"

  for_each = var.resource_names_map

  region                  = join("", split("-", var.region))
  class_env               = var.environment
  cloud_resource_type     = each.value.name
  instance_env            = var.environment_number
  instance_resource       = var.resource_number
  maximum_length          = each.value.max_length
  logical_product_family  = var.logical_product_family
  logical_product_service = var.logical_product_service
}

module "network" {
  source  = "Azure/vnet/azurerm"
  version = "4.1.0"

  resource_group_name = local.resource_group_name
  use_for_each        = true
  vnet_location       = var.location

  address_space = var.address_space
  subnet_names  = var.subnet_names

  subnet_prefixes = var.subnet_prefixes
  vnet_name       = local.vnet_name

  depends_on = [module.resource_group]
}

resource "azurerm_service_plan" "app_service_plan" {
  name                = local.app_service_name
  resource_group_name = module.resource_group.name
  location            = var.region
  sku_name            = "F1"
  os_type             = "Windows"
  depends_on          = [module.resource_group]
}

resource "azurerm_windows_web_app" "windows_web_app_images" {
  name                = local.web_app_name_images
  resource_group_name = module.resource_group.name
  location            = var.region
  service_plan_id     = azurerm_service_plan.app_service_plan.id

  site_config {
    always_on = false
  }

  lifecycle {
    ignore_changes = [
      tags,
      site_config["virtual_application"]
    ]
  }
}

resource "azurerm_windows_web_app" "windows_web_app_videos" {
  name                = local.web_app_name_videos
  resource_group_name = module.resource_group.name
  location            = var.region
  service_plan_id     = azurerm_service_plan.app_service_plan.id

  site_config {
    always_on = false
  }

  lifecycle {
    ignore_changes = [
      tags,
      site_config["virtual_application"]
    ]
  }
}
