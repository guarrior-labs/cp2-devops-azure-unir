---
title: Caso Práctico 2 - DevOps & Cloud
author: Daniel Guerrero
date: 2026
---

# Caso Práctico 2

## Automatización del despliegue de aplicaciones sobre Microsoft Azure mediante Terraform, Podman, Ansible y Azure Kubernetes Service (AKS)

**Diplomado de Especialización en DevOps & Cloud**

**Universidad Internacional de La Rioja (UNIR)**

---

**Autor**

Daniel Guerrero

Especialista Técnico

---

**Repositorio Git**

https://github.com/guarrior-labs/cp2-devops-azure-unir

---

# Tabla de contenido

1. Introducción
2. Objetivos
3. Repositorio Git
4. Arquitectura General
5. Diagramas de la solución
6. Recursos desplegados en Azure
7. Descripción del proceso de despliegue
8. Aplicaciones desarrolladas
9. Automatización implementada
10. Hallazgos y soluciones implementadas
11. Resultados obtenidos
12. Licencia
13. Conclusiones
14. Referencias

---

# 1. Introducción

El presente documento describe el desarrollo del **Caso Práctico 2** del Diplomado de Especialización en **DevOps & Cloud** impartido por la **Universidad Internacional de La Rioja (UNIR)**.

El objetivo principal del proyecto consiste en diseñar una solución completamente automatizada para el aprovisionamiento de infraestructura y el despliegue de aplicaciones sobre Microsoft Azure, aplicando principios DevOps e Infraestructura como Código (Infrastructure as Code - IaC).

A diferencia de un despliegue tradicional realizado manualmente, toda la infraestructura y los procesos desarrollados en este proyecto pueden reproducirse utilizando únicamente código, scripts y herramientas de automatización.

Durante el desarrollo se implementaron dos escenarios completamente independientes que permiten comparar diferentes estrategias de despliegue de aplicaciones contenerizadas:

- Despliegue sobre una Máquina Virtual Linux utilizando Podman y Ansible: https://57.156.66.202:8443/ (usr: unir/pwd: alumno2026)
- Despliegue sobre Azure Kubernetes Service (AKS) utilizando Kubernetes: http://57.156.50.215/

Ambos escenarios utilizan un registro privado de imágenes mediante **Azure Container Registry (ACR)** y comparten una infraestructura creada automáticamente mediante **Terraform**.

El resultado obtenido corresponde a una plataforma completamente automatizada capaz de:

- Aprovisionar infraestructura.
- Construir imágenes de contenedores.
- Publicar imágenes en Azure Container Registry.
- Desplegar aplicaciones automáticamente.
- Validar el resultado del despliegue.
- Gestionar nuevas versiones mediante scripts Bash.

---

# 2. Objetivos

## Objetivo general

Diseñar e implementar una plataforma DevOps completamente automatizada sobre Microsoft Azure utilizando herramientas modernas de Infraestructura como Código, automatización de configuración y orquestación de contenedores.

---

## Objetivos específicos

- Automatizar el aprovisionamiento de infraestructura mediante Terraform.
- Implementar un registro privado de imágenes utilizando Azure Container Registry.
- Automatizar el despliegue de aplicaciones sobre una Máquina Virtual Linux utilizando Podman y Ansible.
- Implementar un clúster administrado de Kubernetes mediante Azure Kubernetes Service.
- Desarrollar una aplicación web desplegable sobre Kubernetes.
- Automatizar completamente el ciclo Build → Push → Deploy.
- Aplicar buenas prácticas de versionamiento mediante Git y GitHub.
- Validar automáticamente cada despliegue realizado.

---

# 3. Repositorio Git

Todo el código fuente desarrollado durante el proyecto se encuentra disponible en el siguiente repositorio GitHub.

**Repositorio**

https://github.com/guarrior-labs/cp2-devops-azure-unir

En este repositorio se encuentran versionados:

- Infraestructura Terraform.
- Configuración Ansible.
- Scripts Bash.
- Aplicación Podman.
- Aplicación Kubernetes.
- Dockerfiles.
- Archivos YAML.
- Documentación del proyecto.

