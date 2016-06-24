FROM php:7-fpm-alpine
MAINTAINER Matt Hartstonge <matt@mykro.co.nz>

RUN apk add --no-cache \
        freetype-dev \
        libjpeg-turbo-dev \
        libmcrypt-dev \
        libpng-dev \
        #libmemcached-dev \
        postgresql-dev \
        zip \
        unzip \
    # Compile PHP extra libs
    && docker-php-ext-configure gd \
        -with-freetype-dir=/usr/include/  \
        -with-png-dir=/usr/png/ \
        -with-jpeg-dir=/usr/jpeg/ \
    && docker-php-ext-configure pgsql \
        -with-pgsql=/usr/include/postgresql/ \
    # While PHP libs are available, run pecl
    && pecl install zip \
    && docker-php-ext-enable zip \
    # memcached not supported on PHP7 through pecl yet
    #&& pecl install memcached \
    #&& docker-php-ext-enable memcached \
    # Finally, install php compiled extensions
    && docker-php-ext-install \
        gd \
        mcrypt \
        mysqli \
        pdo \
        pdo_pgsql \
        pgsql
