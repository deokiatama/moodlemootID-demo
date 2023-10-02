#Base image
FROM php:7.4.33-apache-bullseye
# FROM php:8.0.30-apache-bullseye

#Packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    unoconv \
    unzip \
    git \
    zlib1g-dev \
    libjpeg-dev \
    libpng-dev \
    libfreetype-dev \
    libcurl4-openssl-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    nano \
    cron \
    && rm -rf /var/lib/apt/lists/*

#PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install -j$(nproc) gd
RUN docker-php-ext-install curl
RUN docker-php-ext-install mbstring
RUN docker-php-ext-install soap
RUN docker-php-ext-install zip
RUN docker-php-ext-install intl
RUN docker-php-ext-install exif
RUN docker-php-ext-install opcache
RUN docker-php-ext-install mysqli

#PHP 7.4
RUN docker-php-ext-install xmlrpc

#PHP 8.0
# RUN pecl install channel://pecl.php.net/xmlrpc-1.0.0RC3 && \
#     docker-php-ext-enable xmlrpc

RUN pecl install redis && docker-php-ext-enable redis

#Moodle appfiles
RUN git clone --single-branch -b MOODLE_311_STABLE https://github.com/moodle/moodle.git /var/www/html/
# RUN git clone --single-branch -b MOODLE_402_STABLE https://github.com/moodle/moodle.git /var/www/html/

#Config files
COPY additional-php-setting.ini /usr/local/etc/php/conf.d/additional-php-setting.ini
COPY moodlecron /root/moodlecron
RUN chmod 0644 /root/moodlecron && \
    crontab /root/moodlecron