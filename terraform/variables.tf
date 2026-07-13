variable "subscription_id" {
  description = "ID de la suscripción de Azure"
  type        = string
}

variable "location" {
  description = "Región donde se desplegarán los recursos"
  type        = string
  default     = "chilecentral"
}

variable "vm_size" {
  description = "Tamaño de la máquina virtual"
  type        = string
  default     = "Standard_B2s"
}

variable "admin_username" {
  description = "Usuario administrador de la máquina virtual"
  type        = string
  default     = "azureuser"
}

variable "vm_name" {
  description = "Nombre de la máquina virtual"
  type        = string
  default     = "vm-cp2"

}

variable "acr_name" {
  description = "Nombre global del Azure Container Registry"
  type        = string

}
