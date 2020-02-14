masters = (192.168.137.10)
nodes = (192.168.137.11 192.168.137.12)
masterClain = ''
sealos init --kubeadm-config kubeadm-config.yaml.tmpl \
    --master 192.168.0.2 \
    --master 192.168.0.3 \
    --master 192.168.0.4 \
    --node 192.168.0.5 \
    --user root \
    --passwd your-server-password \
    --version v1.17.0 \
    --pkg-url /root/kube1.17.0.tar.gz 
