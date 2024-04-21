# tf-azurerm-module_collection-application_gateway

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![License: CC BY-NC-ND 4.0](https://img.shields.io/badge/License-CC_BY--NC--ND_4.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc-nd/4.0/)

## Overview

This module uses a public module to deploy Application Gateway.

**Notes:**
1. `claranet/app-gateway/azurerm` public module - version `7.7.2` does not provide ability support `Basic` sku for Application Gateway. It just supports `Standard SKU`. This means, that public IP address associated with the Application Gateway needs to be with `Standard` SKU as well.
For `azurerm_public_ip` resource, Availability Zones are only supported with a Standard SKU and in select regions at this time(as of 04/09/2024). Standard SKU Public IP Addresses that do not specify a zone are not zone-redundant by default.
Hence creating Application Gateway is not possible in `West US` region at this time(as of 04/09/2024). The suppored regions can be found [here](https://learn.microsoft.com/en-us/azure/reliability/availability-zones-service-support#azure-regions-with-availability-zone-support)
Reference documentation:
https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip

2. During deployment of Application Gateway, there was error below:

   ```
   Original Error: Code="ApplicationGatewaySubnetInboundTrafficBlockedByNetworkSecurityGroup" Message="Network security group xxx blocks incoming internet traffic on ports 65200 - 65535 to subnet xxx
   ```
   In order to fix this error, the `network security group rule` is added to the `nsg` for the `subnet` where Application Gateway is deployed.

   ```
   {
        name                       = "AllowVnetInBound"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_ranges    = ["65200-65535"]
        source_address_prefix      = "*"
        destination_address_prefix = "*"
   }
    ```
  Reference documentation:

  https://learn.microsoft.com/en-us/azure/application-gateway/configuration-infrastructure?WT.mc_id=Portal-Microsoft_Azure_HybridNetworking#network-security-groups

  3. Can we deploy Application Gateway with `private IP address` only, without giving it a `public IP address`? 
  Yes. There are additional features available along with just providing the `private IP address` only. The features are mentioned [here](https://learn.microsoft.com/en-us/azure/application-gateway/application-gateway-private-deployment?tabs=portal). 
  However since these features are in private/public preview, they will not be available on Azure government cloud(as of 04/16/2024).

  4. Why is there need of having `public IP address` along with `private IP address` for Application Gateway deployment?
  
  Application Gateway v2 currently supports the following combinations:

  - Private IP address and public IP address
  - Public IP address only
  - Private IP address only (preview)

  It is discussed in question above as to why `Private IP address only (preview)` can not be considered yet. For `Private IP address and public IP address` combination there are certain restrictions:

  1. All Application Gateways v2 deployments must contain public facing frontend IP configuration to enable communication to the Gateway Manager service tag.
  2. Network Security Group associations require rules to allow inbound access from GatewayManager and Outbound access to Internet.
  3. When introducing a default route (0.0.0.0/0) to forward traffic anywhere other than the Internet, metrics, monitoring, and updates of the gateway result in a failed status.

  Point number 1 answers the question. For references check these documenation links:
  1. https://learn.microsoft.com/en-us/azure/application-gateway/configuration-frontend-ip
  2. https://learn.microsoft.com/en-us/azure/application-gateway/application-gateway-private-deployment?tabs=portal


  5. When creating Application Gateway, what is the need of adding specifc rules on network security group attached to the subnet in which Application Gateway resides?

    Point number 2 and 3 in answer of the above question, help answering this question. More documentation references can be found [here](https://learn.microsoft.com/en-us/azure/application-gateway/configuration-infrastructure#network-security-groups)

  6. We can user `private links + private endpoints` to make Application Gateway privately accessible. What is the difference in the two mechanisms(using a private IP vs using private links)?
  Private Link allows you to extend private connectivity to Application Gateway via a Private Endpoint in the following scenarios:

    - VNet in the same or different region from Application Gateway
    - VNet in the same or different subscription from Application Gateway
    - VNet in the same or different subscription and the same or different Microsoft Entra tenant from Application Gateway

    If any of the features below are applicable/needed we should be using `private links + private endpoints`. `private IP` deployment will not be useful for these scenarios.

    References can be found here:
    1. https://learn.microsoft.com/en-us/azure/application-gateway/private-link
    2. https://learn.microsoft.com/en-us/azure/application-gateway/private-link-configure?tabs=portal

## Pre-Commit hooks

[.pre-commit-config.yaml](.pre-commit-config.yaml) file defines certain `pre-commit` hooks that are relevant to terraform, golang and common linting tasks. There are no custom hooks added.

`commitlint` hook enforces commit message in certain format. The commit contains the following structural elements, to communicate intent to the consumers of your commit messages:

- **fix**: a commit of the type `fix` patches a bug in your codebase (this correlates with PATCH in Semantic Versioning).
- **feat**: a commit of the type `feat` introduces a new feature to the codebase (this correlates with MINOR in Semantic Versioning).
- **BREAKING CHANGE**: a commit that has a footer `BREAKING CHANGE:`, or appends a `!` after the type/scope, introduces a breaking API change (correlating with MAJOR in Semantic Versioning). A BREAKING CHANGE can be part of commits of any type.
footers other than BREAKING CHANGE: <description> may be provided and follow a convention similar to git trailer format.
- **build**: a commit of the type `build` adds changes that affect the build system or external dependencies (example scopes: gulp, broccoli, npm)
- **chore**: a commit of the type `chore` adds changes that don't modify src or test files
- **ci**: a commit of the type `ci` adds changes to our CI configuration files and scripts (example scopes: Travis, Circle, BrowserStack, SauceLabs)
- **docs**: a commit of the type `docs` adds documentation only changes
- **perf**: a commit of the type `perf` adds code change that improves performance
- **refactor**: a commit of the type `refactor` adds code change that neither fixes a bug nor adds a feature
- **revert**: a commit of the type `revert` reverts a previous commit
- **style**: a commit of the type `style` adds code changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)
- **test**: a commit of the type `test` adds missing tests or correcting existing tests

Base configuration used for this project is [commitlint-config-conventional (based on the Angular convention)](https://github.com/conventional-changelog/commitlint/tree/master/@commitlint/config-conventional#type-enum)

If you are a developer using vscode, [this](https://marketplace.visualstudio.com/items?itemName=joshbolduc.commitlint) plugin may be helpful.

`detect-secrets-hook` prevents new secrets from being introduced into the baseline. TODO: INSERT DOC LINK ABOUT HOOKS

In order for `pre-commit` hooks to work properly

- You need to have the pre-commit package manager installed. [Here](https://pre-commit.com/#install) are the installation instructions.
- `pre-commit` would install all the hooks when commit message is added by default except for `commitlint` hook. `commitlint` hook would need to be installed manually using the command below

```
pre-commit install --hook-type commit-msg
```

## To test the resource group module locally

1. For development/enhancements to this module locally, you'll need to install all of its components. This is controlled by the `configure` target in the project's [`Makefile`](./Makefile). Before you can run `configure`, familiarize yourself with the variables in the `Makefile` and ensure they're pointing to the right places.

```
make configure
```

This adds in several files and directories that are ignored by `git`. They expose many new Make targets.

2. _THIS STEP APPLIES ONLY TO MICROSOFT AZURE. IF YOU ARE USING A DIFFERENT PLATFORM PLEASE SKIP THIS STEP._ The first target you care about is `env`. This is the common interface for setting up environment variables. The values of the environment variables will be used to authenticate with cloud provider from local development workstation.

`make configure` command will bring down `azure_env.sh` file on local workstation. Devloper would need to modify this file, replace the environment variable values with relevant values.

These environment variables are used by `terratest` integration suit.

Service principle used for authentication(value of ARM_CLIENT_ID) should have below privileges on resource group within the subscription.

```
"Microsoft.Resources/subscriptions/resourceGroups/write"
"Microsoft.Resources/subscriptions/resourceGroups/read"
"Microsoft.Resources/subscriptions/resourceGroups/delete"
```

Then run this make target to set the environment variables on developer workstation.

```
make env
```

3. The first target you care about is `check`.

**Pre-requisites**
Before running this target it is important to ensure that, developer has created files mentioned below on local workstation under root directory of git repository that contains code for primitives/segments. Note that these files are `azure` specific. If primitive/segment under development uses any other cloud provider than azure, this section may not be relevant.

- A file named `provider.tf` with contents below

```
provider "azurerm" {
  features {}
}
```

- A file named `terraform.tfvars` which contains key value pair of variables used.

Note that since these files are added in `gitignore` they would not be checked in into primitive/segment's git repo.

After creating these files, for running tests associated with the primitive/segment, run

```
make check
```

If `make check` target is successful, developer is good to commit the code to primitive/segment's git repo.

`make check` target

- runs `terraform commands` to `lint`,`validate` and `plan` terraform code.
- runs `conftests`. `conftests` make sure `policy` checks are successful.
- runs `terratest`. This is integration test suit.
- runs `opa` tests
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name                                                                      | Version  |
| ------------------------------------------------------------------------- | -------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | <= 1.5.5 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm)       | ~> 3.77  |
| <a name="requirement_random"></a> [random](#requirement\_random)          | ~> 3.6   |

## Providers

No providers.

## Modules

| Name                                                                    | Source                       | Version |
| ----------------------------------------------------------------------- | ---------------------------- | ------- |
| <a name="module_app_gateway"></a> [app\_gateway](#module\_app\_gateway) | claranet/app-gateway/azurerm | 7.7.2   |

## Resources

No resources.

## Inputs

| Name                                                                     | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             | Type                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           | Default | Required |
| ------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- | :------: |
| <a name="input_app_gateways"></a> [app\_gateways](#input\_app\_gateways) | Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at  http://www.apache.org/licenses/LICENSE-2.0  Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License. | <pre>map(object({<br>    appgw_backend_http_settings = list(object({<br>      name                                = string<br>      port                                = optional(number, 443)<br>      protocol                            = optional(string, "Https")<br>      path                                = optional(string)<br>      probe_name                          = optional(string)<br>      cookie_based_affinity               = optional(string, "Disabled")<br>      affinity_cookie_name                = optional(string, "ApplicationGatewayAffinity")<br>      request_timeout                     = optional(number, 20)<br>      host_name                           = optional(string)<br>      pick_host_name_from_backend_address = optional(bool, true)<br>      trusted_root_certificate_names      = optional(list(string), [])<br>      authentication_certificate          = optional(string)<br>      connection_draining_timeout_sec     = optional(number)<br>    })),<br>    appgw_backend_pools = list(object({<br>      name         = string<br>      fqdns        = optional(list(string))<br>      ip_addresses = optional(list(string))<br>    })),<br>    appgw_http_listeners = list(object({<br>      name                           = string<br>      frontend_ip_configuration_name = optional(string)<br>      frontend_port_name             = optional(string)<br>      host_name                      = optional(string)<br>      host_names                     = optional(list(string))<br>      protocol                       = optional(string, "Https")<br>      require_sni                    = optional(bool, false)<br>      ssl_certificate_name           = optional(string)<br>      ssl_profile_name               = optional(string)<br>      firewall_policy_id             = optional(string)<br>      custom_error_configuration = optional(list(object({<br>        status_code           = string<br>        custom_error_page_url = string<br>      })), [])<br>    })),<br>    appgw_routings = list(object({ name = string<br>      rule_type                   = optional(string, "Basic")<br>      http_listener_name          = optional(string)<br>      backend_address_pool_name   = optional(string)<br>      backend_http_settings_name  = optional(string)<br>      url_path_map_name           = optional(string)<br>      redirect_configuration_name = optional(string)<br>      rewrite_rule_set_name       = optional(string)<br>      priority                    = optional(number)<br>    })),<br>    appgw_url_path_map = optional(list(object({<br>      name                                = string<br>      default_backend_address_pool_name   = optional(string)<br>      default_redirect_configuration_name = optional(string)<br>      default_backend_http_settings_name  = optional(string)<br>      default_rewrite_rule_set_name       = optional(string)<br>      path_rules = list(object({<br>        name                        = string<br>        backend_address_pool_name   = optional(string)<br>        backend_http_settings_name  = optional(string)<br>        rewrite_rule_set_name       = optional(string)<br>        redirect_configuration_name = optional(string)<br>        paths                       = optional(list(string), [])<br>      }))<br>    })), []),<br>    client_name                = string,<br>    environment                = string,<br>    location                   = string,<br>    location_short             = optional(string, ""),<br>    logs_destinations_ids      = list(string),<br>    resource_group_name        = string,<br>    stack                      = string,<br>    subnet_cidr                = string,<br>    virtual_network_name       = string,<br>    app_gateway_tags           = optional(map(string), {}),<br>    custom_appgw_name          = optional(string, ""),<br>    create_subnet              = bool,<br>    subnet_id                  = optional(string),<br>    subnet_resource_group_name = optional(string),<br>    appgw_rewrite_rule_set = optional(list(object({<br>      name = string<br>      rewrite_rules = list(object({<br>        name          = string<br>        rule_sequence = string<br>        conditions = optional(list(object({<br>          variable    = string<br>          pattern     = string<br>          ignore_case = optional(bool, false)<br>          negate      = optional(bool, false)<br>          })),<br>        [])<br>        response_header_configurations = optional(list(object({<br>          header_name = string<br>          header_value = string })),<br>        [])<br>        request_header_configurations = optional(list(object({<br>          header_name = string<br>          header_value = string })),<br>        [])<br>        url_reroute = optional(object({<br>          path         = optional(string)<br>          query_string = optional(string)<br>          components   = optional(string)<br>          reroute      = optional(bool)<br>        }))<br>      }))<br>    })), []),<br>    appgw_probes = optional(list(object({<br>      name                                      = string<br>      host                                      = optional(string)<br>      port                                      = optional(number, null)<br>      interval                                  = optional(number, 30)<br>      path                                      = optional(string, "/")<br>      protocol                                  = optional(string, "Https")<br>      timeout                                   = optional(number, 30)<br>      unhealthy_threshold                       = optional(number, 3)<br>      pick_host_name_from_backend_http_settings = optional(bool, false)<br>      minimum_servers                           = optional(number, 0)<br>      match = optional(object(<br>        {<br>          body        = optional(string, "")<br>          status_code = optional(list(string), ["200-399"])<br>      }), {})<br>    })), []),<br>    frontend_port_settings = list(object({<br>      name = string<br>      port = number<br>    })),<br>    custom_ip_name                             = optional(string, "")<br>    custom_ip_label                            = optional(string, "")<br>    custom_frontend_ip_configuration_name      = optional(string, "")<br>    appgw_private                              = optional(bool, false)<br>    appgw_private_ip                           = optional(string, "")<br>    custom_frontend_priv_ip_configuration_name = optional(string, "")<br>    ip_allocation_method                       = optional(string, "Static")<br>    ip_sku                                     = optional(string, "Standard")<br>    ip_tags                                    = optional(map(string), {})<br>    ip_ddos_protection_mode                    = optional(string, "Disabled")<br>    ip_ddos_protection_plan_id                 = optional(string, null)<br>    create_nsg                                 = optional(bool, false)<br>    create_nsg_healthprobe_rule                = optional(bool, false)<br>    create_nsg_https_rule                      = optional(bool, false)<br>    custom_nsg_name                            = optional(string, "")<br>    custom_nsr_healthcheck_name                = optional(string, "")<br>    custom_nsr_https_name                      = optional(string, "")<br>    custom_subnet_name                         = optional(string, "")<br>    enable_http2                               = optional(bool, false)<br>    firewall_policy_id                         = optional(string, null)<br>    force_firewall_policy_association          = optional(bool, false)<br>    nsr_https_source_address_prefix            = optional(string, "")<br>  }))</pre> | n/a     |   yes    |

## Outputs

| Name                                                                                                                                                                                                              | Description                                                                                       |
| ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| <a name="output_appgw_backend_address_pool_ids"></a> [appgw\_backend\_address\_pool\_ids](#output\_appgw\_backend\_address\_pool\_ids)                                                                            | List of backend address pool Ids.                                                                 |
| <a name="output_appgw_backend_http_settings_ids"></a> [appgw\_backend\_http\_settings\_ids](#output\_appgw\_backend\_http\_settings\_ids)                                                                         | List of backend HTTP settings Ids.                                                                |
| <a name="output_appgw_backend_http_settings_probe_ids"></a> [appgw\_backend\_http\_settings\_probe\_ids](#output\_appgw\_backend\_http\_settings\_probe\_ids)                                                     | List of probe Ids from backend HTTP settings.                                                     |
| <a name="output_appgw_custom_error_configuration_ids"></a> [appgw\_custom\_error\_configuration\_ids](#output\_appgw\_custom\_error\_configuration\_ids)                                                          | List of custom error configuration Ids.                                                           |
| <a name="output_appgw_frontend_ip_configuration_ids"></a> [appgw\_frontend\_ip\_configuration\_ids](#output\_appgw\_frontend\_ip\_configuration\_ids)                                                             | List of frontend IP configuration Ids.                                                            |
| <a name="output_appgw_frontend_port_ids"></a> [appgw\_frontend\_port\_ids](#output\_appgw\_frontend\_port\_ids)                                                                                                   | List of frontend port Ids.                                                                        |
| <a name="output_appgw_gateway_ip_configuration_ids"></a> [appgw\_gateway\_ip\_configuration\_ids](#output\_appgw\_gateway\_ip\_configuration\_ids)                                                                | List of IP configuration Ids.                                                                     |
| <a name="output_appgw_http_listener_frontend_ip_configuration_ids"></a> [appgw\_http\_listener\_frontend\_ip\_configuration\_ids](#output\_appgw\_http\_listener\_frontend\_ip\_configuration\_ids)               | List of frontend IP configuration Ids from HTTP listeners.                                        |
| <a name="output_appgw_http_listener_frontend_port_ids"></a> [appgw\_http\_listener\_frontend\_port\_ids](#output\_appgw\_http\_listener\_frontend\_port\_ids)                                                     | List of frontend port Ids from HTTP listeners.                                                    |
| <a name="output_appgw_http_listener_ids"></a> [appgw\_http\_listener\_ids](#output\_appgw\_http\_listener\_ids)                                                                                                   | List of HTTP listener Ids.                                                                        |
| <a name="output_appgw_id"></a> [appgw\_id](#output\_appgw\_id)                                                                                                                                                    | The ID of the Application Gateway.                                                                |
| <a name="output_appgw_name"></a> [appgw\_name](#output\_appgw\_name)                                                                                                                                              | The name of the Application Gateway.                                                              |
| <a name="output_appgw_nsg_id"></a> [appgw\_nsg\_id](#output\_appgw\_nsg\_id)                                                                                                                                      | The ID of the network security group from the subnet where the Application Gateway is attached.   |
| <a name="output_appgw_nsg_name"></a> [appgw\_nsg\_name](#output\_appgw\_nsg\_name)                                                                                                                                | The name of the network security group from the subnet where the Application Gateway is attached. |
| <a name="output_appgw_public_ip_address"></a> [appgw\_public\_ip\_address](#output\_appgw\_public\_ip\_address)                                                                                                   | The public IP address of Application Gateway.                                                     |
| <a name="output_appgw_public_ip_domain_name"></a> [appgw\_public\_ip\_domain\_name](#output\_appgw\_public\_ip\_domain\_name)                                                                                     | Domain Name part from FQDN of the A DNS record associated with the public IP.                     |
| <a name="output_appgw_public_ip_fqdn"></a> [appgw\_public\_ip\_fqdn](#output\_appgw\_public\_ip\_fqdn)                                                                                                            | Fully qualified domain name of the A DNS record associated with the public IP.                    |
| <a name="output_appgw_redirect_configuration_ids"></a> [appgw\_redirect\_configuration\_ids](#output\_appgw\_redirect\_configuration\_ids)                                                                        | List of redirect configuration Ids.                                                               |
| <a name="output_appgw_request_routing_rule_backend_address_pool_ids"></a> [appgw\_request\_routing\_rule\_backend\_address\_pool\_ids](#output\_appgw\_request\_routing\_rule\_backend\_address\_pool\_ids)       | List of backend address pool Ids attached to request routing rules.                               |
| <a name="output_appgw_request_routing_rule_backend_http_settings_ids"></a> [appgw\_request\_routing\_rule\_backend\_http\_settings\_ids](#output\_appgw\_request\_routing\_rule\_backend\_http\_settings\_ids)    | List of HTTP settings Ids attached to request routing rules.                                      |
| <a name="output_appgw_request_routing_rule_http_listener_ids"></a> [appgw\_request\_routing\_rule\_http\_listener\_ids](#output\_appgw\_request\_routing\_rule\_http\_listener\_ids)                              | List of HTTP listener Ids attached to request routing rules.                                      |
| <a name="output_appgw_request_routing_rule_ids"></a> [appgw\_request\_routing\_rule\_ids](#output\_appgw\_request\_routing\_rule\_ids)                                                                            | List of request routing rules Ids.                                                                |
| <a name="output_appgw_request_routing_rule_redirect_configuration_ids"></a> [appgw\_request\_routing\_rule\_redirect\_configuration\_ids](#output\_appgw\_request\_routing\_rule\_redirect\_configuration\_ids)   | List of redirect configuration Ids attached to request routing rules.                             |
| <a name="output_appgw_request_routing_rule_rewrite_rule_set_ids"></a> [appgw\_request\_routing\_rule\_rewrite\_rule\_set\_ids](#output\_appgw\_request\_routing\_rule\_rewrite\_rule\_set\_ids)                   | List of rewrite rule set Ids attached to request routing rules.                                   |
| <a name="output_appgw_request_routing_rule_url_path_map_ids"></a> [appgw\_request\_routing\_rule\_url\_path\_map\_ids](#output\_appgw\_request\_routing\_rule\_url\_path\_map\_ids)                               | List of URL path map Ids attached to request routing rules.                                       |
| <a name="output_appgw_ssl_certificate_ids"></a> [appgw\_ssl\_certificate\_ids](#output\_appgw\_ssl\_certificate\_ids)                                                                                             | List of SSL certificate Ids.                                                                      |
| <a name="output_appgw_subnet_id"></a> [appgw\_subnet\_id](#output\_appgw\_subnet\_id)                                                                                                                             | The ID of the subnet where the Application Gateway is attached.                                   |
| <a name="output_appgw_subnet_name"></a> [appgw\_subnet\_name](#output\_appgw\_subnet\_name)                                                                                                                       | The name of the subnet where the Application Gateway is attached.                                 |
| <a name="output_appgw_url_path_map_default_backend_address_pool_ids"></a> [appgw\_url\_path\_map\_default\_backend\_address\_pool\_ids](#output\_appgw\_url\_path\_map\_default\_backend\_address\_pool\_ids)     | List of default backend address pool Ids attached to URL path maps.                               |
| <a name="output_appgw_url_path_map_default_backend_http_settings_ids"></a> [appgw\_url\_path\_map\_default\_backend\_http\_settings\_ids](#output\_appgw\_url\_path\_map\_default\_backend\_http\_settings\_ids)  | List of default backend HTTP settings Ids attached to URL path maps.                              |
| <a name="output_appgw_url_path_map_default_redirect_configuration_ids"></a> [appgw\_url\_path\_map\_default\_redirect\_configuration\_ids](#output\_appgw\_url\_path\_map\_default\_redirect\_configuration\_ids) | List of default redirect configuration Ids attached to URL path maps.                             |
| <a name="output_appgw_url_path_map_ids"></a> [appgw\_url\_path\_map\_ids](#output\_appgw\_url\_path\_map\_ids)                                                                                                    | List of URL path map Ids.                                                                         |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
