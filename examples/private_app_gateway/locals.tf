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
  resource_group_name         = module.resource_names["resource_group"].minimal_random_suffix
  network_security_group_name = module.resource_names["network_security_group"].minimal_random_suffix
  vnet_name                   = module.resource_names["vnet"].minimal_random_suffix
  app_gtwy_subnet_id          = lookup(module.network.vnet_subnets_name_id, "appgw-subnet", null)
  vm_subnet_id                = lookup(module.network.vnet_subnets_name_id, "subnet1", null)
  jumpbox_vm_subnet_id        = lookup(module.network.vnet_subnets_name_id, "jumpbox-subnet", null)


  app_gateways = { for key, value in var.app_gateways : key => merge(value, {
    resource_group_name        = local.resource_group_name
    subnet_id                  = local.app_gtwy_subnet_id
    subnet_resource_group_name = local.resource_group_name
    virtual_network_name       = local.vnet_name
    subnet_cidr                = value.subnet_cidr
    location                   = var.location
  }) }

  additional_security_rule = [{
    name                       = "AlloHttpToAppGwPublicIP"
    protocol                   = "Tcp"
    access                     = "Allow"
    priority                   = 102
    direction                  = "Inbound"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = module.app_gateway.appgw_public_ip_address["first_gateway"]
  }]

  all_security_rules = concat(var.security_rules, local.additional_security_rule)

  jumpbox_vm_nic_ip_configuration = {
    name                          = var.jumpbox_vm_nic_ip_configuration.name
    subnet_id                     = local.jumpbox_vm_subnet_id
    private_ip_address_allocation = var.jumpbox_vm_nic_ip_configuration.private_ip_address_allocation
    public_ip_address_id          = module.jumpbox_pip.id
  }

  vm_nic_ip_configuration = {
    name                          = var.vm_nic_ip_configuration.name
    subnet_id                     = local.vm_subnet_id
    private_ip_address_allocation = var.vm_nic_ip_configuration.private_ip_address_allocation
  }

  jumpbox_password = random_string.admin_password.result
}
