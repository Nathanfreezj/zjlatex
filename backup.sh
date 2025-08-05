#!/bin/bash

# 自动备份脚本
# 使用方法: ./backup.sh "提交信息"

# 设置颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}开始自动备份...${NC}"

# 检查是否有未提交的更改
if [[ -n $(git status --porcelain) ]]; then
    echo -e "${GREEN}发现文件更改，准备提交...${NC}"
    
    # 添加所有更改的文件
    git add .
    
    # 获取提交信息
    if [ -z "$1" ]; then
        # 如果没有提供提交信息，使用默认信息
        COMMIT_MSG="Auto backup: $(date '+%Y-%m-%d %H:%M:%S')"
    else
        COMMIT_MSG="$1"
    fi
    
    # 提交更改
    git commit -m "$COMMIT_MSG"
    
    # 推送到远程仓库
    echo -e "${GREEN}推送到GitHub...${NC}"
    git push origin main
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ 备份成功完成！${NC}"
        echo -e "${GREEN}提交信息: $COMMIT_MSG${NC}"
    else
        echo -e "${RED}❌ 推送失败，请检查网络连接或GitHub权限${NC}"
    fi
else
    echo -e "${YELLOW}没有发现文件更改，无需备份${NC}"
fi

echo -e "${YELLOW}备份脚本执行完毕${NC}"