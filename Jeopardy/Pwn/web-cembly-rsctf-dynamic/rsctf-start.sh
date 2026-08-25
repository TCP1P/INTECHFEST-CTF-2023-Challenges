#!/bin/sh
set -eu
: "${RSCTF_FLAG:?RSCTF_FLAG is required}"

if ! grep -Eq '(^|[[:space:]])app([[:space:]]|$)' /etc/hosts; then
  printf '127.0.0.1 app\n' >> /etc/hosts
fi

exec /usr/bin/supervisord -c /etc/supervisord.conf
