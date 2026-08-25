FROM php:8.2-apache-bookworm

ENV DEBIAN_FRONTEND=noninteractive \
    COMPOSER_ALLOW_SUPERUSER=1 \
    COMPOSER_HOME=/composer \
    TZ=UTC

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       ca-certificates curl default-mysql-client ftp git libbz2-dev libicu-dev libonig-dev \
       libpq-dev libsqlite3-0 libsqlite3-dev libxml2-dev libzip-dev locales mariadb-server \
       nodejs npm supervisor unzip wkhtmltopdf zip zlib1g-dev \
    && docker-php-ext-install bcmath intl mbstring mysqli pdo pdo_mysql zip \
    && a2enmod rewrite \
    && locale-gen en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

COPY backend/ /work/backend/
WORKDIR /work/backend
RUN composer install --no-dev --no-interaction --prefer-dist --optimize-autoloader \
    && mkdir -p writable/cache writable/debugbar writable/logs writable/session writable/uploads \
    && chown -R www-data:www-data writable

COPY bot/package.json bot/package-lock.json /home/bot/app/
WORKDIR /home/bot/app
RUN npm ci --omit=dev
COPY bot/ /home/bot/app/

COPY infra/docker/apache/httpd.conf /etc/apache2/sites-available/000-default.conf
COPY flag.txt /flag_bb57a3d4461cc065df27165d73d35a0983c7c9113c055434fd7667fbb8654e1f.txt
COPY supervisord.conf /etc/supervisor/conf.d/rsctf.conf
COPY --chmod=0555 rsctf-start.sh /usr/local/bin/rsctf-start

WORKDIR /work/backend
EXPOSE 80
# Original final-stage ENTRYPOINT is wrapped by RSCTF at runtime.

# RSCTF dynamic-flag compatibility layer. The build-time scan records
# exact marker-bearing files; runtime replacement is therefore bounded
# to those files instead of walking the image on every team start.
USER root
COPY rsctf-entrypoint.sh /usr/local/bin/rsctf-entrypoint
RUN set -eu; \
    chmod 0555 /usr/local/bin/rsctf-entrypoint; \
    : > /etc/rsctf-flag-targets; \
    for root in /usr/local/bin/rsctf-start /etc/supervisor/conf.d/rsctf.conf /flag_bb57a3d4461cc065df27165d73d35a0983c7c9113c055434fd7667fbb8654e1f.txt /etc/apache2/sites-available/000-default.conf /home/bot/app /usr/bin/composer /work/backend /app /src /srv /home /opt /var/www /challenge /chall /ctf /root /usr/src /usr/local/bin /workspace /flag /flag.txt; do \
      if [ -e "$root" ]; then \
        find "$root" -xdev -type f ! -path /usr/local/bin/rsctf-entrypoint -exec grep -lF -e RSCTF_DYNAMIC_FLAG_991f8470ca5e2184512f1ddaf -e RSCTF_DYNAMIC_FLAG_5aa465e95fdf3 {} + >> /etc/rsctf-flag-targets 2>/dev/null || true; \
      fi; \
    done; \
    find / -xdev -maxdepth 1 -type f -exec grep -lF -e RSCTF_DYNAMIC_FLAG_991f8470ca5e2184512f1ddaf -e RSCTF_DYNAMIC_FLAG_5aa465e95fdf3 {} + >> /etc/rsctf-flag-targets 2>/dev/null || true; \
    sort -u /etc/rsctf-flag-targets > /etc/rsctf-flag-targets.sorted; \
    mv /etc/rsctf-flag-targets.sorted /etc/rsctf-flag-targets; \
    while IFS= read -r target; do \
      [ -f "$target" ] || continue; \
      chmod a+w "$target"; \
      parent=$(dirname "$target"); \
      while [ "$parent" != / ]; do chmod a+x "$parent"; parent=$(dirname "$parent"); done; \
    done < /etc/rsctf-flag-targets
ENTRYPOINT ["/usr/local/bin/rsctf-entrypoint", "/usr/local/bin/rsctf-start"]
