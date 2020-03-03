### php
docker run -d --name php --net net -p 9000:9000 -p 9501:9501 -v 'D:/www':/var/html -v 'D:/k8s/etc/php/php.ini':/usr/local/etc/php/php.ini baoweikai/php
### nginx
docker run -d --name nginx --net net -p 80:80 -p 443:443 -v 'D:/www':/var/html:ro -v 'D:/k8s/etc/nginx/vhost':/etc/nginx/conf.d:ro -v 'D:/log/nginx':'/var/log/nginx' nginx:alpine
### redis
docker run -d --name redis --net net -p 6379:6379 -v 'D:/k8s/etc/redis/redis.conf':/etc/redis/redis.conf redis redis-server --appendonly yes --requirepass "huaren54321"
### mongo  --config /etc/mongo/mongod.conf
docker run -d --name mongo --net net -p 27017:27017 -v 'D:/k8s/etc/mongo':/etc/mongo -e MONGO_INITDB_ROOT_USERNAME=baoweikai -e MONGO_INITDB_ROOT_PASSWORD=huaren54321 mongo
### db1
docker run -d --name mysql1 --net net -p 3301:3306 -v 'D:/k8s/etc/mysql/my.cnf':/etc/mysql/confi.d/my.cnf -v 'D:/log/mysql1':/var/log/mysql -e MYSQL_ROOT_PASSWORD=huaren54321 mysql