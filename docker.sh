#!/bin/bash
### php
docker run -d --name php --net net \
-p 9000:9000 -p 9501:9501 \
-v '/mnt/www':/var/html:rw \
-v '/mnt/k8s/etc/php/php.ini':/usr/local/etc/php/php.ini baoweikai/php
### nginx
docker run -d --name nginx --net net \
-p 80:80 -p 443:443 \
-v '/mnt/www':/var/html:ro \
-v '/mnt/k8s/etc/nginx/vhost':/etc/nginx/conf.d:ro \
-v '/mnt/log/nginx':'/var/log/nginx' nginx:alpine
### redis
docker run -d --name redis --net net \
-p 6379:6379 \
-v '/mnt/k8s/etc/redis/redis.conf':/etc/redis/redis.conf \
redis redis-server \
--appendonly yes --requirepass "huaren54321"
### mongo  --config /etc/mongo/mongod.conf
docker run -d --name mongo --net net \
-p 27017:27017 \
-v '/mnt/k8s/etc/mongo':/etc/mongo \
-e MONGO_INITDB_ROOT_USERNAME=zhrmghg \
-e MONGO_INITDB_ROOT_PASSWORD=huaren54321 mongo
### mysql1
docker run -d --name mysql1 \
--net net -p 3301:3306 \
-v '/mnt/k8s/etc/mysql/my.cnf':/etc/mysql/conf.d/my.cnf \
-v '/mnt/log/mysql1':/var/log/mysql \
-v '/mnt/data/mysql1':/var/lib/mysql \
-e MYSQL_ROOT_PASSWORD=huaren54321 \
-e MYSQL_USER=zhrmghg \
-e MYSQL_PASSWORD=huaren54321 \
-e MYSQL_DATABASE=sxg mysql