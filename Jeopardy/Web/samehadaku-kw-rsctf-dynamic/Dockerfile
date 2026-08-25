FROM python:3.11-alpine

WORKDIR /app
COPY server/requirements.txt ./requirements.txt
RUN pip install --no-cache-dir -r requirements.txt \
    && adduser -D ctf

COPY --chown=ctf:ctf server/ /app/
COPY flag.txt /flag.txt
RUN random_name="$(python -c 'import os; print(os.urandom(16).hex(), end="")')" \
    && mv /flag.txt "/${random_name}.txt"

USER ctf
EXPOSE 8000
CMD ["./run.sh"]

# RSCTF dynamic-flag compatibility layer. The build-time scan records
# exact marker-bearing files; runtime replacement is therefore bounded
# to those files instead of walking the image on every team start.
USER root
COPY rsctf-entrypoint.sh /usr/local/bin/rsctf-entrypoint
RUN set -eu; \
    chmod 0555 /usr/local/bin/rsctf-entrypoint; \
    : > /etc/rsctf-flag-targets; \
    for root in /app/requirements.txt /app /src /srv /home /opt /var/www /challenge /chall /ctf /root /usr/src /usr/local/bin /workspace /flag /flag.txt; do \
      if [ -e "$root" ]; then \
        find "$root" -xdev -type f ! -path /usr/local/bin/rsctf-entrypoint -exec grep -lF -e RSCTF_DYNAMIC_FLAG_6397636d63e601ebd118412ec4b0f352ee037c4fea137c6e5ba0b2c57 -e RSCTF_DYNAMIC_FLAG_227062fa77e5db0afca9b6b9aa18cd18eda27feefb1a5 {} + >> /etc/rsctf-flag-targets 2>/dev/null || true; \
      fi; \
    done; \
    find / -xdev -maxdepth 1 -type f -exec grep -lF -e RSCTF_DYNAMIC_FLAG_6397636d63e601ebd118412ec4b0f352ee037c4fea137c6e5ba0b2c57 -e RSCTF_DYNAMIC_FLAG_227062fa77e5db0afca9b6b9aa18cd18eda27feefb1a5 {} + >> /etc/rsctf-flag-targets 2>/dev/null || true; \
    sort -u /etc/rsctf-flag-targets > /etc/rsctf-flag-targets.sorted; \
    mv /etc/rsctf-flag-targets.sorted /etc/rsctf-flag-targets; \
    while IFS= read -r target; do \
      [ -f "$target" ] || continue; \
      chmod a+w "$target"; \
      parent=$(dirname "$target"); \
      while [ "$parent" != / ]; do chmod a+x "$parent"; parent=$(dirname "$parent"); done; \
    done < /etc/rsctf-flag-targets
USER ctf
ENTRYPOINT ["/usr/local/bin/rsctf-entrypoint"]
