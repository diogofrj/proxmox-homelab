# Provisionamento de VMs com Terraform

Este diretório contém a configuração do Terraform para provisionar as máquinas virtuais necessárias para o cluster Kubernetes no Proxmox.

## Estrutura do Diretório

```
terraform/
├── main.tf           # Configuração principal
├── variables.tf      # Definição de variáveis
├── outputs.tf        # Outputs do Terraform
├── versions.tf       # Versões dos providers
├── terraform.tfvars  # Valores das variáveis
└── README.md         # Esta documentação
```

## Pré-requisitos

1. Terraform 1.7+
2. Template Ubuntu 24.04 no Proxmox
3. Token de API do Proxmox configurado
4. Rede 192.168.31.0/24 disponível

## Configuração

### Provider Proxmox

```hcl
provider "proxmox" {
  pm_api_url = "https://seu-servidor:8006/api2/json"
  pm_api_token_id = "seu-token-id"
  pm_api_token_secret = "seu-token-secret"
  pm_tls_insecure = true
}
```

### Variáveis

Em `terraform.tfvars`:

```hcl
proxmox_host = "seu-servidor"
template_name = "ubuntu-2404-template"
ssh_key = "sua-chave-ssh-publica"

vms = {
  haproxy = {
    ip = "192.168.31.27"
    cores = 2
    memory = 2048
  }
  master1 = {
    ip = "192.168.31.21"
    cores = 2
    memory = 4096
  }
  master2 = {
    ip = "192.168.31.22"
    cores = 2
    memory = 4096
  }
  master3 = {
    ip = "192.168.31.23"
    cores = 2
    memory = 4096
  }
  worker1 = {
    ip = "192.168.31.24"
    cores = 4
    memory = 8192
  }
  worker2 = {
    ip = "192.168.31.25"
    cores = 4
    memory = 8192
  }
  worker3 = {
    ip = "192.168.31.26"
    cores = 4
    memory = 8192
  }
}
```

## Execução

1. Inicializar o Terraform:
   ```bash
   terraform init
   ```

2. Verificar o plano:
   ```bash
   terraform plan
   ```

3. Aplicar as mudanças:
   ```bash
   terraform apply
   ```

4. Para destruir a infraestrutura:
   ```bash
   terraform destroy
   ```

## Recursos Criados

### VMs
- 1 HAProxy (2 vCPUs, 2GB RAM)
- 3 Masters (2 vCPUs, 4GB RAM cada)
- 3 Workers (4 vCPUs, 8GB RAM cada)

### Rede
- Bridge: vmbr0
- VLAN: Nenhuma
- IPs: 192.168.31.21-27

### Storage
- Disco: 32GB por VM
- Formato: qcow2
- Storage: local-lvm

## Customização

### Ajustar Recursos

Em `variables.tf`:
```hcl
variable "vms" {
  type = map(object({
    ip = string
    cores = number
    memory = number
  }))
}
```

### Cloud-Init

Configurações padrão:
- Usuário: ubuntu
- Senha: desativada
- SSH: apenas chave pública
- Timezone: UTC

## Outputs

```hcl
output "vm_ips" {
  value = {
    for name, vm in proxmox_vm_qemu.vm : name => vm.default_ipv4_address
  }
}
```

## Troubleshooting

1. **Erro de Autenticação**
   - Verificar token do Proxmox
   - Confirmar URL da API
   - Checar permissões

2. **Erro de Template**
   - Confirmar nome do template
   - Verificar permissões
   - Checar storage

3. **Erro de Rede**
   - Verificar bridge
   - Confirmar range de IPs
   - Testar conectividade

## Segurança

1. **Autenticação**
   - Use tokens em vez de senha
   - Armazene secrets em variáveis
   - Não commite credenciais

2. **Rede**
   - Use VLANs se possível
   - Configure firewall
   - Isole redes de gerenciamento

3. **SSH**
   - Use apenas chaves públicas
   - Desative senha root
   - Limite acesso SSH

## Manutenção

1. **Backup**
   - Backup do state
   - Snapshot das VMs
   - Documentação atualizada

2. **Updates**
   - Atualize o provider
   - Mantenha o template atual
   - Teste mudanças

3. **Monitoramento**
   - Logs do Terraform
   - Métricas das VMs
   - Alertas configurados

## Caminhos Importantes

- State file: `terraform.tfstate`
- Variables: `terraform.tfvars`
- Provider: `~/.terraform.d/plugins/`
- Logs: `terraform.log`

Para mais detalhes sobre a infraestrutura completa, consulte o [README principal](../README.md). 