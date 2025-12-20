#!/bin/bash

#git add .
#git commit -m "first commit"

#git remote set-url origin "$AUTH_REPO_URL"
cd /workspace/AppData
echo "步骤0: 创建测试文件..."
echo "自动提交测试于 $(date)" > test_auto_$(date +%s).txt

echo "步骤1: 提交更改..."
git add .
git commit -m "自动提交: $(date '+%Y-%m-%d %H:%M:%S')"

# 设置正确的权限（只有所有者可读写）
chmod 600 /root/.ssh/id_ed25519

# 同时确保.ssh目录权限正确
chmod 700 /root/.ssh

# 如果有公钥文件，也设置适当权限
chmod 644 /root/.ssh/id_ed25519.pub

# 检查expect是否安装
if ! command -v expect &> /dev/null; then
    apt-get update && apt-get install -y expect  # Debian/Ubuntu
    # 或 yum install -y expect  # RHEL/CentOS
fi

# 使用expect自动交互
expect << EOF
spawn git push
expect {
    "Are you sure you want to continue connecting (yes/no/\[fingerprint\])?" {
        send "yes\r"
        exp_continue
    }
    eof
}
EOF