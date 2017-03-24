FROM ubuntu:16.04

#ARG GIT_BRANCH=test

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -yq install \
        wget \
        curl \
        apache2 \
        apache2-doc \
        apache2-utils \
        openssh-server \
        software-properties-common \
        nano \
        git \
        sudo

# add php
RUN apt-get update && \
        apt-get -qy upgrade && \
        apt-get install -qy language-pack-en-base && \
        locale-gen en_US.UTF-8 && \
        locale-gen ru_RU.UTF-8

ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
RUN add-apt-repository -y ppa:ondrej/php
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes php7.0
# add nodejs
RUN apt-get install curl
RUN curl -o node_installer.sh  https://deb.nodesource.com/setup_7.x
RUN sh node_installer.sh
RUN apt-get install -y nodejs
RUN npm install -g forever

# add postgresql repo
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" > /etc/apt/sources.list.d/pgdg.list
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | \
  apt-key add -

# install postgresql9.5
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -yq install python-software-properties \
    software-properties-common \
    && apt-get -y -q install postgresql-9.6


# copy project files and configure php, apache

ADD apache-config.conf /etc/apache2/sites-enabled/000-default.conf
RUN apt-get update
RUN a2enmod rewrite
RUN a2enmod headers
RUN a2enmod proxy_http
RUN a2enmod env

# install php supportive files
RUN DEBIAN_FRONTEND=noninteractive apt-get -y --force-yes install \
    php7.0-pgsql \
    php-mysql \
    php-pear \
    php-dev \
    php-mbstring \
    php-xdebug

#Set up debugger
RUN echo "xdebug.remote_enable=1" >> /etc/php/7.0/apache2/php.ini


RUN chown -R www-data:www-data /var/www/html/
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

WORKDIR /
RUN rm /var/www/html/index.html
EXPOSE 80 8080 443 8443 22 5432

ENTRYPOINT ["/var/www/deployer/entrypoint.sh"]
CMD ["/usr/sbin/apache2", "-D", "FOREGROUND"]

USER postgres
RUN service postgresql start && psql --command "ALTER USER postgres PASSWORD 'APASSWORD';"
RUN service postgresql start && psql --command "CREATE DATABASE evendate WITH OWNER = postgres ENCODING = 'UTF8' TABLESPACE = pg_default TEMPLATE=template0 LC_COLLATE = 'ru_RU.UTF-8' LC_CTYPE = 'ru_RU.UTF-8' CONNECTION LIMIT = -1;"
USER root