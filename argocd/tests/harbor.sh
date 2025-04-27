#!/bin/bash
# Script para configurar e testar o Harbor como registry de imagens Docker
# CloudSeek - 2025

# Configurações
HARBOR_URL="harbor.cloudseek.com.br"
HARBOR_USERNAME="admin"
HARBOR_PASSWORD="Harbor12345"
PROJETO="cloudseek"
IMAGEM="teste-nginx"
TAG="latest"

echo "===== Passo a Passo para utilizar o Harbor como Registry Docker ====="
echo ""

# Passo 1: Verificar se o Harbor está acessível
echo "Passo 1: Verificando conectividade com o Harbor..."
if curl -k -s -o /dev/null -w "%{http_code}" "https://${HARBOR_URL}" | grep -q "200"; then
    echo "✅ Harbor está acessível em https://${HARBOR_URL}"
else
    echo "❌ Harbor não está acessível. Verifique se a aplicação está rodando e o ingress está configurado."
    exit 1
fi

# Passo 2: Login no Harbor
echo ""
echo "Passo 2: Fazendo login no Harbor..."
docker logout "https://${HARBOR_URL}" &>/dev/null
if docker login "https://${HARBOR_URL}" -u "${HARBOR_USERNAME}" -p "${HARBOR_PASSWORD}"; then
    echo "✅ Login no Harbor realizado com sucesso"
else
    echo "❌ Falha ao fazer login no Harbor. Verifique as credenciais."
    exit 1
fi

# Passo 3: Criar um projeto no Harbor (via API)
echo ""
echo "Passo 3: Criando projeto '${PROJETO}' no Harbor (se não existir)..."
projeto_existe=$(curl -k -s -u "${HARBOR_USERNAME}:${HARBOR_PASSWORD}" "https://${HARBOR_URL}/api/v2.0/projects?name=${PROJETO}" | grep -c "project_id")

if [ "$projeto_existe" -eq 0 ]; then
    curl -k -X POST -H "Content-Type: application/json" -u "${HARBOR_USERNAME}:${HARBOR_PASSWORD}" \
        "https://${HARBOR_URL}/api/v2.0/projects" \
        -d "{\"project_name\":\"${PROJETO}\", \"public\":false}" &>/dev/null
    
    if [ $? -eq 0 ]; then
        echo "✅ Projeto ${PROJETO} criado com sucesso"
    else
        echo "❌ Falha ao criar o projeto ${PROJETO}"
        exit 1
    fi
else
    echo "✅ Projeto ${PROJETO} já existe"
fi

# Passo 4: Construir a imagem de teste usando os arquivos fornecidos
echo ""
echo "Passo 4: Construindo imagem de teste..."
cd /home/ubuntu/homedash.cloudseek.com.br/proxmox-homelab/argocd/workloads/harbor
docker build -t "${HARBOR_URL}/${PROJETO}/${IMAGEM}:${TAG}" .

if [ $? -eq 0 ]; then
    echo "✅ Imagem construída com sucesso: ${HARBOR_URL}/${PROJETO}/${IMAGEM}:${TAG}"
else
    echo "❌ Falha ao construir a imagem Docker"
    exit 1
fi

# Passo 5: Enviar a imagem para o Harbor
echo ""
echo "Passo 5: Enviando imagem para o Harbor..."
if docker push "${HARBOR_URL}/${PROJETO}/${IMAGEM}:${TAG}"; then
    echo "✅ Imagem enviada com sucesso para ${HARBOR_URL}/${PROJETO}/${IMAGEM}:${TAG}"
else
    echo "❌ Falha ao enviar a imagem para o Harbor"
    echo "   Dica: Verifique se você adicionou o certificado do Harbor no Docker ou configurou como inseguro"
    exit 1
fi

# Passo 6: Verificar se a imagem está no Harbor
echo ""
echo "Passo 6: Verificando se a imagem está disponível no Harbor..."
imagem_existe=$(curl -k -s -u "${HARBOR_USERNAME}:${HARBOR_PASSWORD}" \
    "https://${HARBOR_URL}/api/v2.0/projects/${PROJETO}/repositories/${IMAGEM}/artifacts" | grep -c "${TAG}")

if [ "$imagem_existe" -gt 0 ]; then
    echo "✅ Imagem encontrada no Harbor"
else
    echo "❌ Imagem não encontrada no Harbor"
    exit 1
fi

# Passo 7: Testar o download da imagem
echo ""
echo "Passo 7: Testando o download da imagem..."
docker rmi "${HARBOR_URL}/${PROJETO}/${IMAGEM}:${TAG}" &>/dev/null
if docker pull "${HARBOR_URL}/${PROJETO}/${IMAGEM}:${TAG}"; then
    echo "✅ Imagem baixada com sucesso do Harbor"
