# Caso Práctico 2 – DevOps & Cloud (UNIR)

## Descripción

Este proyecto corresponde al Caso Práctico 2 del Diplomado de Especialización en DevOps & Cloud de la Universidad Internacional de La Rioja (UNIR).

El objetivo consiste en diseñar, aprovisionar y automatizar una infraestructura en Microsoft Azure utilizando Infraestructura como Código (IaC), automatización de configuración y despliegue de aplicaciones contenerizadas.

La solución implementa dos estrategias de despliegue completamente automatizadas:

- Despliegue sobre Máquina Virtual utilizando Podman y Ansible.
- Despliegue sobre Azure Kubernetes Service (AKS).

---

# Objetivos

- Automatizar el aprovisionamiento de infraestructura mediante Terraform.
- Automatizar el despliegue de aplicaciones contenerizadas.
- Implementar un registro privado de imágenes utilizando Azure Container Registry.
- Desplegar aplicaciones tanto en máquinas virtuales como en Kubernetes.
- Aplicar principios DevOps mediante automatización, versionamiento y validaciones automáticas.

---

# Arquitectura

```
                         Terraform
                              │
        ┌─────────────────────┴─────────────────────┐
        │                                           │
 Azure Resource Group                         Azure Container Registry
        │                                           │
        │                                           │
        ├──────────────┐                            │
        │              │                            │
   Virtual Machine     │                            │
        │              │                            │
     Ansible           │                            │
        │              │                            │
      Podman           │                            │
        │              │                            │
 Aplicación HTTPS      │                            │
                       │                            │
                       ▼                            ▼
                 Azure Kubernetes Service (AKS)
                              │
                      Deployment + Service
                              │
                  Aplicación Flask + API REST
```

---

# Tecnologías utilizadas

- Microsoft Azure
- Terraform
- Azure Virtual Machine
- Azure Kubernetes Service (AKS)
- Azure Container Registry (ACR)
- Podman
- Kubernetes
- Ansible
- Bash
- Python
- Flask
- HTML
- CSS
- JavaScript
- Git
- GitHub

---

# Estructura del proyecto

```
cp2/
├── app/
│   ├── podman/
│   └── kubernetes/
├── ansible/
├── docs/
├── scripts/
├── terraform/
├── LICENSE
├── README.md
└── .gitignore
```

---

# Componentes implementados

## Infraestructura

- Resource Group
- Virtual Network
- Subnet
- Network Security Group
- Public IP
- Virtual Machine
- Azure Container Registry
- Azure Kubernetes Service

---

## Automatización

### deploy-podman.sh

Automatiza completamente el despliegue sobre la Máquina Virtual.

Incluye:

- Construcción de imagen.
- Versionado automático.
- Login seguro al ACR.
- Push de la imagen.
- Actualización automática de Ansible.
- Ejecución del Playbook.
- Validación del contenedor.
- Validación HTTPS.
- Validación de versión desplegada.

---

### deploy-aks.sh

Automatiza completamente el despliegue sobre Kubernetes.

Incluye:

- Lectura automática de Terraform.
- Construcción de imagen.
- Publicación en Azure Container Registry.
- Obtención automática de credenciales AKS.
- Actualización automática del Deployment.
- Rolling Update.
- Validación del clúster.
- Validación del Pod.
- Validación del Service.
- Validación del PersistentVolumeClaim.
- Validación de la API REST.
- Validación de la versión desplegada.

---

# Aplicaciones desarrolladas

## Escenario 1 – Podman

Servidor Nginx protegido mediante:

- HTTPS
- Certificado SSL
- Autenticación Básica
- Versionado automático de la aplicación

---

## Escenario 2 – Azure Kubernetes Service

Aplicación web desarrollada en Flask denominada:

**DevOps Deployment Challenge**

Características:

- Juego interactivo basado en un Pipeline DevOps.
- Registro de usuarios.
- Hall of Fame persistente.
- API REST.
- Persistencia mediante PersistentVolumeClaim.
- Versionado automático de la aplicación.

---

# Versionamiento

Cada despliegue genera automáticamente una nueva versión de la aplicación.

Ejemplos:

```
v1
v2
v3
...
```

La versión desplegada es visible directamente desde la interfaz web.

---

# Despliegue

## Máquina Virtual

```
./scripts/deploy-podman.sh v1
```

---

## Azure Kubernetes Service

```
./scripts/deploy-aks.sh v1
```

---

# Repositorio

El proyecto utiliza Git para el control de versiones y GitHub como repositorio remoto.

Se realizaron commits organizados por funcionalidades implementadas durante el desarrollo.

---

# Autor

**Daniel Guerrero**

Especialista Técnico

Diplomado de Especialización en DevOps & Cloud

Universidad Internacional de La Rioja (UNIR)

2026