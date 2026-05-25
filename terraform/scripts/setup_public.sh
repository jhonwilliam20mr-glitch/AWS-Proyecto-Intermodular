#!/bin/bash

# Actualizar paquetes
apt-get update -y

# Instalar dependencias necesarias
apt-get install -y ca-certificates curl gnupg

# Crear carpeta para claves GPG
install -m 0755 -d /etc/apt/keyrings

# Descargar clave GPG oficial de Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Añadir repositorio oficial Docker
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$UBUNTU_CODENAME") stable" | \
tee /etc/apt/sources.list.d/docker.list > /dev/null

# Actualizar repositorios nuevamente
apt-get update -y

# Instalar Docker y Docker Compose
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Activar Docker
systemctl enable docker
systemctl start docker

# Crear directorio de la app
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

# Levantar contenedores
docker compose up -d
