#!/bin/bash
## 
masters=('192.168.137.10')
workers=('192.168.137.11' '192.168.137.12' '192.168.137.13')
username='root'
password='huaren830415'
APISERVER_IP=${masters[0]}
APISERVER_NAME='apiserver'
VERSION='1.18.2'
## 主节点执行
command=`kubeadm token create --print-join-command`
[[ ${command} =~ 'kubeadm join '${APISERVER_NAME}':6443 --token '([0-9a-z\.]+)' '[^0-9a-z]+'discovery-token-ca-cert-hash '([0-9a-z\:]+) ]]
token=${BASH_REMATCH[1]}
certhash=${BASH_REMATCH[2]}
echo $token
## 循环初始化工作节点
for worker in ${workers[@]}
do
    #sshpass -p $password scp -o "StrictHostKeyChecking no" -r '/mnt/k8s/shell/init.sh' $username'@'$worker':/tmp/init.sh'
    #sshpass -p $password ssh -o "StrictHostKeyChecking no" $username'@'$worker sudo /tmp/init.sh
	sshpass -p ${password} ssh -o "StrictHostKeyChecking no" ${username}'@'${worker} sudo kubeadm reset -f
	sshpass -p ${password} ssh -o "StrictHostKeyChecking no" ${username}'@'${worker} 'echo "'${APISERVER_IP}' '${APISERVER_NAME}'" >> /etc/hosts'
	sshpass -p ${password} ssh -o "StrictHostKeyChecking no" ${username}'@'${worker} 'kubeadm join '${APISERVER_NAME}':6443 --token '${token}' --discovery-token-ca-cert-hash '${certhash}
done
