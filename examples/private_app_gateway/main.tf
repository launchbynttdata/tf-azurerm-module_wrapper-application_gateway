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

  depends_on = [
    module.network,
    azurerm_key_vault_certificate.key_vault_certificate,
    module.key_vault,
  module.log_analytics_workspace]
}

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

module "resource_group" {
  source  = "d2lqlh14iel5k2.cloudfront.net/module_primitive/resource_group/azurerm"
  version = "~> 1.0"

  name     = local.resource_group_name
  location = var.location
  tags = {
    resource_name = local.resource_group_name
  }
}

module "user_managed_identity" {
  source  = "d2lqlh14iel5k2.cloudfront.net/module_primitive/user_managed_identity/azurerm"
  version = "~> 1.0"

  resource_group_name         = local.resource_group_name
  location                    = var.location
  user_assigned_identity_name = local.user_managed_identity_name

  depends_on = [module.resource_group]
}

module "role_assignment_owner" {
  source  = "d2lqlh14iel5k2.cloudfront.net/module_primitive/role_assignment/azurerm"
  version = "~> 1.0"

  for_each             = local.role_assignments_owner
  scope                = each.value.scope
  role_definition_name = each.value.role_definition_name
  principal_id         = each.value.principal_id

  depends_on = [module.key_vault, module.user_managed_identity]
}

module "role_assignment" {
  source  = "d2lqlh14iel5k2.cloudfront.net/module_primitive/role_assignment/azurerm"
  version = "~> 1.0"

  for_each             = local.role_assignments
  scope                = each.value.scope
  role_definition_name = each.value.role_definition_name
  principal_id         = each.value.principal_id

  depends_on = [module.role_assignment_owner]
}

module "key_vault" {
  source  = "d2lqlh14iel5k2.cloudfront.net/module_primitive/key_vault/azurerm"
  version = "~> 2.0"

  resource_group = {
    name     = local.resource_group_name
    location = var.location
  }
  key_vault_name                = local.key_vault_name
  enable_rbac_authorization     = var.enable_rbac_authorization
  network_acls                  = local.network_acls
  public_network_access_enabled = var.public_network_access_enabled

  depends_on = [module.resource_group, module.network]
}

module "network" {
  source  = "d2lqlh14iel5k2.cloudfront.net/module_primitive/virtual_network/azurerm"
  version = "~> 2.0"

  resource_group_name = local.resource_group_name
  use_for_each        = true
  vnet_location       = var.location

  address_space = var.address_space
  subnet_names  = var.subnet_names

  subnet_prefixes = var.subnet_prefixes
  vnet_name       = local.vnet_name
  subnet_service_endpoints = {
    appgw-subnet = ["Microsoft.KeyVault", "Microsoft.Storage"]
  }

  depends_on = [module.resource_group]
}

module "network_security_group" {
  source  = "d2lqlh14iel5k2.cloudfront.net/module_primitive/network_security_group/azurerm"
  version = "~> 1.0"

  name                = local.network_security_group_name
  location            = var.location
  resource_group_name = local.resource_group_name
  security_rules      = local.all_security_rules

  depends_on = [module.network]
}

module "nsg_subnet_association" {
  source  = "d2lqlh14iel5k2.cloudfront.net/module_primitive/nsg_subnet_association/azurerm"
  version = "~> 1.0"

  network_security_group_id = module.network_security_group.network_security_group_id
  subnet_id                 = local.app_gtwy_subnet_id

  depends_on = [module.network_security_group]

}

//Generate private key for the CA certificate
resource "tls_private_key" "ca_cert_private_key" {
  algorithm = var.algorithm
  rsa_bits  = var.rsa_bits
}

//Save the private key to a file
resource "local_file" "ca_cert_private_key" {
  content  = tls_private_key.ca_cert_private_key.private_key_pem
  filename = var.ca_private_key
}

//Generate the CA certificate
resource "tls_self_signed_cert" "ca_cert" {
  private_key_pem = tls_private_key.ca_cert_private_key.private_key_pem

  dns_names         = var.ca_certificate_attributes.dns_names
  is_ca_certificate = var.ca_certificate_attributes.is_ca_certificate
  uris              = var.ca_certificate_attributes.uris

  subject {
    common_name         = var.ca_certificate_attributes.subject.common_name
    country             = var.ca_certificate_attributes.subject.country
    locality            = var.ca_certificate_attributes.subject.locality
    province            = var.ca_certificate_attributes.subject.province
    organization        = var.ca_certificate_attributes.subject.organization
    organizational_unit = var.ca_certificate_attributes.subject.organizational_unit
    postal_code         = var.ca_certificate_attributes.subject.postal_code
    street_address      = var.ca_certificate_attributes.subject.street_address
  }

  validity_period_hours = var.ca_certificate_attributes.validity_period_hours

  allowed_uses = var.ca_certificate_attributes.allowed_uses
}

//Save the CA certificate to a file
resource "local_file" "ca_cert" {
  content  = tls_self_signed_cert.ca_cert.cert_pem
  filename = var.ca_cert
}

//Generate private key for the server certificate
resource "tls_private_key" "cert_private_key" {
  algorithm = var.algorithm
  rsa_bits  = var.rsa_bits
}

//Save the private key for the service certificate to a file
resource "local_file" "cert_private_key" {
  content  = tls_private_key.cert_private_key.private_key_pem
  filename = var.cert_private_key
}

