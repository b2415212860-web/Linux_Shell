#!/bin/bash

# 1. 递归创建数据目录和配置目录
mkdir -p /data/redis/data
mkdir -p /data/redis/conf

# 2. 创建配置文件
touch /data/redis/conf/redis.conf

# 3. 创建 docker-compose 目录及文件
mkdir -p /opt/dockercompose/redis/
touch /opt/dockercompose/redis/docker-compose.yaml

# 4. 写入配置（已清理所有非法空格，全部为标准半角空格）
cat > /opt/dockercompose/redis/docker-compose.yaml << 'EOF'
version: '3.8'

services:
  redis:
    image: redis:latest
    container_name: redis
    ports:
      - "6379:6379"
    volumes:
      - /data/redis/data:/data
      - /data/redis/conf/redis.conf:/etc/redis/redis.conf
    restart: unless-stopped
    command: redis-server /etc/redis/redis.conf
EOF

# 5. 启动服务
docker-compose -f /opt/dockercompose/redis/docker-compose.yaml up -d