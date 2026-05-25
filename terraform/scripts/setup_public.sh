#!/bin/bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$UBUNTU_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
#-----------
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
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
        resolver 127.0.0.1 valid=10s;
        location /gitea/{
        set \$gitea http://gitea:3000;
        proxy_pass \$gitea/;
        }
        location /vscode/{
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

# Docker Compose
cat <<EOF > docker-compose.yml
services:
  nginx:
    image: nginx:latest
    ports: ["80:80"]
    volumes: ["./nginx.conf:/etc/nginx/nginx.conf:ro"]
    depends-on:
     gitea
     vscode
  gitea:
    image: gitea/gitea:latest
    ports: ["3000:3000"]
  vscode:
    image: codercom/code-server:latest
    ports: ["8080:8080"]
    environment: ["PASSWORD=demo123"]
EOF
docker compose up -d
