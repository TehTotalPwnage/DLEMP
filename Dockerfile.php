FROM php:fpm-alpine

COPY config/php/pool.d/www.conf /usr/local/etc/php-fpm.d/www.conf

RUN adduser -D -g '' dlemp

RUN docker-php-ext-install mbstring
RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install tokenizer

# By default, the installer will NOT automatically install libxml2-dev, a dependency of the XML extension.
# Therefore, we load it here instead.
# https://lists.alpinelinux.org/alpine-aports/2526.html
RUN apk add --no-cache libxml2-dev
RUN docker-php-ext-install xml

RUN docker-php-ext-install zip
