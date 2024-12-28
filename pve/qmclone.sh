#!/bin/bash
#### ATENCAO: Este script é para ser executado no Proxmox VE para criação manual de VMs
# Clone a VM
qm clone 9002 100 --name VM-1 --full true --target bee

# Set VM properties
qm set 100 --net0 virtio,bridge=vmbr0 --memory 4096 --cores 3 --sockets 2 --ide2 local-lvm:vm-100-cloudinit --boot c --bootdisk scsi0 --serial0 socket --vga serial0 --agent enabled=1

# Configurações de Cloud-Init
qm set 100 --ipconfig0 ip=dhcp
qm set 100 --sshkey '.ssh/authorized_keys'
qm set 100 --ciuser ubuntu --cipassword ubuntu

qm start 100