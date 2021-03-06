FROM nginx:alpine

LABEL maintainer="tehtotalpwnage@gmail.com"

# Sets up the server environment.
COPY config/nginx/nginx.conf /etc/nginx/nginx.conf
COPY repo /srv/www/
COPY composer.phar /srv/www/composer.phar

# Run postinstallation scripts.
RUN mkdir -p /srv/logs/

# For security reasons, we want the container to be able to run without root permissions.
RUN adduser -D -g '' dlemp
RUN chown -R dlemp:dlemp /srv
USER dlemp:dlemp
RUN chmod +x /srv/www/composer.phar
RUN mkdir -p /srv/env
RUN cp /srv/www/.env.example /srv/env/.env
RUN ln -s /srv/env/.env /srv/www/.env

# The script is still being run as root, but the processes will be under the dlemp user.
USER root:root
