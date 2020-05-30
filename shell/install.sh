#!/bin/bash
## 
masters=('192.168.137.10')
workers=('192.168.137.11' '192.168.137.12' '192.168.137.13')
username='root'
password='huaren830415'
APISERVER_IP=${masters[0]}
APISERVER_NAME='apiserver'
VERSION='1.18.2'
### 安装sshpass
yum remove -y sshpass && yum install -y sshpass
## 初始化主节点
/mnt/k8s/shell/init.sh
echo "127.0.0.1    ${APISERVER_NAME}" >> /etc/hosts
result=`/mnt/k8s/shell/init_master.sh ${APISERVER_NAME} ${VERSION}`
[[ ${result} =~ 'kubeadm join '${APISERVER_NAME}':6443 --token '([0-9a-z\.]+)' '[^0-9a-z]+'discovery-token-ca-cert-hash '([0-9a-z\:\.]+)' '[^0-9a-z]+'control-plane --certificate-key '([0-9a-z\.]+)[^0-9a-z]+ ]]
token=${BASH_REMATCH[1]}
certhash=${BASH_REMATCH[2]}
certificatekey=${BASH_REMATCH[3]}
## 循环初始化主节点
for master in ${masters[@]}
do
    if [ $APISERVER_IP != master ]
		sshpass -p $password scp -o "StrictHostKeyChecking no" -r '/mnt/k8s/shell/init.sh' $username'@'$master':/tmp/init.sh'
		sshpass -p $password ssh -o "StrictHostKeyChecking no" $username'@'$master sudo /tmp/init.sh
		sshpass -p $password ssh -o "StrictHostKeyChecking no" $username'@'$master echo "${APISERVER_IP} ${APISERVER_NAME}" >> /etc/hosts
		sshpass -p $password ssh -o "StrictHostKeyChecking no" $username'@'$master kubeadm join ${APISERVER_NAME}:6443 --token $token --discovery-token-ca-cert-hash ${certhash} --control-plane --certificate-key ${certificatekey}
    fi
done
## 循环初始化工作节点
for worker in ${workers[@]}
do
    sshpass -p $password scp -o "StrictHostKeyChecking no" -r '/mnt/k8s/shell/init.sh' $username'@'$master':/tmp/init.sh'
    sshpass -p $password ssh -o "StrictHostKeyChecking no" $username'@'$master sudo /tmp/init.sh
	sshpass -p $password ssh -o "StrictHostKeyChecking no" $username'@'$worker echo "${APISERVER_IP} ${APISERVER_NAME}" >> /etc/hosts
	sshpass -p $password ssh -o "StrictHostKeyChecking no" $username'@'$worker kubeadm join ${APISERVER_NAME}:6443 --token ${token} --discovery-token-ca-cert-hash ${certhash}
done
