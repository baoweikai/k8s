#!/bin/bash

masters=('192.168.137.10')
workers=('192.168.137.11' '192.168.137.12' '192.168.137.13')
username='vagrant'
password='huaren830415'
APISERVER_IP=${masters[0]}
APISERVER_NAME=apiserver
varsion='1.17.3'
## 循环安装主节点
for master in ${masters[@]}
do
    # ssh-keygen -R "${master}" ## 清除之前无效登录信息
    sshpass -p $password scp -r '/mnt/k8s/shell/init.sh' $username'@'$master':/tmp/init.sh'
    sshpass -p $password scp -r '/mnt/k8s/shell/master.sh' $username'@'$master':/tmp/master.sh'
    sshpass -p $password ssh $username'@'$master sudo /tmp/init.sh
    ## 初始化主节点
    result=sshpass -p $password ssh $username'@'$master sudo /tmp/master.sh ${APISERVER_IP} ${APISERVER_NAME} ${varsion}
    if [$APISERVER_IP==master];
    then
	[[ "$result" =~ 'kubeadm join apiserver:6443 --token '([0-9a-z\.]+)' \'[^0-9a-z]+'discovery-token-ca-cert-hash '([0-9a-z\:\.]+)' \'[^0-9a- z]+'control-plane --certificate-key '([0-9a-z\.]+)[^0-9a-z]+ ]]
	token=${BASH_REMATCH[1]}
	cert-hash=${BASH_REMATCH[2]}
	certificate-key=${BASH_REMATCH[3]}
    else
    ## 加入集群主节点
	kubeadm join ${APISERVER_NAME}:6443 --token $token discovery-token-ca-cert-hash ${cert-hash} control-plane --certificate-key ${certificate-key}
    fi
    ## logout # 退出当前机器
done
## 循环安装工作节点
for worker in ${workers[@]}
do
    # ssh-keygen -R "${worker}"
    sshpass -p $password scp -r '/mnt/k8s/shell/init.sh' $username'@'$worker':/tmp/init.sh'
    sshpass -p $password scp -r '/mnt/k8s/shell/worker.sh' $username'@'$worker':/tmp/worker.sh'
    sshpass -p $password ssh $username'@'$worker sudo /tmp/init.sh
	#### 初始化工作节点
	echo "${APISERVER_IP} ${APISERVER_NAME}" >> /etc/hosts
	# 加入集群工作节点
	kubeadm join ${APISERVER_NAME}:6443 --token $token discovery-token-ca-cert-hash ${cert-hash}
done
