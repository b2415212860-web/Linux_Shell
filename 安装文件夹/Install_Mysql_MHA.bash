#!/bin/bash
setenforce 0
set -e
HOSTNAME=$(hostname)

IP=$(hostname -I | awk '{print $1}' | cut -d . -f 4)
myslave_passwd='123456'
mha_passwd='manager'
mysql_passwd='123456'
install_yilai
###没写ssh连接 需手动
case "$HOSTNAME" in
    *master*)
        echo "匹配到主库节点..."
        # 写入主库配置
        echo '#写入主库配置'
        cat >> /etc/my.cnf <<-EOF
server-id =${IP}
log_bin = master-bin

# 1. 开启 GTID 模式
gtid_mode = ON
# 2. 强制 GTID 一致性（防止不支持 GTID 的语句被执行）
enforce_gtid_consistency = ON
   
EOF
        systemctl restart mysqld
        sleep 3
        echo '#隐式创建用户 如果是8.0必须先创建用户！！！'
###mysql5.7隐式创建用户 如果是8.0必须先创建用户！！！
        mysql -u root -p"${mysql_passwd}" -e "
        SET GLOBAL validate_password_policy=LOW;
        SET GLOBAL validate_password_length=6;
        grant replication slave on *.* to 'myslave'@'172.21.30.%' identified by '${myslave_passwd}';
        grant all privileges on *.* to 'mha'@'172.21.30.%' identified by '${mha_passwd}';
        flush privileges;
        "
        echo '主从复制结束，接下来开始Mha配置'
        install_mhanode
        ;;
    *slave*)
        echo "匹配到从库节点..."
        # 写入从库配置
        echo '写入从库配置'
        cat >> /etc/my.cnf << EOF
server-id =${IP}
log_bin = slave-bin
relay-log = relay-log-bin
relay-log-index = relay-log-bin.index
read_only=1
# 1. 开启 GTID 模式
gtid_mode = ON
# 2. 强制 GTID 一致性（防止不支持 GTID 的语句被执行）
enforce_gtid_consistency = ON
# 4. 从库必须开启此参数（记录从库重放的日志，级联复制必备）
log_slave_updates = ON

EOF
echo '写入成功'
#重启
        systemctl restart mysqld
        sleep 3
        echo '设置从库 mha'
        #设置从库 mha
        mysql -u root -p"${mysql_passwd}" -e "
        SET GLOBAL validate_password_policy=LOW;
        SET GLOBAL validate_password_length=6;
        grant all privileges on *.* to 'mha'@'172.21.30.%' identified by '${mha_passwd}';
        "
        echo '#设置从库GTID'
        #设置从库GTID
        mysql -u root -p"${mysql_passwd}" -e "
        STOP SLAVE;
        CHANGE MASTER TO 
            MASTER_HOST='172.21.30.149',
            MASTER_USER='myslave', 
            MASTER_PASSWORD='123456', 
            MASTER_AUTO_POSITION=1;   -- 核心：开启自动定位
        START SLAVE;
        "
        echo '设置从库id结束'
        sleep 2
        systemctl restart mysqld
        sleep 10
        echo '查看主从同步'
        ###查看主从同步
        status=$(mysql -u root -p"${mysql_passwd}" -e 'SHOW SLAVE STATUS\G' | grep -E "Slave_IO_Running|Slave_SQL_Running" | awk '{print $2}' | grep -c Yes)
        echo "${status}"
        if [ "${status}" -ne 2 ]; then
             echo "错误：复制未就绪（IO/SQL 线程未全部运行）"
            exit 1
        fi
        install_mhanode
echo "复制建立成功jiesu"
        ;;
    *hmamanager*)
        echo "匹配到HMA管理节点"
        echo "安装mha节点"
        install_mhanode
        echo "安装mhaManager"
        install_mhamanager
        echo '创建工作目录'
        mkdir -p /etc/mha
        mkdir -p /var/log/mha/app1
        touch /etc/mha/app1.cnf
        cat > /etc/mha/app1.cnf << 'EOF'
[server default]
# MHA 管理账户(连接所有 MySQL 节点)
manager_workdir = /var/log/mha/app1
manager_log     = /var/log/mha/app1/manager.log
remote_workdir  = /var/log/mha/app1

# SSH 用户
ssh_user = root
ssh_port = 22

# MySQL 管理账户(三台节点统一为 mha)
user = mha
password = 123456

# 复制账户
repl_user = myslave
repl_password = 123456

# 心跳探测间隔(秒)
ping_interval = 3

# 故障切换脚本(可选,用于 VIP 漂移)
# master_ip_failover_script = /usr/local/bin/master_ip_failover
# master_ip_online_change_script = /usr/local/bin/master_ip_online_change

