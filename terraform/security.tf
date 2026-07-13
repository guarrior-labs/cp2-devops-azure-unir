resource "azurerm_network_security_group" "nsg_cp2" {

  name                = "nsg-cp2"                          # Nombre del Network Security Group en Azure.
  location            = var.location                       # Región donde se desplegará el recurso.
  resource_group_name = azurerm_resource_group.rg_cp2.name # Grupo de recursos al que pertenece el NSG.

  security_rule { # Regla de seguridad del firewall.

    name = "SSH" # Nombre identificador de la regla.

    priority = 100 # Prioridad de evaluación (un valor menor tiene mayor prioridad).

    direction = "Inbound" # Aplica al tráfico entrante hacia la máquina virtual.

    access = "Allow" # Permite el tráfico que cumpla las condiciones de la regla.

    protocol = "Tcp" # Solo acepta conexiones mediante el protocolo TCP.

    source_port_range = "*" # Se acepta cualquier puerto de origen.

    destination_port_range = "22" # Permite únicamente conexiones al puerto SSH (22).

    source_address_prefix = "*" # Autoriza conexiones desde cualquier dirección IP.

    destination_address_prefix = "*" # La regla aplica a cualquier dirección IP de destino del NSG.

  }


  security_rule { #Regla para el puerto 8080 aplicacion web podman

    name = "HTTP-8080"

    priority = 110

    direction = "Inbound"

    access = "Allow"

    protocol = "Tcp"

    source_port_range = "*"

    destination_port_range = "8080"

    source_address_prefix = "*"

    destination_address_prefix = "*"

  }


  security_rule { # Regla para HTTPS de la aplicación

    name = "HTTPS-8443"

    priority = 120

    direction = "Inbound"

    access = "Allow"

    protocol = "Tcp"

    source_port_range = "*"

    destination_port_range = "8443"

    source_address_prefix = "*"

    destination_address_prefix = "*"

  }

}


resource "azurerm_subnet_network_security_group_association" "nsg_subnet_cp2" {

  subnet_id                 = azurerm_subnet.subnet_cp2.id
  network_security_group_id = azurerm_network_security_group.nsg_cp2.id

}
