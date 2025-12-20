#!/bin/bash

cd /workspace/AppData

#git add .
#git commit -m "first commit"

#git remote set-url origin "$AUTH_REPO_URL"

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

expect << 'EOF'
set timeout 20
spawn git push
expect {
    "Are you sure you want to continue connecting" {
        send "yes\r"
        exp_continue
    }
    "yes/no" {
        send "yes\r"
        exp_continue
    }
    eof
}
EOF