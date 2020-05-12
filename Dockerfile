FROM php:5.6-fpm
COPY . /src
RUN \
echo "deb http://http.debian.net/debian stretch-backports contrib non-free main" >> /etc/apt/sources.list && \
apt-get update && apt-get --no-install-recommends -t stretch-backports -y dist-upgrade && \
apt-get install --no-install-recommends -t stretch-backports -y ca-certificates runit file re2c libicu-dev zlib1g-dev libmcrypt-dev libmagickcore-dev libmagickwand-dev libmagick++-dev libjpeg-dev libpng-dev libicu57 libmcrypt4 g++ imagemagick git libssl-dev xfonts-base xfonts-75dpi libfreetype6-dev ssmtp && \
docker-php-ext-install mysql pdo_mysql mysqli && \
mkdir -p /usr/local/etc/php-fpm.d && \
curl -s -L -o /tmp/wkhtmltox.deb https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.stretch_amd64.deb && \
dpkg -i /tmp/wkhtmltox.deb && rm /tmp/wkhtmltox.deb && \
docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/lib && docker-php-ext-install sockets intl zip mbstring mcrypt gd soap && \
pecl install imagick && \
  echo "extension=imagick.so" >> "/usr/local/etc/php/conf.d/ext-imagick.ini" &&  \
  echo "date.timezone=UTC" >> "/usr/local/etc/php/conf.d/timezone.ini" && \
  echo "zend_extension=opcache.so" >> "/usr/local/etc/php/conf.d/ext-opcache.ini" && \
  echo "opcache.enable_cli=1" >> "/usr/local/etc/php/conf.d/ext-opcache.ini" && \
  echo "opcache.memory_consumption=192" >> "/usr/local/etc/php/conf.d/ext-opcache.ini" && \
  echo "opcache.interned_strings_buffer=16" >> "/usr/local/etc/php/conf.d/ext-opcache.ini" && \
  echo "opcache.max_accelerated_files=7963" >> "/usr/local/etc/php/conf.d/ext-opcache.ini" && \
  echo "opcache.fast_shutdown=1" >> "/usr/local/etc/php/conf.d/ext-opcache.ini" && \
  echo "pdo_mysql.default_socket=/run/mysqld/mysqld.sock" >> "/usr/local/etc/php/conf.d/pdo_mysql.ini" && \
  echo "mysql.default_socket=/run/mysqld/mysqld.sock" >> "/usr/local/etc/php/conf.d/mysql.ini" && \
  echo "mysqli.default_socket=/run/mysqld/mysqld.sock" >> "/usr/local/etc/php/conf.d/mysqli.ini" && \
rm /usr/local/etc/php-fpm.d/*conf && \
dpkg --purge libicu-dev libmagickcore-dev libmagickwand-dev libmagick++-dev libssl-dev libfreetype6-dev libmagickcore-6.q16-dev libgraphviz-dev libglib2.0-dev libtiff5-dev libwmf-dev libcairo2-dev libgdk-pixbuf2.0-dev libfontconfig1-dev librsvg2-dev libmagickwand-6.q16-dev libmagick++-6.q16-dev libxml2-dev && \
apt-get autoremove -y && \
rm -rf /var/lib/apt/lists/* && \
mkdir -p /etc/service/php-fpm/ && \
mv /src/policy.xml /etc/ImageMagick-6/policy.xml && \
mv /src/php-fpm.conf /usr/local/etc/php-fpm.conf && \
rm -f /usr/local/etc/php-fpm.d/* && \
mv /src/www.conf /usr/local/etc/php-fpm.d/www.conf && \
mv /src/php-fpm.sh /etc/service/php-fpm/run && \
mv /src/runsvdir-start.sh /usr/local/sbin/runsvdir-start && \
chmod +x /etc/service/php-fpm/run  && \
rm -rf /src
COPY run.sh /run.sh 
RUN \
chmod +x /run.sh
CMD ["/run.sh"]