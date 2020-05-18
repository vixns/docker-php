FROM php:7.0-fpm

COPY php-run /etc/service/php-fpm/run
COPY run.sh /run.sh

ENV TINI_VERSION=0.18.0

RUN set -x \
	\
	&& export DEBIAN_FRONTEND=noninteractive \
  && apt-get update \
  && apt-get dist-upgrade -y \
  && apt-get install --no-install-recommends -y \
		runit \
    gnupg \
    git \
    libmemcached-dev \
    libz-dev \
    libpq-dev \
    libssl-dev libssl-doc libsasl2-dev \
    libmcrypt-dev \
    libxml2-dev \
    zlib1g-dev libicu-dev g++ \
    libldap2-dev libbz2-dev \
    curl libcurl4-openssl-dev \
    libenchant-dev libgmp-dev firebird-dev libib-util \
    re2c libpng++-dev \
    libwebp-dev libjpeg-dev libjpeg62-turbo-dev libpng-dev libxpm-dev libvpx-dev libfreetype6-dev \
    libmagick++-dev \
    libmagickwand-dev \
    zlib1g-dev libgd-dev \
    libtidy-dev libxslt1-dev libmagic-dev libexif-dev file \
    sqlite3 libsqlite3-dev libxslt-dev \
    libmhash2 libmhash-dev libc-client-dev libkrb5-dev libssh2-1-dev \
    libzip-dev libpcre3 libpcre3-dev \
    poppler-utils ghostscript libmagickwand-6.q16-dev libsnmp-dev libedit-dev libreadline6-dev libsodium-dev \
    freetds-bin freetds-dev freetds-common libct4 libsybdb5 tdsodbc libreadline-dev librecode-dev libpspell-dev \
    msmtp msmtp-mta
	
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/ && \
  docker-php-ext-install gd
RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl && \
  docker-php-ext-install imap iconv

RUN docker-php-ext-install bcmath bz2 calendar ctype curl dba dom fileinfo exif ftp gettext intl json mbstring mysqli pdo pdo_mysql pdo_pgsql pdo_sqlite pgsql pcntl pspell readline simplexml soap zip

# install pecl extension
RUN pecl install ds && \
  pecl install imagick && \
  pecl install memcached && \
  pecl install redis && \
  docker-php-ext-enable imagick memcached redis

# install composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
        && php -r "if (hash_file('sha384', 'composer-setup.php') === 'e0012edf3e80b6978849f5eff0d4b4e4c79ff1609dd1e613307e16318854d24ae64f26d17af3ef0bf7cfb710ca74755a') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
        && php composer-setup.php \
        && php -r "unlink('composer-setup.php');" \
        && mv composer.phar /usr/local/sbin/composer \
        && chmod +x /usr/local/sbin/composer

RUN apt-get autoremove -y \
&& rm -rf /var/lib/apt/* \
&& chmod +x /etc/service/php-fpm/run \
&& rm -f /usr/local/etc/php-fpm.d/* \
&& echo "date.timezone=UTC" >> "/usr/local/etc/php/conf.d/timezone.ini" \
&& echo "pdo_mysql.default_socket=/run/mysqld/mysql.sock" >> "/usr/local/etc/php/conf.d/pdo_mysql.ini" \
&& echo "mysql.default_socket=/run/mysqld/mysql.sock" >> "/usr/local/etc/php/conf.d/mysql.ini" \
&& echo "mysqli.default_socket=/run/mysqld/mysql.sock" >> "/usr/local/etc/php/conf.d/mysqli.ini" \
&& echo "zend_extension=opcache.so" >> "/usr/local/etc/php/conf.d/ext-opcache.ini" \
&& echo "opcache.enable_cli=1" >> "/usr/local/etc/php/conf.d/ext-opcache.ini" \
&& echo "opcache.memory_consumption=128" >> "/usr/local/etc/php/conf.d/ext-opcache.ini" \
&& echo "opcache.interned_strings_buffer=8" >> "/usr/local/etc/php/conf.d/ext-opcache.ini" \
&& echo "opcache.max_accelerated_files=4000" >> "/usr/local/etc/php/conf.d/ext-opcache.ini" \
&& echo "opcache.fast_shutdown=1" >> "/usr/local/etc/php/conf.d/ext-opcache.ini" \
&& curl -s -L -o /tmp/tini_${TINI_VERSION}-amd64.deb https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini_${TINI_VERSION}-amd64.deb \
&& dpkg -i /tmp/tini_${TINI_VERSION}-amd64.deb \
&& rm /tmp/tini_${TINI_VERSION}-amd64.deb \
&& chmod +x /run.sh

COPY www.conf /usr/local/etc/php-fpm.d/www.conf
COPY php-fpm.conf /usr/local/etc/php-fpm.conf

ENTRYPOINT ["tini"]
CMD ["/run.sh"]
