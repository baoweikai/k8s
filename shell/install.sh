#!/bin/bash

masters=('192.168.137.10')
workers=('192.168.137.11' '192.168.137.12' '192.168.137.13')
for master in masters; do
    ssh-keygen -R "${master}" ## 清除之前无效登录信息
    sshpass -p 'huaren830415' scp '/mnt/k8s/shell/init.sh' "root@${master}:/tmp/init.sh"
    sshpass -p 'huaren830415' scp '/mnt/k8s/shell/master.sh' "root@${master}:/tmp/master.sh"
	sshpass -p 'huaren830415' ssh "root@${master}"
	/tmp/init.sh
	## /tmp/master.sh ${master}
	logout # 退出当前机器
done

for worker in workers; do
    ssh-keygen -R "${worker}"
    sshpass -p 'huaren830415' scp '/mnt/k8s/shell/init.sh' "root@${worker}:/tmp/init.sh"
	sshpass -p 'huaren830415' ssh "root@${worker}"
	/tmp/init.sh
	logout # 退出当前机器
done
