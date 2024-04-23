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
    client_name           = string,
    environment           = string,
    location_short        = optional(string, ""),
    logs_destinations_ids = list(string),
    stack                 = string,
    app_gateway_tags      = optional(map(string), {}),
    custom_appgw_name     = optional(string, ""),
    create_subnet         = bool,
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
    }))
    custom_ip_name                        = optional(string, "")
    custom_ip_label                       = optional(string, "")
    custom_frontend_ip_configuration_name = optional(string, "")
  }))
}

//variables required by resource names module
variable "resource_names_map" {
  description = "A map of key to resource_name that will be used by tf-launch-module_library-resource_name to generate resource names"
  type = map(object({
    name       = string
    max_length = optional(number, 60)
  }))

  default = {
    resource_group = {
      name       = "rg"
      max_length = 90
    }
    storage_account = {
      name       = "sa"
      max_length = 24
    }
    app_gateway = {
      name       = "appgw"
      max_length = 80
    }
    vnet = {
      name       = "vnet"
      max_length = 80
    }
  }
}

variable "environment_number" {
  description = "The environment count for the respective environment. Defaults to 000. Increments in value of 1"
  default     = "000"
  type        = string
}

variable "resource_number" {
  description = "The resource count for the respective resource. Defaults to 000. Increments in value of 1"
  default     = "000"
  type        = string
}

variable "logical_product_family" {
  type        = string
  description = <<EOF
    (Required) Name of the product family for which the resource is created.
    Example: org_name, department_name.
  EOF
  nullable    = false

  validation {
    condition     = can(regex("^[_\\-A-Za-z0-9]+$", var.logical_product_family))
    error_message = "The variable must contain letters, numbers, -, _, and .."
  }

  default = "launch"
}

variable "logical_product_service" {
  type        = string
  description = <<EOF
    (Required) Name of the product service for which the resource is created.
    For example, backend, frontend, middleware etc.
  EOF
  nullable    = false

  validation {
    condition     = can(regex("^[_\\-A-Za-z0-9]+$", var.logical_product_service))
    error_message = "The variable must contain letters, numbers, -, _, and .."
  }

  default = "appgw"
}

// variables required by network module
variable "subnet_prefixes" {
  type        = list(string)
  description = "(Required) The address prefix to use for the subnet."
}

variable "address_space" {
  type        = list(string)
  description = "(Required)The address space that is used by the virtual network."
}

variable "subnet_names" {
  type        = list(string)
  description = "(Required) The names of the subnets to be created."
}

variable "environment" {
  type        = string
  description = "(Required) Project environment."
}

variable "location" {
  type        = string
  description = "(Required) Azure location."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A map of tags to add to the resources created by the module."
}
