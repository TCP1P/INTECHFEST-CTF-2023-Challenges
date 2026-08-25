#!/bin/sh
set -eu
: "${RSCTF_FLAG:?RSCTF_FLAG is required}"

export database_default_DBDriver=MySQLi
export database_default_hostname=127.0.0.1
export database_default_port=3306
export database_default_database=ci4
export database_default_username=ci4
export database_default_password=ci4

if [ ! -d /var/lib/mysql/mysql ]; then
  mariadb-install-db --user=mysql --datadir=/var/lib/mysql >/dev/null
fi
mysqld_safe --skip-syslog --bind-address=127.0.0.1 >/tmp/mariadb.log 2>&1 &

attempt=0
until mariadb-admin ping --silent >/dev/null 2>&1; do
  attempt=$((attempt + 1))
  [ "$attempt" -lt 60 ] || { cat /tmp/mariadb.log >&2; exit 1; }
  sleep 1
done

mariadb -uroot <<'SQL'
CREATE DATABASE IF NOT EXISTS ci4 CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
CREATE USER IF NOT EXISTS 'ci4'@'localhost' IDENTIFIED BY 'ci4';
CREATE USER IF NOT EXISTS 'ci4'@'127.0.0.1' IDENTIFIED BY 'ci4';
GRANT ALL PRIVILEGES ON ci4.* TO 'ci4'@'localhost';
GRANT ALL PRIVILEGES ON ci4.* TO 'ci4'@'127.0.0.1';
FLUSH PRIVILEGES;
SQL

php spark migrate --all
exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
