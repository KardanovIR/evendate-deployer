FROM ubuntu:16.04
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -yq install \
        wget \
        curl \
        apache2 \
        apache2-doc \
        apache2-utils \
        software-properties-common \
        nano \
        git
# add php
RUN apt-get update && \
        apt-get -qy upgrade && \
        apt-get install -qy language-pack-en-base && \
        locale-gen en_US.UTF-8
    ENV LANG en_US.UTF-8
    ENV LC_ALL en_US.UTF-8
RUN add-apt-repository -y ppa:ondrej/php
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes php7.0
# add nodejs
RUN apt-get install curl
RUN curl -o node_installer.sh  https://deb.nodesource.com/setup_6.x
RUN sh node_installer.sh
RUN apt-get install -y nodejs

# copy project files and configure php, apache
WORKDIR /var/www/html
RUN git clone https://kardanovir:kazuistika31415926@github.com/KardanovIR/evendate_web2
RUN cd evendate_web2 && git checkout production
ADD init.php /var/www/html/
RUN php /var/www/html/init.php
ADD apache-config.conf /etc/apache2/sites-enabled/000-default.conf
RUN apt-get update
RUN a2enmod rewrite
RUN a2enmod headers
# install php supportive files
RUN DEBIAN_FRONTEND=noninteractive apt-get -y --force-yes install \
    php-pgsql \
    php-mysql \
    php-pear \
    php-dev \
    php-mbstring

# install dependence
WORKDIR /var/www/html/node/
RUN npm install
RUN chown -R www-data:www-data /var/www/html/
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid
# check versions
RUN nodejs -v \
    php -v \
    apache2 -v
WORKDIR /
RUN rm /var/www/html/index.html
EXPOSE 80
CMD ["/usr/sbin/apache2", "-D", "FOREGROUND"]
