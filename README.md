# Linux_Shell
国信安运维培训资料库
本仓库为 Linux 运维培训期间的学习资料、安装部署脚本及面试准备材料，按日期与主题分类整理。

目录结构
一、运维实操脚本与文档
日期	文件名	内容概述
06-24	0624	交换机基础知识学习笔记
07-10	0710.docx	Linux 基础操作作业：创建目录与用户、设置密码等
07-10	0710 2 磁盘.docx	磁盘管理实操：添加硬盘、fdisk 分区（三主一扩展）、XFS 格式化与挂载
07-11	0711 磁盘整列	RAID0 阵列创建命令速查（mdadm 建阵列 + mkfs + mount）
07-12	0712 raid + LVM.docx	在 RAID5 中创建并管理 LVM：建阵列、pvcreate/vgcreate/lvcreate、扩容与缩容
07-13	0713 FTP.txt	VSFTPD 被动模式（pasv）配置笔记
07-13	0713 FTP服务部署.docx	VSFTPD 完整部署流程：安装、防火墙放行、匿名/本地用户模式配置
07-14	0714 NFS.docx	NFS 服务端安装与配置、共享目录权限设置、客户端挂载
07-15	0715 Apache服务器部署.docx	Apache 源码安装、虚拟主机配置（基于 IP/域名/端口）
二、实操命令记录
文件名	内容概述
linshi	RAID5 + LVM 完整操作命令记录（临时笔记）：含创建、格式化、挂载、扩容、缩容全流程
三、面试准备材料
文件名	内容概述
自我介绍	面试自我介绍标准结构（五段式）与话术参考，含运维实习生完整范本
自我介绍案例.markdown	多份自我介绍参考案例（渗透测试/安全服务方向），含不同背景转行示例
面试相关	面试综合准备：简历撰写要点、实习生项目深度红线（K8s/Docker/Prometheus/Ansible）、职业规划话术
Jenkins犯错经历.markdown	Jenkins 踩坑复盘场景三例（凭据安全、环境不一致、构建缓存优化），含讲述公式
Prometeus经历.markdown	Prometheus 踩坑复盘场景三例（高基数监控雪崩、NTP 时间同步、告警风暴），含讲述公式
技术栈覆盖

Plain Text

系统基础    Linux 命令、用户管理、磁盘分区（fdisk）、文件系统（XFS/ext4）
存储管理    RAID 0/5（mdadm）、LVM（pv/vg/lv 创建与动态扩缩容）
网络服务    VSFTPD（FTP）、NFS、Apache（源码安装 + 虚拟主机）
DevOps     Jenkins CI/CD、Docker、Ansible
监控告警    Prometheus + Grafana + Alertmanager
容器编排    Kubernetes（kubectl 日常排障）
使用说明
.docx 文件为课堂作业与部署文档，含完整命令与截图，建议用 Word 或 WPS 打开查看。
无扩展名文件（0624、0711 磁盘整列、linshi、自我介绍、面试相关）为纯文本笔记，可用任意文本编辑器打开。
.markdown 文件为面试复盘材料，推荐使用支持 Markdown 的编辑器阅读。
部署脚本中的 IP 地址、密码等均为培训环境示例，生产环境使用前请务必修改。