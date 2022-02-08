FROM alpine:3.15.0

CMD ["/bin/sh"]

RUN apk add --no-cache openssh-client git curl patch shadow mysql-client rsync perl

RUN apk add --no-cache php8 php8-common php8-fpm php8-xml php8-openssl php8-pdo php8-pdo_mysql php8-mysqlnd php8-json php8-mbstring php8-gd php8-bcmath php8-curl php8-session php8-opcache php8-xmlwriter php8-xmlreader php8-tokenizer php8-phar php8-ctype php8-simplexml php8-xdebug php8-pecl-uploadprogress php8-pecl-apcu

RUN ln -sf /usr/bin/php8 /usr/bin/php

RUN /bin/sh -c set -x && adduser -u 82 -D -S -G www-data www-data

ENV DOCKER_USER_ID=501
ENV DOCKER_USER_GID=20

RUN /bin/sh -c set -x && groupmod -g 567 dialout && groupmod -g ${DOCKER_USER_GID} nobody && usermod -g ${DOCKER_USER_GID} -u ${DOCKER_USER_ID} nobody

ENV PHP_INI_DIR=/usr/local/etc/php

RUN mkdir -p $PHP_INI_DIR/conf.d

COPY docker-php-entrypoint /usr/local/bin/

ENTRYPOINT ["docker-php-entrypoint"]

WORKDIR /usr/local/apache2/htdocs

RUN rm -f /etc/php8/php-fpm.conf

RUN rm -f /etc/php8/php-fpm.d/www.conf

COPY php-fpm.conf /etc/php8/php-fpm.conf

COPY opcache-recommended.ini /etc/php8/conf.d/opcache-recommended.ini

COPY 99_custom.ini /etc/php8/conf.d/99_custom.ini 

ENV COMPOSER_HOME=/root/composer

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN curl -o /usr/local/bin/mhsendmail -L https://github.com/mailhog/mhsendmail/releases/download/v0.2.0/mhsendmail_linux_amd64 && chmod 775 /usr/local/bin/mhsendmail

EXPOSE 9000

CMD ["/usr/sbin/php-fpm8"]
