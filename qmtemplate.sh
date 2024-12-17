cd /tmp
wget https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img -O noble-server-cloudimg-amd64.img
apt install libguestfs-tools -y

# Baixar o script de instalação de ferramentas
wget https://raw.githubusercontent.com/diogofrj/platform-toolbox/refs/heads/main/install-tools.sh -O /tmp/install-tools.sh

virt-customize -x --add noble-server-cloudimg-amd64.img \
  --update \
  --install qemu-guest-agent,curl,vim,htop,jq,git,unzip,wget,mtr,traceroute \
  --copy-in /tmp/install-tools.sh:/usr/local/bin \
  --run-command 'chmod +x /usr/local/bin/install-tools.sh' \
  --run-command 'useradd -m -s /bin/bash -f 0 ubuntu' || true \
  --password ubuntu:password:ubuntu \
  --run-command 'echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers' \
  --run-command 'mkdir -p /home/ubuntu/.ssh' \
  --ssh-inject ubuntu:file:/home/ubuntu/.ssh/authorized_keys


qm create 9002 --name ubuntu-2404-cloud-init --numa 0 --ostype l26 --cpu cputype=host --cores 3 --sockets 2 --memory 8196 --net0 virtio,bridge=vmbr0
qm importdisk 9002 ubuntu-2404-cloud-init local-lvm --format qcow2
qm importdisk 9002 noble-server-cloudimg-amd64.img local-lvm --format qcow2
qm set 9002 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9002-disk-0
qm set 9002 --ide2 local-lvm:cloudinit
qm set 9002 --boot c --bootdisk scsi0
qm set 9002 --serial10 socket --vga serial10
qm set 9002 --serial10 socket --vga serial0
qm set 9002 --serial0 socket --vga serial0
qm set 9002 --agent enabled=1
qm disk resize 9002 scsi0 +100G
qm template 9002


