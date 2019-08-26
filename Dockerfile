FROM php:7.2-fpm

# Copy in our helper scripts
COPY wait-for-it.sh /
COPY docker-entry.sh /

# Set working directory
WORKDIR /var/www

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    mariadb-client \
    libpng-dev \
    libpq-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    nano \
    unzip \
    git \
    curl \
    dos2unix \
    cron \
    procps \
    nginx

# fix scripts
RUN dos2unix /*.sh && chmod +x /docker-entry.sh && chmod +x /wait-for-it.sh

# install nodejs
RUN curl sL https://deb.nodesource.com/setup_10.x | bash
RUN apt-get install --yes nodejs && node -v && npm -v

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install extensions
RUN docker-php-ext-install pdo_mysql pdo_pgsql mbstring zip exif pcntl
RUN docker-php-ext-configure gd --with-gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/
RUN docker-php-ext-install gd

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Add user for laravel application
RUN groupadd -g 1000 www && useradd -u 1000 -ms /bin/bash -g www www

# Copy existing application directory and supporting files.
COPY ./application /var/www/
COPY ./configuration/nginx/conf.d/ /etc/nginx/conf.d/
COPY ./configuration/php/local.ini /usr/local/etc/php/conf.d/local.ini

RUN rm -rf /etc/nginx/sites-enabled && mkdir -p /etc/nginx/sites-enabled && chmod -R 777 /var/www/storage

# build the application

RUN /docker-entry.sh

# Expose port 80 and start php-fpm server
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

