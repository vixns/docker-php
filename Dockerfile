FROM php:5.6-fpm

RUN apt-get update && apt-get install -y file re2c libicu-dev zlib1g-dev libmcrypt-dev libfreetype6-dev \
        libjpeg62-turbo-dev libicu52 libmcrypt4 g++ git && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install sockets intl zip mbstring mcrypt gd

# install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN echo "date.timezone=UTC" >> "/usr/local/etc/php/conf.d/timezone.ini"