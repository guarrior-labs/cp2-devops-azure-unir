#!/usr/bin/env bash

###############################################################################
# Proyecto : Caso Práctico 2
# Autor    : Daniel Guerrero
#
# Descripción
# -----------
# Automatiza el despliegue completo de la aplicación en Azure Kubernetes
# Service (AKS).
#
# Flujo:
#
#   1. Lee automáticamente la configuración desde Terraform.
#   2. Construye la imagen Podman.
#   3. Publica la imagen en Azure Container Registry.
#   4. Obtiene las credenciales del clúster AKS.
#   5. Actualiza automáticamente el Deployment.
#   6. Despliega la aplicación.
#   7. Valida el estado del clúster.
#   8. Valida la aplicación publicada.
#
###############################################################################
START_TIME=$(date +%s)

set -Eeuo pipefail

#############################################
# Descubrir rutas
#############################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

APP_DIR="${PROJECT_DIR}/app/kubernetes"
K8S_DIR="${APP_DIR}/manifests"
TF_DIR="${PROJECT_DIR}/terraform"

#############################################
# Configuración
#############################################

IMAGE_NAME="casopractico2-game"
IMAGE_TAG="${1:-v1}"

#############################################
# Funciones
#############################################

die() {

    echo
    echo "ERROR: $1"
    exit 1

}

check_command() {

    command -v "$1" >/dev/null 2>&1 \
    || die "No se encontró el comando '$1'."

}

#############################################
# Verificaciones
#############################################

check_command terraform
check_command az
check_command kubectl
check_command podman
check_command curl

[[ -d "$APP_DIR" ]] \
|| die "No existe ${APP_DIR}"

[[ -d "$K8S_DIR" ]] \
|| die "No existe ${K8S_DIR}"

[[ -d "$TF_DIR" ]] \
|| die "No existe ${TF_DIR}"

#############################################
# Leer outputs de Terraform
#############################################

echo
echo "Leyendo configuración de Terraform..."

RESOURCE_GROUP=$(terraform \
-chdir="$TF_DIR" \
output \
-raw resource_group_name)

AKS_NAME=$(terraform \
-chdir="$TF_DIR" \
output \
-raw aks_name)

ACR_SERVER=$(terraform \
-chdir="$TF_DIR" \
output \
-raw acr_login_server)

ACR_USERNAME=$(terraform \
-chdir="$TF_DIR" \
output \
-raw acr_admin_username)

ACR_PASSWORD=$(terraform \
-chdir="$TF_DIR" \
output \
-raw acr_admin_password)

IMAGE="${ACR_SERVER}/${IMAGE_NAME}:${IMAGE_TAG}"

#############################################
# Validaciones
#############################################

[[ -n "$RESOURCE_GROUP" ]] \
|| die "No fue posible obtener resource_group_name."

[[ -n "$AKS_NAME" ]] \
|| die "No fue posible obtener aks_name."

[[ -n "$ACR_SERVER" ]] \
|| die "No fue posible obtener acr_login_server."

[[ -n "$ACR_USERNAME" ]] \
|| die "No fue posible obtener acr_admin_username."

[[ -n "$ACR_PASSWORD" ]] \
|| die "No fue posible obtener acr_admin_password."

#############################################
# Información
#############################################

echo
echo "========================================================="
echo "        CASO PRÁCTICO 2 - DEPLOY AKS"
echo "========================================================="

echo "Proyecto        : ${PROJECT_DIR}"
echo "AKS             : ${AKS_NAME}"
echo "Resource Group  : ${RESOURCE_GROUP}"
echo "ACR             : ${ACR_SERVER}"
echo "Imagen          : ${IMAGE}"
echo

#############################################
# Paso 1
#############################################

echo "[1/8] Construyendo imagen..."

cd "$APP_DIR"

#Si alguien borra ese archivo por accidente, el error sera claro.
[[ -f "${APP_DIR}/templates/index.template.html" ]] || \
die "No existe template/index.template.html"

