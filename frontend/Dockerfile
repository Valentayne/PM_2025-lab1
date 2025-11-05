FROM nginx:alpine

COPY . /usr/share/nginx/html

COPY conf/nginx.conf.template /etc/nginx/nginx.conf.template

RUN apk add --no-cache gettext

CMD /bin/sh -c "envsubst '\$PORT \$BACKEND_URL' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf && nginx -g 'daemon off;'"
