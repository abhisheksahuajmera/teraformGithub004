resource "azurerm_virtual_network" "rg103vn100tg" {
  name                = local.virtual_network.name
  location            = local.location  
  resource_group_name = local.resource_group_name
  address_space       = [local.virtual_network.address_space]
  depends_on = [
    azurerm_resource_group.appgrp
  ]  
} 


