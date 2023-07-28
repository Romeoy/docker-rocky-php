# docker-rocky-php

## About

Rockylinux + Nginx + PHP-FPM Docker image by <font color=#0000FF>Romeoy</font>

## Version

Rockylinux: 9+

Nginx: 1.20+ (the latest version in Rockylinux base repo)

PHP: 8.1 (can be configured from 7.4 ~ 8.2)

## Usage

Building image:
```
docker build -t rocky-nginx-php:0.1 --rm .
```
or overwrite the ENV arg to make Chinese developer use perfectly. 
```
docker build --build-arg ENV=dev -t rocky-nginx-php:0.1 --rm .
```

Run the Docker container:
```
docker run -itd --name rocky-php -p 8080:80 rocky-nginx-php:0.1
```

## Handy Paths

* nginx include: /etc/nginx/conf.d/\*/*.conf
* nginx vhost root: /var/www/default/public/
* nginx logs: /var/log/nginx/

Ideally the above ones should be mounted from docker host
and container nginx configuration (see vhost.conf for example),
site files and place to right logs to.

Both php-fpm and nginx run under nobody inside the container

Exposes port 80 for nginx.

## Thanks

[alleotech\/docker-nginx-php-fpm](https://github.com/alleotech/docker-nginx-php-fpm)
