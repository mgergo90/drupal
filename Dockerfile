# from https://www.drupal.org/requirements/php#drupalversions
FROM php:7.0-apache

RUN a2enmod rewrite

# install the PHP extensions we need
RUN set -ex \
    && apt-get update \
    && apt-get install software-properties-common -y \
    && add-apt-repository ppa:ondrej/php \
	&& buildDeps=' \
		libjpeg62-turbo-dev \
		libpng12-dev \
		git-core \
		libpq-dev \
		libressl \
        curl \
        wget \
        perl \
        pcre \
        imap \
        imagemagick \
        libtool \
        imagemagick-dev \
        php7-fpm \
        php7-opcache \
        php7-session \
        php7-dom \
        php7-xml \
        php7-xmlreader \
        php7-ctype \
        php7-ftp \
        php7-gd \
        php7-json \
        php7-posix \
        php7-curl \
        php7-pdo \
        php7-pdo_mysql \
        php7-sockets \
        php7-zlib \
        php7-mcrypt \
        php7-mysqli \
        php7-sqlite3 \
        php7-bz2 \
        php7-phar \
        php7-openssl \
        php7-posix \
        php7-zip \
        php7-calendar \
        php7-iconv \
        php7-imap \
        php7-soap \
        php7-dev \
        php7-pear \
        php7-redis \
        php7-mbstring \
        php7-xdebug \
        php7-exif \
        php7-xsl \
        php7-ldap \
        php7-bcmath \
        php7-memcached \
        php7-oauth \
        php7-apcu \
	' \
	&& apt-get update && apt-get install -y --no-install-recommends $buildDeps && rm -rf /var/lib/apt/lists/* \
	&& docker-php-ext-configure gd \
		--with-jpeg-dir=/usr \
		--with-png-dir=/usr \
	&& docker-php-ext-install -j "$(nproc)" gd mbstring pdo pdo_mysql pdo_pgsql zip \
	&& apt-mark manual \
		libjpeg62-turbo \
		libpq5 \
	&& apt-get purge -y --auto-remove $buildDeps \
	# Composer
    && curl -fSL "https://getcomposer.org/installer" -o composer-setup.php \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && rm composer-setup.php \
    # Drush
    && composer global require drush/drush:8.*; \
    ln -s /root/.composer/vendor/bin/drush /usr/local/bin/drush;

COPY files/000-default.conf /etc/apache2/sites-enabled/

WORKDIR /var/www/html

CMD ["apache2ctl", "-D", "FOREGROUND"]
