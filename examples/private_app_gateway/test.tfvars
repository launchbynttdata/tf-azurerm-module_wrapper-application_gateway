app_gateways = {
  "first_gateway" = {
    appgw_backend_http_settings = [{
      name                  = "static_https_settings"
      port                  = 443
      protocol              = "Https"
      cookie_based_affinity = "Disabled"
      request_timeout       = 15
      probe_name            = "static-health-probe"
    }]
    appgw_http_listeners = [{
      name                 = "static_https_listener"
      frontend_port_name   = "frontend_port"
      protocol             = "Https"
      ssl_certificate_name = "server-certificate"
    }]
    appgw_routings = [{
      name                       = "static_app_https_routing_rule"
      rule_type                  = "PathBasedRouting"
      http_listener_name         = "static_https_listener"
      backend_address_pool_name  = "static_app_backend_pool"
      backend_http_settings_name = "static_https_settings"
      priority                   = 100
      url_path_map_name          = "url_path_map"
    }]
    appgw_url_path_map = [{
      name                                = "url_path_map"
      default_backend_address_pool_name   = "backend_pool_static"
      default_redirect_configuration_name = null
      default_backend_http_settings_name  = "static_https_settings"
      default_rewrite_rule_set_name       = null
      path_rules = [
        {
          name                        = "path_rule_static"
          backend_address_pool_name   = "backend_pool_static"
          backend_http_settings_name  = "static_https_settings"
          rewrite_rule_set_name       = null
          redirect_configuration_name = null
          paths                       = ["/static/*"]
        }
      ]
      }
    ]
    appgw_probes = [{
      name                                      = "static-health-probe"
      host                                      = null
      port                                      = null
      interval                                  = 30
      path                                      = "/index.html"
      protocol                                  = "Https"
      timeout                                   = 30
      unhealthy_threshold                       = 3
      pick_host_name_from_backend_http_settings = true
      minimum_servers                           = 0
      match = {
        body        = ""
        status_code = ["200-399"]
      }
    }]
    appgw_rewrite_rule_set = []
    client_name            = "launch"
    environment            = "demo"
    logs_destinations_ids  = []
    stack                  = "appgateway"
    frontend_port_settings = [
      {
        name = "frontend_port"
        port = 443
      }
    ]
    create_subnet                              = false
    custom_ip_name                             = "static-app-gtw-ip"
    custom_ip_label                            = "static-app-gtw-ip-label"
    custom_appgw_name                          = "static-web-app-gtw"
    custom_frontend_priv_ip_configuration_name = "first_fe_ip_config_private"
    custom_frontend_ip_configuration_name      = "static_app_fe_ip_config"
    appgw_private                              = true
    appgw_private_ip                           = "10.0.0.6"
    subnet_cidr                                = "10.0.0.0/24"
    create_nsg                                 = false
    create_nsg_healthprobe_rule                = false
    create_nsg_https_rule                      = false
    custom_nsg_name                            = "appgw-nsg"
    custom_nsr_healthcheck_name                = "appgw-healthcheck"
    custom_nsr_https_name                      = "appgw-https"
    custom_subnet_name                         = "appgw-subnet"
    nsr_https_source_address_prefix            = "Any"
    enable_http2                               = false
  }
}
address_space   = ["10.0.0.0/16"]
environment     = "demo"
location        = "eastus"
subnet_names    = ["appgw-subnet", "subnet1", "jumpbox-subnet"]
subnet_prefixes = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
resource_names_map = {
  resource_group = {
    name       = "rg"
    max_length = 90
  }
  app_gateway = {
    name       = "appgw"
    max_length = 80
  }
  vnet = {
    name       = "vnet"
    max_length = 80
  }
  network_security_group = {
    name       = "nsg"
    max_length = 80
  }
  user_managed_identity = {
    name       = "umi"
    max_length = 80
  }
  key_vault = {
    name       = "kv"
    max_length = 24
  }
  storage_account = {
    name       = "sa"
    max_length = 24
  },
  vnet_link = {
    name       = "vnetlink"
    max_length = 80
  }
}
security_rules = [{
  name                       = "AllowHttpsToAppGwSbnet"
  protocol                   = "Tcp"
  access                     = "Allow"
  priority                   = 100
  direction                  = "Inbound"
  source_port_range          = "*"
  destination_port_range     = "443"
  source_address_prefix      = "10.0.2.0/24"
  destination_address_prefix = "10.0.0.0/24"
  },
  {
    name                       = "AllowHttpsToAppGwPrivateIP"
    protocol                   = "Tcp"
    access                     = "Allow"
    priority                   = 101
    direction                  = "Inbound"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "10.0.2.0/24"
    destination_address_prefix = "10.0.0.6"
  },
  {
    name                       = "AllowHttpsGatewayManager"
    protocol                   = "Tcp"
    access                     = "Allow"
    priority                   = 103
    direction                  = "Inbound"
    source_port_range          = "*"
    destination_port_ranges    = ["65200-65535"]
    source_address_prefix      = "GatewayManager"
    destination_address_prefix = "*"
  }
]
vm_name     = "example-machine-eastus"
vm_nic_name = "example-nic-eastus"
role_assignments = {
  "kv_cert_user_umi" = {
    role_definition_name = "Key Vault Certificate User"
  }
  "kv_cert_officer_umi" = {
    role_definition_name = "Key Vault Certificates Officer"
  },
  "kv_reader_umi" = {
    role_definition_name = "Key Vault Reader"
  }
  "kv_secrets_user_umi" = {
    role_definition_name = "Key Vault Secrets User"
  }
}
role_assignments_owner = {
  "kv_admin_current_user" = {
    role_definition_name = "Key Vault Administrator"
  },
  "kv_cert_officer_current_user" = {
    role_definition_name = "Key Vault Certificates Officer"
  }
  "kv_cert_user_current_user" = {
    role_definition_name = "Key Vault Certificate User"
  }
  "kv_reader_current_user" = {
    role_definition_name = "Key Vault Reader"
  }
}
enable_rbac_authorization     = true
public_network_access_enabled = true
network_acls = {
  bypass         = "AzureServices"
  default_action = "Deny"
  ip_rules       = ["136.226.85.71"]
}
algorithm      = "RSA"
rsa_bits       = 4096
ca_private_key = "ca_private_key.pem" # pragma: allowlist secret
ca_certificate_attributes = {
  dns_names         = ["contoso.com"]
  is_ca_certificate = true
  uris              = ["https://*.contoso.com"]
  subject = {
    common_name         = "example.com"
    country             = "US"
    locality            = "Canton"
    province            = "MI"
    organization        = "ACME Examples, Inc"
    organizational_unit = "IT"
    postal_code         = "48187"
    street_address      = ["1234", "Elm St"]
  }
  validity_period_hours = 1200
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "cert_signing"
  ]
}
cert_private_key = "cert_private_key.pem" # pragma: allowlist secret
server_certificate_attributes = {
  dns_names         = ["apgw.contoso.com", "apgw", "localhost", "myvm", "*.contoso.com"]
  is_ca_certificate = true
  uris              = ["https://*.contoso.com"]
  subject = {
    common_name         = "contoso.com"
    country             = "US"
    locality            = "Canton"
    province            = "MI"
    organization        = "ACME Examples, Inc"
    organizational_unit = "IT"
    postal_code         = "48188"
    street_address      = ["1234", "Duck St"]
  }
  validity_period_hours = 12
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}
server_cert          = "server_cert.pem"
ca_cert              = "ca_cert.pem"
ca_cert_pfx          = "ca_cert.pfx"
server_cert_pfx      = "server_cert.pfx"
chained_cert         = "chained_cert.pem"
zone_name            = "contoso.com"
registration_enabled = true
