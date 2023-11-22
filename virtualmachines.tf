resource "azurerm_network_interface" "rg103vn100ni100tg" {  
  name                = "rg103vn100ni100"
  location            = local.location  
  resource_group_name = local.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.rg103vn100sn100tg.id
    private_ip_address_allocation = "Dynamic"    
  }

  depends_on = [
    azurerm_virtual_network.rg103vn100tg
  ]
}


resource "azurerm_windows_virtual_machine" "r103100100100tg" {  //start witgh char AT MAX 15 CHAR rg103vn100ni100vm100tg
  name                = "r103100100100"
  resource_group_name = local.resource_group_name
  location            = local.location 
  size                = "Standard_D2s_v3"
  admin_username      = "r103100100100100" //rg103vn100ni100vm100tguser100
  admin_password      = "Azure@123"      
    network_interface_ids = [
    azurerm_network_interface.rg103vn100ni100tg.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
  depends_on = [
    azurerm_virtual_network.rg103vn100tg,
    azurerm_network_interface.rg103vn100ni100tg
  ]
}