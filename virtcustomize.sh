virt-customize --add noble-server-cloudimg-amd64.img \
  --update \
  --install qemu-guest-agent,curl,vim,htop,jq,git,unzip,wget,mtr,traceroute \
  --copy-in /tmp/install-tools.sh:/usr/local/bin \
  --run-command 'chmod +x /usr/local/bin/install-tools.sh' #
  
#   --run-command '/usr/local/bin/install-tools.sh' \
#   --run-command 'useradd -m -s /bin/bash novo_usuario' \
#   --password novo_usuario:password:senha_segura \
#   --run-command 'echo "novo_usuario ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers' \
#   --run-command 'mkdir -p /home/novo_usuario/.ssh' \
#   --ssh-inject novo_usuario:file:/path/to/public_key.pub