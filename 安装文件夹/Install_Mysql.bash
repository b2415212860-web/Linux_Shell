#!/bin/bash
setenforce 0
set -e
set -euo pipefail
# MySQL 连接信息（请根据实际修改）
MYSQL_USER="root"
MYSQL_NEWPASS="123456"  # 如果当前有密码就填，没有就留空
yum install -y wget
##安装数据库软件源
wget -P /opt http://repo.mysql.com/mysql57-community-release-el7-10.noarch.rpm

cd /opt
yum -y install mysql57-community-release-el7-10.noarch.rpm
yum -y install mysql-community-server  --nogpgcheck
rpm -qa | grep mysql
systemctl start mysqld
systemctl enable mysqld
###获取mysql临时密码
MYSQL_USER="root"
MYSQL_NEWPASS="123456"  # 如果当前有密码就填，没有就留空
MYSQL_PASS=$(grep 'temporary password' /var/log/mysqld.log | cut -d : -f 4 | tr -d ' ')

#提取密码
echo "提取到的临时密码是 ${MYSQL_PASS}"


###修改密码
mysql -u root -p"${MYSQL_PASS}" --connect-expired-password -e "
SET GLOBAL validate_password_policy=LOW;
SET GLOBAL validate_password_length=6;
ALTER USER '${MYSQL_USER}'@'localhost' IDENTIFIED BY '${MYSQL_NEWPASS}'; 
"
#设置字符集

cat >> /etc/my.cnf << 'EOF'
character-set-server=utf8mb4
init_connect='set names utf8mb4'
EOF
systemctl restart mysqld
###放行防火墙
firewall-cmd --permanent --add-port=3306/tcp
firewall-cmd --reload