#!/bin/bash

# 后台服务管理工具
# 作者: AI Assistant
# 版本: v1.0
# 用途: 管理定时备份系统的后台服务

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# 样式定义
BOLD='\033[1m'
UNDERLINE='\033[4m'

# 配置文件和目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/backup_configs"
SERVICE_DIR="$CONFIG_DIR/services"
JOBS_FILE="$CONFIG_DIR/backup_jobs.conf"
LOGS_DIR="$SCRIPT_DIR/backup_logs"

# 创建必要的目录
mkdir -p "$CONFIG_DIR" "$SERVICE_DIR" "$LOGS_DIR"

# 打印函数
print_info() {
    echo -e "${BLUE}[信息]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[成功]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[警告]${NC} $1"
}

print_error() {
    echo -e "${RED}[错误]${NC} $1"
}

print_header() {
    echo -e "${CYAN}${BOLD}$1${NC}"
}

# 显示Logo和欢迎信息
show_welcome() {
    clear
    echo -e "${CYAN}${BOLD}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                   后台服务管理工具                           ║
║                 Background Service Manager                  ║
╠══════════════════════════════════════════════════════════════╣
║  🔧 服务状态监控                                             ║
║  ⚡ 启动/停止/重启                                           ║
║  📊 服务日志查看                                             ║
║  🛠️ 系统服务管理                                           ║
╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    echo
}

# 显示主菜单
show_main_menu() {
    print_header "后台服务管理菜单"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
    echo -e "${WHITE}${BOLD}🔧 服务管理${NC}"
    echo "  1. 查看所有服务状态"
    echo "  2. 启动服务"
    echo "  3. 停止服务"
    echo "  4. 重启服务"
    echo "  5. 查看服务日志"
    echo
    echo -e "${WHITE}${BOLD}⚙️ 系统管理${NC}"
    echo "  6. 创建系统服务"
    echo "  7. 删除系统服务"
    echo "  8. 管理cron任务"
    echo "  9. 系统服务状态"
    echo
    echo -e "${WHITE}${BOLD}其他选项${NC}"
    echo "  0. 返回主菜单"
    echo
}

# 获取所有备份任务
get_backup_jobs() {
    if [ ! -f "$JOBS_FILE" ]; then
        return 1
    fi
    
    declare -g -a job_names=()
    declare -g -a job_status=()
    declare -g -a job_schedules=()
    
    while IFS=':' read -r name slave_idx master_idx source_path schedule created status; do
        job_names+=("$name")
        job_status+=("$status")
        job_schedules+=("$schedule")
    done < "$JOBS_FILE"
}

# 检查服务状态
check_service_status() {
    local job_name="$1"
    local service_name="backup-${job_name}"
    
    # 检查systemd服务
    if systemctl list-units --type=service | grep -q "$service_name"; then
        if systemctl is-active --quiet "$service_name"; then
            echo "systemd:active"
        else
            echo "systemd:inactive"
        fi
        return
    fi
    
    # 检查cron任务
    if crontab -l 2>/dev/null | grep -q "$job_name"; then
        echo "cron:active"
        return
    fi
    
    echo "stopped"
}

# 显示所有服务状态
show_all_services() {
    print_header "📊 后台服务状态"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
    
    if ! get_backup_jobs; then
        print_warning "未找到备份任务配置"
        return
    fi
    
    printf "%-4s %-20s %-15s %-20s %-15s\n" "序号" "任务名称" "任务状态" "计划" "服务状态"
    echo "──────────────────────────────────────────────────────────────────────────────"
    
    for i in "${!job_names[@]}"; do
        local job_name="${job_names[$i]}"
        local job_stat="${job_status[$i]}"
        local schedule="${job_schedules[$i]}"
        local service_status=$(check_service_status "$job_name")
        
        # 设置颜色
        if [ "$job_stat" = "enabled" ]; then
            job_color="${GREEN}启用${NC}"
        else
            job_color="${RED}禁用${NC}"
        fi
        
        case "$service_status" in
            "systemd:active")
                service_color="${GREEN}SystemD运行${NC}"
                ;;
            "systemd:inactive")
                service_color="${YELLOW}SystemD停止${NC}"
                ;;
            "cron:active")
                service_color="${BLUE}Cron运行${NC}"
                ;;
            *)
                service_color="${RED}未运行${NC}"
                ;;
        esac
        
        printf "%-4s %-20s " "$((i+1))" "$job_name"
        echo -e "$job_color"
        printf "%-20s " "$schedule"
        echo -e "$service_color"
    done
    
    echo
    print_info "说明:"
    echo "  - SystemD: 作为系统服务运行"
    echo "  - Cron: 作为定时任务运行"
    echo "  - 未运行: 任务已配置但未启动服务"
}

