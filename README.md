# Infraestrutura Kubernetes Multi-Master com Proxmox

![Proxmox](https://img.shields.io/badge/Proxmox-E57000?style=for-the-badge&logo=proxmox&logoColor=white)
![Kubernetes](https://img.shields.io/badge/kubernetes-%23326ce5.svg?style=for-the-badge&logo=kubernetes&logoColor=white)
![Ansible](https://img.shields.io/badge/ansible-%231A1918.svg?style=for-the-badge&logo=ansible&logoColor=white)
![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)
![Ubuntu](https://img.shields.io/badge/Ubuntu-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)

Este projeto implementa uma infraestrutura completa de Kubernetes multi-master usando Proxmox como plataforma de virtualização, Terraform para provisionamento de VMs e Ansible para configuração do cluster.

## Arquitetura

```
                                   +----------------+
                                   |    HAProxy     |
                                   | 192.168.31.27  |
                                   +----------------+
                                          |
                    +--------------------+--------------------+
                    |                    |                   |
            +----------------+  +----------------+  +----------------+
            |    Master 1    |  |    Master 2    |  |    Master 3    |
            | 192.168.31.21  |  | 192.168.31.22  |  | 192.168.31.23  |
            +----------------+  +----------------+  +----------------+
                    |                    |                   |
        +-----------+-----------+--------+--------+----------+----------+
        |           |           |                 |          |          |
+----------------+  |  +----------------+  +----------------+  |  +----------------+
|    Worker 1    |  |  |    Worker 2    |  |    Worker 3    |  |  |   MetalLB     |
| 192.168.31.24  |  |  | 192.168.31.25  |  | 192.168.31.26  |  |  | 192.168.31.3- |
+----------------+  |  +----------------+  +----------------+  |  | 192.168.31.15  |
                   |                                          |  +----------------+
                   +------------------------------------------+
```

## Estrutura do Projeto

```
proxmox/
├── terraform/           # Configuração do Terraform para VMs
│   ├── main.tf         # Definição principal das VMs
│   ├── variables.tf    # Variáveis do Terraform
│   └── README.md       # Documentação do Terraform
├── ansible/            # Configuração do Ansible
│   ├── files/         # Arquivos de configuração
│   ├── group_vars/    # Variáveis globais
│   ├── inventory/     # Inventário dos hosts
│   ├── playbook.yml   # Playbook principal
│   └── README.md      # Documentação do Ansible
└── README.md          # Esta documentação
```

## Pré-requisitos

1. Proxmox VE 8.1+
2. Terraform 1.7+
3. Ansible 2.15+
4. Template Ubuntu 24.04 no Proxmox
5. Acesso SSH configurado
6. Rede 192.168.31.0/24 disponível

## Quick Start

1. **Provisionar VMs**
   ```bash
   cd terraform
   terraform init
   terraform apply
   ```

2. **Configurar Cluster**
   ```bash
   cd ../ansible
   ./run.sh
   ```

3. **Verificar Cluster**
   ```bash
   kubectl get nodes
   kubectl get pods -A
   ```

## Componentes

### Infraestrutura
- **Proxmox VE**: Plataforma de virtualização
- **Terraform**: Provisionamento de VMs
- **Ansible**: Configuração e orquestração

### Kubernetes
- **Versão**: 1.31.0
- **CNI**: Calico
- **Load Balancer**: MetalLB
- **Alta Disponibilidade**: HAProxy

### Rede
- **Pod CIDR**: 10.244.0.0/16
- **Service CIDR**: 10.96.0.0/12
- **MetalLB Range**: 192.168.31.3-192.168.31.15

## Documentação Detalhada

- [Configuração do Terraform](terraform/README.md)
- [Configuração do Ansible](ansible/README.md)

## Manutenção

1. **Backup**
   - Backup regular do etcd
   - Snapshot das VMs
   - Backup das configurações

2. **Monitoramento**
   - Logs do Kubernetes
   - Métricas do cluster
   - Status dos nodes

3. **Atualizações**
   - Patches de segurança
   - Atualizações do Kubernetes
   - Renovação de certificados

## Troubleshooting

1. **Problemas de Rede**
   - Verificar HAProxy
   - Testar conectividade entre nodes
   - Verificar CNI

2. **Problemas no Cluster**
   - Logs do kubelet
   - Status dos pods
   - Certificados

3. **Problemas com MetalLB**
   - Verificar configuração
   - Logs dos pods
   - Range de IPs

## Segurança

1. **Rede**
   - Firewall configurado
   - Comunicação criptografada
   - Isolamento de pods

2. **Autenticação**
   - RBAC ativado
   - Certificados TLS
   - Tokens seguros

3. **Monitoramento**
   - Logs centralizados
   - Alertas configurados
   - Auditoria ativada

## Contribuição

1. Fork o projeto
2. Crie uma branch (`git checkout -b feature/nova-feature`)
3. Commit suas mudanças (`git commit -am 'Adiciona nova feature'`)
4. Push para a branch (`git push origin feature/nova-feature`)
5. Crie um Pull Request

## Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.
