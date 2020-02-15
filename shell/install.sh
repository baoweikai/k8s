#!/bin/bash

masters=('192.168.137.10')
workers=('192.168.137.11' '192.168.137.12' '192.168.137.13')
username='vagrant'
password='huaren830415'
for master in ${masters[@]}
do
    # ssh-keygen -R "${master}" ## 清除之前无效登录信息
    sshpass -p $password scp '/mnt/k8s/shell/init.sh' $username'@'$master':/tmp/init.sh'
    sshpass -p $password scp '/mnt/k8s/shell/master.sh' $username'@'$master':/tmp/master.sh'
    sshpass -p $password ssh $username'@'$master sudo /tmp/init.sh
    ## /tmp/master.sh ${master}
    ## logout # 退出当前机器
done

for worker in ${workers[@]}
do
    # ssh-keygen -R "${worker}"
    sshpass -p $password scp '/mnt/k8s/shell/init.sh' $username'@'$worker':/tmp/init.sh'
    sshpass -p $password scp '/mnt/k8s/shell/worker.sh' $username'@'$worker':/tmp/worker.sh'
    sshpass -p $password ssh $username'@'$worker sudo /tmp/init.sh
    ## logout # 退出当前机器
done