# Shell Agent Dockerfile
# 标签: shell-runner
# 工具: shellcheck, bats-core, jq, rsync, sshpass, git, curl
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# 安装 SSH + Java + Shell 工具
RUN apt-get update && apt-get install -y \
    openssh-server \
    openjdk-21-jdk-headless \
    shellcheck \
    jq \
    rsync \
    sshpass \
    git \
    curl \
    && apt-get clean

# 安装 bats-core（Shell 脚本测试框架）
RUN git clone https://github.com/bats-core/bats-core.git /tmp/bats-core && \
    cd /tmp/bats-core && ./install.sh /usr/local && \
    rm -rf /tmp/bats-core

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