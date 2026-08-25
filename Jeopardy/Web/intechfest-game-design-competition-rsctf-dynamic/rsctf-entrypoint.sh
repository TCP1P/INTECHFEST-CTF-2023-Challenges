#!/bin/sh
set -eu
: "${RSCTF_FLAG:?RSCTF_FLAG is required}"
export FLAG="$RSCTF_FLAG" APPFLAG="$RSCTF_FLAG" CTF_FLAG="$RSCTF_FLAG" GZCTF_FLAG="$RSCTF_FLAG" APPSEED="$RSCTF_FLAG"
export FLAG_FILE="${RSCTF_FLAG_FILE:-/flag}" GZCTF_FLAG_FILE="${RSCTF_FLAG_FILE:-/flag}"
marker=RSCTF_DYNAMIC_FLAG_7f87a9ed6d0708c2f9d7c92adc995687a64ae3687
payload_marker=RSCTF_DYNAMIC_FLAG_caf3782278bf0ee8c87fe03aebe0e
rsctf_payload=${RSCTF_FLAG#*\{}
rsctf_payload=${rsctf_payload%\}}
if [ -f /etc/rsctf-flag-targets ]; then
  while IFS= read -r target; do
    [ -f "$target" ] || continue
    temporary=${TMPDIR:-/tmp}/rsctf-flag.$$
    sed -e "s|${marker}|${RSCTF_FLAG}|g" -e "s|${payload_marker}|${rsctf_payload}|g" "$target" > "$temporary"
    cat "$temporary" > "$target"
    unlink "$temporary"
  done < /etc/rsctf-flag-targets
fi
if [ -x /usr/local/bin/rsctf-prepare-flag ]; then /usr/local/bin/rsctf-prepare-flag; fi
[ "$#" -gt 0 ] || { echo 'RSCTF runtime has no command' >&2; exit 1; }
if [ "$(id -u)" -eq 0 ]; then
  chmod 0400 /root/flag.txt
  exec setpriv --reuid=ctf --regid=ctf --init-groups "$@"
fi
exec "$@"
