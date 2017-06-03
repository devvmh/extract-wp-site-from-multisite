#!/bin/bash

# set these to the correct values
MYSQL_USER='change_me'
MYSQL_DB='change_me'

# no need to change this because it
# will be overwritten if you set a prefix below
FILENAME=wp_.sql

read -p "Enter mysql password for $MYSQL_USER: " MYSQL_PASS
if [[ -z "${MYSQL_PASS}" ]]; then
  echo "exiting, no psasword"
  exit 1
fi
read -p "Enter mysql prefix (default is wp_[^0-9]): " WP_PREFIX
if [[ -z "${WP_PREFIX}" ]]; then
  WP_PREFIX='wp_[^0-9]'
else
  FILENAME=${WP_PREFIX}.sql
fi

TABLES=$(mysql -u ${MYSQL_USER} "-p${MYSQL_PASS}" ${MYSQL_DB} -e 'show tables' | egrep $WP_PREFIX)
if [[ -z "${TABLES}" ]]; then
  echo "no tables found with that prefix"
  exit 2
fi

# the sites all share the wp_users & meta table
if [[ "${WP_PREFIX}" != "wp_[^0-9]" ]]; then
  TABLES="${TABLES} wp_users wp_usermeta"
else
  TABLES=$(echo ${TABLES}) # removes newlines
fi

echo "tables:"
echo $TABLES

echo "dumping to ${FILENAME}"
#mysqldump -u ${MYSQL_USER} "-p${MYSQL_PASS}" ${MYSQL_DB} $(echo ${TABLES}) > "${FILENAME}"
mysqldump -u ${MYSQL_USER} "-p${MYSQL_PASS}" ${MYSQL_DB} ${TABLES} > "${FILENAME}"

if [[ "${FILENAME}" != "wp_.sql" ]]; then
  sed -i'' -e s/${WP_PREFIX}_/wp_/g "${FILENAME}"
fi

echo "transformed sql file is at ./${FILENAME}"
