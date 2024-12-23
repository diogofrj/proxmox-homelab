# Criar a estrutura de diretórios e arquivos necessários
```bash
mkdir -p proxmox/ansible/{inventory,files,group_vars} && \
touch proxmox/ansible/inventory/hosts && \
touch proxmox/ansible/files/{bashrc,vimrc,sysctl.conf} && \
touch proxmox/ansible/group_vars/all.yml && \
touch proxmox/ansible/playbook.yml
```

# Criar o arquivo de inventário
```bash
echo "
[master]
192.168.31.20

[worker]
192.168.31.21
192.168.31.22
192.168.31.23
" > proxmox/ansible/inventory/hosts
```

# Criar o arquivo de variáveis
```bash
echo "      
packages:
  - curl
  - wget
  - vim
  - git
  - htop
  - net-tools
  - iptables-persistent
  - python3-pip
  - nfs-common
  - apt-transport-https
  - ca-certificates
  - software-properties-common
" > proxmox/ansible/group_vars/all.yml
```

# Criar o arquivo de playbook
```bash
echo "
---
- name: Configuração básica dos servidores
  hosts: all
  become: true
  vars:
    packages:
      - curl
      - wget
      - vim
      - git
      - htop
      - net-tools
      - iptables-persistent
      - python3-pip
      - nfs-common
      - apt-transport-https
      - ca-certificates
      - software-properties-common
" > proxmox/ansible/playbook.yml
```

# Executar o playbook
```bash
cd proxmox/ansible
ansible-playbook -i inventory/hosts playbook.yml
```
