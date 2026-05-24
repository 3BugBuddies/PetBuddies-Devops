#!/bin/bash
# PetBuddies — Deploy Azure CLI
# Uso: bash azure-deploy.sh
# Pré-requisito: az login já executado

set -e

# ── Variáveis ────────────────────────────────────────────────────────────────
RESOURCE_GROUP="petbuddies-rg"
LOCATION="brazilsouth"
VM_NAME="vm-petbuddies"
VM_SIZE="Standard_B4ms"        # 4 vCPUs / 16 GB — mínimo para Oracle XE + 3 apps
VNET_NAME="vnet-petbuddies"
NSG_NAME="nsg-petbuddies"
PUBLIC_IP_NAME="pip-petbuddies"
VM_USER="petbuddies"
VM_PASSWORD="PetBuddies@2026"
REPO_URL="https://github.com/3BugBuddies/PetBuddies-Devops.git"

# ── Cabeçalho ────────────────────────────────────────────────────────────────
echo "***********************************************"
echo "  PetBuddies — Provisionamento Azure CLI"
echo "***********************************************"
echo ""

# ── 1. Resource group ────────────────────────────────────────────────────────
echo "[1/4] Criando resource group..."
az group create \
  --name "$RESOURCE_GROUP" \
  --location "$LOCATION"

echo ""
echo "Informações do resource group criado:"
az group show -n "$RESOURCE_GROUP" \
  --query "{Nome:name, Localizacao:location}" \
  --output table
echo ""

# ── 2. VM Ubuntu 22.04 (usuário sem privilégios root) ────────────────────────
echo "[2/4] Criando VM..."
az vm create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VM_NAME" \
  --image Ubuntu2204 \
  --size "$VM_SIZE" \
  --authentication-type password \
  --admin-username "$VM_USER" \
  --admin-password "$VM_PASSWORD" \
  --vnet-name "$VNET_NAME" \
  --nsg "$NSG_NAME" \
  --public-ip-address "$PUBLIC_IP_NAME" \
  --output table
echo ""

# ── 3. Abrir portas ──────────────────────────────────────────────────────────
echo "[3/4] Abrindo portas..."
az vm open-port --resource-group "$RESOURCE_GROUP" --name "$VM_NAME" --port 22   --priority 100
az vm open-port --resource-group "$RESOURCE_GROUP" --name "$VM_NAME" --port 8080 --priority 110  # Java
az vm open-port --resource-group "$RESOURCE_GROUP" --name "$VM_NAME" --port 5000 --priority 120  # .NET
az vm open-port --resource-group "$RESOURCE_GROUP" --name "$VM_NAME" --port 8081 --priority 130  # Evolution API
echo ""

# ── 4. Instalar Docker e Git ─────────────────────────────────────────────────
echo "[4/4] Instalando Docker e Git na VM..."
az vm run-command invoke \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VM_NAME" \
  --command-id RunShellScript \
  --scripts "
    sudo apt-get update -y
    sudo apt-get install -y git curl nano
    curl -fsSL https://get.docker.com | sudo sh
    sudo usermod -aG docker $VM_USER
    sudo systemctl enable docker
    sudo systemctl start docker
  "

echo ""
echo "Infraestrutura pronta!"
IP=$(az vm show -d --resource-group "$RESOURCE_GROUP" --name "$VM_NAME" --query publicIps -o tsv)
echo "IP público da VM: $IP"
echo ""
echo "Próximos passos (executar via SSH):"
echo "  ssh $VM_USER@$IP   (senha: $VM_PASSWORD)"
echo "  git clone $REPO_URL petbuddies && cd petbuddies"
echo "  cp .env.example .env && nano .env   # preencher credenciais"
echo "  docker compose up -d --build"
echo ""
echo "LEMBRETE: ao finalizar a entrega, delete a VM obrigatoriamente:"
echo "  az group delete --name $RESOURCE_GROUP --yes --no-wait"
