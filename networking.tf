resource "azurerm_virtual_network" "rg103vn100tg" {
  name                = local.virtual_network.name
  location            = local.location  
  resource_group_name = local.resource_group_name
  address_space       = [local.virtual_network.address_space]
  depends_on = [
    azurerm_resource_group.appgrp
  ]  
} 



resource "azurerm_subnet" "rg103vn100sn100tg" {    
    name                 = "rg103vn100sn100"
    resource_group_name  = local.resource_group_name
    virtual_network_name = local.virtual_network.name
    address_prefixes     = ["10.0.2.0/24"]
    depends_on = [
      azurerm_virtual_network.rg103vn100tg
    ]
}
