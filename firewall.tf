/*

The following links provide the documentation for the new blocks used
in this terraform configuration file

1. azurerm_firewall_policy - https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/firewall_policy

2. azurerm_firewall - https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/firewall

*/

# First we need to create a Public IP address for the Azure Firewall

resource "azurerm_public_ip" "rg103vn100fw100tg" {
  name                = "rg103vn100fw100"
  resource_group_name = local.resource_group_name
  location            = local.location
  allocation_method   = "Static" 
  sku="Standard"
  sku_tier = "Regional"
  depends_on = [
    azurerm_resource_group.appgrp
  ]

}

# We need an additional subnet in the virtual network
resource "azurerm_subnet" "rg103vn100fw100sn100tg" {
  name                 = "rg103vn100fw100sn100"
  resource_group_name  = local.resource_group_name
  virtual_network_name = local.virtual_network.name
  address_prefixes     = ["10.0.3.0/24"] 
  depends_on = [
    azurerm_virtual_network.rg103vn100tg
  ]
}

resource "azurerm_firewall_policy" "rg103vn100fp100tg" {
  name                = "rg103vn100fp100"
  resource_group_name = local.resource_group_name
  location            = local.location
}

resource "azurerm_firewall" "rg103vn100fptosn100tg" {
  name                = "rg103vn100fptosn100"
  location            = local.location
  resource_group_name = local.resource_group_name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.rg103vn100fp100sn100tg.id
    public_ip_address_id = azurerm_public_ip.rg103vn100fp100tg.id
  }

  sku_tier = "Standard"
  sku_name = "AZFW_VNet"

  firewall_policy_id = azurerm_firewall_policy.rg103vn100fp100tg.id
  depends_on = [
    azurerm_firewall_policy.rg103vn100fp100tg
  ]
}