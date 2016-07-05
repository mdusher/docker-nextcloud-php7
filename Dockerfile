FROM php:7.0.8-apache

RUN apt-get update && apt-get install -y \
        bzip2 \
        libcurl4-openssl-dev \
        libfreetype6-dev \
        libicu-dev \
        libjpeg-dev \
        libmcrypt-dev \
        libmemcached-dev \
        libpng12-dev \
        libpq-dev \
        libxml2-dev \
        git \
        unzip \
        && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
        && docker-php-ext-install gd exif intl mbstring mcrypt mysqli opcache pdo_mysql pdo_pgsql pgsql zip

RUN { \
                echo 'opcache.memory_consumption=128'; \
                echo 'opcache.interned_strings_buffer=8'; \
                echo 'opcache.max_accelerated_files=4000'; \
                echo 'opcache.revalidate_freq=60'; \
                echo 'opcache.fast_shutdown=1'; \
                echo 'opcache.enable_cli=1'; \
        } > /usr/local/etc/php/conf.d/opcache-recommended.ini

RUN cd /tmp && \
    git clone https://github.com/php-memcached-dev/php-memcached.git && \
    cd php-memcached && \
    git checkout php7 && \
    phpize && \
    ./configure --disable-memached-sasl && \
    make && make install && \
    echo "extension=memcached.so" > /usr/local/etc/php/conf.d/20-memcached.ini

RUN set -ex \
        && pecl install APCu \
        && pecl install redis \
        && docker-php-ext-enable apcu redis #memcached

RUN a2enmod rewrite

ENV NEXTCLOUD_VERSION 9.0.52
VOLUME /var/www/html

RUN curl -fsSL -o nextcloud.zip \
                "https://download.nextcloud.com/server/releases/nextcloud-${NEXTCLOUD_VERSION}.zip" \
        && curl -fsSL -o nextcloud.zip.asc \
                "https://download.nextcloud.com/server/releases/nextcloud-${NEXTCLOUD_VERSION}.zip.asc" \
        && export GNUPGHOME="$(mktemp -d)" \
        && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys 28806A878AE423A28372792ED75899B9A724937A \
        && gpg --batch --verify nextcloud.zip.asc nextcloud.zip \
        && rm -r "$GNUPGHOME" nextcloud.zip.asc \
        && unzip nextcloud.zip -d /usr/src/ \
        && rm nextcloud.zip

COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]

