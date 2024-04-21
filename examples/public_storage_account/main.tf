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

module "app_gateway" {
  source = "../.."

  app_gateways = local.app_gateways

  depends_on = [module.resource_group, module.network, module.storage_account]
}

module "resource_group" {
  source  = "d2lqlh14iel5k2.cloudfront.net/module_primitive/resource_group/azurerm"
  version = "~> 1.0"

  name     = local.resource_group_name
  location = var.location
  tags = {
    resource_name = local.resource_group_name
  }
}

# This module generates the resource-name of resources based on resource_type, naming_prefix, env etc.
module "resource_names" {
  source  = "d2lqlh14iel5k2.cloudfront.net/module_library/resource_name/launch"
  version = "~> 1.0"

  for_each = var.resource_names_map

  region                  = join("", split("-", var.location))
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

module "storage_account" {
  # source = "d2lqlh14iel5k2.cloudfront.net/module_primitive/storage_account/azurerm"
  # version = "~> 1.1"
  source = "git::https://github.com/launchbynttdata/tf-azurerm-module_primitive-storage_account.git?ref=feature/static-hosting"

  resource_group_name  = local.resource_group_name
  storage_account_name = local.storage_account_name
  location             = var.location
  tags                 = local.tags
  static_website = {
    index_document     = "index.html"
    error_404_document = "404.html"
  }

  depends_on = [module.resource_group]
}

resource "null_resource" "upload_static_website_files" {
  provisioner "local-exec" {
    command = <<-EOF
      find ./site_files -type f -exec az storage blob upload --file {} -c \$web --account-name ${local.storage_account_name} \;
EOF
  }

  depends_on = [module.storage_account]
}
