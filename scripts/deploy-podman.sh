#!/usr/bin/env bash

###############################################################################
# Proyecto : Caso Práctico 2
# Autor    : Daniel Guerrero
#
# Descripción
# -----------
# Automatiza el despliegue completo de la aplicación:
#
#   1. Construye la imagen Podman.
#   2. La etiqueta para Azure Container Registry.
#   3. Obtiene automáticamente las credenciales desde Terraform.
#   4. Realiza login en ACR.
#   5. Publica la imagen.
#   6. Ejecuta el playbook de Ansible.
#   7. Valida el despliegue HTTPS.
###############################################################################

set -Eeuo pipefail

#############################################
# Descubrir rutas del proyecto
#############################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

APP_DIR="${PROJECT_DIR}/app/podman"
ANSIBLE_DIR="${PROJECT_DIR}/ansible"
TF_DIR="${PROJECT_DIR}/terraform"

#############################################
# Configuración
#############################################

IMAGE_NAME="casopractico2"
IMAGE_TAG="${1:-v2}"

APP_USER="unir"
APP_PASSWORD="alumno2026"

#############################################
# Funciones
#############################################

die() {

    echo
    echo "ERROR: $1"
    exit 1

}

check_command() {

    command -v "$1" >/dev/null 2>&1 || die "No se encontró el comando '$1'."

}

#############################################
# Verificaciones
#############################################

check_command terraform
check_command podman
check_command ansible-playbook
check_command curl

[[ -d "$TF_DIR" ]] || die "No existe ${TF_DIR}"

[[ -f "$TF_DIR/terraform.tfstate" ]] || \
die "No existe terraform.tfstate. Ejecute primero Terraform."

#############################################
# Leer outputs de Terraform
#############################################

echo
echo "Leyendo configuración de Terraform..."

#Toda la configuración de Terraform se obtiene en un solo lugar.

VM_IP=$(terraform -chdir="$TF_DIR" output -raw public_ip)

ACR_SERVER=$(terraform -chdir="$TF_DIR" output -raw acr_login_server)
ACR_USERNAME=$(terraform -chdir="$TF_DIR" output -raw acr_admin_username)
ACR_PASSWORD=$(terraform -chdir="$TF_DIR" output -raw acr_admin_password)

APP_URL="https://${VM_IP}:8443"


[[ -n "$ACR_SERVER" ]] || die "No fue posible obtener acr_login_server."

[[ -n "$ACR_USERNAME" ]] || die "No fue posible obtener acr_admin_username."

[[ -n "$ACR_PASSWORD" ]] || die "No fue posible obtener acr_admin_password."

[[ -n "$VM_IP" ]] || die "No fue posible obtener public_ip."


IMAGE="${ACR_SERVER}/${IMAGE_NAME}:${IMAGE_TAG}"

#############################################
# Información
#############################################

echo
echo "========================================================="
echo "        CASO PRÁCTICO 2 - DEPLOY AUTOMATIZADO"
echo "========================================================="

echo "Proyecto : ${PROJECT_DIR}"
echo "Imagen   : ${IMAGE}"
echo "Usuario  : ${ACR_USERNAME}"
echo

#############################################
# Paso 1
#############################################

echo "[1/6] Construyendo imagen..."

cd "$APP_DIR"

#Si alguien borra ese archivo por accidente, el error sera claro.
[[ -f "${APP_DIR}/html/index.template.html" ]] || \
die "No existe html/index.template.html"


cp "${APP_DIR}/html/index.template.html" \
   "${APP_DIR}/html/index.html"


#si alguien modifica la plantilla y elimina el marcador, el script lo detectará inmediatamente.
if ! grep -q "__VERSION__" "${APP_DIR}/html/index.template.html"; then
    die "La plantilla no contiene el marcador __VERSION__."
fi

sed -i \
"s/__VERSION__/${IMAGE_TAG}/g" \
"${APP_DIR}/html/index.html"

#comprobar template y problemas con el reemplazo.
grep -q "${IMAGE_TAG}" "${APP_DIR}/html/index.html" \
|| die "No fue posible insertar la versión ${IMAGE_TAG} en index.html."

