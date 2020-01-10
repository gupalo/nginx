#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

[ -z "${APP_WORKDIR}" ] && APP_WORKDIR="/code/public/"
[ -z "${APP_DOMAIN}" ] && APP_DOMAIN="_"
[ -z "${PHP_APP_FILE}" ] && PHP_APP_FILE="index.php"
[ -z "${PHP_APP_FILE_REGEX}" ] && PHP_APP_FILE_REGEX=${PHP_APP_FILE/\./\\\.}
[ -z "${PHP_HOST}" ] && PHP_HOST="fpm"
[ -z "${PHP_PORT}" ] && PHP_PORT="9000"
[ -z "${REMOTE_ADDR_PARAM}" ] && REMOTE_ADDR_PARAM="http_x_real_ip" # if you don't have X-Real-IP, you can use "remote_addr"
[ -z "${PHP_TIMEOUT}" ] && PHP_TIMEOUT="600"
[ -z "${SEND_TIMEOUT}" ] && SEND_TIMEOUT="300"
[ -z "${APP_ENV}" ] && APP_ENV="prod"
[ -z "${LOG}" ] && LOG="2"
[ -z "${VERBOSE}" ] && VERBOSE="1"
[ -z "${HTTPS}" ] && [ "${APP_ENV}" = "dev" ] && HTTPS="0"
[ -z "${HTTPS}" ] && [ "${APP_ENV}" = "prod" ] && HTTPS="1"
[ -z "${SSL}" ] && SSL="${HTTPS}"

cat ${DIR}/nginx.conf \
    | sed "s%{PHP_TIMEOUT}%${PHP_TIMEOUT}%g" \
    | sed "s%{APP_WORKDIR}%${APP_WORKDIR}%g" \
    | sed "s%{APP_DOMAIN}%${APP_DOMAIN}%g" \
    | sed "s%{PHP_APP_FILE}%${PHP_APP_FILE}%g" \
    | sed "s%{PHP_APP_FILE_REGEX}%${PHP_APP_FILE_REGEX}%g" \
    | sed "s%{PHP_HOST}%${PHP_HOST}%g" \
    | sed "s%{PHP_PORT}%${PHP_PORT}%g" \
    | sed "s%{REMOTE_ADDR_PARAM}%${REMOTE_ADDR_PARAM}%g" \
    | sed "s%{SEND_TIMEOUT}%${SEND_TIMEOUT}%g" \
    | sed "s%{HTTPS}%${HTTPS}%g" \
    | sed "s%{DIR}%${DIR}%g" \
    > /etc/nginx/nginx.conf

[[ "${APP_ENV}" = "dev" ]] && sed -i 's/sendfile on/sendfile off/' /etc/nginx/nginx.conf

if [[ "${SSL}" = "1" ]] && [[ -e "/etc/nginx/ssl/fullchain.pem" ]]; then
    sed -i 's/###SSL //' /etc/nginx/nginx.conf
    sed -i 's/listen 80; #default/#listen 80; #default/' /etc/nginx/nginx.conf
fi

if [[ "${LOG}" = "1" ]] || [[ "${LOG}" = "0" ]] ; then
    sed -i 's/access_log /access_log off;#/' /etc/nginx/nginx.conf

    [[ "${LOG}" = "0" ]] && sed -i 's/error_log /error_log off;#/' /etc/nginx/nginx.conf
fi

[[ -e ${DIR}/fix.sh ]] && ${DIR}/fix.sh
[[ -e ${DIR}/locations.conf ]] && sed -i 's/###LOCATIONS //' /etc/nginx/nginx.conf

[[ "${VERBOSE}" = "1" ]] && nginx -V && echo "" && cat /etc/nginx/nginx.conf

nginx -g "daemon off;"
