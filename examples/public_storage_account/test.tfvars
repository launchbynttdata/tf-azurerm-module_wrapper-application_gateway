
app_gateways = {
  "web_app_gateway" = {
    appgw_backend_http_settings = [{
      name                  = "static_http_settings"
      port                  = 443
      protocol              = "Https"
      cookie_based_affinity = "Disabled"
      request_timeout       = 15
      probe_name            = "static-health-probe"
    }]
    appgw_http_listeners = [{
      name               = "static_http_listener"
      frontend_port_name = "frontend_port"
      protocol           = "Http"
    }]
    client_name           = "launch"
    environment           = "demo"
    logs_destinations_ids = []
    stack                 = "appgateway"
    virtual_network_name  = "vnet"
    subnet_cidr           = "10.0.0.0/24"
    appgw_routings = [{
      name                       = "web_app_http_routing_rule"
      rule_type                  = "PathBasedRouting"
      http_listener_name         = "static_http_listener"
      backend_address_pool_name  = "static_http_settings"
      backend_http_settings_name = "static_http_settings"
      url_path_map_name          = "url_path_map"
    }]
    frontend_port_settings = [{
      name = "frontend_port"
      port = 80
    }]
    create_subnet                         = false
    custom_ip_name                        = "static-app-gtw-ip"
    custom_ip_label                       = "static-app-gtw-ip-label"
    custom_frontend_ip_configuration_name = "static_app_fe_ip_config"
    custom_appgw_name                     = "static-web-app-gtw"
    appgw_url_path_map = [{
      name                                = "url_path_map"
      default_backend_address_pool_name   = "backend_pool_static"
      default_redirect_configuration_name = null
      default_backend_http_settings_name  = "static_http_settings"
      default_rewrite_rule_set_name       = null
      path_rules = [
        {
          name                        = "path_rule_static"
          backend_address_pool_name   = "backend_pool_static"
          backend_http_settings_name  = "static_http_settings"
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
  }
}
subnet_prefixes = ["10.0.0.0/24"]
address_space   = ["10.0.0.0/16"]
subnet_names    = ["app-gtw-subnet"]
environment     = "demo"
location        = "eastus2"
