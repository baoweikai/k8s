#!/bin/bash

# 在 master 节点和 worker 节点都要执行

# 安装 docker
# 参考文档如下
# https://docs.docker.com/install/linux/docker-ce/centos/ 
# https://docs.docker.com/install/linux/linux-postinstall/

# 卸载旧版本
yum remove -y -q docker \
docker-client \
docker-client-latest \
docker-common \
docker-latest \
docker-latest-logrotate \
docker-logrotate \
docker-selinux \
docker-engine-selinux \
docker-engine
# 设置 yum repository
yum install -y -q yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# 安装 containerd.io
if [ ! -d "/mnt/k8s/shell/containerd.io.rpm" ]
then
	yum install -y -q /mnt/k8s/shell/containerd.io.rpm
else
	yum install -y -q https://download.docker.com/linux/centos/7/x86_64/stable/Packages/containerd.io-1.2.10-3.2.el7.x86_64.rpm
fi
# 安装并启动 docker
yum install -y -q /mnt/k8s/shell/docker-ce.rpm /mnt/k8s/shell/docker-ce-cli.rpm ## /mnt/k8s/shell/docker-ce-selinux.noarch.rpm
systemctl enable docker
systemctl start docker
# 安装 nfs-utils 才能挂载 nfs 网络存储
yum install -y -q nfs-utils
# 关闭 防火墙
systemctl stop firewalld
systemctl disable firewalld
# 关闭 SeLinux
setenforce 0
sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config
# 关闭 swap
swapoff -a
yes | cp /etc/fstab /etc/fstab_bak
cat /etc/fstab_bak |grep -v swap > /etc/fstab
# 修改 /etc/sysctl.conf
# 如果有配置，则修改
sed -i "s#^net.ipv4.ip_forward.*#net.ipv4.ip_forward=1#g"  /etc/sysctl.conf
sed -i "s#^net.bridge.bridge-nf-call-ip6tables.*#net.bridge.bridge-nf-call-ip6tables=1#g"  /etc/sysctl.conf
sed -i "s#^net.bridge.bridge-nf-call-iptables.*#net.bridge.bridge-nf-call-iptables=1#g"  /etc/sysctl.conf
# 可能没有，追加
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
echo "net.bridge.bridge-nf-call-ip6tables = 1" >> /etc/sysctl.conf
echo "net.bridge.bridge-nf-call-iptables = 1" >> /etc/sysctl.conf
# 执行命令以应用
sysctl -p
# 设置 docker 镜像源，提高 docker 镜像下载速度和稳定性
## curl -sSL https://get.daocloud.io/daotools/set_mirror.sh | sh -s http://f1361db2.m.daocloud.io
# 修改docker启动配置 Cgroup Driver为systemd
sed -i "s#^ExecStart=/usr/bin/dockerd.*#ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock --exec-opt native.cgroupdriver=systemd#g" /usr/lib/systemd/system/docker.service
## sed -i "s/^Requires=docker.socket/## Requires=docker.socket/g" /usr/lib/systemd/system/docker.service
## 重启 docker，并启动 kubelet
systemctl daemon-reload
systemctl restart docker
## sed -i "s#^SELINUX=disabled#SELINUX=1#g" /etc/selinux/config
# 配置K8S的yum源
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=http://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg
       http://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
# 卸载旧版本
yum remove -y kubelet kubeadm kubectl
# 安装kubelet、kubeadm、kubectl
yum install -y -q /mnt/k8s/shell/kubelet.rpm /mnt/k8s/shell/kubeadm.rpm /mnt/k8s/shell/kubectl.rpm
## 启动kubelet
systemctl enable kubelet || true
systemctl start kubelet || true
## 此时 kubelet 启动失败，请忽略此错误，因为必须完成kubeadm init，kubelet 才能正常启动
## docker version
