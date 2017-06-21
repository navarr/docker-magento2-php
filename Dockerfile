# vim:set ft=dockerfile:
FROM php:5.6-fpm
MAINTAINER Navarr Barnier <Navarr.Barnier@briteskies.com>
# Don't email me.  I have no idea what I'm doing.

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update \
  && apt-get install -y \
    cron \
    libfreetype6-dev \
    libicu-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpng12-dev \
    libxslt1-dev \
    mariadb-server-10.0 \
    ssh \
    git \
    && apt-get clean \
    && cd /tmp \
    && curl -o ioncube.tar.gz http://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz \
    && echo "d9bc9207b0e43cb203207ccecde68f50e0e7d789  ioncube.tar.gz"|shasum -c \
    && tar -xvvzf ioncube.tar.gz \
    && mv ioncube/ioncube_loader_lin_5.6.so /usr/local/lib/php/extensions/* \
    && rm -Rf ioncube.tar.gz ioncube \
    && echo "zend_extension=ioncube_loader_lin_5.6.so" > /usr/local/etc/php/conf.d/00_docker-php-ext-ioncube_loader_lin_5.6.ini

RUN docker-php-ext-configure \
  gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/

RUN docker-php-ext-install \
  gd \
  bcmath \
  intl \
  mbstring \
  mcrypt \
  pdo_mysql \
  xsl \
  soap \
  zip

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

ENV PHP_MEMORY_LIMIT 2G
ENV PHP_PORT 9000
ENV PHP_PM dynamic
ENV PHP_PM_MAX_CHILDREN 10
ENV PHP_PM_START_SERVERS 4
ENV PHP_PM_MIN_SPARE_SERVERS 2
ENV PHP_PM_MAX_SPARE_SERVERS 6
ENV APP_MAGE_MODE default

COPY conf/www.conf /usr/local/etc/php-fpm.d/
COPY conf/php.ini /usr/local/etc/php/
COPY conf/php-fpm.conf /usr/local/etc/
COPY bin/* /usr/local/bin/
COPY conf/my.cnf /etc/mysql/conf.d
COPY conf/known_hosts /etc/ssh/ssh_known_hosts

RUN exec /usr/local/bin/create-mysql-admin-user

WORKDIR /srv/www

CMD ["/usr/local/bin/start"]
