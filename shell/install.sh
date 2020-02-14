masters = (192.168.137.10)
workers = (192.168.137.11 192.168.137.12)
yum install -y sshpass
for master in master; do
	sshpass -p huaren830415 ssh root@${master}
	/mnt/k8s/init.sh
	/mnt/k8s/master.sh ${master}
done

for worker in workers; do
	sshpass -p huaren830415 ssh root@${worker}
	/mnt/k8s/init.sh
done