#!/usr/bin/env bash

echo Checking out the environment.
if [ ! -f /var/www/.env ]; then
# we are running this app for the first time.
echo This is a first run, so we set up the env
cp /var/www/.env.example /var/www/.env
/var/www/php artisan key:generate
echo Setting up the nginx host file.
fi
echo Finished checking out the environment.
exit 0
