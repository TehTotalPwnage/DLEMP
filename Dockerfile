# Dockerfile for LEMP stack.
FROM debian:jessie

MAINTAINER tehtotalpwnage "tehtotalpwnage@gmail.com"

# Ignore interaction when installing via APT (needed for MySQL).
ENV DEBIAN_FRONTEND=noninteractive

# Run all package installation steps.
RUN apt-get update
RUN apt-get install -y php5-fpm
RUN echo 'mysql-server-5.6 mysql-server/root_password password root' | debconf-set-selections \
    && echo 'mysql-server-5.6 mysql-server/root_password_again password root' | debconf-set-selections \
    && apt-get install -y mysql-server php5-mysql
RUN apt-get install -y nginx
RUN apt-get install -y wget

# Sets up the server environment.
COPY config/nginx/ /etc/nginx/
COPY config/php/ /etc/php5/fpm/
COPY repo /srv/www/
COPY composer-installer.sh /usr/local/bin/composer-installer
COPY lemp.sh /usr/local/bin/lemp

# Run postinstallation scripts.
RUN mkdir -p /srv/logs/
RUN /bin/bash -c "/usr/bin/mysqld_safe &" \
    && sleep 5 \
    && mysqladmin -uroot -proot create app \
    && mysqladmin -uroot -proot create appdev

# For security reasons, we want the container to be able to run without root permissions.
RUN adduser --disabled-password --gecos '' dlemp
RUN chown -R dlemp:dlemp /srv
RUN chown dlemp:dlemp /usr/local/bin/composer-installer
RUN chown dlemp:dlemp /usr/local/bin/lemp
USER dlemp:dlemp
RUN chmod +x /usr/local/bin/composer-installer
RUN chmod +x /usr/local/bin/lemp
WORKDIR /srv/www
RUN composer-installer
RUN ./composer.phar install
RUN ln -s /srv/www/composer.phar /srv/www/composer
RUN cp .env.example .env
RUN php artisan key:generate
USER root:root

# Expose NGINX listening port.
EXPOSE 80

# Entrypoint and CMD.
ENTRYPOINT ["lemp"]

CMD ["start"]