# 启动服务
start_service() {
    echo
    show_all_services
    echo
    read -p "请输入要启动的服务序号: " service_num
    
    if [[ ! "$service_num" =~ ^[0-9]+$ ]] || [ "$service_num" -lt 1 ] || [ "$service_num" -gt "${#job_names[@]}" ]; then
        print_error "无效的服务序号"
        return 1
    fi
    
    local job_index=$((service_num - 1))
    local job_name="${job_names[$job_index]}"
    local schedule="${job_schedules[$job_index]}"
    
    echo
    echo -e "${CYAN}选择启动方式:${NC}"
    echo "1. 创建SystemD服务 (推荐)"
    echo "2. 添加到Cron任务"
    echo "0. 取消"
    echo
    
    read -p "请选择 (0-2): " start_choice
    
    case $start_choice in
        1)
            create_systemd_service "$job_name" "$schedule"
            ;;
        2)
            create_cron_service "$job_name" "$schedule"
            ;;
        0)
            return
            ;;
        *)
            print_error "无效选择"
            ;;
    esac
}

# 创建SystemD服务
create_systemd_service() {
    local job_name="$1"
    local schedule="$2"
    local service_name="backup-${job_name}"
    
    print_info "正在创建SystemD服务: $service_name"
    
    # 创建服务文件
    local service_file="/etc/systemd/system/${service_name}.service"
    
    sudo tee "$service_file" > /dev/null << EOF
[Unit]
Description=Backup Service for $job_name
After=network.target

[Service]
Type=oneshot
User=$(whoami)
WorkingDirectory=$SCRIPT_DIR
ExecStart=$SCRIPT_DIR/backup_manager.sh --execute-job "$job_name"
StandardOutput=append:$LOGS_DIR/systemd_${job_name}.log
StandardError=append:$LOGS_DIR/systemd_${job_name}_error.log

[Install]
WantedBy=multi-user.target
EOF

    # 创建定时器文件
    local timer_file="/etc/systemd/system/${service_name}.timer"
    
    # 转换cron格式到systemd格式
    local systemd_schedule=$(convert_cron_to_systemd "$schedule")
    
    sudo tee "$timer_file" > /dev/null << EOF
[Unit]
Description=Timer for Backup Service $job_name
Requires=${service_name}.service

[Timer]
$systemd_schedule
Persistent=true

[Install]
WantedBy=timers.target
EOF

    # 重新加载systemd并启动服务
    sudo systemctl daemon-reload
    sudo systemctl enable "${service_name}.timer"
    sudo systemctl start "${service_name}.timer"
    
    if systemctl is-active --quiet "${service_name}.timer"; then
        print_success "SystemD服务 $service_name 启动成功"
        print_info "服务文件: $service_file"
        print_info "定时器文件: $timer_file"
        print_info "查看状态: systemctl status ${service_name}.timer"
    else
        print_error "SystemD服务启动失败"
        return 1
    fi
}

# 转换cron格式到systemd格式
convert_cron_to_systemd() {
    local cron_schedule="$1"
    
    # 解析cron表达式: 分 时 日 月 周
    read -r minute hour day month weekday <<< "$cron_schedule"
    
    local systemd_time=""
    
    # 处理时间
    if [ "$minute" != "*" ] && [ "$hour" != "*" ]; then
        systemd_time="OnCalendar=*-*-* ${hour}:${minute}:00"
    elif [ "$minute" != "*" ]; then
        systemd_time="OnCalendar=*:${minute}:00"
    elif [ "$hour" != "*" ]; then
        systemd_time="OnCalendar=*-*-* ${hour}:00:00"
    else
        systemd_time="OnCalendar=*:00:00"
    fi
    
    # 处理周期性
    if [ "$weekday" != "*" ]; then
        case "$weekday" in
            0) systemd_time="OnCalendar=Sun *-*-* ${hour:-*}:${minute:-*}:00" ;;
            1) systemd_time="OnCalendar=Mon *-*-* ${hour:-*}:${minute:-*}:00" ;;
            2) systemd_time="OnCalendar=Tue *-*-* ${hour:-*}:${minute:-*}:00" ;;
            3) systemd_time="OnCalendar=Wed *-*-* ${hour:-*}:${minute:-*}:00" ;;
            4) systemd_time="OnCalendar=Thu *-*-* ${hour:-*}:${minute:-*}:00" ;;
            5) systemd_time="OnCalendar=Fri *-*-* ${hour:-*}:${minute:-*}:00" ;;
            6) systemd_time="OnCalendar=Sat *-*-* ${hour:-*}:${minute:-*}:00" ;;
        esac
    fi
    
    echo "$systemd_time"
}

