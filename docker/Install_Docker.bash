#!/bin/bash
# ============================================================
# 脚本名称: install_docker_centos.sh
# 功能描述: CentOS 生产环境一键安装 Docker（官方源）
# 支持系统: CentOS 7, 8, 9（及 RHEL 兼容发行版）
# 使用方法: sudo bash install_docker_centos.sh
# ============================================================

set -e

# ---------- 颜色 ----------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'
info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1" >&2; exit 1; }

# ---------- 检查 root 权限 ----------
if [ "$EUID" -ne 0 ]; then
    error "请使用 root 或 sudo 执行此脚本。"
fi

# ---------- 仅支持 CentOS/RHEL ----------
if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [[ ! "$ID" =~ ^(centos|rhel)$ ]]; then
        error "此脚本仅支持 CentOS 或 RHEL 系统，检测到: $ID"
    fi
else
    error "无法识别操作系统，缺少 /etc/os-release。"
fi

info "系统检测通过: $ID $VERSION_ID"

# ---------- 1. 卸载旧版本 ----------
info "移除旧版本 Docker（如有）..."
yum remove -y docker \
    docker-client \
    docker-client-latest \
    docker-common \
    docker-latest \
    docker-latest-logrotate \
    docker-logrotate \
    docker-engine 2>/dev/null || true

# ---------- 2. 安装依赖 ----------
info "安装依赖工具 yum-utils ..."
yum install -y yum-utils device-mapper-persistent-data lvm2

# ---------- 3. 添加 Docker 官方仓库 ----------
info "添加 Docker 官方 yum 仓库..."
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# ---------- 4. 安装 Docker Engine ----------
info "安装 Docker CE、CLI 和 containerd ..."
yum install -y docker-ce docker-ce-cli containerd.io

# ---------- 5. 配置镜像加速（可选，默认天翼云） ----------
info "配置镜像加速器（天翼云镜像站）..."
mkdir -p /etc/docker
cat > /etc/docker/daemon.json <<EOF
{
  "registry-mirrors": ["https://docker.mirrors.ctyun.cn"]
}
EOF

# ---------- 6. 启动并设置开机自启 ----------
info "启动 Docker 并设置开机自启..."
systemctl start docker
systemctl enable docker

# ---------- 7. 将当前用户加入 docker 组（免 sudo） ----------
if [ -n "$SUDO_USER" ]; then
    info "将用户 $SUDO_USER 加入 docker 组（需重新登录生效）..."
    groupadd docker 2>/dev/null || true
    usermod -aG docker "$SUDO_USER"
    warn "请重新登录或执行 'newgrp docker' 使组权限生效。"
fi

# ---------- 8. 验证 ----------
info "验证 Docker 安装..."
docker --version
if docker run --rm hello-world >/dev/null 2>&1; then
    info "✅ hello-world 测试通过，安装成功！"
else
    warn "hello-world 测试失败，请手动排查。"
fi

info "🎉 CentOS Docker 安装完成！"