Los commits fueron realizados siguiendo un criterio incremental, permitiendo mantener trazabilidad sobre cada funcionalidad implementada durante el desarrollo.

---

## Captura 1 y 2

> **Repositorio GitHub con la estructura del proyecto y los commits realizados.**

![[Pasted image 20260713053426.png]]

![[Pasted image 20260713053622.png]]

---

# 4. Arquitectura General

La solución implementada se diseñó siguiendo una arquitectura basada en automatización completa del ciclo DevOps.

Terraform actúa como herramienta de Infraestructura como Código encargándose de crear todos los recursos necesarios sobre Microsoft Azure.

Una vez disponible la infraestructura, Azure Container Registry funciona como repositorio central de imágenes para ambos escenarios de despliegue.

Posteriormente, cada aplicación utiliza una estrategia distinta de despliegue:

- Máquina Virtual Linux utilizando Podman y Ansible.
- Azure Kubernetes Service utilizando Kubernetes.

Finalmente, ambos escenarios exponen la aplicación para su validación desde Internet.

---

# 5. Diagramas de la solución

## Diagrama 1. Arquitectura general

```text
                           Terraform
                                │
                                │
                ┌───────────────┴────────────────┐
                │                                │
                ▼                                ▼
      Azure Resource Group             Azure Container Registry
                │                                ▲
                │                                │
      ┌─────────┴─────────┐                      │
      │                   │                      │
      ▼                   ▼                      │
Virtual Machine       Azure Kubernetes Service  │
      │                   │                      │
      │                   │                      │
   Ansible            Kubernetes                │
      │                   │                      │
      ▼                   ▼                      │
    Podman          Deployment + Service─────────┘
      │
      ▼
 Aplicación HTTPS
```

---

## Diagrama 2. Flujo DevOps

```text
                 GitHub

                    │

                    ▼

              Terraform Apply

                    │

                    ▼

            Recursos Azure creados

                    │

                    ▼

            Construcción Imagen

                    │

                    ▼

         Azure Container Registry

          ┌───────────────┐
          │               │
          ▼               ▼

     Máquina Virtual      AKS

          │               │

          ▼               ▼

      Podman          Kubernetes

          │               │

          └───────┬───────┘

                  ▼

         Aplicaciones publicadas
```

---


# 6. Recursos desplegados en Azure

Durante la ejecución del proyecto fueron aprovisionados automáticamente los siguientes recursos.

| Recurso | Nombre |
|----------|---------|
| Resource Group | rg-cp2-devops |
| Virtual Network | vnet-cp2 |
| Network Security Group | nsg-cp2 |
| Public IP VM | 57.156.66.202 |
| Azure Virtual Machine | vm-cp2 |
| Azure Container Registry | cp2guarrioracr2026 |
| Azure Kubernetes Service | aks-cp2-devops |
| Public IP AKS | 57.156.50.215 |

Todos estos recursos fueron creados mediante Terraform, garantizando reproducibilidad y evitando configuraciones manuales.

La automatización permitió reconstruir completamente el entorno utilizando únicamente archivos de configuración versionados en Git.

---

## Captura 3

> **Captura del Resource Group mostrando todos los recursos creados.**

![[Pasted image 20260713063351.png]]

![[Pasted image 20260713053950.png]]
---

## Captura 4

> **Captura del Azure Container Registry.**

![[Pasted image 20260713054155.png]]

---

## Captura 5

> **Captura del clúster Azure Kubernetes Service.**

![[Pasted image 20260713054451.png]]

![[Pasted image 20260713054422.png]]
---

## Captura 6

> **Captura de la Máquina Virtual creada por Terraform.**

![[Pasted image 20260713054710.png]]

---

# 7. Descripción del proceso de despliegue

La solución implementada contempla dos escenarios de despliegue completamente independientes. Ambos utilizan la misma infraestructura base creada mediante Terraform y un registro privado de imágenes administrado por Azure Container Registry (ACR). Sin embargo, cada uno emplea tecnologías diferentes para demostrar distintos enfoques de automatización.

---

# 7.1 Escenario 1 – Despliegue sobre Máquina Virtual utilizando Podman

