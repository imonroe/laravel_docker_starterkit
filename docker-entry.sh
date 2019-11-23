#!/bin/sh

cd /var/www

if [ ! -f /var/www/.env ]; then
FIRST_RUN=true
else
FIRST_RUN=false
fi

if [ $FIRST_RUN = true ]; then

echo Installing Composer dependencies.
composer install
composer require laravel/ui --dev
composer require barryvdh/laravel-debugbar --dev
composer require predis/predis
composer require jeroen-g/laravel-packager --dev
composer require squizlabs/php_codesniffer --dev
echo Completed Composer install.

echo This is a first run, so we will create the environment file and download dependencies.
cp /var/www/.env.example /var/www/.env
cd /var/www
echo Generating application key.
php artisan key:generate

echo Setting up UI dependencies and basic scaffolding
php artisan ui bootstrap
php artisan ui vue
php artisan ui vue --auth

echo Setting up cron.
touch /etc/crontab /etc/cron.*/*
crontab -l | { cat; echo "* * * * * cd /var/www && php artisan schedule:run >> /dev/null 2>&1"; } | crontab -
echo Crontab added.

echo Installing Node dependencies.
npm install
echo Finished installing node dependencies.

echo Running Webpack build process.
npm run dev
echo Webpack build complete.

fi

echo Checking composer.lock changes
composer install
echo Migrating database schema.
php artisan migrate
echo Database schema migrations complete.

echo Clearing the Laravel cache.
php artisan cache:clear
echo Laravel cache cleared.

echo Preflight completed. Have fun!
php-fpm -D -R
/usr/sbin/nginx -g "daemon off;"
