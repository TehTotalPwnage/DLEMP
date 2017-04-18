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

# Sets up the server environment.
COPY config/nginx/ /etc/nginx/
COPY config/php/ /etc/php5/fpm/
COPY repo /srv/www/
COPY lemp.sh /usr/local/bin/lemp

# Run postinstallation scripts.
RUN chmod +x /usr/local/bin/lemp
RUN mkdir -p /srv/logs/
RUN /bin/bash -c "/usr/bin/mysqld_safe &" \
    && sleep 5 \
    && mysqladmin -uroot -proot create app \
    && mysqladmin -uroot -proot create appdev

# Expose NGINX listening port.
EXPOSE 80

# Entrypoint and CMD.
ENTRYPOINT ["lemp"]

CMD ["start"]
