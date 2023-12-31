/*

The following links provide the documentation for the new blocks used
in this terraform configuration file

1. azurerm_application_gateway - https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway

*/

resource "azurerm_public_ip" "rg103vn100fw100ag100tg" {
  name                = "rg103vn100fw100ag100"
  resource_group_name = local.resource_group_name
  location            = local.location
  allocation_method   = "Static" 
  sku="Standard"
  sku_tier = "Regional"
}

# We need an additional subnet in the virtual network
resource "azurerm_subnet" "rg103vn100fw100ag100sn100tg" {
  name                 = "rg103vn100fw100ag100sn100"
  resource_group_name  = local.resource_group_name
  virtual_network_name = local.virtual_network.name
  address_prefixes     = ["10.0.1.0/24"] 
}

resource "azurerm_application_gateway" "rg103vn100fw100agtosn100tg" {
  name                = "rg103vn100fw100agtosn100"
  resource_group_name = local.resource_group_name
  location            = local.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "rg103vn100fw100agtosn100tg-ip-config"
    subnet_id = azurerm_subnet.rg103vn100fw100ag100sn100tg.id
  }

  frontend_port {
    name = "rg103vn100fw100agtosn100af100pt100"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "rg103vn100fw100agtosn100af100ip100"
    public_ip_address_id = azurerm_public_ip.rg103vn100fw100ag100tg.id    
  }

  depends_on = [
    azurerm_public_ip.rg103vn100fw100ag100tg,
    azurerm_subnet.rg103vn100fw100ag100sn100tg
  ]

   dynamic backend_address_pool {  
     for_each = toset(local.function)
     content {
      name  = "${backend_address_pool.value}-pool"
      ip_addresses = [
      "${azurerm_network_interface.rg103vn100ni101tg[backend_address_pool.value].private_ip_address}"
      ]
    }
   }

      backend_http_settings {
    name                  = "HTTPSetting"
    cookie_based_affinity = "Disabled"
    path                  = ""
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

 http_listener {
    name                           = "rg103vn100fw100agtosntoaf100"
    frontend_ip_configuration_name = "rg103vn100fw100agtosn100af100ip100"
    frontend_port_name             = "rg103vn100fw100agtosn100af100pt100"
    protocol                       = "Http"
  }

 request_routing_rule {
    name               = "RoutingRuleA"
    rule_type          = "PathBasedRouting"
    url_path_map_name  = "RoutingPath"
    http_listener_name = "rg103vn100fw100agtosntoaf100"    
    priority = 1
  }

  url_path_map {
    name                               = "RoutingPath"    
    default_backend_address_pool_name   = "${local.function[0]}-pool"
    default_backend_http_settings_name  = "HTTPSetting"
   
     dynamic path_rule {
      for_each = toset(local.function)
       content {
      name                          = "${path_rule.value}RoutingRule"
      backend_address_pool_name     = "${path_rule.value}-pool"
      backend_http_settings_name    = "HTTPSetting"
      paths = [
        "/${path_rule.value}/*",
      ]
    }
     }
    
  }

}