#!/bin/sh
set -eu
: "${RSCTF_FLAG:?RSCTF_FLAG is required}"

export TARGET_USERNAME=dimas
export TARGET_PASSWORD="$RSCTF_FLAG"
export APPURL=http://127.0.0.1
export PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome

exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
