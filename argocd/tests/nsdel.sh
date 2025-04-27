#!/bin/bash

# Script para remover de forma forçada um namespace e todos os seus recursos vinculados
# Uso: ./nsdel.sh 'nome do namespace'

set -e

# Se nenhum argumento for fornecido, mostrar informações do cluster e namespaces disponíveis
if [ $# -ne 1 ]; then
  echo "Uso: $0 <nome-do-namespace>"
  echo ""
  echo "=== Informações do Cluster ==="
  kubectl cluster-info
  echo ""
  echo "=== Namespaces Disponíveis ==="
  kubectl get namespaces
  exit 1
fi

NAMESPACE=$1

# Exibir informações do cluster
echo "=== Informações do Cluster ==="
kubectl cluster-info
echo ""

# Listar todas as namespaces
echo "=== Namespaces Disponíveis ==="
kubectl get namespaces
echo ""

# Verificar se o namespace existe
if ! kubectl get namespace "$NAMESPACE" &>/dev/null; then
  echo "Erro: Namespace '$NAMESPACE' não encontrado!"
  exit 1
fi

# Pedir confirmação
echo -e "\033[31mATENÇÃO: Você está prestes a excluir o namespace '$NAMESPACE' e TODOS os seus recursos!\033[0m"
echo -e "\033[31mEsta ação é IRREVERSÍVEL!\033[0m"
read -p "Digite 'sim' para confirmar a exclusão: " CONFIRM

if [ "$CONFIRM" != "sim" ]; then
  echo "Operação cancelada."
  exit 0
fi

echo "Iniciando remoção forçada do namespace '$NAMESPACE'..."

# Remover recursos específicos primeiro
echo "Removendo ingressroutes..."
kubectl delete ingressroute --all -n "$NAMESPACE" --force --grace-period=0 || true

# Remover finalizers do namespace
echo "Removendo finalizers do namespace..."
kubectl patch namespace "$NAMESPACE" -p '{"metadata":{"finalizers":[]}}' --type=merge || true

# Verificar se o namespace ainda existe
if kubectl get namespace "$NAMESPACE" &>/dev/null; then
  echo "Namespace ainda existe, aplicando método de remoção forçada..."
  kubectl get namespace "$NAMESPACE" -o json | jq '.spec.finalizers = []' | kubectl replace --raw "/api/v1/namespaces/$NAMESPACE/finalize" -f - || true
  kubectl delete namespace "$NAMESPACE" --force --grace-period=0 || true
fi

# Tentar excluir o namespace normalmente
echo "Tentando excluir o namespace..."
kubectl delete namespace "$NAMESPACE" --force --grace-period=0 || true





# Verificar novamente
if kubectl get namespace "$NAMESPACE" &>/dev/null; then
  echo "FALHA: Não foi possível remover o namespace '$NAMESPACE'."
  exit 1
else
  echo "SUCESSO: Namespace '$NAMESPACE' removido com sucesso!"
fi
