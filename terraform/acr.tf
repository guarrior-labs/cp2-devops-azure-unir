
resource "azurerm_container_registry" "acr" {

  name = var.acr_name

  resource_group_name = azurerm_resource_group.rg_cp2.name

  location = azurerm_resource_group.rg_cp2.location

  sku = "Basic"

  admin_enabled = true

  tags = {
    environment = "casopractico2"
  }
}
