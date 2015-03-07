FROM vixns/php:5.6-fpm
MAINTAINER Stéphane Cottin <stephane.cottin@vixns.com>

ENV PHLACON_VERSION 1.3.2

RUN apt-get update && apt-get install -y g++ libgearman-dev imagemagick libgeoip-dev libmemcached-dev libgraphicsmagick1-dev && rm -rf /var/lib/apt/lists/*

RUN git clone -b $PHLACON_VERSION git://github.com/phalcon/cphalcon.git /usr/src/cphalcon && cd /usr/src/cphalcon/build && ./install && echo "extension=phalcon.so" >> "/usr/local/etc/php/conf.d/ext-phalcon.ini" && rm -rf /usr/src/cphalcon

RUN pecl install memcached gearman mongo geoip gmagick-beta && \
  echo "extension=gmagick.so" >> "/usr/local/etc/php/conf.d/ext-gmagick.ini" &&  \
  echo "extension=memcached.so" >> "/usr/local/etc/php/conf.d/ext-memcached.ini" &&  \
  echo "extension=gearman.so" >> "/usr/local/etc/php/conf.d/ext-gearman.ini" &&  \
  echo "extension=mongo.so" >> "/usr/local/etc/php/conf.d/ext-mongo.ini" &&  \
  echo "extension=geoip.so" >> "/usr/local/etc/php/conf.d/ext-geoip.ini"