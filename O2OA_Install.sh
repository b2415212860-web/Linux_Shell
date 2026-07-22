mkdir /soft
unzip /soft/o2server-9.5.3-linux-x64.zip -d /usr/local
mkdir -p /usr/local/o2server/custom/jars
cp /soft/mysql-connector-java-5.1.49.jar /usr/local/o2server/custom/jars/
cp /soft/mysql-connector-java-5.1.49.jar /usr/local/o2server/commons/ext_java11/
vi /usr/local/o2server/commons/ext_java11/manifest.cfg 

mkdir /usr/local/o2server/config
 cp /usr/local/o2server/configSample/node_127.0.0.1.json /usr/local/o2server/config
cp /usr/local/o2server/configSample/externalDataSources.json /usr/local/o2server/config
vi /usr/local/o2server/configSample/node_127.0.0.1.json
vi /usr/local/o2server/configSample/externalDataSources.json
    "enable": true,
    "url": "jdbc:mysql://172.21.30.139:3306/o2oa?autoReconnect\u003dtrue\u0026allowPublicKeyRetrieval\u003dtrue\u0026useSSL\u003dfalse\u0026useUnicode\u003dtrue\u0026characterEncoding\u003dUTF-8\u0026useLegacyDatetimeCode\u003dfalse\u0026serverTimezone\u003dGMT%2B8",
    "username": "root",
    "password": "P@ssw0rd!",
    "driverClassName": "com.mysql.jdbc.Driver",