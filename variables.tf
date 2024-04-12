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
variable "app_gateways" {
  type = map(object({
    appgw_backend_http_settings = list(object({
      name                                = string
      port                                = optional(number, 443)
      protocol                            = optional(string, "Https")
      path                                = optional(string)
      probe_name                          = optional(string)
      cookie_based_affinity               = optional(string, "Disabled")
      affinity_cookie_name                = optional(string, "ApplicationGatewayAffinity")
      request_timeout                     = optional(number, 20)
      host_name                           = optional(string)
      pick_host_name_from_backend_address = optional(bool, true)
      trusted_root_certificate_names      = optional(list(string), [])
      authentication_certificate          = optional(string)
      connection_draining_timeout_sec     = optional(number)
    })),
    appgw_backend_pools = list(object({
      name         = string
      fqdns        = optional(list(string))
      ip_addresses = optional(list(string))
    })),
    appgw_http_listeners = list(object({
      name                           = string
      frontend_ip_configuration_name = optional(string)
      frontend_port_name             = optional(string)
      host_name                      = optional(string)
      host_names                     = optional(list(string))
      protocol                       = optional(string, "Https")
      require_sni                    = optional(bool, false)
      ssl_certificate_name           = optional(string)
      ssl_profile_name               = optional(string)
      firewall_policy_id             = optional(string)
      custom_error_configuration = optional(list(object({
        status_code           = string
        custom_error_page_url = string
      })), [])
    })),
    appgw_routings = list(object({ name = string
      rule_type                   = optional(string, "Basic")
      http_listener_name          = optional(string)
      backend_address_pool_name   = optional(string)
      backend_http_settings_name  = optional(string)
      url_path_map_name           = optional(string)
      redirect_configuration_name = optional(string)
      rewrite_rule_set_name       = optional(string)
      priority                    = optional(number)
    })),
    appgw_url_path_map = optional(list(object({
      name                                = string
      default_backend_address_pool_name   = optional(string)
      default_redirect_configuration_name = optional(string)
      default_backend_http_settings_name  = optional(string)
      default_rewrite_rule_set_name       = optional(string)
      path_rules = list(object({
        name                        = string
        backend_address_pool_name   = optional(string)
        backend_http_settings_name  = optional(string)
        rewrite_rule_set_name       = optional(string)
        redirect_configuration_name = optional(string)
        paths                       = optional(list(string), [])
      }))
    })), []),
    client_name                = string,
    environment                = string,
    location                   = string,
    location_short             = optional(string, ""),
    logs_destinations_ids      = list(string),
    resource_group_name        = string,
    stack                      = string,
    subnet_cidr                = string,
    virtual_network_name       = string,
    app_gateway_tags           = optional(map(string), {}),
    custom_appgw_name          = optional(string, ""),
    create_subnet              = bool,
    subnet_id                  = optional(string),
    subnet_resource_group_name = optional(string),
    appgw_rewrite_rule_set = optional(list(object({
      name = string
      rewrite_rules = list(object({
        name          = string
        rule_sequence = string
        conditions = optional(list(object({
          variable    = string
          pattern     = string
          ignore_case = optional(bool, false)
          negate      = optional(bool, false)
          })),
        [])
        response_header_configurations = optional(list(object({
          header_name = string
          header_value = string })),
        [])
        request_header_configurations = optional(list(object({
          header_name = string
          header_value = string })),
        [])
        url_reroute = optional(object({
          path         = optional(string)
          query_string = optional(string)
          components   = optional(string)
          reroute      = optional(bool)
        }))
      }))
    })), []),
    appgw_probes = optional(list(object({
      name                                      = string
      host                                      = optional(string)
      port                                      = optional(number, null)
      interval                                  = optional(number, 30)
      path                                      = optional(string, "/")
      protocol                                  = optional(string, "Https")
      timeout                                   = optional(number, 30)
      unhealthy_threshold                       = optional(number, 3)
      pick_host_name_from_backend_http_settings = optional(bool, false)
      minimum_servers                           = optional(number, 0)
      match = optional(object(
        {
          body        = optional(string, "")
          status_code = optional(list(string), ["200-399"])
      }), {})
    })), []),
    frontend_port_settings = list(object({
      name = string
      port = number
    })),
    custom_ip_name                             = optional(string, "")
    custom_ip_label                            = optional(string, "")
    custom_frontend_ip_configuration_name      = optional(string, "")
    appgw_private                              = optional(bool, false)
    appgw_private_ip                           = optional(string, "")
    custom_frontend_priv_ip_configuration_name = optional(string, "")
    ip_allocation_method                       = optional(string, "Static")
    ip_sku                                     = optional(string, "Standard")
    ip_tags                                    = optional(map(string), {})
    ip_ddos_protection_mode                    = optional(string, "Disabled")
    ip_ddos_protection_plan_id                 = optional(string, null)
    create_nsg                                 = optional(bool, false)
    create_nsg_healthprobe_rule                = optional(bool, false)
    create_nsg_https_rule                      = optional(bool, false)
    custom_nsg_name                            = optional(string, "")
    custom_nsr_healthcheck_name                = optional(string, "")
    custom_nsr_https_name                      = optional(string, "")
    custom_subnet_name                         = optional(string, "")
    enable_http2                               = optional(bool, false)
    firewall_policy_id                         = optional(string, null)
    force_firewall_policy_association          = optional(bool, false)
    nsr_https_source_address_prefix            = optional(string, "")
  }))
}