El primer escenario consiste en desplegar una aplicación web sobre una Máquina Virtual Linux creada automáticamente mediante Terraform.

Una vez creada la infraestructura, la configuración del servidor se automatiza mediante **Ansible**, mientras que la aplicación se ejecuta dentro de un contenedor administrado por **Podman**.

El proceso completo se encuentra automatizado mediante el script:

```
scripts/deploy-podman.sh
```

Este script permite ejecutar todo el proceso utilizando un único comando:

```bash
./scripts/deploy-podman.sh v19
```

donde el parámetro recibido corresponde a la versión de la imagen que será publicada y desplegada.

---

## Flujo del despliegue

El script realiza automáticamente las siguientes actividades:

1. Obtiene la configuración del proyecto desde Terraform.
2. Construye la imagen Podman.
3. Inserta automáticamente la versión de la aplicación.
4. Etiqueta la imagen.
5. Realiza autenticación segura contra Azure Container Registry.
6. Publica la imagen.
7. Actualiza automáticamente la configuración utilizada por Ansible.
8. Ejecuta el Playbook.
9. Verifica el contenedor desplegado.
10. Comprueba la versión instalada.
11. Valida el servicio HTTPS.
12. Verifica el contenido publicado.

Todo este procedimiento se realiza sin intervención manual.

---

## Automatización implementada

El script incorpora múltiples validaciones para garantizar la confiabilidad del proceso.

Entre ellas se encuentran:

- Verificación de comandos instalados.
- Obtención automática de parámetros desde Terraform.
- Construcción automática de la imagen.
- Inserción dinámica del número de versión.
- Validación del Push hacia Azure Container Registry.
- Validación del contenedor desplegado.
- Validación HTTP y HTTPS.
- Verificación de la versión publicada.

En caso de producirse cualquier error durante el proceso, el despliegue finaliza inmediatamente mostrando un mensaje descriptivo.

---

## Aplicación desplegada

La aplicación desplegada sobre la Máquina Virtual corresponde a un servidor **Nginx** configurado con:

- HTTPS.
- Certificado SSL.
- Autenticación Básica.
- Página HTML con versión automática.
- Versionamiento dinámico durante cada despliegue.

Esto permitió demostrar la automatización completa del ciclo Build → Push → Deploy utilizando Podman.

---

## Captura 7

> **Captura de la aplicación ejecutándose mediante HTTPS sobre la Máquina Virtual.**

![[Pasted image 20260713054949.png]]

---

## Captura 8

> **Insertar captura del script `deploy-podman.sh` finalizando correctamente.**

![[Pasted image 20260713055055.png]]

---

# 7.2 Escenario 2 – Despliegue sobre Azure Kubernetes Service (AKS)

Como segundo escenario se implementó una aplicación completamente diferente orientada a demostrar las capacidades de Kubernetes.

El despliegue se realiza sobre un clúster administrado de Azure Kubernetes Service (AKS).

La aplicación fue desarrollada utilizando:

- Python
- Flask
- HTML
- CSS
- JavaScript

y se ejecuta dentro de un Deployment de Kubernetes.

Toda la automatización se encuentra implementada mediante el script:

```
scripts/deploy-aks.sh
```

El despliegue completo puede ejecutarse mediante:

```bash
./scripts/deploy-aks.sh v10
```

---

## Flujo del despliegue

El script automatiza completamente las siguientes tareas:

1. Lectura automática de los outputs de Terraform.
2. Construcción de la imagen.
3. Inserción automática del número de versión.
4. Publicación en Azure Container Registry.
5. Validación del Push.
6. Obtención automática de credenciales del clúster AKS.
7. Creación o actualización automática del Deployment.
8. Actualización de la imagen mediante Rolling Update.
9. Espera automática del Rollout.
10. Verificación del Pod.
11. Verificación del PersistentVolumeClaim.
12. Verificación del Service.
13. Validación HTTP.
14. Validación de la API REST.
15. Resumen automático del despliegue.

Al igual que en el escenario anterior, todo el proceso puede ejecutarse mediante un único comando.

