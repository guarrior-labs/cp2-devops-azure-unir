# Caso Práctico 2 - DevOps & Cloud (UNIR)

## Descripción

Este proyecto corresponde al Caso Práctico 2 del Diploma de Especialización en DevOps & Cloud de la Universidad Internacional de La Rioja (UNIR).

El objetivo consiste en automatizar el aprovisionamiento de infraestructura en Microsoft Azure y el despliegue de aplicaciones utilizando herramientas de Infraestructura como Código (IaC), automatización y contenedores.

El proyecto incluye dos escenarios de despliegue:

- Despliegue en Máquina Virtual mediante Podman.
- Despliegue sobre Azure Kubernetes Service (AKS).

---

## Arquitectura

- Terraform
- Azure Resource Group
- Azure Virtual Machine
- Azure Container Registry
- Azure Kubernetes Service
- Ansible
- Podman

## Estructura del proyecto

cp2/
├── terraform/
├── ansible/
├── scripts/
├── app/
│   ├── podman/
│   └── kubernetes/
├── docs/
│   ├──capturas/


## Tecnologías utilizadas

- Terraform
- Microsoft Azure
- Azure Container Registry (ACR)
- Ansible
- Podman
- Kubernetes
- Azure Kubernetes Service (AKS)
- Dockerfile
- Bash
- Git
- GitHub

## Automatización
deploy-podman.sh realiza automáticamente:
1. Construcción de imagen.
2. Versionado.
3. Login al ACR.
4. Push.
5. Despliegue mediante Ansible.
6. Validación automática.

## Aplicaciones
Podman

Servidor Nginx protegido mediante HTTPS y autenticación básica.

Kubernetes

DevOps Deployment Challenge.

## Autor

Daniel Guerrero
Especialista Técnico
UNIR - DevOps & Cloud
