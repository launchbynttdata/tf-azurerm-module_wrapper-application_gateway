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
  resource_group_name          = module.resource_names["resource_group"].minimal_random_suffix
  network_security_group_name  = module.resource_names["network_security_group"].minimal_random_suffix
  user_managed_identity_name   = module.resource_names["user_managed_identity"].minimal_random_suffix
  key_vault_name               = module.resource_names["key_vault"].minimal_random_suffix_without_any_separators
  vnet_name                    = module.resource_names["vnet"].minimal_random_suffix
  storage_account_name         = module.resource_names["storage_account"].minimal_random_suffix_without_any_separators
  vnet_link_name               = module.resource_names["vnet_link"].minimal_random_suffix
  log_analytics_workspace_name = module.resource_names["log_analytics_workspace"].minimal_random_suffix
  diagnostic_settings_name     = module.resource_names["diagnostic_settings"].minimal_random_suffix
  app_gtwy_subnet_id           = lookup(module.network.vnet_subnets_name_id, "appgw-subnet", null)
  jumpbox_vm_subnet_id         = lookup(module.network.vnet_subnets_name_id, "jumpbox-subnet", null)


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
    subnet_cidr                = value.subnet_cidr
    location                   = var.location
    user_assigned_identity_id  = module.user_managed_identity.id
    appgw_backend_pools        = local.appgw_backend_pools
    ssl_certificates_configs = [{
      name                = "server-certificate"
      key_vault_secret_id = data.azurerm_key_vault_certificate.key_vault_certificate["server-certificate"].secret_id
    }]
    logs_destinations_ids           = [module.log_analytics_workspace.id]
    custom_diagnostic_settings_name = local.diagnostic_settings_name
  }) }

  additional_security_rule = [
    for key, value in var.app_gateways : {
      name                       = "AlloHttpToAppGwPublicIP"
      protocol                   = "Tcp"
      access                     = "Allow"
      priority                   = 102
      direction                  = "Inbound"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = module.app_gateway.appgw_public_ip_address[key]
  }]

  all_security_rules = concat(var.security_rules, local.additional_security_rule)

  jumpbox_vm_nic_ip_configuration = {
    name                          = var.jumpbox_vm_nic_ip_configuration.name
    subnet_id                     = local.jumpbox_vm_subnet_id
    private_ip_address_allocation = var.jumpbox_vm_nic_ip_configuration.private_ip_address_allocation
    public_ip_address_id          = module.jumpbox_pip.id
  }

  password = random_string.password.result

  role_assignments = {
    for key, value in var.role_assignments : key => merge(value, { scope = module.key_vault.key_vault_id,
    principal_id = module.user_managed_identity.principal_id })
  }

  role_assignments_owner = {
    for key, value in var.role_assignments_owner : key => merge(value, { scope = module.key_vault.key_vault_id,
    principal_id = local.object_id })
  }

  network_acls = merge(var.network_acls, {
    virtual_network_subnet_ids = [local.app_gtwy_subnet_id]
  })

  certificates = {
    "root-certificate" = {
      filepath = data.local_file.ca_certificate_pfx.content_base64
      password = local.password
      contents = null
    }
    "server-certificate" = {
      filepath = null
      contents = data.local_file.server_certificate_pfx.content_base64
      password = local.password
    }
  }

  default_tags = {
    provisioner = "Terraform"
  }

  tags = merge(local.default_tags, var.tags)

  object_id = data.azurerm_client_config.current.object_id

  a_records = { for key, value in var.app_gateways : key => {
    name                = "apgw"
    resource_group_name = local.resource_group_name
    zone_name           = module.private_dns_zone.zone_name
    ttl                 = 1
    records             = [var.app_gateways[key].appgw_private_ip]
    tags                = {}
  } }
}