---

## Kubernetes

Para este escenario fueron implementados los siguientes recursos:

### Deployment

Encargado de mantener la aplicación ejecutándose y administrar los Rolling Updates.

---

### Service

Permite publicar la aplicación hacia Internet utilizando un LoadBalancer administrado por Azure.

---

### PersistentVolumeClaim

Se implementó un volumen persistente para almacenar el Hall of Fame de la aplicación.

Gracias a este componente la información permanece disponible incluso después de reiniciar el Pod.

---

## Rolling Update

Una de las características más importantes implementadas fue la actualización automática de imágenes mediante:

```bash
kubectl set image deployment/cp2-game ...
```

Esto permitió desplegar nuevas versiones sin necesidad de eliminar el Deployment existente.

Durante las pruebas se validaron correctamente múltiples versiones consecutivas (v1, v2, v3...v8), observándose el cambio automático de versión desde la interfaz web.

---

## Captura 9

> **Captura del clúster AKS funcionando.**

![[Pasted image 20260713055625.png]]

![[Pasted image 20260713055656.png]]

---

## Captura 10

> **Captura de los Pods ejecutándose (`kubectl get pods`).**

![[Pasted image 20260713055850.png]]

---

## Captura 11

> **Captura del Service (`kubectl get svc`).**

![[Pasted image 20260713055936.png]]

---

## Captura 12

> **Captura del PersistentVolumeClaim (`kubectl get pvc`).**

![[Pasted image 20260713060054.png]]

---

# 8. Descripción de la aplicación desarrollada

A diferencia de la aplicación desplegada sobre la Máquina Virtual, la solución implementada para Kubernetes fue diseñada específicamente para demostrar conceptos DevOps de una forma interactiva.

La aplicación recibe el nombre de:

# DevOps Deployment Challenge

El objetivo consiste en simular la ejecución de un Pipeline DevOps mediante un pequeño juego.

El usuario debe reconstruir correctamente el orden de las etapas del pipeline para conseguir un despliegue exitoso.

---

## Funcionamiento

Al iniciar la aplicación el usuario debe registrar un nombre.

Cada nombre únicamente puede registrarse una vez.

Posteriormente aparecen cuatro actividades del Pipeline DevOps en un orden aleatorio.

El jugador debe seleccionar cada etapa en el orden correcto.

Cuando las cuatro etapas han sido seleccionadas, se habilita el botón **Ejecutar Deploy**.

La aplicación valida automáticamente el orden elegido.

Si la secuencia es correcta:

- se muestra un despliegue exitoso;
- se incrementa el contador del jugador;
- se actualiza automáticamente el Hall of Fame.

En caso contrario, la aplicación informa cuál era el orden correcto.

---

## Hall of Fame

El Hall of Fame almacena el número total de despliegues exitosos realizados por cada participante.

La información permanece disponible gracias al PersistentVolumeClaim implementado en Kubernetes.

Esto permitió demostrar el funcionamiento del almacenamiento persistente dentro del clúster.

---

## API REST

La aplicación incorpora una pequeña API REST utilizada por el frontend.

Los principales endpoints implementados fueron:

| Método | Endpoint | Función |
|---------|----------|---------|
| GET | /api/ranking | Consulta el Hall of Fame |
| POST | /api/player | Registra nuevos jugadores |
| POST | /api/win | Incrementa el número de despliegues exitosos |

Durante el proceso de despliegue, el script `deploy-aks.sh` valida automáticamente que la API responda correctamente antes de finalizar la ejecución.

---

## Versionado automático

Cada imagen generada incorpora automáticamente el número de versión correspondiente al despliegue.

De esta forma fue posible validar visualmente que cada Rolling Update realmente publicaba una nueva versión de la aplicación.

---

## Captura 13

> **Captura de la pantalla principal del juego.**

![[Pasted image 20260713060202.png]]

---

## Captura 14

> **Insertar captura del Hall of Fame.**

![[Pasted image 20260713060314.png]]

---

## Captura 15

> **Captura mostrando la versión desplegada (v1, v2, v3...).**

![[Pasted image 20260713060922.png]]

