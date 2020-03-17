# refer upstream: https://github.com/docker-library/wordpress
FROM php:7.2-fpm-alpine
LABEL MAINTAINER="Matt Hartstonge <matt@mykro.co.nz>"

RUN set -ex; \
    \
    apk add --no-cache --virtual .build-deps \
        freetype-dev \
        libjpeg-turbo-dev \
        imagemagick-dev \
        libpng-dev \
        libzip-dev \
        postgresql-dev \
        tidyhtml-dev \
    ; \
    \
    # Compile PHP extra libs
    docker-php-ext-configure gd \
        -with-freetype-dir=/usr/include/  \
        -with-png-dir=/usr/png/ \
        -with-jpeg-dir=/usr/jpeg/; \
    # Add postgres support
    docker-php-ext-configure pgsql \
        -with-pgsql=/usr/include/postgresql/; \
    # Add php-apc support
    pecl install apcu &&\
    pecl install apcu_bc-1.0.5 &&\
    docker-php-ext-enable apcu --ini-name 10-docker-php-ext-apcu.ini &&\
    docker-php-ext-enable apc --ini-name 20-docker-php-ext-apc.ini &&\
    \
    # While PHP libs are available, run pecl
    pecl install imagick-3.4.4; \
    docker-php-ext-enable imagick; \
    \
    # Install php compiled extensions
    docker-php-ext-install -j "$(nproc)" \
        bcmath \
        exif \
        gd \
        mysqli \
        opcache \
        pdo \
        pdo_pgsql \
        pgsql \
        tidy \
        zip \
    ; \
    \
    runDeps="$( \
        scanelf --needed --nobanner --format '%n#p' --recursive /usr/local/lib/php/extensions \
            | tr ',' '\n' \
            | sort -u \
            | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    )"; \
    apk add --virtual .wordpress-phpexts-rundeps $runDeps; \
    apk del .build-deps

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
        echo 'opcache.memory_consumption=128'; \
        echo 'opcache.interned_strings_buffer=8'; \
        echo 'opcache.max_accelerated_files=4000'; \
        echo 'opcache.revalidate_freq=2'; \
        echo 'opcache.fast_shutdown=1'; \
    } > /usr/local/etc/php/conf.d/opcache-recommended.ini

# https://wordpress.org/support/article/editing-wp-config-php/#configure-error-logging
# https://www.php.net/manual/en/errorfunc.constants.php
# https://github.com/docker-library/wordpress/issues/420#issuecomment-517839670
RUN { \
        echo 'error_reporting = E_ERROR | E_WARNING | E_PARSE | E_CORE_ERROR | E_CORE_WARNING | E_COMPILE_ERROR | E_COMPILE_WARNING | E_RECOVERABLE_ERROR'; \
        echo 'display_errors = Off'; \
        echo 'display_startup_errors = Off'; \
        echo 'log_errors = On'; \
        echo 'error_log = /dev/stderr'; \
        echo 'log_errors_max_len = 1024'; \
        echo 'ignore_repeated_errors = On'; \
        echo 'ignore_repeated_source = Off'; \
        echo 'html_errors = Off'; \
    } > /usr/local/etc/php/conf.d/error-logging.ini
