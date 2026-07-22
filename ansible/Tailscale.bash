sudo tee /etc/yum.repos.d/tailscale.repo << EOF
[tailscale]
name=Tailscale
baseurl=https://pkgs.tailscale.com/stable/centos/\$releasever/\$basearch
enabled=1
gpgcheck=1
gpgkey=https://pkgs.tailscale.com/stable/centos/\$releasever/\$basearch/repo.gpg
EOF

sudo rpm --import https://pkgs.tailscale.com/stable/centos/7/repo.gpg
 #如果遇见404情况就
 ## 尝试手动导入官方 key (Tailscale 通用密钥)
## sudo rpm --import https://pkgs.tailscale.com/stable/centos/7/repo.gpg
# 安装 Tailscale（CentOS 7 使用 yum，Rocky/Fedora 使用 dnf）
sudo yum  install tailscale -y  # 或 sudo yum install tailscale -y

# 启动服务并设置开机自启（systemd 系统）
sudo systemctl enable --now tailscaled

#登录
#sudo tailscale up
#会生成连接

#加入网络
tailscale up --auth-key=tskey-auth-kvtZE5xPGG11CNTRL-x4tCcDwMKagcfbqdpKLPZgV1BHJrZ6an4
#15:08 等会要去按摩 总结一下目前情况，安装脚本那条命令不管用 需要使用以上命令安装，所以现在需要将以上
##bash命令修改为playbook（适合ansible)执行的yaml脚本
