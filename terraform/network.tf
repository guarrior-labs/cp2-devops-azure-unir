resource "azurerm_virtual_network" "vnet_cp2" {

  name                = "vnet-cp2"
  location            = azurerm_resource_group.rg_cp2.location
  resource_group_name = azurerm_resource_group.rg_cp2.name

  address_space = [
    "10.0.0.0/16"
  ]
}

resource "azurerm_subnet" "subnet_cp2" {

  name                 = "snet-cp2"
  resource_group_name  = azurerm_resource_group.rg_cp2.name
  virtual_network_name = azurerm_virtual_network.vnet_cp2.name

  address_prefixes = [
    "10.0.1.0/24"
  ]
}
