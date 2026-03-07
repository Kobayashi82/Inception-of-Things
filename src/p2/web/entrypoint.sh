#!/bin/sh

sed -e "s|APP_NAME|${APP_NAME:-Unknown}|g" /usr/share/nginx/html/index.html.tmpl > /usr/share/nginx/html/index.html

exec nginx -g "daemon off;"
