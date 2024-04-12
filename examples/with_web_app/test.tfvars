
app_gateways = {
  "web_app_gateway" = {
    appgw_backend_http_settings = [{
      name                  = "images_http_settings"
      port                  = 80
      protocol              = "Http"
      cookie_based_affinity = "Disabled"
      request_timeout       = 15
      probe_name            = "images-health-probe"
      },
      {
        name                  = "videos_http_settings"
        port                  = 80
        protocol              = "Http"
        cookie_based_affinity = "Disabled"
        request_timeout       = 15
        probe_name            = "videos-health-probe"
    }]
    appgw_http_listeners = [{
      name               = "web_app_http_listener"
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
      http_listener_name         = "web_app_http_listener"
      backend_address_pool_name  = "backend_pool_images"
      backend_http_settings_name = "images_http_settings"
      url_path_map_name          = "url_path_map"
    }]
    client_name           = "launch"
    environment           = "demo"
    logs_destinations_ids = []
    stack                 = "appgateway"
    subnet_cidr           = "10.0.0.0/24"
    frontend_port_settings = [{
      name = "frontend_port"
      port = 80
    }]
    create_subnet                         = false
    custom_ip_name                        = "web-app-gtw-ip"
    custom_ip_label                       = "web-app-gtw-ip-label"
    custom_frontend_ip_configuration_name = "web_app_fe_ip_config"
    custom_appgw_name                     = "web-app-gtw"
    appgw_url_path_map = [{
      name                                = "url_path_map"
      default_backend_address_pool_name   = "backend_pool_images"
      default_redirect_configuration_name = null
      default_backend_http_settings_name  = "images_http_settings"
      default_rewrite_rule_set_name       = "rewrite-rules"
      path_rules = [
        {
          name                        = "path_rule_images"
          backend_address_pool_name   = "backend_pool_images"
          backend_http_settings_name  = "images_http_settings"
          rewrite_rule_set_name       = "rewrite-rules"
          redirect_configuration_name = null
          paths                       = ["/images/*"]
        },
        {
          name                        = "path_rule_videos"
          backend_address_pool_name   = "backend_pool_videos"
          backend_http_settings_name  = "videos_http_settings"
          rewrite_rule_set_name       = null
          redirect_configuration_name = null
          paths                       = ["/videos/*"]
        }
      ]
      }
    ]
    appgw_probes = [{
      name                                      = "images-health-probe"
      host                                      = null
      port                                      = null
      interval                                  = 30
      path                                      = "/images/default.html"
      protocol                                  = "Http"
      timeout                                   = 30
      unhealthy_threshold                       = 3
      pick_host_name_from_backend_http_settings = true
      minimum_servers                           = 0
      match = {
        body        = ""
        status_code = ["200-399"]
      }
      },
      {
        name                                      = "videos-health-probe"
        host                                      = null
        port                                      = null
        interval                                  = 30
        path                                      = "/videos/default.html"
        protocol                                  = "Http"
        timeout                                   = 30
        unhealthy_threshold                       = 3
        pick_host_name_from_backend_http_settings = true
        minimum_servers                           = 0
        match = {
          body        = ""
          status_code = ["200-399"]
        }
      }
    ]
    appgw_rewrite_rule_set = [{
      name = "rewrite-rules"
      rewrite_rules = [{
        name          = "rewrite-rule"
        rule_sequence = "101"
        conditions = [{
          ignore_case = true
          negate      = false
          pattern     = "pip-appgateway-launch-eastus-demo.eastus.cloudapp.azure.com"
          variable    = "var_host"
        }]
        request_header_configurations = [{
          header_name  = "hostname"
          header_value = "appgateway"
        }]
        response_header_configurations = [{
          header_name  = "hostname"
          header_value = "appgateway"
        }]
      }]
    }]
  }
}
create_subnet   = false
subnet_prefixes = ["10.0.0.0/24"]
address_space   = ["10.0.0.0/16"]
subnet_names    = ["app-gtw-subnet"]
environment     = "demo"
location        = "eastus2"
