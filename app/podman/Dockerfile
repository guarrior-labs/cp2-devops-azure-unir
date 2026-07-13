FROM docker.io/library/nginx:alpine

COPY html/ /usr/share/nginx/html/

COPY nginx/default.conf /etc/nginx/conf.d/default.conf

COPY cert/server.crt /etc/nginx/certs/server.crt
COPY cert/server.key /etc/nginx/certs/server.key
COPY cert/.htpasswd /etc/nginx/certs/.htpasswd

EXPOSE 80
EXPOSE 8443
