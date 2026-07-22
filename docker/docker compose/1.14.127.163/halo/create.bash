mkdir -p ./halo/data

mkdir -p ./postgresql/data

mkdir -p ./nginx/{conf.d,certs,logs}

touch ./nginx/nginx.conf
touch ./nginx/conf.d/halo.conf

#touch ./nginx/certs/{example.com.crt,example.com.key}

cat > ./nginx/nginx.conf << 'EOF'
user nginx;
worker_processes auto;

error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

events {
    worker_connections 10240;
}

http {

    include       mime.types;
    default_type  application/octet-stream;

    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;

    keepalive_timeout 65;

    client_max_body_size 100m;

    gzip on;
    gzip_comp_level 6;

    access_log /var/log/nginx/access.log;

    include /etc/nginx/conf.d/*.conf;
}
EOF

cat > ./nginx/conf.d/halo.conf << 'EOF'
server {

    listen 80;

    server_name www.longtrail.cloud;

    client_max_body_size 100M;

    access_log /var/log/nginx/halo.access.log;
    error_log  /var/log/nginx/halo.error.log;

    location / {

        proxy_pass http://halo:8090;

        proxy_http_version 1.1;

        proxy_set_header Host $host;

        proxy_set_header X-Real-IP $remote_addr;

        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

        proxy_set_header X-Forwarded-Proto $scheme;

        proxy_set_header Upgrade $http_upgrade;

        proxy_set_header Connection "upgrade";

        proxy_read_timeout 300;

        proxy_buffering off;

    }

}
EOF