else
    echo "❌ Falha ao baixar a imagem do Harbor"
    exit 1
fi

# Passo 8: Configurar o Kubernetes para usar o Harbor como registry
# echo ""
# echo "Passo 8: Configurando o Kubernetes para usar o Harbor como registry..."
# kubectl create namespace teste-harbor 2>/dev/null || true
# kubens teste-harbor || true

# # Gerar o secret para autenticação no registry diretamente (sem depender do docker config)
# echo "Criando secret para autenticação no Harbor..."
# auth_string=$(echo -n "${HARBOR_USERNAME}:${HARBOR_PASSWORD}" | base64)
# docker_config="{\"auths\":{\"${HARBOR_URL}\":{\"username\":\"${HARBOR_USERNAME}\",\"password\":\"${HARBOR_PASSWORD}\",\"auth\":\"${auth_string}\"}}}"
# docker_config_base64=$(echo -n "$docker_config" | base64 -w 0)

# cat <<EOF > /tmp/harbor-secret.yaml
# apiVersion: v1
# kind: Secret
# metadata:
#   name: harbor-registry-secret
#   namespace: teste-harbor
# type: kubernetes.io/dockerconfigjson
# data:
#   .dockerconfigjson: ${docker_config_base64}
# EOF

# if kubectl apply -f /tmp/harbor-secret.yaml; then
#     echo "✅ Secret para autenticação no Harbor criado com sucesso"
# else
#     echo "❌ Falha ao criar secret para autenticação no Harbor"
#     exit 1
# fi

# # Passo 9: Criar um pod de teste usando a imagem pública do nginx
# echo ""
# echo "Passo 9: Criando um pod de teste usando a imagem do Harbor..."
# cat <<EOF > /tmp/teste-harbor-pod.yaml
# apiVersion: v1
# kind: Pod
# metadata:
#   name: teste-harbor-nginx
#   namespace: teste-harbor
# spec:
#   containers:
#   - name: nginx
#     image: ${HARBOR_URL}/${PROJETO}/${IMAGEM}:${TAG}
#     ports:
#     - containerPort: 80
#   imagePullSecrets:
#   - name: harbor-registry-secret
# EOF

# if kubectl apply -f /tmp/teste-harbor-pod.yaml; then
#     echo "✅ Pod de teste criado com sucesso"
# else
#     echo "❌ Falha ao criar o pod de teste"
#     exit 1
# fi

# # Passo 10: Verificar se o pod está rodando
# echo ""
# echo "Passo 10: Verificando se o pod está rodando..."
# sleep 5
# pod_status=$(kubectl get pod teste-harbor-nginx -n teste-harbor -o jsonpath='{.status.phase}')

# if [ "$pod_status" == "Running" ]; then
#     echo "✅ Pod está rodando com sucesso"
    
#     # Porta-forward para testar o acesso à aplicação
#     echo ""
#     echo "Acessando a aplicação via port-forward..."
#     echo "Pressione Ctrl+C para encerrar o port-forward quando terminar"
#     echo "Acesse http://localhost:8080 no seu navegador para ver a página de teste"
#     kubectl port-forward pod/teste-harbor-nginx -n teste-harbor 8080:80
# else
#     echo "❌ Pod não está rodando corretamente. Status: $pod_status"
#     echo "Verificando eventos do pod:"
#     kubectl describe pod teste-harbor-nginx -n teste-harbor
#     exit 1
# fi

# echo ""
# echo "===== Teste do Harbor como Registry Docker Completo ====="
# echo ""
# echo "Resumo:"
# echo "- Harbor URL: https://${HARBOR_URL}"
# echo "- Projeto: ${PROJETO}"
# echo "- Imagem: ${IMAGEM}:${TAG}"
# echo "- Caminho completo: ${HARBOR_URL}/${PROJETO}/${IMAGEM}:${TAG}"
# echo ""
# echo "Dicas para uso contínuo:"
# echo "1. Para adicionar o Harbor como registro inseguro no Docker (ambiente de desenvolvimento):"
# echo "   Edite /etc/docker/daemon.json e adicione:"
# echo "   {\"insecure-registries\":[\"${HARBOR_URL}\"]}"
# echo ""
# echo "2. Para adicionar o certificado do Harbor como confiável (produção):"
# echo "   curl -k https://${HARBOR_URL}/api/v2.0/systeminfo/getcert > harbor.crt"
# echo "   sudo cp harbor.crt /usr/local/share/ca-certificates/"
# echo "   sudo update-ca-certificates"
# echo "   systemctl restart docker"
# echo ""
# echo "3. Para usar no Kubernetes, sempre inclua o imagePullSecret:"
# echo "   imagePullSecrets:"
# echo "   - name: harbor-registry-secret"
