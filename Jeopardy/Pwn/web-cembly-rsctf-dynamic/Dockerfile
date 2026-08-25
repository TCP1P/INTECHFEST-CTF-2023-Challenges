FROM node:20-alpine

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

RUN apk add --no-cache chromium nginx supervisor

WORKDIR /app/bot
COPY bot/package.json ./
RUN npm install --omit=dev
COPY bot/ ./

COPY src/ /var/www/html/
COPY nginx.conf /etc/nginx/http.d/default.conf
COPY supervisord.conf /etc/supervisord.conf
COPY --chmod=0555 rsctf-start.sh /usr/local/bin/rsctf-start

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
    for root in /usr/local/bin/rsctf-start /etc/supervisord.conf /etc/nginx/http.d/default.conf /var/www/html /app/bot /app /src /srv /home /opt /var/www /challenge /chall /ctf /root /usr/src /usr/local/bin /workspace /flag /flag.txt; do \
      if [ -e "$root" ]; then \
        find "$root" -xdev -type f ! -path /usr/local/bin/rsctf-entrypoint -exec grep -lF -e RSCTF_DYNAMIC_FLAG_36f4b0e27ebec801ae299b971aea29b90711e003a0d3a41c6ca396cc653c5fbd3 -e RSCTF_DYNAMIC_FLAG_341de9eed62d5e631b6368699e0b0154249687f5a1ac6792b4b6f {} + >> /etc/rsctf-flag-targets 2>/dev/null || true; \
      fi; \
    done; \
    find / -xdev -maxdepth 1 -type f -exec grep -lF -e RSCTF_DYNAMIC_FLAG_36f4b0e27ebec801ae299b971aea29b90711e003a0d3a41c6ca396cc653c5fbd3 -e RSCTF_DYNAMIC_FLAG_341de9eed62d5e631b6368699e0b0154249687f5a1ac6792b4b6f {} + >> /etc/rsctf-flag-targets 2>/dev/null || true; \
    sort -u /etc/rsctf-flag-targets > /etc/rsctf-flag-targets.sorted; \
    mv /etc/rsctf-flag-targets.sorted /etc/rsctf-flag-targets; \
    while IFS= read -r target; do \
      [ -f "$target" ] || continue; \
      chmod a+w "$target"; \
      parent=$(dirname "$target"); \
      while [ "$parent" != / ]; do chmod a+x "$parent"; parent=$(dirname "$parent"); done; \
    done < /etc/rsctf-flag-targets
ENTRYPOINT ["/usr/local/bin/rsctf-entrypoint", "/usr/local/bin/rsctf-start"]
