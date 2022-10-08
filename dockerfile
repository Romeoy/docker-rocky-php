# base image
FROM rockylinux:9

# label
LABEL org.label-schema.schema-version="1.0" \
    org.label-schema.name="Rockylinux with PHP-FPM Docker Image"

# matainer
MAINTAINER romeo

# define script variables
ARG ENVIRONMENT=prd
ARG PHP_VERSION=8.1
ARG TIME_ZONE=Asia/Shanghai

# modify root password
RUN echo 'root:admin123' | chpasswd

# set China image soure if dev environment
RUN if [ ${ENVIRONMENT} = dev ]; then \
        sed -e 's|^mirrorlist=|#mirrorlist=|g' \
            -e 's|^#baseurl=http://dl.rockylinux.org/$contentdir|baseurl=https://mirrors.aliyun.com/rockylinux|g' \
            -i.bak \
            /etc/yum.repos.d/rocky*.repo && \
        dnf makecache \
    ;fi && \
    dnf -y update

# install basic command lib
RUN dnf install -y epel-release.noarch \
    http://rpms.remirepo.net/enterprise/remi-release-9.rpm &&\
    dnf module -y install php:remi-${PHP_VERSION} &&\
    dnf -y install php-redis \
        php-soap \
        composer \
        nginx && \
    dnf clean all && \
    rm -rf /var/cache/dnf

# for development environment
RUN if [ ${ENVIRONMENT} = dev ]; then \
        dnf -y install \
            git \
            findutils \
            vim \
            wget \
            ncurses && \
        dnf clean all && \
        rm -rf /var/cache/dnf \
    ;fi

# Configure things
RUN sed -i -e 's~^;date.timezone =$~date.timezone = ${TIME_ZONE}~g' /etc/php.ini \
    && mkdir -p /etc/nginx/conf.d/000-default \
    && mkdir -p /var/www/html/000-default/webroot \
    && mkdir -p /var/www/html/000-default/webroot/.well-known \
    && mkdir -p /run/php-fpm \
    && mkdir -p /var/cache/nginx/fastcgi \
    && chown nobody:nobody /var/lib/php -R \
    && chown nobody:nobody /var/cache/nginx -R \
    && chown nobody:nobody /var/lib/nginx -R \
    && echo '<?php phpinfo(); ?>' > /var/www/html/000-default/webroot/index.php

COPY nginx.conf /etc/nginx/nginx.conf
COPY vhost.conf /etc/nginx/conf.d/000-default/vhost.conf
COPY pool.conf /etc/php-fpm.d/www.conf
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

EXPOSE 80

CMD ["/usr/local/bin/entrypoint.sh"]
