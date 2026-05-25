#!/bin/bash
dnf update -y
dnf install -y docker
systemctl enable --now docker
mkdir -p /home/ec2-user/app && cd /home/ec2-user/app

# Crear config de Nginx como Balanceador de Carga
cat <<EOF > nginx.conf
events {}
http {
    upstream nextcloud_backend {
        server 10.0.2.110:80; # Nodo Privado 1
        server 10.0.2.120:80; # Nodo Privado 2
    }

    server {
        listen 80;
        location /gitea/ { proxy_pass http://gitea:3000/; }
        location /vscode/ { proxy_pass http://vscode:8080/; }
        
        location /nextcloud/ { 
            proxy_pass http://nextcloud_backend/; 
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        }
    }
}
EOF

# Docker Compose
cat <<EOF > docker-compose.yml
services:
  nginx:
    image: nginx:latest
    ports: ["80:80"]
    volumes: ["./nginx.conf:/etc/nginx/nginx.conf:ro"]
  gitea:
    image: gitea/gitea:latest
    ports: ["3000:3000"]
  vscode:
    image: codercom/code-server:latest
    ports: ["8080:8080"]
    environment: ["PASSWORD=demo123"]
EOF
docker compose up -d