![[Pasted image 20260713060855.png]]

---

## Captura 16

> **Captura de la API REST respondiendo correctamente.**

![[Pasted image 20260713060802.png]]


---

# 9. Automatización implementada

Uno de los principales objetivos del proyecto consistió en minimizar la intervención manual durante el ciclo completo de despliegue.

Para lograrlo se desarrollaron dos scripts Bash independientes que automatizan completamente ambos escenarios implementados.

El resultado obtenido fue un proceso repetible, versionado y confiable, alineado con los principios DevOps estudiados durante el diplomado.

---

# 9.1 Script deploy-podman.sh

El script `deploy-podman.sh` automatiza completamente el despliegue de la aplicación sobre la Máquina Virtual Linux.

Su funcionamiento puede resumirse en el siguiente flujo:

```
Leer Terraform

↓

Construir Imagen

↓

Versionar Aplicación

↓

Login Azure Container Registry

↓

Publicar Imagen

↓

Actualizar Variables de Ansible

↓

Ejecutar Playbook

↓

Validar Contenedor

↓

Validar HTTPS

↓

Validar Versión
```

Durante su ejecución el script realiza automáticamente las siguientes actividades:

- Descubre la ubicación del proyecto.
- Lee la IP pública de la VM desde Terraform.
- Obtiene automáticamente las credenciales del Azure Container Registry.
- Construye una nueva imagen Podman.
- Inserta dinámicamente el número de versión.
- Publica la imagen en ACR.
- Actualiza la imagen utilizada por Ansible.
- Ejecuta el Playbook.
- Comprueba la imagen desplegada.
- Valida HTTPS.
- Comprueba que la versión publicada corresponde con la esperada.
- Finaliza mostrando un resumen del despliegue.

Gracias a este proceso fue posible reducir completamente la configuración manual del despliegue.

---

## Captura 17

> **Insertar captura del script `deploy-podman.sh` ejecutándose correctamente.**

![[Pasted image 20260713055055.png]]

---

# 9.2 Script deploy-aks.sh

Para el despliegue sobre Kubernetes se desarrolló un segundo script completamente independiente.

Este script automatiza el ciclo completo Build → Push → Deploy sobre Azure Kubernetes Service.

Su funcionamiento puede resumirse mediante el siguiente flujo:

```
Terraform

↓

Construcción Imagen

↓

Versionado

↓

Push Azure Container Registry

↓

Conexión AKS

↓

Deployment

↓

Rolling Update

↓

Validaciones

↓

Aplicación publicada
```

Durante su ejecución realiza automáticamente:

- Obtención de parámetros desde Terraform.
- Construcción de la imagen.
- Inserción automática del número de versión.
- Publicación en Azure Container Registry.
- Verificación de la imagen publicada.
- Obtención de credenciales del clúster AKS.
- Creación del Deployment durante el primer despliegue.
- Actualización automática del Deployment en despliegues posteriores.
- Rolling Update.
- Verificación de Pods.
- Verificación del Service.
- Verificación del PersistentVolumeClaim.
- Validación HTTP.
- Validación de la API REST.
- Validación del contenido publicado.
- Presentación de un resumen completo del despliegue.

La automatización permitió ejecutar múltiples despliegues consecutivos únicamente modificando el número de versión recibido como parámetro.

---

## Captura 18

> **Captura del script `deploy-aks.sh` finalizando correctamente.**

![[Pasted image 20260713060610.png]]

---

# 10. Hallazgos y soluciones implementadas

Durante el desarrollo del proyecto surgieron diferentes inconvenientes técnicos que requirieron análisis, investigación y ajustes en la solución implementada.

Cada uno de estos hallazgos permitió fortalecer el proyecto y mejorar significativamente la calidad de la automatización obtenida.

---

## Hallazgo 1

### Restricción de regiones en Azure

**Problema**

La suscripción Azure for Students no permitía crear recursos en determinadas regiones debido a políticas institucionales.

**Causa**

Azure Policy restringía las regiones autorizadas para el despliegue.

**Solución**

Se identificó la política aplicada mediante Azure CLI y se modificó la variable de ubicación utilizada por Terraform hacia la región **Chile Central**.

