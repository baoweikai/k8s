#!/bin/bash
# network
docker network craete -d bridge network
### php
docker run -d --name swoole --net network \
-p 9000:9000 -p 9501:9501 \
-v 'd:/www/ls/api':/var/www:rw \
-v 'd:/k8s/etc/php/php.ini':/usr/local/etc/php/php.ini baoweikai/php \
'php /var/www/think swoole &'
### nginx
docker run -d --name nginx --net network \
-p 80:80 -p 443:443 \
-v 'd:/www':/var/www:ro \
-v 'd:/k8s/etc/nginx/vhost':/etc/nginx/conf.d:ro \
-v 'd:/log/nginx':'/var/log/nginx' nginx:alpine
### redis
docker run -d --name redis --net network \
-p 6379:6379 \
-v 'd:/k8s/etc/redis/redis.conf':/etc/redis/redis.conf \
redis redis-server \
--appendonly yes --requirepass "huaren54321"
### mongo  --config /etc/mongo/mongod.conf
docker run -d --name mongo --net network \
-p 27017:27017 \
-v 'd:/k8s/etc/mongo':/etc/mongo \
-e MONGO_INITDB_ROOT_USERNAME=zhrmghg \
-e MONGO_INITDB_ROOT_PASSWORD=huaren54321 mongo
### mysql1
docker run -d --name mysql --net network \
-p 3306:3306 \
-v 'd:/k8s/etc/mysql/my.cnf':/etc/mysql/conf.d/my.cnf \
-v 'd:/log/mysql':/var/log/mysql \
-v 'd:/data/mysql':/var/lib/mysql \
-e MYSQL_ROOT_PASSWORD=huaren54321 \
-e MYSQL_USER=zhrmghg \
-e MYSQL_PASSWORD=huaren54321 \
-e MYSQL_DATABASE=lishi mysql
## swoole
docker run -d --name swoole --net network \
-p 9501:9501 \
-v 'd:/www':/var/html:rw \
phpswoole/swoole /var/html/swoole

sealos init --passwd huaren830415 \
	--master 192.168.137.10 \
	--node 192.168.137.11 --node 192.168.137.12 --node 192.168.137.13 \
	--pkg-url /mnt/k8s/kube1.18.5.tar.gz \
	--version v1.18.5

# composer config -g repo.packagist composer https://packagist.phpcomposer.com