//Generate CSR for the server certificate
resource "tls_cert_request" "cert_request" {
  private_key_pem = tls_private_key.cert_private_key.private_key_pem
  dns_names       = var.server_certificate_attributes.dns_names
  uris            = var.server_certificate_attributes.uris
  subject {
    common_name         = var.server_certificate_attributes.subject.common_name
    country             = var.server_certificate_attributes.subject.country
    locality            = var.server_certificate_attributes.subject.locality
    province            = var.server_certificate_attributes.subject.province
    organization        = var.server_certificate_attributes.subject.organization
    organizational_unit = var.server_certificate_attributes.subject.organizational_unit
    postal_code         = var.server_certificate_attributes.subject.postal_code
    street_address      = var.server_certificate_attributes.subject.street_address
  }
}

//Generate and sign the server certificate with CA's private key
resource "tls_locally_signed_cert" "server_cert" {
  cert_request_pem   = tls_cert_request.cert_request.cert_request_pem
  ca_private_key_pem = tls_private_key.ca_cert_private_key.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca_cert.cert_pem

  validity_period_hours = var.server_certificate_attributes.validity_period_hours

  allowed_uses = var.server_certificate_attributes.allowed_uses
}

//Save the server certificate to a file
resource "local_file" "locally_signed_cert" {
  content  = tls_locally_signed_cert.server_cert.cert_pem
  filename = var.server_cert
}

//Generate PFX file for the server certificate
resource "null_resource" "pem2pfx_server_cert" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "cat ${local_file.locally_signed_cert.filename} ${local_file.ca_cert.filename} > ${var.chained_cert} && openssl pkcs12 -export -in ${var.chained_cert} -inkey ${local_file.cert_private_key.filename} -out ${var.server_cert_pfx} -passout pass:${local.password}"
  }

  depends_on = [local_file.locally_signed_cert, local_file.ca_cert, local_file.cert_private_key]
}

//Generate PFX file for the CA certificate
resource "null_resource" "pem2pfx_ca_cert" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "openssl pkcs12 -export -in ${local_file.ca_cert.filename} -inkey ${local_file.ca_cert_private_key.filename} -out ${var.ca_cert_pfx} -passout pass:${local.password}"
  }

  depends_on = [local_file.locally_signed_cert, local_file.ca_cert, local_file.cert_private_key]
}

//Read the PFX file
data "local_file" "server_certificate_pfx" {
  filename = var.server_cert_pfx
  depends_on = [
    null_resource.pem2pfx_server_cert
  ]
}

data "local_file" "ca_certificate_pfx" {
  filename = var.ca_cert_pfx
  depends_on = [
    null_resource.pem2pfx_ca_cert
  ]
}
resource "azurerm_key_vault_certificate" "key_vault_certificate" {
  for_each     = local.certificates
  name         = each.key
  key_vault_id = module.key_vault.key_vault_id

  certificate {
    contents = each.value.filepath != null ? each.value.filepath : each.value.contents
    password = each.value.password
  }

  depends_on = [module.role_assignment, data.local_file.server_certificate_pfx, data.local_file.ca_certificate_pfx]
}

data "azurerm_key_vault_certificate" "key_vault_certificate" {
  for_each = local.certificates

  name         = each.key
  key_vault_id = module.key_vault.key_vault_id
  depends_on   = [azurerm_key_vault_certificate.key_vault_certificate]
}

resource "random_string" "password" {
  length  = var.length
  numeric = var.number
  special = var.special
}

//Backend pool - Storage account
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
  network_rules = {
    default_action             = "Deny"
    virtual_network_subnet_ids = [local.app_gtwy_subnet_id]
    ip_rules                   = [data.http.ip.response_body]
  }
  depends_on = [module.resource_group, module.network]
}

resource "null_resource" "upload_static_website_files" {
  provisioner "local-exec" {
    command = <<-EOF
      find ./site_files -type f -exec az storage blob upload --file {} -c \$web --account-name ${local.storage_account_name} --only-show-errors \;
EOF
  }
  depends_on = [module.storage_account]
}

module "private_dns_zone" {
  source  = "d2lqlh14iel5k2.cloudfront.net/module_primitive/private_dns_zone/azurerm"
  version = "~> 1.0"

  zone_name           = var.zone_name
  resource_group_name = local.resource_group_name

  depends_on = [module.resource_group]
}

module "private_dns_zone_link" {
  source  = "d2lqlh14iel5k2.cloudfront.net/module_primitive/private_dns_vnet_link/azurerm"
  version = "~> 1.0"

  link_name             = local.vnet_link_name
  resource_group_name   = local.resource_group_name
  private_dns_zone_name = module.private_dns_zone.zone_name
  virtual_network_id    = module.network.vnet_id
  registration_enabled  = var.registration_enabled

  depends_on = [module.network, module.private_dns_zone]
}

module "private_dns_records" {
  source  = "d2lqlh14iel5k2.cloudfront.net/module_primitive/private_dns_records/azurerm"
  version = "~> 1.0"

  a_records = local.a_records

  depends_on = [module.private_dns_zone]
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
  admin_password         = local.password
  network_interface_ids  = [module.jumpbox_nic.id]
  os_disk                = var.os_disk
  source_image_reference = var.jumpbox_source_image_reference
}

module "log_analytics_workspace" {
  source = "git::https://github.com/launchbynttdata/tf-azurerm-module_primitive-log_analytics_workspace.git?ref=1.0.0"

  name                = local.log_analytics_workspace_name
  location            = var.location
  resource_group_name = local.resource_group_name
  sku                 = var.log_analytics_workspace_sku
  retention_in_days   = var.log_analytics_workspace_retention_in_days

  depends_on = [module.resource_group]

}

data "http" "ip" {
  url = "https://ifconfig.me/ip"
}

data "azurerm_client_config" "current" {
}
