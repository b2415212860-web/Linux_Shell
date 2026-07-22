# 1. 创建一个 2G 的交换文件
sudo dd if=/dev/zero of=/swapfile bs=1M count=2048

# 2. 赋予正确的权限
sudo chmod 600 /swapfile

# 3. 设置为 Swap 分区
sudo mkswap /swapfile

# 4. 启用 Swap
sudo swapon /swapfile

# 5. 永久生效（防止重启服务器后失效）
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
#给京东云服务器搞了个swap虚拟内存分区


遇见的情况
部署企业级办公系统O2OA
nginx反代后打不开（或者是一直在加载页面）直连服务器反而能打开网页
查找错误原因：打开了F12查看，找出了错误 Uncaught ReferenceError:xhr is not defined

#任务
需要根据错误内容，找出系统无法正常拉取初始化数据的真实层网络
以 公网 nginx tailscale -内部系统 这条链路来理顺参数逻辑

#行动
最开始是怀疑Nginx的nginx.conf配置缺少webSocket支持，导致连接断开
测试与结果：补充完Websocket依旧卡再加载页面
#行动2
依旧是再F12的network抓包。发现了304
在set-cookie抓到了警告
原因是nginx没有透传host，导致o2oa后端误以为用户在内网访问，遇、
于是返回了ip是tailscaleip的cookie，被nginx转发给处于nginx服务器的浏览器
导致跨域同源将cookie拒收，前端没收到cookie，无法访问
#解决办法
改造后端（认清身份）： 修改 O2OA 的 centerServer.json 和 webServer.json，将 proxyHost 设为 117.72.192.137，让后端知道自己面临外网。

改造网关（透明透传）： 在 Nginx 中补齐 proxy_set_header Host $host; 以及相关的真实 IP 透传和 WebSocket 升级代码。

清理战场： 在浏览器 Application 面板执行了“核弹级”的站点数据清理，彻底抹除历史冲突 Cookie。

nginx的负载均衡方法
1 轮询 ：简单公平 适用于后端服务器性能相近
2 权重 ：因地制宜，适合后端服务器性能不一致
3 iphash： 将同ip分配到同服务器，利于会话保持，不适用于ipv6或者代理较多
4 最少连接： 将新请求分配给连接数最少服务器，利用业务处理请求时间差异大的业务
5 响应时间权重 ： 优先把请求给响应时间最少的服务器