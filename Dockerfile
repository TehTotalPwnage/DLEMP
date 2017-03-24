# Dockerfile for LEMP stack.
FROM debian:jessie

MAINTAINER tehtotalpwnage "tehtotalpwnage@gmail.com"

# Ignore interaction when installing via APT (needed for MySQL).
ARG REPO
ENV DEBIAN_FRONTEND=noninteractive

# Run all package installation steps.
RUN apt-get update
RUN echo 'mysql-server-5.6 mysql-server/root_password password root' | debconf-set-selections \
    && echo 'mysql-server-5.6 mysql-server/root_password_again password root' | debconf-set-selections \
    && apt-get install -y mysql-server php5-mysql
RUN apt-get install -y nginx
RUN apt-get install -y php5-fpm
RUN apt-get install -y git

# Sets up the server environment.
RUN git clone $REPO /srv/www/
COPY lemp.sh /usr/local/bin/lemp

# Run postinstallation scripts.
RUN mkdir -p /srv/logs/

# Expose NGINX listening port.
EXPOSE 80

# Entrypoint and CMD.
ENTRYPOINT ["lemp"]

CMD ["start"]
