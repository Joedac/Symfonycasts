ARG SYMFONY_PARAMS="--version=7.0.* --webapp"

FROM php:8.2-apache

# Install required dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
    libicu-dev \
    libonig-dev \
    libzip-dev \
    zip \
    unzip \
    curl \
    git \
    libpq-dev \
    && docker-php-ext-configure intl \
    && docker-php-ext-install intl mbstring zip pdo pdo_mysql pdo_pgsql \
    && docker-php-ext-enable intl mbstring zip pdo pdo_mysql pdo_pgsql \
    && a2enmod rewrite

# Enable PHP extensions
RUN docker-php-ext-enable intl mbstring zip pdo_pgsql

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER=1

# Install Symfony CLI
RUN curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.deb.sh' | bash \
    && apt install -y symfony-cli

# Configure Apache
COPY apache-default.conf /etc/apache2/sites-available/000-default.conf

# Set the working directory
WORKDIR /usr/src
VOLUME /usr/src

# Copy and set the entrypoint script
COPY ./docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Set the entrypoint and command
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["apache2-foreground"]
