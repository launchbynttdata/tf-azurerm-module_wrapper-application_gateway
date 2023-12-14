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
      ip_addresses = ["74.249.99.178"]
    }]
    appgw_http_listeners = [{
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
      priority                   = 10010
    }]
    client_name           = "launch"
    environment           = "demo"
    location              = "East Us 2"
    location_short        = "eastus2"
    logs_destinations_ids = []
    stack                 = "appgateway"
    subnet_cidr           = "10.0.0.0/24"
    frontend_port_settings = [{
      name = "frontend_port"
      port = 80
    }]
    create_subnet                         = false
    custom_ip_name                        = "first-app-gtw-ip"
    custom_ip_label                       = "first-app-gtw-ip-label"
    custom_frontend_ip_configuration_name = "first_fe_ip_config"
    custom_appgw_name                     = "first-app-gtw"
  },
  "second_gateway" = {
    appgw_backend_http_settings = [{
      name                  = "second_backend_http_settings"
      port                  = 80
      protocol              = "Http"
      cookie_based_affinity = "Disabled"
      request_timeout       = 15
    }]
    appgw_backend_pools = [{
      name         = "second_backend_pool"
      fqdns        = []
      ip_addresses = ["74.249.99.179"]
    }]
    appgw_http_listeners = [{
      name               = "second_http_listener"
      frontend_port_name = "frontend_port"
      protocol           = "Http"
    }]
    appgw_routings = [{
      name                       = "second_http_routing_rule"
      rule_type                  = "Basic"
      http_listener_name         = "second_http_listener"
      backend_address_pool_name  = "second_backend_pool"
      backend_http_settings_name = "second_backend_http_settings"
      priority                   = 10010
    }]
    client_name           = "launch"
    environment           = "demo"
    location              = "East Us 2"
    location_short        = "eastus2"
    logs_destinations_ids = []
    stack                 = "appgateway"
    subnet_cidr           = "10.0.0.0/24"
    frontend_port_settings = [{
      name = "frontend_port"
      port = 80
    }]
    create_subnet                         = false
    custom_ip_name                        = "second-app-gtw-ip"
    custom_ip_label                       = "second-app-gtw-ip-label"
    custom_frontend_ip_configuration_name = "second_fe_ip_config"
    custom_appgw_name                     = "second-app-gtw"
  }
}
address_space   = ["10.0.0.0/16"]
environment     = "demo"
location        = "East Us 2"
subnet_names    = ["app-gtw-subnet"]
subnet_prefixes = ["10.0.0.0/24"]
