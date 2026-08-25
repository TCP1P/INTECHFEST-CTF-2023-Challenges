FROM rust:1.70-bookworm AS builder

RUN rustup toolchain install nightly-2023-06-01 --profile minimal

WORKDIR /build
COPY Cargo.toml Cargo.lock ./
COPY src/ src/
COPY readflag.c /tmp/readflag.c
RUN cargo +nightly-2023-06-01 build --release --locked \
    && gcc -O2 -o /tmp/readflag /tmp/readflag.c

FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates rustc wget \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=builder /build/target/release/gdc-bin /app/gdc-bin
COPY templates/ /app/templates/
COPY static/ /app/static/
COPY Rocket.toml /app/Rocket.toml
COPY flag.txt /root/flag.txt
COPY --from=builder /tmp/readflag /readflag
RUN chown root:root /readflag /root/flag.txt \
    && chmod 4755 /readflag \
    && chmod 0400 /root/flag.txt \
    && useradd --create-home --shell /bin/bash ctf \
    && chown -R ctf:ctf /app \
    && chmod 0700 /app

ENV ROCKET_ENV=production
EXPOSE 80
CMD ["/app/gdc-bin"]

# RSCTF dynamic-flag compatibility layer. The build-time scan records
# exact marker-bearing files; runtime replacement is therefore bounded
# to those files instead of walking the image on every team start.
USER root
COPY rsctf-entrypoint.sh /usr/local/bin/rsctf-entrypoint
RUN set -eu; \
    chmod 0555 /usr/local/bin/rsctf-entrypoint; \
    : > /etc/rsctf-flag-targets; \
    for root in /tmp/readflag.c /root/flag.txt /app/Rocket.toml /app/static /app/templates /app/gdc-bin /app/src /app /src /srv /home /opt /var/www /challenge /chall /ctf /root /usr/src /usr/local/bin /workspace /flag /flag.txt; do \
      if [ -e "$root" ]; then \
        find "$root" -xdev -type f ! -path /usr/local/bin/rsctf-entrypoint -exec grep -lF -e RSCTF_DYNAMIC_FLAG_7f87a9ed6d0708c2f9d7c92adc995687a64ae3687 -e RSCTF_DYNAMIC_FLAG_caf3782278bf0ee8c87fe03aebe0e {} + >> /etc/rsctf-flag-targets 2>/dev/null || true; \
      fi; \
    done; \
    find / -xdev -maxdepth 1 -type f -exec grep -lF -e RSCTF_DYNAMIC_FLAG_7f87a9ed6d0708c2f9d7c92adc995687a64ae3687 -e RSCTF_DYNAMIC_FLAG_caf3782278bf0ee8c87fe03aebe0e {} + >> /etc/rsctf-flag-targets 2>/dev/null || true; \
    sort -u /etc/rsctf-flag-targets > /etc/rsctf-flag-targets.sorted; \
    mv /etc/rsctf-flag-targets.sorted /etc/rsctf-flag-targets; \
    while IFS= read -r target; do \
      [ -f "$target" ] || continue; \
      chmod a+w "$target"; \
      parent=$(dirname "$target"); \
      while [ "$parent" != / ]; do chmod a+x "$parent"; parent=$(dirname "$parent"); done; \
    done < /etc/rsctf-flag-targets
ENTRYPOINT ["/usr/local/bin/rsctf-entrypoint"]
