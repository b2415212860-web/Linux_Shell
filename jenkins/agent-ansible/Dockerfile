# Ansible Agent Dockerfile
# 标签: ansible-runner
# 工具: Ansible, ansible-lint, molecule
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# 安装 SSH + Java + Ansible 基础工具
RUN apt-get update && apt-get install -y \
    openssh-server \
    openjdk-21-jdk-headless \
    python3 \
    python3-pip \
    python3-venv \
    ansible \
    git \
    curl \
    && apt-get clean

# 安装 Ansible 代码检查和测试工具
RUN pip3 install ansible-lint molecule

# 创建 Jenkins 用户
RUN useradd -m -s /bin/bash jenkins && \
    echo "jenkins:jenkins" | chpasswd && \
    mkdir -p /home/jenkins/.ssh && \
    chown -R jenkins:jenkins /home/jenkins

# 配置 SSH 允许密码登录
RUN mkdir -p /var/run/sshd && \
    sed -i 's/#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]