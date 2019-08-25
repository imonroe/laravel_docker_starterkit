#!/bin/sh

/wait-for-it.sh ${COMPOSE_PROJECT_NAME}_mysql:3306
cd /var/www
composer install
npm install
npm run dev
php artisan migrate
php artisan cache:clear

php-fpm && nginx -g "daemon off;"
