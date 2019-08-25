FROM php:7.2-fpm

# Copy composer.lock and composer.json
COPY ./application/composer.lock ./application/composer.json /var/www/
COPY docker-entry.sh /
COPY firstrun.sh /
COPY wait-for-it.sh /


# Set working directory
WORKDIR /var/www

# set up environment variables
RUN echo "NODE_ENV=development" >> /etc/environment

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
    nginx

# fix scripts
RUN dos2unix /*.sh && chmod +x /docker-entry.sh && chmod +x /firstrun.sh && chmod +x /wait-for-it.sh

# install nodejs
RUN curl sL https://deb.nodesource.com/setup_10.x | bash
RUN apt-get install --yes nodejs
RUN node -v
RUN npm -v

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install extensions
RUN docker-php-ext-install pdo_mysql pdo_pgsql mbstring zip exif pcntl
RUN docker-php-ext-configure gd --with-gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/
RUN docker-php-ext-install gd

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Add user for laravel application
RUN groupadd -g 1000 www
RUN useradd -u 1000 -ms /bin/bash -g www www

# Copy existing application directory
COPY ./application /var/www/
RUN ls /var/www

COPY ./configuration/nginx/conf.d/ /etc/nginx/conf.d/
RUN ls /etc/nginx/conf.d
RUN perl -pi -w -e "s/__CONTAINER_NAME__/${COMPOSE_PROJECT_NAME}_webserver/g" /etc/nginx/conf.d/app.conf

COPY ./configuration/php/local.ini /usr/local/etc/php/conf.d/local.ini
RUN ls /usr/local/etc/php/conf.d
RUN cat /usr/local/etc/php/conf.d/local.ini

RUN rm -rf /etc/nginx/sites-enabled
RUN mkdir -p /etc/nginx/sites-enabled

# Build the application
RUN chmod -R 777 /var/www/storage

# set up an environment file if it's necessary
RUN /firstrun.sh

# Expose port 80 and start php-fpm server
EXPOSE 80
CMD ["/docker-entry.sh"]
