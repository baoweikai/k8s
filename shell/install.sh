#!/bin/bash
## 
masters=('192.168.137.10')
workers=('192.168.137.11' '192.168.137.12' '192.168.137.13')
username='vagrant'
password='huaren830415'
APISERVER_IP=${masters[0]}
APISERVER_NAME='apiserver'
VERSION='1.18.3'
### 安装sshpass
yum remove -y sshpass && yum install -y sshpass
## 所有节点安装docker及kubelet
nodes=(${masters[@]} ${workers[@]})
for master in ${nodes[@]}
do
    # ssh-keygen -R "${master}" ## 清除之前无效登录信息
    sshpass -p $password scp -o "StrictHostKeyChecking no" -r '/mnt/k8s/shell/init.sh' $username'@'$master':/tmp/init.sh'
    sshpass -p $password ssh -o "StrictHostKeyChecking no" $username'@'$master sudo /tmp/init.sh
done
## 循环初始化主节点
for master in ${masters[@]}
do
    ## 初始化主节点
    if [ $APISERVER_IP==master ];
    then
			sshpass -p $password scp -o "StrictHostKeyChecking no" -r '/mnt/k8s/shell/master.sh' $username'@'$master':/tmp/master.sh'
			result=`sshpass -p $password ssh $username'@'$master sudo /tmp/master.sh ${APISERVER_IP} ${APISERVER_NAME} ${VERSION}`
			[[ "$result" =~ 'kubeadm join apiserver:6443 --token '([0-9a-z\.]+)' \'[^0-9a-z]+'discovery-token-ca-cert-hash '([0-9a-z\:\.]+)' \'[^0-9a-z]+'control-plane --certificate-key '([0-9a-z\.]+)[^0-9a-z]+ ]]
			token=${BASH_REMATCH[1]}
			certhash=${BASH_REMATCH[2]}
			certificatekey=${BASH_REMATCH[3]}
    else
			sshpass -p $password ssh -o "StrictHostKeyChecking no" $username'@'$master sudo /tmp/master.sh ${APISERVER_IP} ${APISERVER_NAME} ${VERSION}
			## 加入集群主节点
			sshpass -p $password ssh -o "StrictHostKeyChecking no" $username'@'$worker `sudo kubeadm join ${APISERVER_NAME}:6443 --token $token discovery-token-ca-cert-hash ${certhash} control-plane --certificate-key ${certificatekey}`
    fi
done
## 循环初始化工作节点
for worker in ${workers[@]}
do
	## 设定节点hosts
	sshpass -p $password ssh -o "StrictHostKeyChecking no" $username'@'$worker `sudo sed -i "\$a ${APISERVER_IP} ${APISERVER_NAME}" /etc/hosts`
	# 加入集群工作节点
	##sshpass -p $password ssh -o "StrictHostKeyChecking no" $username'@'$worker `sudo kubeadm join ${APISERVER_NAME}:6443 --token $token discovery-token-ca-cert-hash ${certhash}`
done
