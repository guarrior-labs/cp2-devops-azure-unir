###############################################
# Azure Kubernetes Service (AKS)
###############################################

resource "azurerm_kubernetes_cluster" "aks_cp2" {

  name                = "aks-cp2-devops"
  location            = azurerm_resource_group.rg_cp2.location
  resource_group_name = azurerm_resource_group.rg_cp2.name

  dns_prefix = "akscp2"

  sku_tier = "Free"

  default_node_pool {

    name       = "default"
    node_count = 1

    vm_size = "Standard_D2s_v3"

  }

  identity {

    type = "SystemAssigned"

  }

  tags = {

    environment = "casopractico2"

  }

}

###############################################
# Lectura del ACR existente
###############################################

data "azurerm_container_registry" "acr" {

  name                = azurerm_container_registry.acr.name
  resource_group_name = azurerm_resource_group.rg_cp2.name

}

###############################################
# Permitir a AKS descargar imágenes del ACR
###############################################

resource "azurerm_role_assignment" "aks_acr_pull" {

  scope                = data.azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"

  principal_id = azurerm_kubernetes_cluster.aks_cp2.kubelet_identity[0].object_id

  skip_service_principal_aad_check = true

}
