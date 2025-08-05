#!/bin/bash

# 高级自动备份脚本
# 可以设置定时备份或监控文件变化

# 设置颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 配置
BACKUP_INTERVAL=300  # 5分钟检查一次
LOG_FILE="backup.log"

# 日志函数
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
    echo -e "$1"
}

# 备份函数
perform_backup() {
    if [[ -n $(git status --porcelain) ]]; then
        log_message "${GREEN}发现文件更改，执行自动备份...${NC}"
        
        git add .
        COMMIT_MSG="Auto backup: $(date '+%Y-%m-%d %H:%M:%S')"
        git commit -m "$COMMIT_MSG"
        
        if git push origin main; then
            log_message "${GREEN}✅ 自动备份成功: $COMMIT_MSG${NC}"
        else
            log_message "${RED}❌ 自动备份失败${NC}"
        fi
    else
        log_message "${BLUE}无文件更改，跳过备份${NC}"
    fi
}

# 显示使用说明
show_usage() {
    echo -e "${YELLOW}自动备份脚本使用说明:${NC}"
    echo "  ./auto_backup.sh start    - 启动定时备份监控"
    echo "  ./auto_backup.sh once     - 执行一次备份检查"
    echo "  ./auto_backup.sh status   - 查看Git状态"
    echo "  ./auto_backup.sh log      - 查看备份日志"
}

# 主逻辑
case "$1" in
    "start")
        log_message "${YELLOW}启动自动备份监控 (每${BACKUP_INTERVAL}秒检查一次)${NC}"
        log_message "${YELLOW}按 Ctrl+C 停止监控${NC}"
        
        while true; do
            perform_backup
            sleep $BACKUP_INTERVAL
        done
        ;;
    
    "once")
        log_message "${YELLOW}执行单次备份检查...${NC}"
        perform_backup
        ;;
    
    "status")
        echo -e "${BLUE}Git 状态:${NC}"
        git status
        echo -e "${BLUE}最近的提交:${NC}"
        git log --oneline -5
        ;;
    
    "log")
        if [ -f "$LOG_FILE" ]; then
            echo -e "${BLUE}备份日志:${NC}"
            tail -20 "$LOG_FILE"
        else
            echo -e "${YELLOW}暂无备份日志${NC}"
        fi
        ;;
    
    *)
        show_usage
        ;;
esac