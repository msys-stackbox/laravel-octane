FROM php:8.0.3-fpm

# Set working directory
WORKDIR /var/www

# Arguments defined in docker-compose.yml
ARG user=www-data
ARG uid=501

# OPcache defaults
ENV PHP_OPCACHE_ENABLE="1"
ENV PHP_OPCACHE_MEMORY_CONSUMPTION="128"
ENV PHP_OPCACHE_MAX_ACCELERATED_FILES="10000"
ENV PHP_OPCACHE_REVALIDATE_FREQUENCY="0"
ENV PHP_OPCACHE_VALIDATE_TIMESTAMPS="0"

# Install system dependencies
RUN apt-get update && apt-get install -y \
  git \
  curl \
  libpng-dev \
  libonig-dev \
  libxml2-dev \
  zip \
  unzip \
  && pecl install --configureoptions 'enable-sockets="no" enable-openssl="no" enable-http2="no" enable-mysqlnd="no" enable-swoole-json="no" enable-swoole-curl="no"' swoole

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd sockets opcache

COPY ./project /var/www

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
ADD ./essentials/php/conf.d/swoole.ini /usr/local/etc/php/conf.d
ADD ./essentials/php/conf.d/user_ini.ini /usr/local/etc/php/conf.d

# Add Scripts
ADD ./start.sh /start.sh

CMD ["/start.sh"]

EXPOSE 8000