# 二次检测脚本(可选,降低误判)
# secondary_check_script = /usr/bin/masterha_secondary_check -s node1 -s node2

# ===== 节点定义 =====
[server1]
hostname = 172.21.30.149
port     = 3306
candidate_master = 1    # 优先选为主
check_repl_delay = 0    # 忽略复制延迟检查(按需)

[server2]
hostname = 172.21.30.151
port     = 3306
candidate_master = 1    # B 也作为候选主

[server3]
hostname = 172.21.30.152
port     = 3306
# 不设 candidate_master,则 C 默认不优先
no_master = 0
EOF
masterha_check_ssh  --conf=/etc/mha/app1.cnf
masterha_check_repl --conf=/etc/mha/app1.cnf
touch_mha_service
systemctl daemon-reload
systemctl enable mha
systemctl start mha
systemctl status mha
        ;;
esac

install_mhanode(){
echo '开始安装mhaNode'
cd /usr/local/src
wget https://github.com/yoshinorim/mha4mysql-node/releases/download/v0.58/mha4mysql-node-0.58-0.el7.centos.noarch.rpm
yum localinstall -y mha4mysql-node-0.58-0.el7.centos.noarch.rpm
count=$(ls -l /usr/bin/{apply_diff_relay_logs,save_binary_logs,purge_relay_logs,filter_mysqlbinlog} | grep -c "^-rwx")
if ["${count}" -eq 4]; then
    echo '检查通过 mha核心组件为4'
else
    echo '检查失败，mha核心组件缺失，请使用ls -l /usr/bin/{apply_diff_relay_logs,save_binary_logs,purge_relay_logs,filter_mysqlbinlog}查看缺失组件'

fi
}

install_mhamanager(){
cd /usr/local/src
wget https://github.com/yoshinorim/mha4mysql-manager/releases/download/v0.58/mha4mysql-manager-0.58-0.el7.centos.noarch.rpm

yum localinstall -y mha4mysql-manager-0.58-0.el7.centos.noarch.rpm

# ========== 验证脚本 ==========
# 检查 1:确认 manager 和 node 两个包都已安装
PKG_OK=0
rpm -qa | grep -q "mha4mysql-manager" && echo "[OK] mha4mysql-manager 已安装" || { echo "[FAIL] mha4mysql-manager 未安装"; PKG_OK=1; }
rpm -qa | grep -q "mha4mysql-node"   && echo "[OK] mha4mysql-node 已安装"   || { echo "[FAIL] mha4mysql-node 未安装";   PKG_OK=1; }

# 检查 2:确认核心命令存在
CMD_OK=0
for cmd in masterha_manager masterha_check_ssh masterha_check_repl masterha_check_status masterha_stop; do
  if command -v "$cmd" >/dev/null 2>&1; then
    echo "[OK] $cmd --> $(command -v $cmd)"
  else
    echo "[FAIL] $cmd 未找到"
    CMD_OK=1
  fi
done

# 检查 3:确认 Node 工具链存在
for tool in apply_diff_relay_logs save_binary_logs purge_relay_logs filter_mysqlbinlog; do
  if command -v "$tool" >/dev/null 2>&1; then
    echo "[OK] $tool --> $(command -v $tool)"
  else
    echo "[FAIL] $tool 未找到"
    CMD_OK=1
  fi
done

# 汇总结果
echo ""
if [ "$PKG_OK" -eq 0 ] && [ "$CMD_OK" -eq 0 ]; then
  echo "==== 所有检查通过,MHA 安装验证成功 ===="
else
  echo "==== 存在缺失项,请排查上方 [FAIL] 行 ===="
  exit 1
fi
}

install_yilai(){
    yum install -y epel-release
    yum install -y perl-DBD-MySQL perl-Config-Tiny perl-Log-Dispatch \
    perl-Parallel-ForkManager perl-Time-HiRes perl-ExtUtils-CBuilder \
    perl-ExtUtils-MakeMaker net-tools wget vim

    # 时间同步(复制强烈依赖时间一致)
    yum install -y ntp
    systemctl start ntpd
    systemctl enable ntpd
    ntpdate cn.pool.ntp.org

}

touch_mha_service(){
touch /etc/systemd/system/mha.service
cat > /etc/systemd/system/mha.service << EOF
[Unit]
Description=MHA Manager for app1
After=network.target mysqld.service

[Service]
Type=simple
User=root
ExecStart=/usr/bin/masterha_manager \
  --conf=/etc/mha/app1.cnf \
  --remove_dead_master_conf \
  --ignore_last_failover
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
}