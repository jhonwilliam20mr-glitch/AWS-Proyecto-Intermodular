#!/bin/bash
apt update -y
apt install -y docker docker-compose
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
