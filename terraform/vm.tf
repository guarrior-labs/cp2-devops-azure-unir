/******************************************************************************
 Recurso: Dirección IP Pública

 Este recurso crea una dirección IP pública que permitirá acceder
 a la máquina virtual Linux desde Internet mediante SSH.
******************************************************************************/

resource "azurerm_public_ip" "pip_cp2" {

  name                = "pip-cp2"                          # Nombre de la IP pública en Azure.
  location            = var.location                       # Región donde se desplegará el recurso.
  resource_group_name = azurerm_resource_group.rg_cp2.name # Grupo de recursos donde se creará.

  allocation_method = "Static" # Asigna una dirección IP fija.

  sku = "Standard" # SKU recomendada para entornos de producción.

}


/******************************************************************************
 Recurso: Interfaz de Red (NIC)

 Este recurso crea la interfaz de red que conectará la máquina virtual
 a la subred y le asociará la dirección IP pública.
******************************************************************************/

resource "azurerm_network_interface" "nic_cp2" {

  name                = "nic-cp2"                          # Nombre de la interfaz de red.
  location            = var.location                       # Región donde se desplegará el recurso.
  resource_group_name = azurerm_resource_group.rg_cp2.name # Grupo de recursos.

  ip_configuration {

    name                          = "ipconfig1"                  # Nombre de la configuración IP.
    subnet_id                     = azurerm_subnet.subnet_cp2.id # Subred donde se conectará la NIC.
    private_ip_address_allocation = "Dynamic"                    # Asigna automáticamente una IP privada.
    public_ip_address_id          = azurerm_public_ip.pip_cp2.id # Asocia la IP pública creada anteriormente.

  }

}


/******************************************************************************
 Recurso: Máquina Virtual Linux

 Crea una máquina virtual Ubuntu Server utilizando autenticación
 mediante clave pública SSH.
******************************************************************************/

resource "azurerm_linux_virtual_machine" "vm_cp2" {

  name                = var.vm_name                        # Nombre de la máquina en Azure
  computer_name       = var.vm_name                        # Nombre del host dentro del sistema operativo.
  location            = var.location                       # Región donde se desplegará.
  resource_group_name = azurerm_resource_group.rg_cp2.name # Grupo de recursos.
  size                = var.vm_size                        # Tamaño de la máquina virtual.

  admin_username = var.admin_username # Usuario administrador.

  disable_password_authentication = true # Deshabilita el acceso mediante contraseña.

  network_interface_ids = [
    azurerm_network_interface.nic_cp2.id # NIC asociada a la VM.
  ]

  admin_ssh_key {

    username   = var.admin_username            # Usuario autorizado.
    public_key = file("~/.ssh/id_ed25519.pub") # Clave pública SSH.

  }

  os_disk {

    name                 = "osdisk-cp2"   # Nombre del disco del sistema operativo.
    caching              = "ReadWrite"    # Caché recomendada para el disco del SO.
    storage_account_type = "Standard_LRS" # Disco SSD estándar.

  }

  source_image_reference {

    publisher = "Canonical"        # Fabricante de la imagen.
    offer     = "ubuntu-24_04-lts" # Distribución Ubuntu 24.04 LTS.
    sku       = "server"           # Edición Server.
    version   = "latest"           # Última versión disponible.

  }

}
