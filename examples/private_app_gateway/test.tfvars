app_gateways = {
  "first_gateway" = {
    appgw_backend_http_settings = [{
      name                  = "first_backend_http_settings"
      port                  = 80
      protocol              = "Http"
      cookie_based_affinity = "Disabled"
      request_timeout       = 15
    }]
    appgw_backend_pools = [{
      name         = "first_backend_pool"
      fqdns        = []
      ip_addresses = ["10.0.1.4"]
    }]
    appgw_http_listeners = [
      {
        name               = "first_http_listener"
        frontend_port_name = "frontend_port"
        protocol           = "Http"
    }]
    appgw_routings = [{
      name                       = "first_http_routing_rule"
      rule_type                  = "Basic"
      http_listener_name         = "first_http_listener"
      backend_address_pool_name  = "first_backend_pool"
      backend_http_settings_name = "first_backend_http_settings"
      priority                   = 100
    }]
    client_name           = "launch"
    environment           = "demo"
    logs_destinations_ids = []
    stack                 = "appgateway"
    frontend_port_settings = [
      {
        name = "frontend_port"
        port = 80
      }
    ]
    create_subnet                              = false
    custom_appgw_name                          = "first-app-gtw"
    custom_frontend_priv_ip_configuration_name = "first_fe_ip_config_private"
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
}
security_rules = [{
  name                       = "AllowHttpToAppGwSbnet"
  protocol                   = "Tcp"
  access                     = "Allow"
  priority                   = 100
  direction                  = "Inbound"
  source_port_range          = "*"
  destination_port_range     = "80"
  source_address_prefix      = "10.0.2.0/24"
  destination_address_prefix = "10.0.0.0/24"
  },
  {
    name                       = "AllowHttpToAppGwPrivateIP"
    protocol                   = "Tcp"
    access                     = "Allow"
    priority                   = 101
    direction                  = "Inbound"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "10.0.2.0/24"
    destination_address_prefix = "10.0.0.6"
  },
  {
    name                       = "AllowHttpGatewayManager"
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
