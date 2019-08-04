# laravel_docker_starterkit

This started life as an example app for [CapRover](https://github.com/caprover/caprover), to which I have made a few modifications.

## What's included?

- Laravel 5.8.x
- the basic Laravel auth scaffolding
- mysql 5.7.22
- nginx
- a helper file for windows, `larabash.bat`, which launches you a nice bash window in the laravel container for things like `artisan` commands.
- npm 10.x
- a basic package.lock file supporting the default laravel `webpack.mix.js` configuration.
- a basic `captain-definition` file for CapRover deployments
- a modified docker file which will do a `composer install` and a `npm run dev` as part of the build process.


IMPORTANT:

Note that the build process for laravel projects are quite heavy, you need at least 2GB, or in some instances 4gb of RAM or your server might crash.
