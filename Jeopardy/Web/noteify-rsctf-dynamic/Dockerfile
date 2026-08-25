FROM golang:1.20-bookworm AS backend-builder
RUN apt-get update \
    && apt-get install -y --no-install-recommends gcc libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /build/backend
COPY backend/go.mod backend/go.sum ./
RUN go mod download
COPY backend/ ./
RUN CGO_ENABLED=1 go build -trimpath -ldflags="-s -w" -o /out/noteify .

FROM node:18-bookworm AS frontend-builder
WORKDIR /build/front
COPY front/package.json front/package-lock.json ./
RUN npm ci
COPY front/ ./
RUN npm run build

FROM node:18-bookworm AS bot-builder
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
WORKDIR /build/bot
COPY bot/package.json bot/package-lock.json ./
RUN npm ci --omit=dev
COPY bot/ ./

FROM node:18-bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates chromium fonts-liberation libsqlite3-0 nginx supervisor \
    && rm -rf /var/lib/apt/lists/* \
    && ln -sf /usr/bin/chromium /usr/bin/google-chrome

COPY --from=backend-builder /out/noteify /app/backend/noteify
COPY --from=frontend-builder /build/front /app/front
COPY --from=bot-builder /build/bot /app/bot
COPY nginx.conf /etc/nginx/sites-available/default
COPY supervisord.conf /etc/supervisor/conf.d/rsctf.conf
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
    for root in /usr/local/bin/rsctf-start /etc/supervisor/conf.d/rsctf.conf /etc/nginx/sites-available/default /app/bot /app/front /app/backend/noteify /build/bot /app /src /srv /home /opt /var/www /challenge /chall /ctf /root /usr/src /usr/local/bin /workspace /flag /flag.txt; do \
      if [ -e "$root" ]; then \
        find "$root" -xdev -type f ! -path /usr/local/bin/rsctf-entrypoint -exec grep -lF -e RSCTF_DYNAMIC_FLAG_07e3e9ba0a0efacae5d16f26f8784a114e838353d9de72832f763a03e -e RSCTF_DYNAMIC_FLAG_f582ffb9d2ba45ea5ef8b9cfcd8b297ed2e690a51f642 {} + >> /etc/rsctf-flag-targets 2>/dev/null || true; \
      fi; \
    done; \
    find / -xdev -maxdepth 1 -type f -exec grep -lF -e RSCTF_DYNAMIC_FLAG_07e3e9ba0a0efacae5d16f26f8784a114e838353d9de72832f763a03e -e RSCTF_DYNAMIC_FLAG_f582ffb9d2ba45ea5ef8b9cfcd8b297ed2e690a51f642 {} + >> /etc/rsctf-flag-targets 2>/dev/null || true; \
    sort -u /etc/rsctf-flag-targets > /etc/rsctf-flag-targets.sorted; \
    mv /etc/rsctf-flag-targets.sorted /etc/rsctf-flag-targets; \
    while IFS= read -r target; do \
      [ -f "$target" ] || continue; \
      chmod a+w "$target"; \
      parent=$(dirname "$target"); \
      while [ "$parent" != / ]; do chmod a+x "$parent"; parent=$(dirname "$parent"); done; \
    done < /etc/rsctf-flag-targets
ENTRYPOINT ["/usr/local/bin/rsctf-entrypoint", "/usr/local/bin/rsctf-start"]
