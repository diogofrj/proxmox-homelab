# Primeiro, faça login no servidor ArgoCD (substitua os valores conforme necessário)
argocd login <argocd-server> --username <seu-usuario> --password <sua-senha>

# Crie ou atualize o projeto (com a flag --upsert para forçar a atualização se existir)
argocd proj create cloudseek \
  --description "Projeto para aplicações CloudSeek" \
  --dest "https://kubernetes.default.svc,*" \
  --src "https://github.com/diogofrj/proxmox-homelab" \
  --src "https://helm.goharbor.io" \
  --upsert

# Crie a role (com a flag --upsert para sobrescrever se existir)
argocd proj role create cloudseek admin \
  --description "Role com permissões administrativas para o projeto cloudseek" \
  --upsert

# Adicione o grupo admin à role
argocd proj role add-group cloudseek admin admin

# Adicione as políticas de permissão
argocd proj role add-policy cloudseek admin \
  "p, proj:cloudseek:admin, projects, get, cloudseek, allow"

argocd proj role add-policy cloudseek admin \
  "p, proj:cloudseek:admin, applications, *, cloudseek/*, allow"

# Aplique os manifestos YAML da aplicação Harbor diretamente
kubectl apply -f /home/ubuntu/homedash.cloudseek.com.br/proxmox-homelab/argocd/applications/app-harbor.yaml

# Ou alternativamente, se você precisar realmente usar a CLI:
# Primeiro, crie um arquivo valuesFile temporário localmente:
# cp /home/ubuntu/homedash.cloudseek.com.br/proxmox-homelab/argocd/workloads/harbor/harbor-values-chart1-17-0.yaml /tmp/harbor-values.yaml

# Crie a aplicação harbor (com a flag --upsert para atualizar se existe)
# argocd app create harbor \
#   --repo https://helm.goharbor.io \
#   --helm-chart harbor \
#   --revision 1.17.0 \
#   --dest-server https://kubernetes.default.svc \
#   --dest-namespace harbor \
#   --sync-policy automated \
#   --auto-prune \
#   --self-heal \
#   --sync-option CreateNamespace=true \
#   --project cloudseek \
#   --helm-values-file /tmp/harbor-values.yaml \
#   --upsert

# Crie a aplicação ingress (com a flag --upsert para atualizar se existe)
# argocd app create harbor-ingress \
#   --repo https://github.com/diogofrj/proxmox-homelab \
#   --path argocd/workloads/harbor \
#   --directory-include traefik-ingressroute.yaml \
#   --directory-recurse false \
#   --dest-server https://kubernetes.default.svc \
#   --dest-namespace harbor \
#   --sync-policy automated \
#   --auto-prune \
#   --self-heal \
#   --sync-option CreateNamespace=true \
#   --project cloudseek \
#   --upsert

# Sincronize as aplicações
argocd app sync harbor
argocd app sync harbor-ingress

# Obtenha informações sobre as aplicações
argocd app get harbor
argocd app get harbor-ingress
