#!/bash
#备份原yum文件
cd /etc/yum.repos.d/
mkdir  bak
mv *.repo bak

#下载阿里云yum源配置文件
curl  -o /etc/yum.repos.d/CentOS-Base.repo http ://mirrors.aliyun.com/repo/Centos-7.repo

#更新yum缓存
yum clean all
yum makecache