**Resultado**

Terraform logró desplegar correctamente toda la infraestructura.

---

## Hallazgo 2

### Outputs de Terraform no disponibles

**Problema**

Los scripts no obtenían automáticamente la IP pública ni las credenciales del ACR.

**Causa**

Los nuevos outputs agregados al proyecto aún no existían dentro del archivo de estado (`terraform.tfstate`).

**Solución**

Se ejecutó:

```bash
terraform apply -refresh-only
```

para sincronizar el estado sin modificar la infraestructura existente.

**Resultado**

Los scripts comenzaron a obtener automáticamente toda la configuración requerida.

---

## Hallazgo 3

### Login inseguro hacia Azure Container Registry

**Problema**

Inicialmente la contraseña era enviada mediante el parámetro `-p`.

**Causa**

Este mecanismo expone la contraseña dentro del historial de comandos.

**Solución**

Se reemplazó por:

```bash
podman login --password-stdin
```

**Resultado**

Se mejoró la seguridad del proceso de autenticación.

---

## Hallazgo 4

### Rutas absolutas dentro de los scripts

**Problema**

Los scripts dependían del directorio desde donde eran ejecutados.

**Causa**

Las rutas estaban codificadas manualmente.

**Solución**

Se implementó el descubrimiento automático del directorio utilizando:

```bash
BASH_SOURCE
```

**Resultado**

Los scripts pueden ejecutarse desde cualquier ubicación.

---

## Hallazgo 5

### Errores durante la validación HTTP

**Problema**

El proceso de validación fallaba aun cuando la aplicación respondía correctamente.

**Causa**

El archivo Bash contenía caracteres invisibles (tabulaciones) que interrumpían la continuidad del comando `curl`.

**Solución**

Se normalizó completamente el archivo eliminando dichos caracteres.

**Resultado**

Las validaciones comenzaron a funcionar correctamente.

---

## Hallazgo 6

### Versionado manual de la aplicación

**Problema**

Era necesario editar manualmente el número de versión mostrado por la aplicación.

**Causa**

La versión estaba escrita directamente dentro del HTML.

**Solución**

Se implementó un archivo plantilla (`index.template.html`) junto con reemplazo automático mediante `sed`.

**Resultado**

Cada despliegue actualiza automáticamente la versión mostrada.

---

## Hallazgo 7

### Actualización manual del Deployment de Kubernetes

**Problema**

Cada nueva versión obligaba a modificar manualmente el manifiesto YAML.

**Causa**

El Deployment tenía una referencia fija hacia la imagen.

**Solución**

Se implementó:

```bash
kubectl set image
```

para actualizar automáticamente el Deployment.

**Resultado**

Se habilitaron Rolling Updates completamente automáticos.

---

## Hallazgo 8

### Persistencia del Hall of Fame

**Problema**

El Hall of Fame desaparecía al reiniciar el Pod.

**Causa**

Los datos eran almacenados únicamente dentro del sistema de archivos del contenedor.

**Solución**

Se implementó un PersistentVolumeClaim.

**Resultado**

La información permanece disponible incluso después de recrear los Pods.

---

## Hallazgo 9

### Usuarios duplicados

**Problema**

Era posible registrar múltiples jugadores con el mismo nombre.

**Causa**

No existía validación dentro de la API REST.

**Solución**

Se implementó una búsqueda previa antes de registrar un nuevo usuario.

**Resultado**

Cada usuario únicamente puede registrarse una vez.

---

## Hallazgo 10

### Automatización incompleta del despliegue sobre AKS

**Problema**

Inicialmente el despliegue requería ejecutar múltiples comandos manuales.

**Causa**

Las operaciones sobre Kubernetes no estaban integradas en un único flujo.

**Solución**

Se desarrolló el script `deploy-aks.sh`.

**Resultado**

Actualmente el despliegue completo puede ejecutarse mediante un único comando.

---

# Lecciones aprendidas

Durante el desarrollo del proyecto se confirmó que la automatización representa uno de los pilares fundamentales de DevOps.

