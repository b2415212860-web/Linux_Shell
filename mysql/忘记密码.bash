sudo systemctl stop mysqld
sudo mysqld --skip-grant-tables --skip-networking --user=mysql &
mysql -u root
UPDATE mysql.user SET password=PASSWORD('你的新密码') WHERE user='root' AND host='localhost';
FLUSH PRIVILEGES;
EXIT;