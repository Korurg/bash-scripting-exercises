FROM nginx

ARG WP_USER

ARG LC_ALL=C.UTF-8
ENV LC_ALL=$LC_ALL

ARG WP_PASSWORD=password
ENV WP_PASSWORD=$WP_PASSWORD

ARG WP_PATH=wp
ENV WP_PATH=$WP_PATH

WORKDIR /app

COPY ./nginx .

RUN apt-get update -y \
    && apt-get install gawk -y \
    && apt-get install zip -y \
    && apt-get install apache2-utils -y

RUN mkdir "/etc/apache2" \
    && echo "$WP_USER" > "user.txt" \
    && htpasswd -c -b "/etc/apache2/.htpasswd" "$WP_USER" "$WP_PASSWORD" \
    && envsubst "${WP_PATH}" < "/app/default.conf" > "/etc/nginx/conf.d/default.conf" \
    && mkdir -p "/opt/html/root" \
    && bash "/app/top-words.sh" > "/opt/html/root/static.html" \
    && echo "<br>" >> "/opt/html/root/static.html" \
    && awk 'BEGIN{ORS="<br>"} 1' < "/etc/os-release" >> "/opt/html/root/static.html" \
    && printenv | awk 'BEGIN{ORS="<br>"} 1' > "/opt/html/root/index.html"