# 创建Cron服务
create_cron_service() {
    local job_name="$1"
    local schedule="$2"
    
    print_info "正在添加Cron任务: $job_name"
    
    # 创建cron脚本
    local cron_script="$SERVICE_DIR/cron_${job_name}.sh"
    
    cat > "$cron_script" << EOF
#!/bin/bash
# Cron script for backup job: $job_name
cd "$SCRIPT_DIR"
./backup_manager.sh --execute-job "$job_name" >> "$LOGS_DIR/cron_${job_name}.log" 2>&1
EOF
    
    chmod +x "$cron_script"
    
    # 添加到crontab
    local cron_entry="$schedule $cron_script"
    local temp_cron=$(mktemp)
    
    # 获取现有的crontab，排除相同任务
    crontab -l 2>/dev/null | grep -v "$job_name" > "$temp_cron" || true
    
    # 添加新任务
    echo "$cron_entry" >> "$temp_cron"
    
    # 安装新的crontab
    if crontab "$temp_cron"; then
        print_success "Cron任务添加成功"
        print_info "脚本文件: $cron_script"
        print_info "计划: $schedule"
        print_info "查看任务: crontab -l | grep $job_name"
    else
        print_error "Cron任务添加失败"
        rm -f "$temp_cron"
        return 1
    fi
    
    rm -f "$temp_cron"
}

# 停止服务
stop_service() {
    echo
    show_all_services
    echo
    read -p "请输入要停止的服务序号: " service_num
    
    if [[ ! "$service_num" =~ ^[0-9]+$ ]] || [ "$service_num" -lt 1 ] || [ "$service_num" -gt "${#job_names[@]}" ]; then
        print_error "无效的服务序号"
        return 1
    fi
    
    local job_index=$((service_num - 1))
    local job_name="${job_names[$job_index]}"
    local service_name="backup-${job_name}"
    local service_status=$(check_service_status "$job_name")
    
    case "$service_status" in
        "systemd:active"|"systemd:inactive")
            print_info "正在停止SystemD服务: $service_name"
            
            sudo systemctl stop "${service_name}.timer" 2>/dev/null || true
            sudo systemctl disable "${service_name}.timer" 2>/dev/null || true
            
            print_success "SystemD服务已停止"
            ;;
        "cron:active")
            print_info "正在移除Cron任务: $job_name"
            
            local temp_cron=$(mktemp)
            crontab -l 2>/dev/null | grep -v "$job_name" > "$temp_cron" || true
            crontab "$temp_cron"
            rm -f "$temp_cron"
            
            print_success "Cron任务已移除"
            ;;
        *)
            print_warning "服务未运行"
            ;;
    esac
}

# 重启服务
restart_service() {
    echo
    show_all_services
    echo
    read -p "请输入要重启的服务序号: " service_num
    
    if [[ ! "$service_num" =~ ^[0-9]+$ ]] || [ "$service_num" -lt 1 ] || [ "$service_num" -gt "${#job_names[@]}" ]; then
        print_error "无效的服务序号"
        return 1
    fi
    
    local job_index=$((service_num - 1))
    local job_name="${job_names[$job_index]}"
    local service_name="backup-${job_name}"
    local service_status=$(check_service_status "$job_name")
    
    case "$service_status" in
        "systemd:active"|"systemd:inactive")
            print_info "正在重启SystemD服务: $service_name"
            
            sudo systemctl restart "${service_name}.timer"
            
            if systemctl is-active --quiet "${service_name}.timer"; then
                print_success "SystemD服务重启成功"
            else
                print_error "SystemD服务重启失败"
            fi
            ;;
        "cron:active")
            print_info "Cron任务无需重启，配置已生效"
            ;;
        *)
            print_warning "服务未运行，请先启动服务"
            ;;
    esac
}

