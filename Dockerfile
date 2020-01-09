FROM nginx:latest

ENV DEBIAN_FRONTEND=noninteractive

VOLUME /var/log/nginx

COPY ./nginx/ /opt/nginx/

CMD ["/opt/nginx/entrypoint.sh"]
