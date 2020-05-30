masters = (192.168.137.10)
nodes = (192.168.137.11 192.168.137.12 192.168.137.13)
masterClain = ''
sealos init --master 192.168.137.10 \
    --node 192.168.137.11 \
    --node 192.168.137.12 \
    --node 192.168.137.13 \
    --user root \
    --passwd huaren830415 \
    --version v1.18.3 \
    --pkg-url /mnt/k8s/kube1.18.3.tar.gz
