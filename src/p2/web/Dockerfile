FROM nginx:alpine

COPY html/index.html /usr/share/nginx/html/index.html.tmpl
COPY html/main.css /usr/share/nginx/html/
COPY html/logo.svg /usr/share/nginx/html/
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
