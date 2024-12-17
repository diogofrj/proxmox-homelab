# Proxmox Homelab

![Proxmox](https://img.shields.io/badge/Proxmox-E57000?style=for-the-badge&logo=proxmox&logoColor=white)
![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)
![Ubuntu](https://img.shields.io/badge/Ubuntu-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)

Este projeto fornece uma estrutura automatizada para criar e gerenciar um ambiente homelab usando Proxmox VE (Virtual Environment). O projeto utiliza Terraform para provisionar máquinas virtuais de forma automatizada e padronizada.

## Pré-requisitos

- Servidor Proxmox VE instalado e configurado
- Token Proxmox (Verificar diretamente na pagina do Provider Terraform - BPG Proxmox)
- Terraform instalado na máquina local
- Acesso SSH configurado
- Git instalado
- GitHub CLI (gh) instalado (opcional, para criação do repositório)

## Início Rápido

1. Clone o repositório:
```bash
git clone https://github.com/seu-usuario/proxmox-homelab.git
cd proxmox-homelab
```

2. Crie o template Ubuntu Cloud-Init:
```bash
chmod +x qmtemplate.sh
./qmtemplate.sh
```
- ATENÇÃO: A execução do script qmtemplate.sh é necessária para criar o template Ubuntu 24.04 com Cloud-Init e ferramentas essenciais. Sem ele, o Terraform não conseguirá criar as VMs.


3. Configure o Terraform:
```bash
terraform init
terraform plan
terraform apply
```

## Estrutura do Projeto

```
proxmox-homelab/
├── .gitignore          # Arquivos ignorados pelo Git
├── README.md           # Esta documentação
├── criarepo.sh         # Script para criar repositório GitHub
├── main.tf             # Configuração principal do Terraform
├── qmclone.sh         # Script para clonar VMs manualmente
├── qmtemplate.sh      # Script para criar template Ubuntu
└── virtcustomize.sh   # Script para personalizar imagem Ubuntu
```

## Configurações Padrão

### Rede
- Rede: 192.168.31.0/24
- Gateway: 192.168.31.1
- Bridge: vmbr0

### VM Padrão
- 3 cores
- 4GB RAM
- 105GB disco
- Ubuntu 24.04
- Cloud-init habilitado
- QEMU Guest Agent instalado

## Scripts Utilitários

### qmtemplate.sh
Cria um template Ubuntu 24.04 com Cloud-Init e ferramentas essenciais:
- QEMU Guest Agent
- Ferramentas de rede
- Git, Curl, Vim, etc.

### qmclone.sh
Permite clonar VMs manualmente com configurações personalizadas.

### virtcustomize.sh
Script para personalizar a imagem Ubuntu Cloud com ferramentas adicionais.

## Segurança

- Autenticação baseada em chave SSH
- Usuário não-root com sudo
- Senha padrão que deve ser alterada após a primeira inicialização
- QEMU Guest Agent para melhor integração com Proxmox

## Boas Práticas

1. Altere as senhas padrão após a criação das VMs
2. Mantenha o template atualizado regularmente
3. Faça backup das configurações importantes
4. Use o arquivo `.gitignore` para evitar commit de arquivos sensíveis
5. Documente todas as modificações realizadas

## Troubleshooting

### Problemas Comuns

1. **Terraform não consegue conectar ao Proxmox**
   - Verifique se o Proxmox está acessível
   - Confirme as credenciais do usuário Terraform
   - Verifique se o firewall permite a conexão

2. **Template não encontrado**
   - Confirme se o template existe (ID: 9002)
   - Verifique se o script qmtemplate.sh foi executado com sucesso

3. **Problemas de rede**
   - Confirme se as configurações de rede estão corretas
   - Verifique se o bridge vmbr0 existe no Proxmox

## Contribuição

1. Faça um fork do repositório
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Faça commit das alterações (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## Licença

Este projeto está licenciado sob a licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

## Contato

Para questões e suporte, abra uma issue no repositório GitHub.

---

**Nota**: Este projeto é destinado para uso em ambiente de laboratório. Para ambientes de produção, considere medidas adicionais de segurança e redundância.
