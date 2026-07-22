#!/bin/bash
# 开启错误拦截，遇到报错立即停止
set -e

SERVER_ADDR="1.14.127.163"
SERVER_PORT="7000"         # frps 的通信端口
AUTH_TOKEN="b322927"

# 当前虚拟机的专属映射配置
PROXY_NAME="ssh_vm_143"    # 代理名称，如 ssh_vm_a
REMOTE_PORT="60143"        # 注意：端口号不能超过 65535，原 600140 已修改为 60140

echo "[1/6] 正在安装 wget..."
yum install -y wget

echo "[2/6] 正在下载 frp 安装包..."
# 添加重试机制并隐藏大段冗余输出
wget http://ticosnb2k.hn-bkt.clouddn.com/frp_0.70.0_linux_amd64.tar.gz -P /tmp

echo "[3/6] 正在解压并安装..."
tar -zxvf /tmp/frp_0.70.0_linux_amd64.tar.gz -C /tmp > /dev/null
mv /tmp/frp_0.70.0_linux_amd64 /tmp/frp
# 如果之前安装过，覆盖时强制执行
\cp -f /tmp/frp/frpc /usr/local/bin/frpc
chmod +x /usr/local/bin/frpc

echo "[4/6] 正在生成配置文件..."
mkdir -p /etc/frp
cat > /etc/frp/frpc.toml << EOF
serverAddr = "${SERVER_ADDR}"
serverPort = ${SERVER_PORT}
auth.token = "${AUTH_TOKEN}"

[[proxies]]
name = "${PROXY_NAME}"
type = "tcp"
localIP = "127.0.0.1"
localPort = 22
remotePort = ${REMOTE_PORT}
EOF

# 提升安全性：限制配置文件权限
chmod 600 /etc/frp/frpc.toml

echo "[5/6] 正在清理临时文件..."
rm -rf /tmp/frp_0.70.0_linux_amd64* /tmp/frp

echo "[6/6] 正在创建 systemd 守护进程服务..."
cat > /etc/systemd/system/frpc.service <<EOF
[Unit]
Description=Frp Client Service
After=network.target
Wants=network-online.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/frpc -c /etc/frp/frpc.toml
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

echo "🔄 正在刷新系统服务并启动 frpc..."
systemctl daemon-reload
systemctl start frpc
systemctl enable frpc

# 检查启动状态
sleep 1
if systemctl is-active --quiet frpc; then
    echo "✅ frpc 服务已成功启动并设置为开机自启！"
    echo "👉 可以使用命令 ssh -p ${REMOTE_PORT} root@${SERVER_ADDR} 尝试连接。"
else
    echo "❌ frpc 启动失败，请使用 journalctl -u frpc -n 20 查看错误日志。"
fi