Cada problema encontrado evidenció la importancia de construir procesos repetibles y verificables, donde las validaciones automáticas permiten detectar errores antes de afectar el entorno productivo.

También se comprobó que Kubernetes ofrece un nivel superior de flexibilidad respecto a un despliegue tradicional sobre una Máquina Virtual, especialmente gracias a características como los Rolling Updates, los Deployments y el almacenamiento persistente.

Finalmente, el uso conjunto de Terraform, Azure, Podman, Ansible y Kubernetes permitió integrar diferentes tecnologías dentro de un único flujo automatizado, acercándose a un escenario muy similar al encontrado en proyectos reales de ingeniería de software.

---

## Captura 19

> **Captura del Hall of Fame persistente después de actualizar la aplicación.**

![[Pasted image 20260713062005.png]]


---

## Captura 20

> **Captura del Rolling Update mostrando la actualización de versión sin interrupciones.**

![[Pasted image 20260713062318.png]]

---

# 11. Resultados obtenidos

El desarrollo del Caso Práctico 2 permitió cumplir satisfactoriamente los objetivos planteados al inicio del proyecto, integrando múltiples tecnologías dentro de una arquitectura completamente automatizada.

A lo largo del desarrollo se implementaron procesos de Infraestructura como Código (IaC), automatización de configuración, construcción de imágenes, despliegue de aplicaciones contenerizadas y orquestación mediante Kubernetes.

El resultado obtenido demuestra que es posible desplegar una misma infraestructura utilizando diferentes estrategias tecnológicas manteniendo un alto nivel de automatización y reduciendo significativamente la intervención manual.

---

## Resultados alcanzados

Durante el proyecto se logró implementar exitosamente:

### Infraestructura

- Creación automática del Resource Group.
- Creación de la red virtual.
- Configuración del Network Security Group.
- Aprovisionamiento automático de la Máquina Virtual Linux.
- Creación automática de Azure Container Registry.
- Creación automática del clúster Azure Kubernetes Service.

---

### Automatización

- Automatización del aprovisionamiento mediante Terraform.
- Automatización del despliegue sobre Podman.
- Automatización del despliegue sobre Kubernetes.
- Automatización del versionado de aplicaciones.
- Automatización del Push hacia Azure Container Registry.
- Automatización del Rolling Update.
- Automatización de las validaciones posteriores al despliegue.

---

### Contenedores

Se desarrollaron dos aplicaciones diferentes.

#### Escenario 1

Servidor Nginx protegido mediante:

- HTTPS
- Certificado SSL
- Autenticación Básica
- Versionado automático

---

#### Escenario 2

Aplicación Flask denominada:

**DevOps Deployment Challenge**

Incluye:

- Registro de jugadores.
- Validación de usuarios.
- Hall of Fame.
- API REST.
- Persistencia mediante PersistentVolumeClaim.
- Rolling Updates automáticos.

---

### Control de versiones

El proyecto fue administrado completamente mediante Git.

Se utilizó GitHub como repositorio remoto para mantener el historial de cambios, permitiendo la trazabilidad de todas las funcionalidades implementadas.

---

## Evidencias de funcionamiento

Durante las pruebas finales se verificó correctamente:

- Creación automática de infraestructura.
- Construcción de imágenes.
- Publicación en Azure Container Registry.
- Despliegue sobre Máquina Virtual.
- Despliegue sobre Azure Kubernetes Service.
- Funcionamiento del servidor HTTPS.
- Funcionamiento de la API REST.
- Persistencia del Hall of Fame.
- Actualización automática de versiones.
- Rolling Updates.
- Validaciones automáticas posteriores al despliegue.

Todos estos resultados fueron comprobados mediante pruebas funcionales y verificaciones automáticas incorporadas dentro de los scripts desarrollados.

---

# 12. Licencia

El presente proyecto utiliza la licencia **MIT License**.

La licencia MIT es una licencia de software libre ampliamente utilizada debido a su simplicidad y flexibilidad.

Permite:

- Uso personal.
- Uso académico.
- Uso comercial.
- Copia del software.
- Modificación.
- Distribución.
- Publicación.

