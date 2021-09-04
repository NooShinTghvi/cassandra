FROM php:7.1.11-apache

ENV CASSANDRA_PHP_DRIVER_VERSION 1.3.2

#Install libssl-dev, git, wget, libuv and cmake dependencies
RUN apt-get update -y && \
	apt-get install -y libuv-dev  
	
RUN rm /var/lib/apt/lists/* -vrf && \
    apt-get clean && apt-get update

RUN apt-get update -y && \
    apt-get install -y git wget libssl-dev zlib1g-dev g++ make cmake libgmp-dev uuid-dev && \
    apt-get autoclean -y && \
    apt-get clean -y

# Download and Install datastax php-driver for cassandra
RUN git clone https://github.com/datastax/php-driver.git /usr/src/datastax-php-driver && \
    cd /usr/src/datastax-php-driver && \
    git checkout --detach v${CASSANDRA_PHP_DRIVER_VERSION} && \
    git submodule update --init && \
    cd ext && \
    ./install.sh && \
    echo extension=cassandra.so > /usr/local/etc/php/conf.d/cassandra.ini

RUN apt-get update -y && \
	apt-get install -y zlib1g-dev libicu-dev g++ && \
	docker-php-ext-configure intl && \
	docker-php-ext-install intl

# Install PHP extensions
RUN docker-php-ext-install zip mbstring intl opcache bcmath && \
    echo extension=bcmath.so > /usr/local/etc/php/conf.d/docker-php-ext-bcmath.ini && \
    pecl install xdebug-2.9.0 && \
    echo zend_extension=xdebug.so > /usr/local/etc/php/conf.d/xdebug.ini && \
    pecl install apcu-5.1.5 && \
    echo extension=apcu.so > /usr/local/etc/php/conf.d/apcu.ini && \
    pecl install uuid && \
    echo extension=uuid.so > /usr/local/etc/php/conf.d/uuid.ini


RUN a2enmod rewrite
RUN echo "\nServerName localhost\n" >> /etc/apache2/apache2.conf


RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php && php -r "unlink('composer-setup.php');" \
    && mv composer.phar /usr/local/bin/composer

RUN apt-get update && \
	apt-get install apt-file -y && \
	apt-file update && \
	apt-get install vim -y
	
## Cleanup
RUN apt-get purge -y \
    g++ \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html

EXPOSE 80

CMD ["apache2-foreground"]