# 查看服务日志
show_service_logs() {
    echo
    show_all_services
    echo
    read -p "请输入要查看日志的服务序号: " service_num
    
    if [[ ! "$service_num" =~ ^[0-9]+$ ]] || [ "$service_num" -lt 1 ] || [ "$service_num" -gt "${#job_names[@]}" ]; then
        print_error "无效的服务序号"
        return 1
    fi
    
    local job_index=$((service_num - 1))
    local job_name="${job_names[$job_index]}"
    local service_name="backup-${job_name}"
    local service_status=$(check_service_status "$job_name")
    
    echo
    echo -e "${CYAN}选择日志类型:${NC}"
    echo "1. 最新系统日志"
    echo "2. 备份执行日志"
    echo "3. 错误日志"
    echo "4. 实时日志监控"
    echo "0. 返回"
    echo
    
    read -p "请选择 (0-4): " log_choice
    
    case $log_choice in
        1)
            case "$service_status" in
                "systemd:active"|"systemd:inactive")
                    print_info "SystemD服务日志:"
                    journalctl -u "${service_name}.service" -n 50 --no-pager
                    ;;
                "cron:active")
                    local cron_log="$LOGS_DIR/cron_${job_name}.log"
                    if [ -f "$cron_log" ]; then
                        print_info "Cron执行日志:"
                        tail -50 "$cron_log"
                    else
                        print_warning "未找到Cron日志文件"
                    fi
                    ;;
                *)
                    print_warning "服务未运行"
                    ;;
            esac
            ;;
        2)
            local backup_logs=$(ls -1t "$LOGS_DIR"/${job_name}_*.log 2>/dev/null | head -5)
            if [ -n "$backup_logs" ]; then
                echo -e "${CYAN}最近的备份日志:${NC}"
                select log_file in $backup_logs; do
                    if [ -n "$log_file" ]; then
                        print_info "显示日志: $(basename "$log_file")"
                        cat "$log_file"
                        break
                    fi
                done
            else
                print_warning "未找到备份日志"
            fi
            ;;
        3)
            local error_log="$LOGS_DIR/systemd_${job_name}_error.log"
            if [ -f "$error_log" ]; then
                print_info "错误日志:"
                tail -50 "$error_log"
            else
                print_warning "未找到错误日志"
            fi
            ;;
        4)
            case "$service_status" in
                "systemd:active"|"systemd:inactive")
                    print_info "实时监控SystemD服务日志 (Ctrl+C退出):"
                    journalctl -u "${service_name}.service" -f
                    ;;
                "cron:active")
                    local cron_log="$LOGS_DIR/cron_${job_name}.log"
                    print_info "实时监控Cron日志 (Ctrl+C退出):"
                    tail -f "$cron_log" 2>/dev/null || print_warning "日志文件不存在"
                    ;;
                *)
                    print_warning "服务未运行"
                    ;;
            esac
            ;;
        0)
            return
            ;;
        *)
            print_error "无效选择"
            ;;
    esac
    
    echo
    read -p "按 Enter 键继续..."
}

# 删除系统服务
delete_system_service() {
    echo
    show_all_services
    echo
    read -p "请输入要删除的服务序号: " service_num
    
    if [[ ! "$service_num" =~ ^[0-9]+$ ]] || [ "$service_num" -lt 1 ] || [ "$service_num" -gt "${#job_names[@]}" ]; then
        print_error "无效的服务序号"
        return 1
    fi
    
    local job_index=$((service_num - 1))
    local job_name="${job_names[$job_index]}"
    local service_name="backup-${job_name}"
    
    print_warning "此操作将完全删除服务相关文件"
    read -p "确认删除服务 $service_name? (y/N): " confirm
    
    if [[ $confirm =~ ^[Yy]$ ]]; then
        # 停止并删除SystemD服务
        sudo systemctl stop "${service_name}.timer" 2>/dev/null || true
        sudo systemctl disable "${service_name}.timer" 2>/dev/null || true
        sudo rm -f "/etc/systemd/system/${service_name}.service"
        sudo rm -f "/etc/systemd/system/${service_name}.timer"
        sudo systemctl daemon-reload
        
        # 删除Cron任务
        local temp_cron=$(mktemp)
        crontab -l 2>/dev/null | grep -v "$job_name" > "$temp_cron" || true
        crontab "$temp_cron"
        rm -f "$temp_cron"
        
        # 删除相关脚本
        rm -f "$SERVICE_DIR/cron_${job_name}.sh"
        
        print_success "服务 $service_name 已完全删除"
    fi
}

