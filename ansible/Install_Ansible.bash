yum install -y epel-release	
yum install -y ansible
mkdir -p /opt/ansible/{collections,inventory,playbooks,roles}
vi /opt/ansible/inventory/pord/host.ini
#生成ssh密钥
ssh-keygen -t rsa -b 4096
#分发ssh密钥
ssh-copy-id root@172.21.30.142