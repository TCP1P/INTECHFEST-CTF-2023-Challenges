#!/bin/sh
set -eu
: "${RSCTF_FLAG:?RSCTF_FLAG is required}"

if ! grep -Eq '(^|[[:space:]])db([[:space:]]|$)' /etc/hosts; then
  printf '127.0.0.1 db\n' >> /etc/hosts
fi

mkdir -p /data/db
chown -R mongodb:mongodb /data/db
mongod --bind_ip 127.0.0.1 --dbpath /data/db --fork --logpath /tmp/mongod.log

attempt=0
until mongosh --quiet --host 127.0.0.1 --eval 'quit(db.adminCommand({ ping: 1 }).ok ? 0 : 1)' >/dev/null 2>&1; do
  attempt=$((attempt + 1))
  [ "$attempt" -lt 60 ] || { cat /tmp/mongod.log >&2; exit 1; }
  sleep 1
done

mongosh --quiet --host 127.0.0.1 --eval '
  const target = db.getSiblingDB("flagdb");
  target.flag.drop();
  target.flag.insertMany([
    {flag: "fake flag 1"},
    {flag: "fake flag 2"},
    {flag: process.env.RSCTF_FLAG},
    {flag: "fake flag 3"}
  ]);
' >/dev/null

exec socat TCP-LISTEN:8080,reuseaddr,fork EXEC:/app/app.sh,pty,stderr,su=ctf