cp "${APP_DIR}/templates/index.template.html" \
   "${APP_DIR}/templates/index.html"

#si alguien modifica la plantilla y elimina el marcador, el script lo detectará inmediatamente.
if ! grep -q "__VERSION__" "${APP_DIR}/templates/index.template.html"; then
    die "La plantilla no contiene el marcador __VERSION__."
fi

sed -i \
"s/__VERSION__/${IMAGE_TAG}/g" \
"${APP_DIR}/templates/index.html"

echo
echo "Versión insertada en index.html: ${IMAGE_TAG}"

#comprobar template y problemas con el reemplazo.
grep -q "${IMAGE_TAG}" "${APP_DIR}/templates/index.html" \
|| die "No fue posible insertar la versión ${IMAGE_TAG} en index.html."

podman build \
--no-cache \
-t "${IMAGE_NAME}:${IMAGE_TAG}" \
.

podman image exists \
"${IMAGE_NAME}:${IMAGE_TAG}" \
|| die "La imagen no fue creada."

#############################################
# Paso 2
#############################################

echo
echo "[2/8] Etiquetando imagen..."

podman tag \
"${IMAGE_NAME}:${IMAGE_TAG}" \
"${IMAGE}"

#############################################
# Paso 3
#############################################

echo
echo "[3/8] Login en Azure Container Registry..."

echo "${ACR_PASSWORD}" | podman login \
"${ACR_SERVER}" \
-u "${ACR_USERNAME}" \
--password-stdin

#############################################
# Paso 4
#############################################

echo
echo "[4/8] Publicando imagen..."

podman push "${IMAGE}"
#verificar que la imagen fue publicada correctamente.
echo
echo "Imagen publicada correctamente:"
echo "${IMAGE}"

echo
echo "Verificando publicación en ACR..."

az acr repository show-tags \
--name "${ACR_USERNAME}" \
--repository "${IMAGE_NAME}" \
--output tsv \
| grep -Fxq "${IMAGE_TAG}" \
|| die "La imagen ${IMAGE_TAG} no fue encontrada en Azure Container Registry."

#############################################
# Paso 5
#############################################

echo
echo "[5/8] Obteniendo credenciales del clúster AKS..."

az aks get-credentials \
--resource-group "${RESOURCE_GROUP}" \
--name "${AKS_NAME}" \
--overwrite-existing

echo
echo "Conexión establecida con AKS."

kubectl cluster-info

echo
kubectl get nodes

#############################################
# Paso 6
#############################################

echo
echo "[6/8] Desplegando aplicación..."

echo
echo "Aplicando PersistentVolumeClaim..."
kubectl apply \
-f "${K8S_DIR}/pvc.yaml"

[[ -f "${K8S_DIR}/deployment.yaml" ]] \
|| die "No existe deployment.yaml"

if kubectl get deployment cp2-game >/dev/null 2>&1; then

    echo
    echo "Deployment existente. Actualizando imagen..."

    kubectl set image \
    deployment/cp2-game \
    cp2-game="${IMAGE}"

else

    echo
    echo "Primer despliegue. Creando Deployment..."

    kubectl apply \
    -f "${K8S_DIR}/deployment.yaml"

fi

echo
echo "Aplicando Service..."
kubectl apply \
-f "${K8S_DIR}/service.yaml"

echo
echo "Esperando rollout..."

kubectl rollout status \
deployment/cp2-game \
--timeout=300s

#Comprobar que el Deployment tiene al menos una réplica disponible.
AVAILABLE=$(kubectl get deployment cp2-game \
-o jsonpath='{.status.availableReplicas}')

[[ "${AVAILABLE}" == "1" ]] \
|| die "El Deployment no tiene réplicas disponibles."

echo
echo "Imagen desplegada:"

kubectl get deployment cp2-game \
-o jsonpath='{.spec.template.spec.containers[0].image}'

echo

#############################################
# Paso 7
#############################################

echo
echo "[7/8] Verificando recursos..."

echo
kubectl get pods

echo
kubectl get pvc

