cat > backup.sh <<'EOF'
#!/bin/bash
# 简单的文件备份脚本

SOURCE_FILE="/tmp/my-backup-pipeline/important_data.txt"
BACKUP_DIR="/tmp/backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="${BACKUP_DIR}/important_data_${TIMESTAMP}.txt"

echo "===== 开始备份 ====="
echo "源文件: ${SOURCE_FILE}"
echo "备份到: ${BACKUP_FILE}"

# 复制文件
cp "${SOURCE_FILE}" "${BACKUP_FILE}"

if [ $? -eq 0 ]; then
    echo "备份成功！"
    echo "备份时间: $(date)"
    echo "备份大小: $(wc -c < ${BACKUP_FILE}) 字节"
else
    echo "备份失败！"
    exit 1
fi
echo "===== 备份完成 ====="
EOF

# 赋予执行权限
chmod +x backup.sh