# 管理cron任务
manage_cron_tasks() {
    print_header "📋 Cron任务管理"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
    
    echo -e "${CYAN}选择操作:${NC}"
    echo "1. 查看所有Cron任务"
    echo "2. 手动添加Cron任务"
    echo "3. 删除Cron任务"
    echo "4. 编辑Cron任务"
    echo "0. 返回主菜单"
    echo
    
    read -p "请选择 (0-4): " cron_choice
    
    case $cron_choice in
        1)
            print_info "当前用户的Cron任务:"
            crontab -l 2>/dev/null || print_warning "未找到Cron任务"
            ;;
        2)
            echo
            read -p "请输入Cron表达式 (分 时 日 月 周): " cron_expr
            read -p "请输入要执行的命令: " cron_cmd
            
            if [ -n "$cron_expr" ] && [ -n "$cron_cmd" ]; then
                local temp_cron=$(mktemp)
                crontab -l 2>/dev/null > "$temp_cron" || true
                echo "$cron_expr $cron_cmd" >> "$temp_cron"
                crontab "$temp_cron"
                rm -f "$temp_cron"
                print_success "Cron任务添加成功"
            else
                print_error "输入信息不完整"
            fi
            ;;
        3)
            echo
            print_info "当前Cron任务:"
            crontab -l 2>/dev/null | nl
            echo
            read -p "请输入要删除的任务行号: " line_num
            
            if [[ "$line_num" =~ ^[0-9]+$ ]]; then
                local temp_cron=$(mktemp)
                crontab -l 2>/dev/null | sed "${line_num}d" > "$temp_cron"
                crontab "$temp_cron"
                rm -f "$temp_cron"
                print_success "Cron任务删除成功"
            else
                print_error "无效的行号"
            fi
            ;;
        4)
            print_info "正在打开Cron编辑器..."
            crontab -e
            ;;
        0)
            return
            ;;
        *)
            print_error "无效选择"
            ;;
    esac
    
    echo
    read -p "按 Enter 键继续..."
}

# 显示系统服务状态
show_system_services() {
    print_header "🔧 系统服务状态"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
    
    print_info "备份系统相关的SystemD服务:"
    systemctl list-units --type=service | grep "backup-" || print_warning "未找到备份系统服务"
    
    echo
    print_info "备份系统相关的定时器:"
    systemctl list-units --type=timer | grep "backup-" || print_warning "未找到备份系统定时器"
    
    echo
    print_info "系统Cron服务状态:"
    systemctl status cron.service --no-pager || systemctl status crond.service --no-pager || print_warning "未找到Cron服务"
    
    echo
    read -p "按 Enter 键继续..."
}

# 主函数
main() {
    # 主循环
    while true; do
        show_welcome
        show_main_menu
        
        read -p "请选择操作 (0-9): " choice
        echo
        
        case $choice in
            1)
                if get_backup_jobs; then
                    show_all_services
                    echo
                    read -p "按 Enter 键继续..."
                else
                    print_warning "未找到备份任务配置"
                    read -p "按 Enter 键继续..."
                fi
                ;;
            2)
                if get_backup_jobs; then
                    start_service
                else
                    print_warning "未找到备份任务配置"
                    read -p "按 Enter 键继续..."
                fi
                ;;
            3)
                if get_backup_jobs; then
                    stop_service
                else
                    print_warning "未找到备份任务配置"
                    read -p "按 Enter 键继续..."
                fi
                ;;
            4)
                if get_backup_jobs; then
                    restart_service
                else
                    print_warning "未找到备份任务配置"
                    read -p "按 Enter 键继续..."
                fi
                ;;
            5)
                if get_backup_jobs; then
                    show_service_logs
                else
                    print_warning "未找到备份任务配置"
                    read -p "按 Enter 键继续..."
                fi
                ;;
            6)
                if get_backup_jobs; then
                    start_service  # 重用启动服务功能
                else
                    print_warning "未找到备份任务配置"
                    read -p "按 Enter 键继续..."
                fi
                ;;
            7)
                if get_backup_jobs; then
                    delete_system_service
                else
                    print_warning "未找到备份任务配置"
                    read -p "按 Enter 键继续..."
                fi
                ;;
            8)
                manage_cron_tasks
                ;;
            9)
                show_system_services
                ;;
            0)
                return
                ;;
            *)
                print_warning "无效选择，请输入 0-9 之间的数字"
                read -p "按 Enter 键继续..."
                ;;
        esac
    done
}

# 信号处理
trap 'print_info "程序被中断"; exit 1' INT TERM

# 启动程序
main "$@" 