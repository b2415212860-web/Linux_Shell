JDK_NAME='JDK'
JDK_VERSION='17'
JDK_ALL=$JDK_NAME+$JDK_VERSION
mkdir /usr/local/jdk
tar -zxvf /soft/$JDK_NAME.tar.gz
mv /soft/$JDK_NAME /usr/local/jdk
mv /usr/local/jdk /usr/local/$JDK_ALL
echo "export JAVA_HOME=/usr/local/$JDK_ALL">>/etc/profile
echo "PATH=$JAVA_HOME/bin:PATH">>/etc/profile
source /etc/profile