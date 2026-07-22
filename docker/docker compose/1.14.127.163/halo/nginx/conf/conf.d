server {
    listen       80;
    server_name  localhost;

    client_max_body_size 100m;   # halo 上传附件限制

    location / {
        proxy_pass http://halo:8090;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
