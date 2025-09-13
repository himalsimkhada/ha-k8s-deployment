# Disable swap
swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab

modprobe br_netfilter
echo "1" > /proc/sys/net/bridge/bridge-nf-call-iptables

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
EOF

sudo sysctl --system

# Install essential packages
yum install -y yum-utils device-mapper-persistent-data lvm2 git curl wget vim

# Install containerd
yum install -y containerd
containerd config default > /etc/containerd/config.toml
cat /etc/containerd/config.toml | grep SystemdCgroup # needs to change this to true
systemctl enable --now containerd

# Install kubeadm, kubelet, kubectl
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.34/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.34/rpm/repodata/repomd.xml.key
EOF
yum install -y kubeadm kubelet kubectl
systemctl enable --now kubelet
