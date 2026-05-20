#!/bin/bash
dnf update -y
dnf install -y docker
systemctl enable --now docker
mkdir -p /home/ec2-user/nextcloud && cd /home/ec2-user/nextcloud

cat <<EOF > docker-compose.yml
services:
  db:
    image: postgres:15
    environment:
      - POSTGRES_PASSWORD=nc_pass
      - POSTGRES_DB=nextcloud
      - POSTGRES_USER=nextcloud
  app:
    image: nextcloud:latest
    ports: ["80:80"]
    environment:
      - POSTGRES_HOST=db
      - POSTGRES_DB=nextcloud
      - POSTGRES_USER=nextcloud
      - POSTGRES_PASSWORD=nc_pass
      - NEXTCLOUD_ADMIN_USER=admin
      - NEXTCLOUD_ADMIN_PASSWORD=ProyectoNC123
      - NEXTCLOUD_TRUSTED_DOMAINS=*
      # --- CONTROL DE ACCESO ESTRICTO ---
      - TRUSTED_PROXIES=10.0.1.0/24  # Solo acepta peticiones que vengan de la subred pública (Nginx)
EOF
docker compose up -d
