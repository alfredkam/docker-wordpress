#!/usr/bin/env bash

build_dir=$1
cache_dir=$2

# fail fast
set -e

echo "-----> Installing nginx-light with apt-get"

apt-get -y update
apt-get -y install nginx-light

echo "       Nginx installed"

echo "-----> Adding Nginx config"

cat > $build_dir/.nginx.conf <<STUFF
daemon off;
error_log stderr;
worker_processes 1;

events {
    worker_connections 1024;
}
http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    access_log /dev/stdout;

    server {
        listen 5000;
        port_in_redirect off;

        location / {
            root "/app/";
            autoindex on;
            try_files $uri $uri/ /index.html;
        }

        error_page 404 /404.html;

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
            root "/app/";
        }

        # pass the PHP scripts to FastCGI server listening on the php-fpm socket
        location ~ \.php$ {
                try_files $uri =404;
                fastcgi_pass unix:/var/run/php5-fpm.sock;
                fastcgi_index index.php;
                fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
                include fastcgi_params;

        }
    }
}
STUFF
