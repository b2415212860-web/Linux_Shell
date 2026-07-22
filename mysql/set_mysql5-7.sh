

mkdir /soft
tar -zxvf /soft/mysql-5.7.44-linux-glibc2.12-x86_64.tar.gz -C /usr/local/
mv /usr/local/mysql-5.7.44-linux-glibc2.12-x86_64 /usr/local/mysql
#添加组和用户，进行权限隔离
groupadd mysql
useradd -r -g mysql mysql

mkdir -p /data/mysql

ls -dl /usr/local/mysql/
ls -dl /data/mysql/

chown -R mysql.mysql /usr/local/mysql
chown -R mysql.mysql /data/mysql

chmod 750 /data/mysql

#配置环境变量
echo 'export PATH=/usr/local/mysql/bin:$PATH' | sudo tee -a /etc/profile
source /etc/profile
#初始化mysql
#/usr/local/mysql/bin/mysqld是MYSQL主程序完整路径
# --user是 该主程序由 用户 mysql运行 （一般不用root运行）
# --basidir是指定安装根目录
# --datadir是指定数据存放目录
# --initalize是初始化命令
/usr/local/mysql/bin/mysqld --user=mysql --basedir=/usr/local/mysql/ --datadir=/data/mysql --initialize
#记下初始化密码  O9iHFU7ost#K
sudo tee /etc/my.cnf <<EOF
[mysqld]
basedir = /usr/local/mysql
datadir = /data/mysql
socket = /tmp/mysql.sock
port = 3306
log-error = /data/mysql/mysql-error.log
pid-file = /data/mysql/mysql.pid
# 安全配置
skip-name-resolve = 1
symbolic-links = 0
explicit_defaults_for_timestamp = 1
# 内存优化（根据服务器配置调整）
key_buffer_size = 256M
max_allowed_packet = 64M
EOF


#配置service以便systemctl自启动
tee /etc/systemd/system/mysql.service <<EOF
[Unit]
Description=MySQL Server
After=network.target


[Service]
User=mysql
Group=mysql
ExecStart=/usr/local/mysql/bin/mysqld --defaults-file=/etc/my.cnf
Restart=on-failure


[Install]
WantedBy=multi-user.target
EOF

#Mysql自启动
systemctl daemon-reload
systemctl start mysql
systemctl enable mysql

#5.登录
mysql -u root -p
#设置密码
ALTER USER 'root'@'localhost' IDENTIFIED BY 'root';
FLUSH PRIVILEGES;
EXIT;

##CREATE USER 'root'@'172.21.30.1' IDENTIFIED BY 'P@ssw0rd!';创建新用户