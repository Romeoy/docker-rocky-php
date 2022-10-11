# base image
FROM rockylinux:9

# label
LABEL org.label-schema.schema-version="1.0" \
    org.label-schema.name="Rockylinux with PHP-FPM & nginx Docker Image"

# matainer
MAINTAINER romeo

# define script variables
ARG ENV=prod
ARG PHP_VERSION=8.1
ARG TIME_ZONE=America/New_York

# modify root password
RUN echo 'root:admin123' | chpasswd

# set China image soure if dev environment
RUN if [ $ENV = dev ]; then \
        sed -e 's|^mirrorlist=|#mirrorlist=|g' \
            -e 's|^#baseurl=http://dl.rockylinux.org/$contentdir|baseurl=https://mirrors.aliyun.com/rockylinux|g' \
            -i.bak \
            /etc/yum.repos.d/rocky*.repo && \
        dnf makecache \
    ;fi && \
    dnf -y update && \
    ln -snf /usr/share/zoneinfo/$TIME_ZONE /etc/localtime


# install basic command lib
RUN dnf install -y epel-release.noarch \
    http://rpms.remirepo.net/enterprise/remi-release-9.rpm &&\
    dnf module -y install php:remi-$PHP_VERSION &&\
    dnf -y install php-redis \
        php-soap \
        php-pdo \
        composer \
        nginx && \
    dnf clean all && \
    rm -rf /var/cache/dnf

# Configure things
RUN sed -i -e 's|^;date.timezone =$|date.timezone = $TIME_ZONE|g' /etc/php.ini \
    && mkdir -p /etc/nginx/conf.d/default \
    && mkdir -p /var/www/default/public \
#    && mkdir -p /var/www/default/public/.well-known \
    && mkdir -p /run/php-fpm \
    && mkdir -p /var/cache/nginx/fastcgi \
    && chown nobody:nobody /var/lib/php -R \
    && chown nobody:nobody /var/cache/nginx -R \
    && chown nobody:nobody /var/lib/nginx -R \
    && chown nobody:nobody /var/www/default -R \
    && echo '<?php phpinfo(); ?>' > /var/www/default/public/index.php

# for development environment
RUN if [ $ENV = dev ]; then \
        ln -snf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
        sed -i -e 's|^date.timezone =*|date.timezone = Asia/Shanghai|g' /etc/php.ini && \
        composer config -g repo.packagist composer https://mirrors.aliyun.com/composer && \
        dnf -y install \
            git \
            findutils \
            vim \
            wget \
            ncurses && \
        dnf clean all && \
        rm -rf /var/cache/dnf \
    ;fi

COPY nginx.conf /etc/nginx/nginx.conf
COPY vhost.conf /etc/nginx/conf.d/default/vhost.conf
COPY pool.conf /etc/php-fpm.d/www.conf
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

EXPOSE 80

CMD ["/usr/local/bin/entrypoint.sh"]
