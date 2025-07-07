# refer upstream: https://github.com/docker-library/wordpress
FROM php:8.1.33-fpm-alpine
LABEL MAINTAINER="Matthew Hartstonge <matt@mykro.co.nz>"

# persistent dependencies
RUN set -eux; \
    apk add --no-cache \
        # Ghostscript is required for rendering PDF previews
        ghostscript \
        # Alpine package for "imagemagick" contains ~120 .so files, see: https://github.com/docker-library/wordpress/pull/497
        imagemagick \
    ;

# install the PHP extensions we need (https://make.wordpress.org/hosting/handbook/handbook/server-environment/#php-extensions)
RUN set -ex; \
    \
    apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS \
        autoconf \
        bzip2-dev \
        freetype-dev \
        icu-dev \
        imagemagick-dev \
        libheif-dev \
        libavif-dev \
        libjpeg-turbo-dev \
        libpng-dev \
        libwebp-dev \
        libzip-dev \
        postgresql-dev \
        tidyhtml-dev \
    ; \
    # Configure image support
    docker-php-ext-configure gd \
        --with-avif \
        --with-freetype \
        --with-jpeg \
        --with-webp  \
    ; \
    # Configure postgres support
    docker-php-ext-configure pgsql -with-pgsql=/usr/include/postgresql/ ; \
    # Install php extensions
    docker-php-ext-install -j1 \
        bcmath \
        bz2 \
        calendar \
        exif \
        gd \
        intl \
        mysqli \
        opcache \
        pdo \
        pdo_mysql \
        pdo_pgsql \
        pgsql \
        tidy \
        zip \
    ; \
    # Install PECL PHP extensions. \
    pecl install apcu-5.1.24 && docker-php-ext-enable apcu ; \
    pecl install imagick-3.8.0 && docker-php-ext-enable imagick ; \
    docker-php-ext-enable opcache ; \
    # Clean up
    rm -r /tmp/pear ; \
    \
    # some misbehaving extensions end up outputting to stdout 🙈 (https://github.com/docker-library/wordpress/issues/669#issuecomment-993945967)
    out="$(php -r 'exit(0);')"; \
    [ -z "$out" ]; \
    err="$(php -r 'exit(0);' 3>&1 1>&2 2>&3)"; \
    [ -z "$err" ]; \
    \
    extDir="$(php -r 'echo ini_get("extension_dir");')"; \
    [ -d "$extDir" ]; \
    runDeps="$( \
        scanelf --needed --nobanner --format '%n#p' --recursive "$extDir" \
            | tr ',' '\n' \
            | sort -u \
            | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    )"; \
    apk add --no-network --virtual .wordpress-phpexts-rundeps $runDeps; \
    apk del --no-network .build-deps; \
    \
    ! { ldd "$extDir"/*.so | grep 'not found'; }; \
    # check for output like "PHP Warning:  PHP Startup: Unable to load dynamic library 'foo' (tried: ...)
    err="$(php --version 3>&1 1>&2 2>&3)"; \
    [ -z "$err" ]

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
        echo 'opcache.memory_consumption=128'; \
        echo 'opcache.interned_strings_buffer=8'; \
        echo 'opcache.max_accelerated_files=4000'; \
        echo 'opcache.revalidate_freq=2'; \
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
