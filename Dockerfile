
# Multi-stage build for Node.js dependencies
FROM node:22-alpine AS node-builder
WORKDIR /app


# PHP Production Image
FROM php:8.4-fpm-alpine AS production

# Install system dependencies in a single layer
RUN apk add --no-cache \
    git \
    curl \
    libpng-dev \
    oniguruma-dev \
    libxml2-dev \
    postgresql-dev \
    libzip-dev \
    zip \
    unzip \
    icu-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    libwebp-dev \
    freetype-dev \
    libwebp-dev \
    linux-headers \
    autoconf \
    g++ \
    make \
    && rm -rf /var/cache/apk/*

# Configure and install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-configure intl \
    && docker-php-ext-install -j$(nproc) \
        pdo \
        pdo_pgsql \
        pgsql \
        mbstring \
        exif \
        pcntl \
        bcmath \
        gd \
        intl \
        zip \
        opcache

# Install Redis extension
RUN pecl install redis \
    && docker-php-ext-enable redis \
    && rm -rf /tmp/pear

# Remove build dependencies to keep image small
#RUN apk del autoconf g++ make

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Create non-root user for security
RUN addgroup -g 1000 -S laravel \
    && adduser -u 1000 -S laravel -G laravel

# Set working directory
WORKDIR /var/www/html


# Remove build dependencies to keep image small
RUN apk del autoconf g++ make

COPY ./php.ini /usr/local/etc/php/conf.d/99-production.ini


# Switch to non-root user
USER laravel


