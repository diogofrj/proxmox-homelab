#!/bin/bash
# TODO: Testar esse script
# Verifica se o diretório .kube existe
if [ ! -d "$HOME/.kube" ]; then
    mkdir -p "$HOME/.kube"
fi

# Backup do config atual
if [ -f "$HOME/.kube/config" ]; then
    cp "$HOME/.kube/config" "$HOME/.kube/config.bak.$(date +%Y%m%d_%H%M%S)"
fi

# Lista todos os arquivos de configuração a serem mesclados
configs_to_merge=""
for config in "$@"; do
    if [ -f "$config" ]; then
        configs_to_merge="$configs_to_merge:$config"
    else
        echo "Aviso: Arquivo $config não encontrado"
    fi
done

# Remove o primeiro ':' da string
configs_to_merge=${configs_to_merge#:}

# Realiza o merge
if [ ! -z "$configs_to_merge" ]; then
    KUBECONFIG=$configs_to_merge kubectl config view --flatten > "$HOME/.kube/config.merged"
    mv "$HOME/.kube/config.merged" "$HOME/.kube/config"
    echo "Merge concluído com sucesso!"
else
    echo "Nenhum arquivo válido para merge"
fi