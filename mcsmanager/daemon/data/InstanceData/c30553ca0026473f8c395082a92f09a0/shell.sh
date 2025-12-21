#!/bin/bash
# persistent_shell.sh - 持续运行的交互式Shell（带信号处理）

echo "🚀 启动持久化Shell环境..."
echo "💡 提示: 输入 'exit' 退出，输入 'help' 查看帮助"
echo "⚠️  注意: 按 Ctrl+C 不会退出，输入 'exit' 才能退出"

# 设置工作目录
cd /workspace/AppData/mcsmanager/daemon/data/InstanceData/c30553ca0026473f8c395082a92f09a0

# 创建命令历史文件
HISTFILE="/workspace/.persistent_shell_history"
touch "$HISTFILE"

# 信号处理函数
cleanup() {
    echo ""
    echo "🛑 收到中断信号 (Ctrl+C)"
    echo "❓ 确认要退出吗？输入 'exit' 确认退出，或按 Enter 继续"
}

# 设置信号捕获
trap cleanup SIGINT SIGTERM

# 检查是否在后台运行
check_background() {
    if [[ $(ps -o stat= -p $$) =~ "+" ]]; then
        echo "📝 前台运行模式"
    else
        echo "🔍 后台运行模式"
    fi
}

# 显示系统信息
show_system_info() {
    echo "📊 系统信息:"
    echo "  工作目录: $(pwd)"
    echo "  用户: $(whoami)"
    echo "  Shell: $SHELL"
    echo "  时间: $(date)"
}

# 主循环
main_loop() {
    local command=""
    
    while true; do
        echo -n "persistent-shell> "
        
        # 使用read命令读取输入，设置超时以便检查信号
        if ! read -r -t 3600 command; then
            # 读取超时，继续循环
            continue
        fi
        
        # 检查退出命令
        if [ "$command" = "exit" ] || [ "$command" = "quit" ]; then
            echo "👋 退出持久化Shell..."
            break
        fi
        
        # 检查帮助命令
        if [ "$command" = "help" ]; then
            show_help
            continue
        fi
        
        # 检查状态命令
        if [ "$command" = "status" ]; then
            show_status
            continue
        fi
        
        # 检查clear命令
        if [ "$command" = "clear" ]; then
            clear
            continue
        fi
        
        # 检查pwd命令
        if [ "$command" = "pwd" ]; then
            pwd
            continue
        fi
        
        # 检查ls命令
        if [ "$command" = "ls" ]; then
            ls
            continue
        fi
        
        # 执行命令
        if [ -n "$command" ]; then
            # 保存到历史
            echo "$(date '+%Y-%m-%d %H:%M:%S') - $command" >> "$HISTFILE"
            
            # 执行命令
            echo "执行: $command"
            eval "$command"
            
            # 检查命令执行状态
            local exit_code=$?
            if [ $exit_code -ne 0 ]; then
                echo "❌ 命令执行失败 (退出代码: $exit_code): $command"
            else
                echo "✅ 命令执行成功"
            fi
        fi
    done
}

# 显示帮助信息
show_help() {
    echo "可用命令:"
    echo "  help     - 显示此帮助"
    echo "  exit     - 退出持久化Shell"
    echo "  status   - 显示系统状态"
    echo "  clear    - 清屏"
    echo "  ls, pwd  - 标准Shell命令"
    echo "  任何其他Linux命令"
    echo ""
    echo "信号处理:"
    echo "  Ctrl+C   - 显示退出提示（不会直接退出）"
    echo "  只有输入 'exit' 才会真正退出"
}

# 显示状态信息
show_status() {
    echo "📊 系统状态:"
    echo "  工作目录: $(pwd)"
    echo "  用户: $(whoami)"
    echo "  时间: $(date)"
    echo "  运行时间: $(uptime -p 2>/dev/null || echo '未知')"
    echo "  内存: $(free -h 2>/dev/null | grep Mem: | awk '{print $3 \"/\" $2}')"
    echo "  磁盘: $(df -h /workspace 2>/dev/null | tail -1 | awk '{print $4 \"/\" $2 \" 可用\"}')"
    echo "  历史命令数: $(wc -l < "$HISTFILE" 2>/dev/null || echo 0)"
}

# 初始化
init() {
    show_system_info
    check_background
    echo ""
}

# 清理函数
cleanup_exit() {
    echo ""
    echo "🧹 执行清理..."
    echo "📝 命令历史已保存到: $HISTFILE"
    echo "🔚 持久化Shell已退出"
    exit 0
}

# 设置退出时的清理
trap cleanup_exit EXIT

# 主程序
init
main_loop