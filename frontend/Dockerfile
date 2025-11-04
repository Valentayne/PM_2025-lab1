FROM nginx:alpine

COPY . /usr/share/nginx/html

COPY ./conf/nginx.conf.template /etc/nginx/nginx.conf.template

CMD /bin/sh -c "\
  export LISTEN_PORT=\${PORT} && \
  envsubst '\$LISTEN_PORT' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf && \
  nginx -g 'daemon off;'\
"
