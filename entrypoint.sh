#!/bin/bash

echo "Starting cron"
crond start

echo "Starting PHP-FPM in background"
php-fpm -D

echo "Starting Nginx"
nginx -g "daemon off;"