La única condición consiste en conservar el aviso de copyright y el texto de la licencia original en cualquier redistribución del software.

La licencia no ofrece garantías sobre el funcionamiento del software y exime al autor de cualquier responsabilidad derivada de su utilización.

---

# 13. Conclusiones

Terraform demostró ser una herramienta sólida para automatizar completamente el aprovisionamiento de infraestructura, eliminando configuraciones manuales y garantizando la reproducibilidad del entorno.

La implementación de Azure Container Registry permitió centralizar la gestión de imágenes utilizadas por ambos escenarios de despliegue, facilitando el versionamiento y la distribución de las aplicaciones.

El escenario basado en Podman permitió comprender el proceso tradicional de despliegue sobre una Máquina Virtual, mientras que Azure Kubernetes Service evidenció las ventajas de la orquestación moderna de contenedores mediante Deployments, Services y PersistentVolumeClaims.

Uno de los aspectos más relevantes del proyecto fue el desarrollo de dos scripts completamente automatizados (`deploy-podman.sh` y `deploy-aks.sh`), capaces de ejecutar el ciclo completo de construcción, publicación, despliegue y validación utilizando un único comando.

La aplicación **DevOps Deployment Challenge** permitió demostrar de manera práctica conceptos fundamentales como la persistencia de datos, el consumo de una API REST, el versionamiento automático y los Rolling Updates sobre Kubernetes.

Desde una perspectiva personal, este proyecto representó el primer acercamiento práctico a tecnologías como Terraform, Podman, Ansible y Kubernetes. El proceso implicó enfrentar diversos desafíos técnicos cuya resolución fortaleció significativamente la comprensión de los principios DevOps y de las buenas prácticas de automatización.

Más allá de cumplir con los objetivos académicos propuestos, el proyecto dejó una reflexión importante: la automatización no consiste únicamente en reducir tareas repetitivas, sino en construir procesos confiables, reproducibles y mantenibles. Ese cambio de enfoque constituye uno de los aprendizajes más valiosos obtenidos durante el desarrollo del Caso Práctico 2.


---

# 14. Referencias

Ansible Community. (2025). *Ansible Documentation*. https://docs.ansible.com/

HashiCorp. (2025). *Terraform Documentation*. https://developer.hashicorp.com/terraform/docs

Kubernetes Authors. (2025). *Kubernetes Documentation*. https://kubernetes.io/docs/

Microsoft. (2025). *Azure Container Registry Documentation*. https://learn.microsoft.com/azure/container-registry/

Microsoft. (2025). *Azure Kubernetes Service Documentation*. https://learn.microsoft.com/azure/aks/

Microsoft. (2025). *Azure Virtual Machines Documentation*. https://learn.microsoft.com/azure/virtual-machines/

Podman Team. (2025). *Podman Documentation*. https://podman.io/

Python Software Foundation. (2025). *Flask Documentation*. https://flask.palletsprojects.com/

Git Project. (2025). *Git Documentation*. https://git-scm.com/docs

---

# Anexos

## Anexo A. Estructura final del proyecto

```text
cp2/
├── app/
│   ├── podman/
│   └── kubernetes/
├── ansible/
├── docs/
├── scripts/
│   ├── deploy-podman.sh
│   └── deploy-aks.sh
├── terraform/
├── README.md
├── LICENSE
└── .gitignore
```

---

## Anexo B. Scripts desarrollados

Durante el proyecto se desarrollaron los siguientes componentes de automatización:

- `deploy-podman.sh`
- `deploy-aks.sh`
- Playbooks de Ansible.
- Archivos Terraform.
- Manifiestos Kubernetes.
- Dockerfiles para ambos escenarios.

---


---

# Declaración final

Declaro que el presente trabajo corresponde a un desarrollo original realizado para el Caso Práctico 2 del Diplomado de Especialización en DevOps & Cloud de la Universidad Internacional de La Rioja (UNIR).

Las decisiones técnicas, la implementación, las pruebas realizadas y la documentación presentada reflejan el proceso de aprendizaje y la integración de los conocimientos adquiridos durante el diplomado.

---

# Fin del documento