#!/bin/bash

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Diretório base do script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

echo -e "${YELLOW}Verificando e criando estrutura de diretórios...${NC}"

# Criar estrutura de diretórios
mkdir -p "${SCRIPT_DIR}/inventory"
mkdir -p "${SCRIPT_DIR}/files"
mkdir -p "${SCRIPT_DIR}/group_vars"

echo -e "${YELLOW}Verificando pré-requisitos...${NC}"

# Verificar se o Ansible está instalado
if ! command -v ansible &> /dev/null; then
    echo -e "${RED}Ansible não está instalado. Instalando...${NC}"
    sudo apt update
    sudo apt install -y ansible
fi

# Verificar se o arquivo de inventário existe
if [ ! -f "${SCRIPT_DIR}/inventory/hosts" ]; then
    echo -e "${RED}Arquivo de inventário não encontrado!${NC}"
    exit 1
fi

# Verificar se o arquivo de playbook existe
if [ ! -f "${SCRIPT_DIR}/playbook.yml" ]; then
    echo -e "${RED}Arquivo de playbook não encontrado!${NC}"
    exit 1
fi

# Verificar se o arquivo de variáveis existe
if [ ! -f "${SCRIPT_DIR}/group_vars/all.yml" ]; then
    echo -e "${RED}Arquivo de variáveis não encontrado!${NC}"
    exit 1
fi

# Verificar se o arquivo de configuração do HAProxy existe
if [ ! -f "${SCRIPT_DIR}/files/haproxy.cfg" ]; then
    echo -e "${RED}Arquivo de configuração do HAProxy não encontrado!${NC}"
    exit 1
fi

echo -e "${GREEN}Todos os pré-requisitos verificados!${NC}"

# Verificar conectividade com os hosts
echo -e "${YELLOW}Verificando conectividade com os hosts...${NC}"
ansible all -i "${SCRIPT_DIR}/inventory/hosts" -m ping
if [ $? -ne 0 ]; then
    echo -e "${RED}Erro na conectividade com os hosts!${NC}"
    exit 1
fi

# Executar o playbook
echo -e "${YELLOW}Executando o playbook...${NC}"
ansible-playbook -i "${SCRIPT_DIR}/inventory/hosts" "${SCRIPT_DIR}/playbook.yml"

# Verificar se a execução foi bem sucedida
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Playbook executado com sucesso!${NC}"
    
    echo -e "${YELLOW}Configurando kubeconfig local...${NC}"
    mkdir -p ~/.kube
    cp "${SCRIPT_DIR}/files/kubeconfig" ~/.kube/config
    chmod 600 ~/.kube/config
    
    echo -e "${YELLOW}Testando conexão com o cluster...${NC}"
    kubectl get nodes
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Cluster Kubernetes configurado e acessível via HAProxy!${NC}"
    else
        echo -e "${RED}Erro ao acessar o cluster!${NC}"
        exit 1
    fi
else
    echo -e "${RED}Erro na execução do playbook!${NC}"
    exit 1
fi 