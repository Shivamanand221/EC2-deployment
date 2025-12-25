#!/bin/bash

set -e

apt-get update -y
apt-get upgrade -y

apt-get install -y ca-certificates curl gnupg lsb-release
curl -fsSL https://get.docker.com | sh

systemctl start docker
systemctl enable docker
usermod -aG docker ubuntu

curl -L https://github.com/docker/compose/releases/download/v2.25.0/docker-compose-linux-x86_64 \
  -o /usr/local/bin/docker-compose

chmod +x /usr/local/bin/docker-compose

mkdir -p /opt/strapi
chown ubuntu:ubuntu /opt/strapi

cd /opt/strapi

cat <<EOF > docker-compose.yml
version: "3.9"
services:
      
  postgres:
    image: postgres:15
    container_name: strapi_postgres
    environment:
      POSTGRES_DB: strapi
      POSTGRES_USER: strapi
      POSTGRES_PASSWORD: strapi
    volumes:
      - pgdata:/var/lib/postgresql/data

  strapi:
    image: shivamanand221/strapi:latest
    container_name: strapi
    environment:
      DATABASE_CLIENT: postgres
      DATABASE_HOST: postgres
      DATABASE_PORT: 5432
      DATABASE_NAME: strapi
      DATABASE_USERNAME: strapi
      DATABASE_PASSWORD: strapi

      APP_KEYS: rlkHtEO3OmbvRD3ttbfcWw==,VeEdQy7xarlWwkBXQm6ivg==,FLiOSPzqC64SaOhVLULx/Q==,wclX3ufFrkjj/uCXv9AsuA==
      API_TOKEN_SALT: lmKXY7Vr0z4jJR2msi+fwA==
      ADMIN_JWT_SECRET: JNrFoapKZUbtX1RUWD3twg==
      TRANSFER_TOKEN_SALT: WRCFuoWJ27cqvGG8FHD6rQ==
      ENCRYPTION_KEY: M4M+D4fk6vADAYNqoEhisw==
      JWT_SECRET: ZLoCAamyFMM3cH7hFn3e1w==
      
    ports:
      - "1337:1337"
    depends_on:
      - postgres

volumes:
  pgdata: {}
EOF
docker-compose pull
docker-compose up -d