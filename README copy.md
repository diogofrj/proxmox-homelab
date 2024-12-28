UBUNTU SERVER LTS 24.04.1 - https://ubuntu.com/download/server
KUBERNETES 1.31.3         - https://kubernetes.io/releases/
CONTAINERD 1.7.24         - https://containerd.io/releases/
RUNC 1.2.2                - https://github.com/opencontainers/runc/releases
CNI PLUGINS 1.6.1         - https://github.com/containernetworking/plugins/releases
CALICO CNI 3.29.1         - https://docs.tigera.io/calico/3.29/getting-started/kubernetes/quickstart

master1  192.168.31.20
master2  192.168.31.21
master3  192.168.31.22
worker1  192.168.31.23
worker2  192.168.31.24
worker3  192.168.31.25
haproxy  192.168.31.27

## HAProxy
ssh ubuntu@192.168.31.27

## MASTER NODES
ssh ubuntu@192.168.31.21
ssh ubuntu@192.168.31.22
ssh ubuntu@192.168.31.23

## WORKER NODES
ssh ubuntu@192.168.31.24
ssh ubuntu@192.168.31.25
ssh ubuntu@192.168.31.26


# CONFIGURE ALL NODES

printf "\n192.168.31.20 master1\n192.168.31.21 master2\n192.168.31.22 master3\n192.168.31.23 worker1\n192.168.31.24 worker2\n192.168.31.25 worker3\n192.168.31.26 worker4\n192.168.31.27 haproxy\n\n" >> /etc/hosts

printf "overlay\nbr_netfilter\n" >> /etc/modules-load.d/containerd.conf
cat /etc/modules-load.d/containerd.conf
modprobe overlay
modprobe br_netfilter
printf "net.bridge.bridge-nf-call-iptables = 1\nnet.ipv4.ip_forward = 1\nnet.bridge.bridge-nf-call-ip6tables = 1\n" >> /etc/sysctl.d/99-kubernetes-cri.conf
sysctl --system

wget https://github.com/containerd/containerd/releases/download/v1.7.24/containerd-1.7.24-linux-amd64.tar.gz -P /tmp/
tar Cxzvf /usr/local /tmp/containerd-1.7.24-linux-amd64.tar.gz

wget https://raw.githubusercontent.com/containerd/containerd/main/containerd.service -P /etc/systemd/system/
systemctl daemon-reload
systemctl enable --now containerd

wget https://github.com/opencontainers/runc/releases/download/v1.2.2/runc.amd64 -P /tmp/
install -m 755 /tmp/runc.amd64 /usr/local/sbin/runc

wget https://github.com/containernetworking/plugins/releases/download/v1.6.1/cni-plugins-linux-amd64-v1.6.1.tgz -P /tmp/
mkdir -p /opt/cni/bin
tar Cxzvf /opt/cni/bin /tmp/cni-plugins-linux-amd64-v1.6.1.tgz
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
systemctl restart containerd

swapoff -a
cat  /etc/fstab

apt-get update
apt-get install -y apt-transport-https ca-certificates curl gpg
mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
apt-get update
apt-get install -y kubelet=1.31.3-1.1 kubeadm=1.31.3-1.1 kubectl=1.31.3-1.1
apt-mark hold kubelet kubeadm kubectl
kubeadm config images pull --kubernetes-version=v1.31.3

kubeadm init --pod-network-cidr 10.10.0.0/16 --kubernetes-version 1.31.3 --node-name master1
export KUBECONFIG=/etc/kubernetes/admin.conf

kubectl get nodes

-----------------------------------------------------------------------------------------------------

# CONFIGURE ALL WORKER NODES

printf "\n192.168.31.20 MASTER\n192.168.31.21 WORKER1\n192.168.31.22 WORKER2\n192.168.31.23 WORKER3\n\n" >> /etc/hosts
printf "overlay\nbr_netfilter\n" >> /etc/modules-load.d/containerd.conf
modprobe overlay
modprobe br_netfilter
printf "net.bridge.bridge-nf-call-iptables = 1\nnet.ipv4.ip_forward = 1\nnet.bridge.bridge-nf-call-ip6tables = 1\n" >> /etc/sysctl.d/99-kubernetes-cri.conf
sysctl --system

wget https://github.com/containerd/containerd/releases/download/v1.7.24/containerd-1.7.24-linux-amd64.tar.gz -P /tmp/
tar Cxzvf /usr/local /tmp/containerd-1.7.24-linux-amd64.tar.gz

wget https://raw.githubusercontent.com/containerd/containerd/main/containerd.service -P /etc/systemd/system/
systemctl daemon-reload
systemctl enable --now containerd

wget https://github.com/opencontainers/runc/releases/download/v1.2.2/runc.amd64 -P /tmp/
install -m 755 /tmp/runc.amd64 /usr/local/sbin/runc

wget https://github.com/containernetworking/plugins/releases/download/v1.6.1/cni-plugins-linux-amd64-v1.6.1.tgz -P /tmp/
mkdir -p /opt/cni/bin
tar Cxzvf /opt/cni/bin /tmp/cni-plugins-linux-amd64-v1.6.1.tgz
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
systemctl restart containerd

cat /etc/fstab
swapoff -a

apt-get update
apt-get install -y apt-transport-https ca-certificates curl gpg
mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

apt-get update
apt-get install -y kubelet=1.31.3-1.1 kubeadm=1.31.3-1.1 kubectl=1.31.3-1.1
apt-mark hold kubelet kubeadm kubectl

kubeadm join 192.168.31.20:6443 --token kyjj8q.uos6css0qunko4pd --discovery-token-ca-cert-hash sha256:46be91f16c1c9334134cd7266876861b5a4e2cc57c0c45c290b7e657b1ba43ca