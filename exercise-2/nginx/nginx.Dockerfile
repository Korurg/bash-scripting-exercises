FROM nginx

ARG WP_USER

ENV LC_ALL=C.UTF-8

ENV WP_PASSWORD=password

WORKDIR /app

RUN apt-get update -y \
    && apt-get install gawk -y \
    && apt-get install zip -y \
    && apt-get install apache2-utils -y

COPY ./nginx .

RUN mkdir "/etc/apache2" \
    && htpasswd -c -b "/etc/apache2/.htpasswd" "$WP_USER" "$WP_PASSWORD" \
    && mkdir "/etc/nginx/templates" \
    && cp "/app/default.conf.template" "/etc/nginx/templates/default.conf.template" \
    && mkdir -p "/opt/html/root" \
    && bash "/app/top-words.sh" > "/opt/html/root/static.html" \
    && echo "<br>" >> "/opt/html/root/static.html" \
    && awk 'BEGIN{ORS="<br>"} 1' < "/etc/os-release" >> "/opt/html/root/static.html" \
    && printenv | awk 'BEGIN{ORS="<br>"} 1' > "/opt/html/root/index.html" \
