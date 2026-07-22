#修改o2oa的node.json 将data.改为flase
sed -i '/"stackTrace": {/,/}/ s/"enable": false/"enable": true/' config.json
#2、开启和配置外部数据库信息
配置文件路径：o2server/config/externalDataSources.json
如果没有该文件，请从目录o2server/configSample/ 中复制externalDataSources.json文件到o2server/config目录下。
只有config目录下修改配置文件才会生效。
将其中的url、username、password以及enable信息修改为上述Mysql的相关信息，如：
[
  {
    "enable": true,
    "url": "jdbc:mysql://172.21.30.139:3306/X?autoReconnect\u003dtrue\u0026allowPublicKeyRetrieval\u003dtrue\u0026useSSL\u003dfalse\u0026useUnicode\u003dtrue\u0026characterEncoding\u003dUTF-8\u0026useLegacyDatetimeCode\u003dfalse\u0026serverTimezone\u003dGMT%2B8",
    "username": "root",
    "password": "P@ssw0rd!",
  }}


  #目前情况
  132是驱动类出问题 似乎没识别出external json
  135似乎只识别出h2数据库
  #

  1.解压
  2.修改start_linux.#
  3.修改node-127.0.0.1.json
  4.修改externalDataSources.json
  [
        {
                "url": "jdbc:mysql://172.21.30.139:3306/o2oa?sslMode=PREFERRED&allowPublicKeyRetrieval=true&characterEncoding=UTF-8&serverTimezone=Asia/Shanghai&connectTimeout=5000&socketTimeout=180000&rewriteBatchedStatements=true&createDatabaseIfNotExist=true",
                "username": "root",
                "password": "p@ssw0rd!",
                "includes": [],
                "excludes": [],
                "driverClassName" : "com.mysql.jdbc.Driver"
                "enable": true
        }
]
  5.把驱动加入custom/jars和commons/ext_java11
  6.把manifest.conf修改jar版本
  7.
  
  问题