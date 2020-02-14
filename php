# 基于php:alpine创建镜像,可自行替换centos或其他
FROM php:fpm-alpine
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories # 修改软件源为阿里云镜像
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" # 配置文件
RUN apk update # 更新软件包
# Override with custom opcache settings
# COPY config/opcache.ini $PHP_INI_DIR/conf.d/  # 缓存配置
# 安装 pdo_mysql 扩展
RUN docker-php-ext-install pdo_mysql
# 安装rdis扩展
RUN curl -fsSL 'https://pecl.php.net/get/redis-5.1.1.tgz' -o redis.tar.gz \
    && mkdir -p /tmp/redis \
    && tar -xf redis.tar.gz -C /tmp/redis --strip-components=1 \
    && rm redis.tar.gz \
    && docker-php-ext-configure /tmp/redis --enable-redis \
    && docker-php-ext-install /tmp/redis \
    && rm -r /tmp/redis
# 安装mongodb扩展
RUN apk add openssl openssl-dev # mongo依赖库
RUN curl -fsSL 'https://pecl.php.net/get/mongodb-1.6.1.tgz' -o mongodb.tar.gz \
    && mkdir -p /tmp/mongodb \
    && tar -xf mongodb.tar.gz -C /tmp/mongodb --strip-components=1 \
    && rm mongodb.tar.gz \
    && docker-php-ext-configure /tmp/mongodb --enable-mongodb --with-mongodb-ssl=auto \
    && docker-php-ext-install /tmp/mongodb \
    && rm -r /tmp/mongodb
# 安装swoole扩展
RUN apk add libstdc++ # swoole依赖库
RUN curl -fsSL 'https://github.com/swoole/swoole-src/archive/v4.4.12.tar.gz' -o swoole.tar.gz \
    && mkdir -p /tmp/swoole \
    && tar -xf swoole.tar.gz -C /tmp/swoole --strip-components=1 \
    && rm swoole.tar.gz \
    && docker-php-ext-configure /tmp/swoole --enable-swoole \
    && docker-php-ext-install /tmp/swoole \
    && rm -r /tmp/swoole