podman build \
--no-cache \
-t "${IMAGE_NAME}:${IMAGE_TAG}" \
.

#Comprobar que el build realmente terminó
podman image exists "${IMAGE_NAME}:${IMAGE_TAG}" \
|| die "La imagen no fue creada correctamente."

#############################################
# Paso 2
#############################################

echo
echo "[2/6] Etiquetando imagen..."

podman tag \
"${IMAGE_NAME}:${IMAGE_TAG}" \
"${IMAGE}"

#############################################
# Paso 3
#############################################

echo
echo "[3/6] Login en Azure Container Registry..."

#Ocultar la contraseña del login
echo "${ACR_PASSWORD}" | podman login \
"${ACR_SERVER}" \
-u "${ACR_USERNAME}" \
--password-stdin

#############################################
# Paso 4
#############################################

echo
echo "[4/6] Publicando imagen..."

podman push "${IMAGE}"

echo
echo "Verificando publicación en ACR..."

az acr repository show-tags \
    --name "${ACR_USERNAME}" \
    --repository "${IMAGE_NAME}" \
    --output table

#############################################
# Paso 5
#############################################

echo
echo "[5/6] Ejecutando Ansible..."

cd "$ANSIBLE_DIR"

echo
echo "Actualizando versión de la imagen en Ansible..."

sed -i \
"s|^container_image:.*|container_image: ${IMAGE}|" \
"${ANSIBLE_DIR}/group_vars/all.yml"

ansible-playbook playbooks/site.yml


echo
echo "Validando imagen desplegada..."

#si falla SSH, el error sera mas claro.
CONTAINER_IMAGE=$(ssh \
-o ConnectTimeout=5 \
-o BatchMode=yes \
azureuser@"${VM_IP}" \
"podman inspect casopractico2 --format '{{.ImageName}}'") \
|| die "No fue posible consultar la imagen desplegada por SSH."


echo "Imagen en ejecución: ${CONTAINER_IMAGE}"

echo "Versión esperada : ${IMAGE_TAG}"


if [[ "${CONTAINER_IMAGE}" != *":${IMAGE_TAG}" ]]; then

    echo
    echo "ERROR: El contenedor no está ejecutando la versión ${IMAGE_TAG}"
    exit 1

fi

#############################################
# Paso 6
#############################################

#Esperará hasta 24 segundos como máximo y continuará apenas la aplicación responda.

echo
echo "[6/6]Esperando que la aplicación esté disponible..."

#printf 'VM_IP  = <%q>\n' "$VM_IP"
#printf 'APP_URL= <%q>\n' "$APP_URL"

for i in {1..12}; do

    HTTP_CODE=$(curl \
        --connect-timeout 2 \
        --max-time 3 \
        -k \
        -u "${APP_USER}:${APP_PASSWORD}" \
        -o /dev/null \
        -s \
        -w "%{http_code}" \
        "${APP_URL}" || true)

    [[ "$HTTP_CODE" == "200" ]] && break

    sleep 2

done


CONTENT=$(curl \
--connect-timeout 5 \
--max-time 10 \
-k \
-u "${APP_USER}:${APP_PASSWORD}" \
-s \
"${APP_URL}")


#Valida versiones
if [[ "$HTTP_CODE" != "200" ]]; then

    echo "ERROR: HTTP ${HTTP_CODE}"
    exit 1

fi

if ! grep -q "${IMAGE_TAG}" <<< "$CONTENT"; then

    echo "ERROR: la versión ${IMAGE_TAG} no fue encontrada."
    exit 1

fi

echo
echo "=============================================="
echo "DEPLOY FINALIZADO CORRECTAMENTE"
echo "=============================================="
echo "Imagen   : ${IMAGE}"
echo "Versión  : ${IMAGE_TAG}"
echo "Servidor : ${VM_IP}"
echo "HTTPS    : OK"
echo "URL HTTP : http://${VM_IP}:8080"
echo "URL HTTPS: https://${VM_IP}:8443"
echo "=============================================="

