#!/bin/bash
dnf update -y
dnf install -y docker
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
systemctl enable --now docker
mkdir -p /home/ec2-user/nextcloud && cd /home/ec2-user/nextcloud

cat <<EOF > docker-compose.yml
services:
  app:
    image: nextcloud:latest
    ports: ["80:80"]
    environment:
      - POSTGRES_HOST=10.0.2.100 # IP de la primera máquina privada
      - POSTGRES_DB=nextcloud
      - POSTGRES_USER=nextcloud
      - POSTGRES_PASSWORD=nc_pass
      - NEXTCLOUD_TRUSTED_DOMAINS=*
       # --- CONTROL DE ACCESO ESTRICTO ---
      - TRUSTED_PROXIES=10.0.1.0/24  # Solo acepta peticiones que vengan de la subred pública (Nginx)
EOF
docker compose up -d
