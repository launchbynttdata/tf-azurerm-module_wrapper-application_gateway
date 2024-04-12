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


# This module generates the resource-name of resources based on resource_type, naming_prefix, env etc.
module "resource_names" {
  source = "git::https://github.com/launchbynttdata/tf-launch-module_library-resource_name.git?ref=1.0.0"

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

module "resource_group" {
  source = "git::https://github.com/launchbynttdata/tf-azurerm-module_primitive-resource_group.git?ref=1.0.0"

  name     = local.resource_group_name
  location = var.location
  tags = {
    resource_name = local.resource_group_name
  }
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

module "network_security_group" {
  source = "git::https://github.com/launchbynttdata/tf-azurerm-module_primitive-network_security_group.git?ref=1.0.0"

  name                = local.network_security_group_name
  location            = var.location
  resource_group_name = local.resource_group_name
  security_rules      = local.all_security_rules

  depends_on = [module.network]
}

module "nsg_subnet_association" {
  source = "git::https://github.com/launchbynttdata/tf-azurerm-module_primitive-nsg_subnet_association.git?ref=1.0.0"

  network_security_group_id = module.network_security_group.network_security_group_id
  subnet_id                 = local.app_gtwy_subnet_id

  depends_on = [module.network_security_group]

}

module "app_gateway" {
  source = "../.."

  app_gateways = local.app_gateways

  depends_on = [module.resource_group, module.network]
}

module "vm_nic" {
  source = "git::https://github.com/launchbynttdata/tf-azurerm-module_primitive-network_interface.git?ref=1.0.0"

  name                = var.vm_nic_name
  location            = var.location
  resource_group_name = local.resource_group_name
  ip_configuration    = [local.vm_nic_ip_configuration]
}

resource "azurerm_linux_virtual_machine" "vm_instance" {
  name                = var.vm_name
  priority            = var.vm_priority
  eviction_policy     = var.vm_priority == "Spot" ? var.eviction_policy : null
  resource_group_name = local.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.vm_username
  custom_data         = base64encode(file(var.custom_data))
  network_interface_ids = [
    module.vm_nic.id,
  ]

  admin_ssh_key {
    username   = var.admin_ssh_key.username
    public_key = file(var.admin_ssh_key.public_key_path)
  }

  os_disk {
    caching              = var.os_disk.caching
    storage_account_type = var.os_disk.storage_account_type
  }

  source_image_reference {
    publisher = var.source_image_reference.publisher
    offer     = var.source_image_reference.offer
    sku       = var.source_image_reference.sku
    version   = var.source_image_reference.version
  }
}

module "jumpbox_nic" {
  source = "git::https://github.com/launchbynttdata/tf-azurerm-module_primitive-network_interface.git?ref=1.0.0"

  name                = var.jumpbox_nic_name
  location            = var.location
  resource_group_name = local.resource_group_name
  ip_configuration    = [local.jumpbox_vm_nic_ip_configuration]
}

module "jumpbox_pip" {
  source = "git::https://github.com/launchbynttdata/tf-azurerm-module_primitive-public_ip.git?ref=1.0.0"

  name                    = var.public_ip_name
  location                = var.location
  resource_group_name     = local.resource_group_name
  allocation_method       = var.public_ip_allocation
  idle_timeout_in_minutes = var.public_ip_idle_timeout_in_minutes

  depends_on = [module.resource_group]
}

module "windows_vm_jumpbox" {
  source = "git::https://github.com/launchbynttdata/tf-azurerm-module_primitive-windows_virtual_machine.git?ref=1.0.0"

  name                   = var.jumpbox_name
  resource_group_name    = local.resource_group_name
  location               = var.location
  size                   = var.vm_size
  admin_username         = var.vm_username
  admin_password         = local.jumpbox_password
  network_interface_ids  = [module.jumpbox_nic.id]
  os_disk                = var.os_disk
  source_image_reference = var.jumpbox_source_image_reference
}

resource "random_string" "admin_password" {
  length  = var.length
  numeric = var.number
  special = var.special
}
