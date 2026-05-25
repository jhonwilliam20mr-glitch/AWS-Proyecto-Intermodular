#!/bin/bash

# ---------------------------
# ACTUALIZAR SISTEMA
# ---------------------------

dnf update -y

# ---------------------------
# INSTALAR DOCKER
# ---------------------------

dnf install -y docker

# Iniciar Docker
systemctl enable docker
systemctl start docker

# ---------------------------
# INSTALAR DOCKER COMPOSE
# ---------------------------

curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 \
-o /usr/local/bin/docker-compose

chmod +x /usr/local/bin/docker-compose

# ---------------------------
# CREAR DIRECTORIO APP
# ---------------------------

mkdir -p /home/ec2-user/app
cd /home/ec2-user/app

# ---------------------------
# CONFIG NGINX
# ---------------------------

cat <<EOF > nginx.conf
events {}

http {

    upstream nextcloud_backend {
        server 10.0.2.110:80;
        server 10.0.2.120:80;
    }

    server {

        listen 80;

        resolver 127.0.0.1 valid=10s;

        location /gitea/ {
            set \$gitea http://gitea:3000;
            proxy_pass \$gitea/;
        }

        location /vscode/ {
            set \$vscode http://vscode:8080;
            proxy_pass \$vscode/;
        }

        location /nextcloud/ {

            proxy_pass http://nextcloud_backend/;

            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        }
    }
}
EOF

# ---------------------------
# DOCKER COMPOSE
# ---------------------------

cat <<EOF > docker-compose.yml
services:

  nginx:
    image: nginx:latest

    ports:
      - "80:80"

    volumes:
      - "./nginx.conf:/etc/nginx/nginx.conf:ro"

    depends_on:
      - gitea
      - vscode

  gitea:
    image: gitea/gitea:latest

    ports:
      - "3000:3000"

  vscode:
    image: codercom/code-server:latest

    ports:
      - "8080:8080"

    environment:
      - PASSWORD=demo123

EOF

# ---------------------------
# LEVANTAR CONTENEDORES
# ---------------------------

docker-compose up -d