echo
kubectl get svc

#############################################
# Paso 8
#############################################

echo
echo "[8/8] Validando aplicación..."

echo
echo "Esperando IP pública..."

EXTERNAL_IP=""

for i in {1..60}; do

    EXTERNAL_IP=$(
        kubectl get svc cp2-game-service \
        -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
    )

    if [[ -n "${EXTERNAL_IP}" ]]; then

        break

    fi

    printf "."

    sleep 5

done

echo

[[ -n "${EXTERNAL_IP}" ]] \
|| die "Azure no asignó una IP pública."

echo
echo "IP pública asignada: ${EXTERNAL_IP}"

echo
echo "Esperando que la aplicación responda..."

HTTP_CODE=""

for i in {1..30}; do

    HTTP_CODE=$(curl \
        --connect-timeout 3 \
        --max-time 5 \
        -o /dev/null \
        -s \
        -w "%{http_code}" \
        "http://${EXTERNAL_IP}" || true)

    [[ "${HTTP_CODE}" == "200" ]] && break

    sleep 5

done

API_CODE=$(curl \
--connect-timeout 3 \
--max-time 5 \
-o /dev/null \
-s \
-w "%{http_code}" \
"http://${EXTERNAL_IP}/api/ranking")

[[ "$API_CODE" == "200" ]] \
|| die "La API REST respondió HTTP ${API_CODE}"

API_CONTENT=$(curl -s \
"http://${EXTERNAL_IP}/api/ranking")

grep -q "\"user\"" <<< "${API_CONTENT}" \
|| die "La API REST devolvió un JSON inesperado."

#############################################
# Validación final
#############################################

if [[ "${HTTP_CODE}" != "200" ]]; then

    echo
    echo "ERROR: la aplicación respondió HTTP ${HTTP_CODE}"

    exit 1

fi

CONTENT=$(curl \
-s \
"http://${EXTERNAL_IP}")

if ! grep -q "${IMAGE_TAG}" <<< "${CONTENT}"; then

    die "La versión ${IMAGE_TAG} no fue encontrada."

fi

#############################################
# Información adicional
#############################################

echo
echo "Recursos del Deployment"

kubectl get deployment cp2-game

echo
echo "Recursos del Pod"

kubectl get pods -l app=cp2-game

echo
echo "Storage"

kubectl get pvc hall-of-fame-pvc

kubectl get svc 
#############################################
# Resumen
#############################################

echo
echo "==============================================================="
echo "              DEPLOY FINALIZADO CORRECTAMENTE"
echo "==============================================================="
echo

echo "AKS             : ${AKS_NAME}"
echo "Resource Group  : ${RESOURCE_GROUP}"
echo "ACR             : ${ACR_SERVER}"

echo
echo "Deployment      : cp2-game"
echo "Service         : cp2-game-service"
echo "PVC             : hall-of-fame-pvc"

echo
NAMESPACE=$(kubectl config view \
--minify \
-o jsonpath='{..namespace}')
NAMESPACE=${NAMESPACE:-default}
echo "Namespace       : ${NAMESPACE}"
echo "Imagen          : ${IMAGE}"
echo "Versión         : ${IMAGE_TAG}"
echo "IP Pública      : ${EXTERNAL_IP}"

echo
echo "Pod             : $(kubectl get pods -l app=cp2-game --no-headers | awk '{print $1}')"

POD_STATUS=$(kubectl get pods \
-l app=cp2-game \
-o jsonpath='{.items[0].status.phase}')

echo "Estado          : ${POD_STATUS}"

echo "HTTP            : ${HTTP_CODE}"
echo "API REST        : OK"

echo
echo "URL"
echo "---------------------------------------------------------------"
echo "http://${EXTERNAL_IP}"
echo "API REST: http://${EXTERNAL_IP}/api/ranking"

echo
echo "Hall of Fame persistente : SI"

echo
echo "==============================================================="

END_TIME=$(date +%s)

echo
echo "Tiempo total : $((END_TIME-START_TIME)) segundos"