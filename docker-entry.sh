#!/bin/sh

# echo Waiting on the database to be ready.
# /wait-for-it.sh ${COMPOSE_PROJECT_NAME}_mysql:3306
# echo Database is responding.

cd /var/www

echo Installing Composer dependencies.
composer install
echo Completed Composer install.

echo Checking out the environment.
if [ ! -f /var/www/.env ]; then
# we are running this app for the first time.
echo This is a first run, so we will create the environment file.
cp /var/www/.env.example /var/www/.env
cd /var/www
php artisan key:generate
echo Setting up the nginx host file.
sed -i "s/__CONTAINER_NAME__/$PROJECT_WEBSERVER/g" /etc/nginx/conf.d/app.conf
echo Host file updated.
fi
echo Finished checking out the environment.

echo Installing Node dependencies.
npm install
echo Finished installing node dependencies.

echo Running Webpack build process.
npm run dev
echo Webpack build complete.

echo Migrating database schema.
php artisan migrate
echo Database schema migrations complete.

echo Clearing the Laravel cache.
php artisan cache:clear
echo Laravel cache cleared.

echo Preflight completed. Have fun!
php-fpm && nginx -g "daemon off;"
