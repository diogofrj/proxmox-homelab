# Configuração do Cluster Kubernetes com Ansible

Este diretório contém os playbooks e configurações Ansible para implantar um cluster Kubernetes multi-master com HAProxy e MetalLB.

## Estrutura do Diretório

```
ansible/
├── files/                  # Arquivos de configuração
│   ├── haproxy.cfg        # Configuração do HAProxy
│   └── kubeconfig         # Arquivo kubeconfig gerado
├── group_vars/            # Variáveis globais
│   └── all.yml           # Configurações gerais do cluster
├── inventory/             # Inventário Ansible
│   └── hosts             # Definição dos hosts
├── playbook.yml          # Playbook principal
├── README.md             # Esta documentação
└── run.sh               # Script de execução
```

## Configuração dos Hosts

O arquivo `inventory/hosts` deve conter:

```ini
[haproxy]
192.168.31.27 ansible_user=ubuntu

[master]
192.168.31.21 ansible_user=ubuntu
192.168.31.22 ansible_user=ubuntu
192.168.31.23 ansible_user=ubuntu

[worker]
192.168.31.24 ansible_user=ubuntu
192.168.31.25 ansible_user=ubuntu
192.168.31.26 ansible_user=ubuntu
```

## Variáveis Globais

Em `group_vars/all.yml`:

```yaml
k8s_version: "1.31.0"
pod_network_cidr: "10.244.0.0/16"
metallb_ip_range: "192.168.31.3-192.168.31.15"
```

## Componentes Instalados

1. **HAProxy**
   - Load balancer para os masters
   - Endpoint: 192.168.31.27:6443
   - Configuração: `files/haproxy.cfg`

2. **Kubernetes**
   - Versão: 1.31.0
   - Multi-master (3 nodes)
   - 3 workers

3. **Calico CNI**
   - Rede de pods
   - CIDR: 10.244.0.0/16

4. **MetalLB**
   - Load balancer para serviços
   - Range: 192.168.31.3-192.168.31.15
   - Modo: L2

## Execução

1. Verifique as configurações:
   ```bash
   # Ajuste o inventário
   vim inventory/hosts

   # Ajuste as variáveis
   vim group_vars/all.yml
   ```

2. Execute o script:
   ```bash
   ./run.sh
   ```

O script irá:
1. Verificar pré-requisitos
2. Testar conectividade
3. Executar o playbook
4. Configurar kubeconfig local

## Verificação

Após a execução:

```bash
# Verificar nodes
kubectl get nodes

# Verificar pods
kubectl get pods -A

# Verificar MetalLB
kubectl get pods -n metallb-system
```

## Troubleshooting

### HAProxy
- Logs: `journalctl -xeu haproxy.service`
- Config: `cat /etc/haproxy/haproxy.cfg`
- Status: `systemctl status haproxy`

### Kubernetes
- Logs master: `journalctl -xeu kubelet`
- Certificados: `/etc/kubernetes/pki/`
- Kubeconfig: `~/.kube/config`

### MetalLB
- Logs: `kubectl logs -n metallb-system -l app=metallb`
- Config: `kubectl get ipaddresspool -n metallb-system`

## Caminhos Importantes

- Kubeconfig local: `/home/diogo/.kube/config`
- HAProxy config: `/etc/haproxy/haproxy.cfg`
- Playbook: `/home/diogo/kode/proxmox/ansible/playbook.yml`

## Notas de Segurança

1. O kubeconfig é configurado com permissões 600
2. As chaves SSH são necessárias para acesso aos hosts
3. O HAProxy usa configurações seguras por padrão
4. Os certificados são gerenciados pelo Kubernetes

## Manutenção

1. Backup regular do etcd
2. Atualização dos certificados
3. Monitoramento dos logs
4. Verificação do status dos componentes

Para mais detalhes sobre a infraestrutura completa, consulte o [README principal](../README.md).