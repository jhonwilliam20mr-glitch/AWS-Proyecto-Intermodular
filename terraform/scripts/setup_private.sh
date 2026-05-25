#!/bin/bash
dnf update -y
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
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
      ports: ["5432:5432"]
EOF
docker compose up -d
