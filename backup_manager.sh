#!/bin/bash

# 定时备份管理工具
# 作者: AI Assistant
# 版本: v1.0
# 用途: 管理远程服务器间的定时备份任务

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
BACKUP_DIR="$SCRIPT_DIR/backup_data"
LOGS_DIR="$SCRIPT_DIR/backup_logs"
CONFIG_FILE="$CONFIG_DIR/backup_config.conf"
HOSTS_FILE="$CONFIG_DIR/hosts.conf"
JOBS_FILE="$CONFIG_DIR/backup_jobs.conf"
EMAIL_CONFIG="$CONFIG_DIR/email_config.conf"
BACKUP_USER="backup_user"

# 创建必要的目录
mkdir -p "$CONFIG_DIR" "$BACKUP_DIR" "$LOGS_DIR"

# 日志记录函数
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local log_file="$LOGS_DIR/backup_system.log"
    
    echo "[$timestamp] [$level] $message" >> "$log_file"
    
    case $level in
        "INFO") print_info "$message" ;;
        "SUCCESS") print_success "$message" ;;
        "WARNING") print_warning "$message" ;;
        "ERROR") print_error "$message" ;;
    esac
}

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

print_title() {
    echo -e "${WHITE}${BOLD}$1${NC}"
}

# 发送邮件通知
send_email_notification() {
    local subject="$1"
    local body="$2"
    local attachment="$3"
    
    if [ ! -f "$EMAIL_CONFIG" ]; then
        log_message "WARNING" "邮件配置文件不存在，跳过邮件通知"
        return 1
    fi
    
    # 读取邮件配置
    source "$EMAIL_CONFIG"
    
    if [ -z "$SMTP_SERVER" ] || [ -z "$SMTP_PORT" ] || [ -z "$SENDER_EMAIL" ] || [ -z "$SENDER_PASSWORD" ] || [ -z "$RECEIVER_EMAIL" ]; then
        log_message "WARNING" "邮件配置不完整，跳过邮件通知"
        return 1
    fi
    
    # 使用Python脚本发送邮件
    if command -v python3 &> /dev/null; then
        local python_script=$(mktemp)
        cat > "$python_script" << EOF
import smtplib
import ssl
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.base import MIMEBase
from email import encoders
import os

# 邮件配置
smtp_server = "$SMTP_SERVER"
smtp_port = $SMTP_PORT
sender_email = "$SENDER_EMAIL"
sender_password = "$SENDER_PASSWORD"
receiver_email = "$RECEIVER_EMAIL"

# 创建邮件
msg = MIMEMultipart()
msg['From'] = sender_email
msg['To'] = receiver_email
msg['Subject'] = "$subject"

# 添加邮件正文
msg.attach(MIMEText("""$body""", 'plain', 'utf-8'))

# 添加附件
if "$attachment" and os.path.exists("$attachment"):
    with open("$attachment", "rb") as attachment_file:
        part = MIMEBase('application', 'octet-stream')
        part.set_payload(attachment_file.read())
    
    encoders.encode_base64(part)
    part.add_header(
        'Content-Disposition',
        f'attachment; filename= {os.path.basename("$attachment")}'
    )
    msg.attach(part)

# 发送邮件
try:
    context = ssl.create_default_context()
    if smtp_port == 587:
        server = smtplib.SMTP(smtp_server, smtp_port)
        server.starttls(context=context)
    elif smtp_port == 465:
        server = smtplib.SMTP_SSL(smtp_server, smtp_port, context=context)
    else:
        server = smtplib.SMTP(smtp_server, smtp_port)
    
    server.login(sender_email, sender_password)
    text = msg.as_string()
    server.sendmail(sender_email, receiver_email, text)
    server.quit()
    print("邮件发送成功")
except Exception as e:
    print(f"邮件发送失败: {e}")
    exit(1)
EOF
        python3 "$python_script"
        local result=$?
        rm -f "$python_script"
    else
        log_message "ERROR" "未找到Python3，无法发送邮件"
        return 1
    fi
    
    if [ $result -eq 0 ]; then
        log_message "SUCCESS" "邮件通知发送成功"
        return 0
    else
        log_message "ERROR" "邮件通知发送失败"
        return 1
    fi
}

# 显示Logo和欢迎信息
show_welcome() {
    clear
    echo -e "${CYAN}${BOLD}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                     定时备份管理工具                         ║
║                 Scheduled Backup Manager                    ║
╠══════════════════════════════════════════════════════════════╣
║  🔄 远程数据备份                                             ║
║  ⏰ 定时任务管理                                             ║
║  📊 备份状态监控                                             ║
║  🛠️ 服务器配置                                              ║
╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    echo
}

# 显示主菜单
show_main_menu() {
    print_header "定时备份管理菜单"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
    echo -e "${WHITE}${BOLD}🔧 备份配置${NC}"
    echo "  1. 配置主机信息"
    echo "  2. 创建备份任务"
    echo "  3. 管理备份任务"
    echo "  4. 测试连接"
    echo "  5. 配置邮件通知"
    echo
    echo -e "${WHITE}${BOLD}⏰ 备份操作${NC}"
    echo "  6. 立即执行备份"
    echo "  7. 查看备份历史"
    echo "  8. 清理旧备份"
    echo
    echo -e "${WHITE}${BOLD}📊 监控管理${NC}"
    echo "  9. 查看备份状态"
    echo " 10. 查看系统日志"
    echo " 11. 备份统计信息"
    echo
    echo -e "${WHITE}${BOLD}其他选项${NC}"
    echo "  0. 返回主菜单"
    echo
}

# 配置邮件通知
configure_email() {
    print_header "📧 配置邮件通知"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
    
    echo -e "${CYAN}选择邮箱类型:${NC}"
    echo "1. QQ邮箱 (smtp.qq.com)"
    echo "2. 163邮箱 (smtp.163.com)"
    echo "3. Gmail (smtp.gmail.com)"
    echo "4. 自定义SMTP服务器"
    echo "0. 返回主菜单"
    echo
    
    read -p "请选择 (0-4): " email_choice
    
    case $email_choice in
        1)
            SMTP_SERVER="smtp.qq.com"
            SMTP_PORT=587
            print_info "QQ邮箱需要使用授权码而非密码"
            ;;
        2)
            SMTP_SERVER="smtp.163.com"
            SMTP_PORT=465
            print_info "163邮箱需要使用授权码而非密码"
            ;;
        3)
            SMTP_SERVER="smtp.gmail.com"
            SMTP_PORT=587
            print_info "Gmail需要使用应用专用密码"
            ;;
        4)
            read -p "请输入SMTP服务器地址: " SMTP_SERVER
            read -p "请输入SMTP端口 (25/465/587): " SMTP_PORT
            ;;
        0)
            return
            ;;
        *)
            print_error "无效选择"
            return 1
            ;;
    esac
    
    echo
    read -p "请输入发送邮箱地址: " SENDER_EMAIL
    read -s -p "请输入发送邮箱密码或授权码: " SENDER_PASSWORD
    echo
    read -p "请输入接收邮箱地址: " RECEIVER_EMAIL
    
    if [ -z "$SENDER_EMAIL" ] || [ -z "$SENDER_PASSWORD" ] || [ -z "$RECEIVER_EMAIL" ]; then
        print_error "邮箱配置信息不完整"
        return 1
    fi
    
    # 保存邮件配置
    cat > "$EMAIL_CONFIG" << EOF
# 邮件通知配置
SMTP_SERVER="$SMTP_SERVER"
SMTP_PORT=$SMTP_PORT
SENDER_EMAIL="$SENDER_EMAIL"
SENDER_PASSWORD="$SENDER_PASSWORD"
RECEIVER_EMAIL="$RECEIVER_EMAIL"
EOF
    
    chmod 600 "$EMAIL_CONFIG"  # 保护密码文件
    
    print_success "邮件配置已保存"
    
    # 测试邮件发送
    echo
    read -p "是否发送测试邮件? (y/N): " test_email
    if [[ $test_email =~ ^[Yy]$ ]]; then
        send_email_notification "备份系统测试邮件" "这是一封来自备份系统的测试邮件。如果您收到此邮件，说明邮件配置成功。

发送时间: $(date)
主机名: $(hostname)
IP地址: $(hostname -I | awk '{print $1}')"
    fi
    
    echo
    read -p "按 Enter 键继续..."
}

# 创建备份专用用户
create_backup_user() {
    local host_ip="$1"
    local host_port="$2"
    local host_user="$3"
    local host_key="$4"
    local role="$5"  # master 或 slave
    
    log_message "INFO" "开始在 $role 主机 $host_ip 上创建备份用户 $BACKUP_USER"
    
    # 构建SSH命令
    local ssh_cmd="ssh -p $host_port -o ConnectTimeout=10"
    if [ -n "$host_key" ] && [ -f "$host_key" ]; then
        ssh_cmd="$ssh_cmd -i $host_key"
    fi
    
    # 创建用户的脚本
    local create_user_script="
        # 检查用户是否已存在
        if id '$BACKUP_USER' &>/dev/null; then
            echo '用户 $BACKUP_USER 已存在'
        else
            # 创建用户
            sudo useradd -m -s /bin/bash '$BACKUP_USER' 2>/dev/null || {
                echo '错误: 无法创建用户，可能需要root权限'
                exit 1
            }
            echo '用户 $BACKUP_USER 创建成功'
        fi
        
        # 创建SSH密钥目录
        sudo mkdir -p /home/$BACKUP_USER/.ssh
        sudo chmod 700 /home/$BACKUP_USER/.ssh
        
        # 设置用户权限
        if [ '$role' = 'master' ]; then
            # 主机需要写入权限，创建备份存储目录
            sudo mkdir -p /home/$BACKUP_USER/backup_storage
            sudo mkdir -p /home/$BACKUP_USER/backup_logs
            sudo chown -R $BACKUP_USER:$BACKUP_USER /home/$BACKUP_USER
            echo '主机存储目录创建完成'
        else
            # 从机设置读取权限
            sudo chown -R $BACKUP_USER:$BACKUP_USER /home/$BACKUP_USER
            echo '从机用户权限设置完成'
        fi
        
        echo '备份用户 $BACKUP_USER 配置完成'
    "
    
    # 执行用户创建命令
    if $ssh_cmd "$host_user@$host_ip" "$create_user_script" 2>/dev/null; then
        log_message "SUCCESS" "备份用户在 $role 主机 $host_ip 上创建成功"
        return 0
    else
        log_message "ERROR" "备份用户在 $role 主机 $host_ip 上创建失败"
        return 1
    fi
}

# 设置SSH密钥认证
setup_ssh_keys() {
    local slave_ip="$1"
    local slave_port="$2"
    local slave_user="$3"
    local slave_key="$4"
    local master_ip="$5"
    local master_port="$6"
    local master_user="$7"
    local master_key="$8"
    
    log_message "INFO" "开始设置SSH密钥认证"
    
    local key_file="$CONFIG_DIR/backup_rsa"
    
    # 生成SSH密钥对（如果不存在）
    if [ ! -f "$key_file" ]; then
        ssh-keygen -t rsa -b 4096 -f "$key_file" -N "" -C "backup_system_$(date +%Y%m%d)"
        chmod 600 "$key_file"
        log_message "SUCCESS" "SSH密钥对生成成功"
    fi
    
    # 将公钥复制到从机
    local slave_ssh_cmd="ssh -p $slave_port"
    if [ -n "$slave_key" ] && [ -f "$slave_key" ]; then
        slave_ssh_cmd="$slave_ssh_cmd -i $slave_key"
    fi
    
    if $slave_ssh_cmd "$slave_user@$slave_ip" "
        sudo mkdir -p /home/$BACKUP_USER/.ssh
        echo '$(cat ${key_file}.pub)' | sudo tee -a /home/$BACKUP_USER/.ssh/authorized_keys
        sudo chmod 600 /home/$BACKUP_USER/.ssh/authorized_keys
        sudo chown -R $BACKUP_USER:$BACKUP_USER /home/$BACKUP_USER/.ssh
    " 2>/dev/null; then
        log_message "SUCCESS" "SSH公钥已添加到从机"
    else
        log_message "ERROR" "SSH公钥添加到从机失败"
        return 1
    fi
    
    # 将公钥复制到主机
    local master_ssh_cmd="ssh -p $master_port"
    if [ -n "$master_key" ] && [ -f "$master_key" ]; then
        master_ssh_cmd="$master_ssh_cmd -i $master_key"
    fi
    
    if $master_ssh_cmd "$master_user@$master_ip" "
        sudo mkdir -p /home/$BACKUP_USER/.ssh
        echo '$(cat ${key_file}.pub)' | sudo tee -a /home/$BACKUP_USER/.ssh/authorized_keys
        sudo chmod 600 /home/$BACKUP_USER/.ssh/authorized_keys
        sudo chown -R $BACKUP_USER:$BACKUP_USER /home/$BACKUP_USER/.ssh
    " 2>/dev/null; then
        log_message "SUCCESS" "SSH公钥已添加到主机"
    else
        log_message "ERROR" "SSH公钥添加到主机失败"
        return 1
    fi
    
    # 保存私钥路径到配置
    if ! grep -q "BACKUP_SSH_KEY" "$CONFIG_FILE" 2>/dev/null; then
        echo "BACKUP_SSH_KEY=\"$key_file\"" >> "$CONFIG_FILE"
    fi
    
    return 0
}

# 保存主机配置
save_host_config() {
    local name="$1"
    local ip="$2"
    local port="$3"
    local user="$4"
    local key_path="$5"
    local role="$6"
    
    echo "$name:$ip:$port:$user:$key_path:$role" >> "$HOSTS_FILE"
    print_success "主机配置已保存"
}

# 读取主机配置
load_hosts() {
    if [ ! -f "$HOSTS_FILE" ]; then
        return 1
    fi
    
    declare -g -a host_names=()
    declare -g -a host_ips=()
    declare -g -a host_ports=()
    declare -g -a host_users=()
    declare -g -a host_keys=()
    declare -g -a host_roles=()
    
    while IFS=':' read -r name ip port user key role; do
        host_names+=("$name")
        host_ips+=("$ip")
        host_ports+=("$port")
        host_users+=("$user")
        host_keys+=("$key")
        host_roles+=("$role")
    done < "$HOSTS_FILE"
}

# 配置主机信息
configure_hosts() {
    print_header "🔧 配置主机信息"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
    
    echo -e "${CYAN}选择操作:${NC}"
    echo "1. 添加新主机"
    echo "2. 查看现有主机"
    echo "3. 删除主机"
    echo "0. 返回主菜单"
    echo
    
    read -p "请选择 (0-3): " choice
    
    case $choice in
        1)
            add_new_host
            ;;
        2)
            show_existing_hosts
            ;;
        3)
            delete_host
            ;;
        0)
            return
            ;;
        *)
            print_warning "无效选择"
            ;;
    esac
}

# 添加新主机
add_new_host() {
    echo
    print_info "添加新主机配置"
    echo
    
    read -p "请输入主机名称: " host_name
    if [ -z "$host_name" ]; then
        print_error "主机名称不能为空"
        return 1
    fi
    
    read -p "请输入主机IP地址: " host_ip
    if [ -z "$host_ip" ]; then
        print_error "IP地址不能为空"
        return 1
    fi
    
    read -p "请输入SSH端口 (默认22): " host_port
    host_port=${host_port:-22}
    
    read -p "请输入SSH用户名: " host_user
    if [ -z "$host_user" ]; then
        print_error "用户名不能为空"
        return 1
    fi
    
    read -p "请输入SSH私钥路径 (留空使用密码): " host_key
    
    echo
    echo -e "${CYAN}选择主机角色:${NC}"
    echo "1. 主机 (备份目标)"
    echo "2. 从机 (备份源)"
    read -p "请选择 (1-2): " role_choice
    
    case $role_choice in
        1) host_role="master" ;;
        2) host_role="slave" ;;
        *) 
            print_error "无效选择"
            return 1
            ;;
    esac
    
    # 测试连接
    echo
    print_info "正在测试连接..."
    if test_ssh_connection "$host_ip" "$host_port" "$host_user" "$host_key"; then
        save_host_config "$host_name" "$host_ip" "$host_port" "$host_user" "$host_key" "$host_role"
    else
        print_error "连接测试失败，请检查配置"
        return 1
    fi
}

# 显示现有主机
show_existing_hosts() {
    echo
    print_info "现有主机配置："
    echo
    
    if ! load_hosts; then
        print_warning "未找到主机配置"
        return
    fi
    
    printf "%-4s %-15s %-15s %-6s %-12s %-10s\n" "序号" "主机名称" "IP地址" "端口" "用户名" "角色"
    echo "─────────────────────────────────────────────────────────────────────"
    
    for i in "${!host_names[@]}"; do
        role_display="${host_roles[$i]}"
        if [ "$role_display" = "master" ]; then
            role_display="${GREEN}主机${NC}"
        else
            role_display="${YELLOW}从机${NC}"
        fi
        
        printf "%-4s %-15s %-15s %-6s %-12s " "$((i+1))" "${host_names[$i]}" "${host_ips[$i]}" "${host_ports[$i]}" "${host_users[$i]}"
        echo -e "$role_display"
    done
}

# 删除主机
delete_host() {
    echo
    if ! show_existing_hosts; then
        return
    fi
    
    echo
    read -p "请输入要删除的主机序号: " del_num
    
    if [[ ! "$del_num" =~ ^[0-9]+$ ]] || [ "$del_num" -lt 1 ] || [ "$del_num" -gt "${#host_names[@]}" ]; then
        print_error "无效的主机序号"
        return 1
    fi
    
    del_index=$((del_num - 1))
    host_to_delete="${host_names[$del_index]}"
    
    read -p "确认删除主机 $host_to_delete? (y/N): " confirm
    if [[ $confirm =~ ^[Yy]$ ]]; then
        # 创建临时文件，排除要删除的行
        temp_file=$(mktemp)
        if [ -f "$HOSTS_FILE" ]; then
            head -n "$del_index" "$HOSTS_FILE" > "$temp_file"
            tail -n +$((del_index + 2)) "$HOSTS_FILE" >> "$temp_file"
            mv "$temp_file" "$HOSTS_FILE"
        fi
        print_success "主机 $host_to_delete 已删除"
    fi
}

# 测试SSH连接
test_ssh_connection() {
    local ip="$1"
    local port="$2"
    local user="$3"
    local key="$4"
    
    local ssh_cmd="ssh -o ConnectTimeout=10 -o BatchMode=yes -p $port"
    
    if [ -n "$key" ] && [ -f "$key" ]; then
        ssh_cmd="$ssh_cmd -i $key"
    fi
    
    if $ssh_cmd "$user@$ip" "echo 'Connection successful'" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# 创建备份任务
create_backup_job() {
    print_header "🔧 创建备份任务"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
    
    if ! load_hosts; then
        print_error "请先配置主机信息"
        return 1
    fi
    
    # 选择从机（备份源）
    echo -e "${CYAN}选择从机（备份源）:${NC}"
    printf "%-4s %-15s %-15s %-10s\n" "序号" "主机名称" "IP地址" "角色"
    echo "──────────────────────────────────────────────────"
    
    slave_indices=()
    slave_count=0
    for i in "${!host_names[@]}"; do
        if [ "${host_roles[$i]}" = "slave" ]; then
            slave_indices+=("$i")
            slave_count=$((slave_count + 1))
            printf "%-4s %-15s %-15s %-10s\n" "$slave_count" "${host_names[$i]}" "${host_ips[$i]}" "从机"
        fi
    done
    
    if [ $slave_count -eq 0 ]; then
        print_error "未找到从机配置"
        return 1
    fi
    
    echo
    read -p "请选择从机序号: " slave_choice
    
    if [[ ! "$slave_choice" =~ ^[0-9]+$ ]] || [ "$slave_choice" -lt 1 ] || [ "$slave_choice" -gt $slave_count ]; then
        print_error "无效的从机序号"
        return 1
    fi
    
    slave_index="${slave_indices[$((slave_choice - 1))]}"
    
    # 选择主机（备份目标）
    echo
    echo -e "${CYAN}选择主机（备份目标）:${NC}"
    printf "%-4s %-15s %-15s %-10s\n" "序号" "主机名称" "IP地址" "角色"
    echo "──────────────────────────────────────────────────"
    
    master_indices=()
    master_count=0
    for i in "${!host_names[@]}"; do
        if [ "${host_roles[$i]}" = "master" ]; then
            master_indices+=("$i")
            master_count=$((master_count + 1))
            printf "%-4s %-15s %-15s %-10s\n" "$master_count" "${host_names[$i]}" "${host_ips[$i]}" "主机"
        fi
    done
    
    if [ $master_count -eq 0 ]; then
        print_error "未找到主机配置"
        return 1
    fi
    
    echo
    read -p "请选择主机序号: " master_choice
    
    if [[ ! "$master_choice" =~ ^[0-9]+$ ]] || [ "$master_choice" -lt 1 ] || [ "$master_choice" -gt $master_count ]; then
        print_error "无效的主机序号"
        return 1
    fi
    
    master_index="${master_indices[$((master_choice - 1))]}"
    
    # 配置备份路径
    echo
    read -p "请输入从机上要备份的路径: " source_path
    if [ -z "$source_path" ]; then
        print_error "备份路径不能为空"
        return 1
    fi
    
    # 配置备份频率
    echo
    echo -e "${CYAN}选择备份频率:${NC}"
    echo "1. 每小时备份"
    echo "2. 每天备份"
    echo "3. 每周备份"
    echo "4. 自定义cron表达式"
    read -p "请选择 (1-4): " freq_choice
    
    case $freq_choice in
        1) schedule="0 * * * *" ;;
        2) 
            read -p "请输入每天备份的小时 (0-23, 默认2): " hour
            hour=${hour:-2}
            schedule="0 $hour * * *"
            ;;
        3)
            read -p "请输入每周备份的星期几 (0-6, 0=周日, 默认0): " day
            day=${day:-0}
            read -p "请输入备份的小时 (0-23, 默认2): " hour
            hour=${hour:-2}
            schedule="0 $hour * * $day"
            ;;
        4)
            read -p "请输入cron表达式 (分 时 日 月 周): " schedule
            if [ -z "$schedule" ]; then
                print_error "cron表达式不能为空"
                return 1
            fi
            ;;
        *)
            print_error "无效选择"
            return 1
            ;;
    esac
    
    # 任务名称
    echo
    read -p "请输入备份任务名称: " job_name
    if [ -z "$job_name" ]; then
        print_error "任务名称不能为空"
        return 1
    fi
    
    # 保存备份任务配置
    job_config="$job_name:$slave_index:$master_index:$source_path:$schedule:$(date +%s):enabled"
    echo "$job_config" >> "$JOBS_FILE"
    
    print_success "备份任务创建成功"
    
    # 询问是否立即执行或设置定时任务
    echo
    echo -e "${CYAN}选择执行方式:${NC}"
    echo "1. 立即执行备份"
    echo "2. 设置为定时任务"
    echo "3. 仅保存配置"
    read -p "请选择 (1-3): " exec_choice
    
    case $exec_choice in
        1)
            execute_backup_job "$job_name"
            ;;
        2)
            setup_cron_job "$job_name" "$schedule"
            ;;
        3)
            print_info "任务配置已保存"
            ;;
    esac
}

# 执行备份任务（增强版：支持自动用户创建、断点续传、邮件通知）
execute_backup_job() {
    local job_name="$1"
    local backup_start_time=$(date)
    
    log_message "INFO" "开始执行备份任务: $job_name"
    
    # 从配置文件中读取任务信息
    local job_line=$(grep "^$job_name:" "$JOBS_FILE" 2>/dev/null)
    if [ -z "$job_line" ]; then
        log_message "ERROR" "未找到备份任务: $job_name"
        return 1
    fi
    
    IFS=':' read -r name slave_idx master_idx source_path schedule created status <<< "$job_line"
    
    if ! load_hosts; then
        log_message "ERROR" "无法加载主机配置"
        return 1
    fi
    
    # 获取主机信息
    slave_name="${host_names[$slave_idx]}"
    slave_ip="${host_ips[$slave_idx]}"
    slave_port="${host_ports[$slave_idx]}"
    slave_user="${host_users[$slave_idx]}"
    slave_key="${host_keys[$slave_idx]}"
    
    master_name="${host_names[$master_idx]}"
    master_ip="${host_ips[$master_idx]}"
    master_port="${host_ports[$master_idx]}"
    master_user="${host_users[$master_idx]}"
    master_key="${host_keys[$master_idx]}"
    
    # 创建备份目录和日志
    local backup_timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_subdir="$job_name"
    local local_backup_dir="$BACKUP_DIR/$backup_subdir"
    local log_file="$LOGS_DIR/${job_name}_${backup_timestamp}.log"
    
    mkdir -p "$local_backup_dir"
    
    log_message "INFO" "从机: $slave_name ($slave_ip:$slave_port)"
    log_message "INFO" "主机: $master_name ($master_ip:$master_port)"
    log_message "INFO" "备份路径: $source_path"
    
    # 开始备份日志
    cat > "$log_file" << EOF
=== 备份任务执行日志 ===
任务名称: $job_name
开始时间: $backup_start_time
从机: $slave_name ($slave_ip:$slave_port)
主机: $master_name ($master_ip:$master_port)
备份路径: $source_path

=== 详细日志 ===
EOF
    
    # 步骤1: 创建备份用户（如果需要）
    log_message "INFO" "步骤1: 检查并创建备份用户"
    
    if ! create_backup_user "$slave_ip" "$slave_port" "$slave_user" "$slave_key" "slave"; then
        log_message "WARNING" "从机备份用户创建失败，将使用原用户"
        echo "从机备份用户创建失败: $(date)" >> "$log_file"
    fi
    
    if ! create_backup_user "$master_ip" "$master_port" "$master_user" "$master_key" "master"; then
        log_message "WARNING" "主机备份用户创建失败，将使用原用户"
        echo "主机备份用户创建失败: $(date)" >> "$log_file"
    fi
    
    # 步骤2: 设置SSH密钥认证
    log_message "INFO" "步骤2: 设置SSH密钥认证"
    
    if setup_ssh_keys "$slave_ip" "$slave_port" "$slave_user" "$slave_key" \
                      "$master_ip" "$master_port" "$master_user" "$master_key"; then
        log_message "SUCCESS" "SSH密钥认证设置成功"
        echo "SSH密钥认证设置成功: $(date)" >> "$log_file"
        
        # 使用备份用户进行后续操作
        local backup_key="$CONFIG_DIR/backup_rsa"
        slave_ssh_cmd="ssh -p $slave_port -i $backup_key"
        master_ssh_cmd="ssh -p $master_port -i $backup_key"
        backup_user_flag=true
    else
        log_message "WARNING" "SSH密钥认证设置失败，使用原有认证方式"
        echo "SSH密钥认证设置失败: $(date)" >> "$log_file"
        
        # 使用原有认证方式
        slave_ssh_cmd="ssh -p $slave_port"
        if [ -n "$slave_key" ] && [ -f "$slave_key" ]; then
            slave_ssh_cmd="$slave_ssh_cmd -i $slave_key"
        fi
        
        master_ssh_cmd="ssh -p $master_port"
        if [ -n "$master_key" ] && [ -f "$master_key" ]; then
            master_ssh_cmd="$master_ssh_cmd -i $master_key"
        fi
        backup_user_flag=false
    fi
    
    # 步骤3: 执行数据备份（支持断点续传）
    log_message "INFO" "步骤3: 开始数据备份"
    echo "开始数据备份: $(date)" >> "$log_file"
    
    # 在主机上创建备份目录
    local remote_backup_dir="/home/$BACKUP_USER/backup_storage/$backup_subdir"
    if [ "$backup_user_flag" = "true" ]; then
        $master_ssh_cmd "$BACKUP_USER@$master_ip" "mkdir -p $remote_backup_dir" >> "$log_file" 2>&1
    else
        $master_ssh_cmd "$master_user@$master_ip" "mkdir -p $SCRIPT_DIR/backup_data/$backup_subdir" >> "$log_file" 2>&1
        remote_backup_dir="$SCRIPT_DIR/backup_data/$backup_subdir"
    fi
    
    # 构建rsync命令（支持断点续传）
    local rsync_cmd="rsync -avz --progress --partial --inplace --delete"
    
    if [ "$backup_user_flag" = "true" ]; then
        rsync_cmd="$rsync_cmd -e 'ssh -p $slave_port -i $backup_key'"
        local source_spec="$BACKUP_USER@$slave_ip:$source_path/"
    else
        if [ -n "$slave_key" ] && [ -f "$slave_key" ]; then
            rsync_cmd="$rsync_cmd -e 'ssh -p $slave_port -i $slave_key'"
        else
            rsync_cmd="$rsync_cmd -e 'ssh -p $slave_port'"
        fi
        local source_spec="$slave_user@$slave_ip:$source_path/"
    fi
    
    # 先同步到本地临时目录
    local temp_backup="$local_backup_dir/temp_$backup_timestamp"
    mkdir -p "$temp_backup"
    
    log_message "INFO" "正在同步数据 (支持断点续传)..."
    if eval "$rsync_cmd $source_spec $temp_backup/" >> "$log_file" 2>&1; then
        log_message "SUCCESS" "数据同步完成"
        echo "数据同步完成: $(date)" >> "$log_file"
        
        # 步骤4: 创建压缩包
        log_message "INFO" "步骤4: 创建压缩包"
        local backup_filename="${job_name}_${backup_timestamp}.tar.gz"
        local backup_filepath="$local_backup_dir/$backup_filename"
        
        if tar -czf "$backup_filepath" -C "$temp_backup" . >> "$log_file" 2>&1; then
            log_message "SUCCESS" "压缩包创建完成: $(du -h "$backup_filepath" | cut -f1)"
            echo "压缩包创建完成: $(date)" >> "$log_file"
            
            # 步骤5: 传输到主机（支持断点续传）
            log_message "INFO" "步骤5: 传输备份到主机"
            
            local rsync_upload_cmd="rsync -avz --progress --partial --inplace"
            
            if [ "$backup_user_flag" = "true" ]; then
                rsync_upload_cmd="$rsync_upload_cmd -e 'ssh -p $master_port -i $backup_key'"
                local target_spec="$BACKUP_USER@$master_ip:$remote_backup_dir/"
            else
                if [ -n "$master_key" ] && [ -f "$master_key" ]; then
                    rsync_upload_cmd="$rsync_upload_cmd -e 'ssh -p $master_port -i $master_key'"
                else
                    rsync_upload_cmd="$rsync_upload_cmd -e 'ssh -p $master_port'"
                fi
                local target_spec="$master_user@$master_ip:$remote_backup_dir/"
            fi
            
            if eval "$rsync_upload_cmd $backup_filepath $target_spec" >> "$log_file" 2>&1; then
                log_message "SUCCESS" "备份传输完成"
                echo "备份传输完成: $(date)" >> "$log_file"
                
                # 步骤6: 清理旧备份
                log_message "INFO" "步骤6: 清理旧备份文件"
                cleanup_old_backups "$job_name"
                
                if [ "$backup_user_flag" = "true" ]; then
                    cleanup_old_backups_remote "$job_name" "$master_ssh_cmd" "$BACKUP_USER@$master_ip" "$remote_backup_dir"
                else
                    cleanup_old_backups_remote "$job_name" "$master_ssh_cmd" "$master_user@$master_ip" "$remote_backup_dir"
                fi
                
                # 备份成功，发送成功通知邮件
                local backup_end_time=$(date)
                local backup_size=$(du -h "$backup_filepath" | cut -f1)
                echo "备份任务完成: $backup_end_time" >> "$log_file"
                
                log_message "SUCCESS" "备份任务执行完成！"
                
                # 发送成功邮件通知
                local email_body="备份任务执行成功通知

任务名称: $job_name
开始时间: $backup_start_time
完成时间: $backup_end_time
备份大小: $backup_size

从机: $slave_name ($slave_ip)
主机: $master_name ($master_ip)
备份路径: $source_path

备份文件: $backup_filename
本地路径: $backup_filepath
远程路径: $remote_backup_dir/$backup_filename

日志文件: $log_file"

                send_email_notification "✅ 备份成功 - $job_name" "$email_body" "$log_file"
                
                # 清理临时文件
                rm -rf "$temp_backup"
                
                return 0
                
            else
                log_message "ERROR" "备份传输失败"
                echo "备份传输失败: $(date)" >> "$log_file"
            fi
        else
            log_message "ERROR" "压缩包创建失败"
            echo "压缩包创建失败: $(date)" >> "$log_file"
        fi
        
        # 清理临时文件
        rm -rf "$temp_backup"
        
    else
        log_message "ERROR" "数据同步失败"
        echo "数据同步失败: $(date)" >> "$log_file"
    fi
    
    # 备份失败，发送失败通知邮件
    local backup_end_time=$(date)
    echo "备份任务失败: $backup_end_time" >> "$log_file"
    
    local email_body="备份任务执行失败通知

任务名称: $job_name
开始时间: $backup_start_time
失败时间: $backup_end_time

从机: $slave_name ($slave_ip)
主机: $master_name ($master_ip)
备份路径: $source_path

错误详情请查看附件日志文件。

日志文件: $log_file"

    send_email_notification "❌ 备份失败 - $job_name" "$email_body" "$log_file"
    
    return 1
}

# 清理旧备份（本地）
cleanup_old_backups() {
    local job_name="$1"
    local backup_subdir="$BACKUP_DIR/$job_name"
    
    if [ ! -d "$backup_subdir" ]; then
        return
    fi
    
    # 保留最新的3个备份文件
    local files_to_delete=$(ls -1t "$backup_subdir"/${job_name}_*.tar.gz 2>/dev/null | tail -n +4)
    
    if [ -n "$files_to_delete" ]; then
        echo "$files_to_delete" | xargs rm -f
        print_info "清理了旧的本地备份文件"
    fi
}

# 清理远程主机上的旧备份
cleanup_old_backups_remote() {
    local job_name="$1"
    local ssh_cmd="$2"
    local host="$3"
    local backup_dir="$4"
    
    # 如果没有指定备份目录，使用默认目录
    if [ -z "$backup_dir" ]; then
        backup_dir="$SCRIPT_DIR/backup_data/$job_name"
    fi
    
    $ssh_cmd "$host" "
        if [ -d \"$backup_dir\" ]; then
            cd \"$backup_dir\"
            files_to_delete=\$(ls -1t ${job_name}_*.tar.gz 2>/dev/null | tail -n +4)
            if [ -n \"\$files_to_delete\" ]; then
                echo \"\$files_to_delete\" | xargs rm -f
                echo \"清理了远程旧备份文件\"
            fi
        fi
    " 2>/dev/null || true
}

# 设置cron任务
setup_cron_job() {
    local job_name="$1"
    local schedule="$2"
    
    print_info "正在设置定时任务..."
    
    # 创建cron任务脚本
    local cron_script="$CONFIG_DIR/cron_${job_name}.sh"
    
    cat > "$cron_script" << EOF
#!/bin/bash
cd "$SCRIPT_DIR"
./backup_manager.sh --execute-job "$job_name" >> "$LOGS_DIR/cron_${job_name}.log" 2>&1
EOF
    
    chmod +x "$cron_script"
    
    # 添加到crontab
    local cron_entry="$schedule $cron_script"
    local temp_cron=$(mktemp)
    
    # 获取现有的crontab
    crontab -l 2>/dev/null | grep -v "$cron_script" > "$temp_cron" || true
    
    # 添加新的任务
    echo "$cron_entry" >> "$temp_cron"
    
    # 安装新的crontab
    if crontab "$temp_cron"; then
        print_success "定时任务设置成功"
        print_info "任务将按以下计划执行: $schedule"
    else
        print_error "定时任务设置失败"
    fi
    
    rm -f "$temp_cron"
}

# 管理备份任务
manage_backup_jobs() {
    print_header "📋 管理备份任务"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
    
    if [ ! -f "$JOBS_FILE" ]; then
        print_warning "未找到备份任务配置"
        return
    fi
    
    echo -e "${CYAN}选择操作:${NC}"
    echo "1. 查看所有任务"
    echo "2. 启用/禁用任务"
    echo "3. 删除任务"
    echo "4. 修改任务"
    echo "0. 返回主菜单"
    echo
    
    read -p "请选择 (0-4): " choice
    
    case $choice in
        1)
            show_backup_jobs
            ;;
        2)
            toggle_job_status
            ;;
        3)
            delete_backup_job
            ;;
        4)
            modify_backup_job
            ;;
        0)
            return
            ;;
        *)
            print_warning "无效选择"
            ;;
    esac
}

# 显示备份任务
show_backup_jobs() {
    echo
    print_info "备份任务列表："
    echo
    
    if [ ! -f "$JOBS_FILE" ] || [ ! -s "$JOBS_FILE" ]; then
        print_warning "没有配置的备份任务"
        return
    fi
    
    load_hosts
    
    printf "%-4s %-15s %-15s %-15s %-20s %-15s %-10s\n" "序号" "任务名称" "从机" "主机" "备份路径" "计划" "状态"
    echo "──────────────────────────────────────────────────────────────────────────────────────────────────"
    
    local index=1
    while IFS=':' read -r name slave_idx master_idx source_path schedule created status; do
        local slave_name="${host_names[$slave_idx]:-未知}"
        local master_name="${host_names[$master_idx]:-未知}"
        
        # 状态颜色
        if [ "$status" = "enabled" ]; then
            status_color="${GREEN}启用${NC}"
        else
            status_color="${RED}禁用${NC}"
        fi
        
        printf "%-4s %-15s %-15s %-15s %-20s %-15s " "$index" "$name" "$slave_name" "$master_name" "${source_path:0:18}..." "$schedule"
        echo -e "$status_color"
        
        ((index++))
    done < "$JOBS_FILE"
}

# 查看备份历史
show_backup_history() {
    print_header "📊 备份历史记录"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
    
    if [ ! -d "$BACKUP_DIR" ]; then
        print_warning "备份目录不存在"
        return
    fi
    
    print_info "本地备份文件："
    echo
    
    printf "%-20s %-25s %-15s %-20s\n" "任务名称" "备份文件" "文件大小" "创建时间"
    echo "────────────────────────────────────────────────────────────────────────────────"
    
    for job_dir in "$BACKUP_DIR"/*; do
        if [ -d "$job_dir" ]; then
            local job_name=$(basename "$job_dir")
            
            for backup_file in "$job_dir"/*.tar.gz; do
                if [ -f "$backup_file" ]; then
                    local filename=$(basename "$backup_file")
                    local filesize=$(du -h "$backup_file" | cut -f1)
                    local filetime=$(stat -c %y "$backup_file" | cut -d. -f1)
                    
                    printf "%-20s %-25s %-15s %-20s\n" "$job_name" "$filename" "$filesize" "$filetime"
                fi
            done
        fi
    done
}

# 查看系统日志
show_system_logs() {
    print_header "📋 系统日志"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
    
    if [ ! -d "$LOGS_DIR" ]; then
        print_warning "日志目录不存在"
        return
    fi
    
    echo -e "${CYAN}选择查看的日志:${NC}"
    echo "1. 最新备份日志"
    echo "2. 所有日志文件"
    echo "3. 特定任务日志"
    echo "0. 返回主菜单"
    echo
    
    read -p "请选择 (0-3): " choice
    
    case $choice in
        1)
            local latest_log=$(ls -1t "$LOGS_DIR"/*.log 2>/dev/null | head -1)
            if [ -n "$latest_log" ]; then
                print_info "显示最新日志: $(basename "$latest_log")"
                echo
                tail -50 "$latest_log"
            else
                print_warning "未找到日志文件"
            fi
            ;;
        2)
            print_info "所有日志文件："
            echo
            ls -la "$LOGS_DIR"/*.log 2>/dev/null || print_warning "未找到日志文件"
            ;;
        3)
            echo
            read -p "请输入任务名称: " job_name
            if [ -n "$job_name" ]; then
                local job_logs=$(ls -1t "$LOGS_DIR"/${job_name}_*.log 2>/dev/null)
                if [ -n "$job_logs" ]; then
                    echo -e "${CYAN}任务 $job_name 的日志文件:${NC}"
                    echo "$job_logs"
                    echo
                    read -p "请输入要查看的日志文件序号 (回车查看最新): " log_choice
                    local selected_log
                    if [ -z "$log_choice" ]; then
                        selected_log=$(echo "$job_logs" | head -1)
                    else
                        selected_log=$(echo "$job_logs" | sed -n "${log_choice}p")
                    fi
                    
                    if [ -n "$selected_log" ] && [ -f "$selected_log" ]; then
                        print_info "显示日志: $(basename "$selected_log")"
                        echo
                        cat "$selected_log"
                    else
                        print_error "无效的日志选择"
                    fi
                else
                    print_warning "未找到任务 $job_name 的日志"
                fi
            fi
            ;;
        0)
            return
            ;;
        *)
            print_warning "无效选择"
            ;;
    esac
    
    echo
    read -p "按 Enter 键继续..."
}

# 备份统计信息
show_backup_statistics() {
    print_header "📈 备份统计信息"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
    
    # 统计备份任务数量
    local total_jobs=0
    local enabled_jobs=0
    local disabled_jobs=0
    
    if [ -f "$JOBS_FILE" ]; then
        total_jobs=$(wc -l < "$JOBS_FILE")
        enabled_jobs=$(grep ":enabled$" "$JOBS_FILE" | wc -l)
        disabled_jobs=$(grep ":disabled$" "$JOBS_FILE" | wc -l)
    fi
    
    # 统计备份文件
    local total_backups=0
    local total_size=0
    
    if [ -d "$BACKUP_DIR" ]; then
        total_backups=$(find "$BACKUP_DIR" -name "*.tar.gz" | wc -l)
        if [ $total_backups -gt 0 ]; then
            total_size=$(du -sh "$BACKUP_DIR" | cut -f1)
        fi
    fi
    
    # 统计日志文件
    local total_logs=0
    if [ -d "$LOGS_DIR" ]; then
        total_logs=$(find "$LOGS_DIR" -name "*.log" | wc -l)
    fi
    
    # 显示统计信息
    echo -e "${CYAN}任务统计:${NC}"
    echo "  总任务数: $total_jobs"
    echo "  启用任务: $enabled_jobs"
    echo "  禁用任务: $disabled_jobs"
    echo
    
    echo -e "${CYAN}备份统计:${NC}"
    echo "  备份文件数: $total_backups"
    echo "  占用空间: ${total_size:-0}"
    echo
    
    echo -e "${CYAN}日志统计:${NC}"
    echo "  日志文件数: $total_logs"
    echo
    
    # 最近备份活动
    if [ -d "$LOGS_DIR" ] && [ $total_logs -gt 0 ]; then
        echo -e "${CYAN}最近备份活动:${NC}"
        find "$LOGS_DIR" -name "*.log" -mtime -7 | while read -r log_file; do
            local job_name=$(basename "$log_file" | sed 's/_[0-9]*_[0-9]*.log$//')
            local log_time=$(stat -c %y "$log_file" | cut -d. -f1)
            echo "  $job_name: $log_time"
        done
    fi
    
    echo
    read -p "按 Enter 键继续..."
}

# 清理旧备份
cleanup_old_backups_menu() {
    print_header "🧹 清理旧备份"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
    
    echo -e "${CYAN}选择清理方式:${NC}"
    echo "1. 清理所有任务的旧备份"
    echo "2. 清理特定任务的旧备份"
    echo "3. 清理指定天数前的备份"
    echo "0. 返回主菜单"
    echo
    
    read -p "请选择 (0-3): " choice
    
    case $choice in
        1)
            print_warning "将清理所有任务的旧备份，仅保留最新3份"
            read -p "确认继续? (y/N): " confirm
            if [[ $confirm =~ ^[Yy]$ ]]; then
                for job_dir in "$BACKUP_DIR"/*; do
                    if [ -d "$job_dir" ]; then
                        cleanup_old_backups "$(basename "$job_dir")"
                    fi
                done
                print_success "清理完成"
            fi
            ;;
        2)
            show_backup_jobs
            echo
            read -p "请输入任务名称: " job_name
            if [ -n "$job_name" ]; then
                cleanup_old_backups "$job_name"
                print_success "任务 $job_name 的旧备份已清理"
            fi
            ;;
        3)
            read -p "请输入天数 (删除N天前的备份): " days
            if [[ "$days" =~ ^[0-9]+$ ]] && [ "$days" -gt 0 ]; then
                print_warning "将删除 $days 天前的所有备份文件"
                read -p "确认继续? (y/N): " confirm
                if [[ $confirm =~ ^[Yy]$ ]]; then
                    find "$BACKUP_DIR" -name "*.tar.gz" -mtime +$days -delete 2>/dev/null || true
                    find "$LOGS_DIR" -name "*.log" -mtime +$days -delete 2>/dev/null || true
                    print_success "清理完成"
                fi
            else
                print_error "无效的天数"
            fi
            ;;
        0)
            return
            ;;
        *)
            print_warning "无效选择"
            ;;
    esac
}

# 命令行参数处理
handle_command_line() {
    case "$1" in
        --execute-job)
            if [ -n "$2" ]; then
                execute_backup_job "$2"
                exit $?
            else
                print_error "请指定任务名称"
                exit 1
            fi
            ;;
        --list-jobs)
            show_backup_jobs
            exit 0
            ;;
        --help)
            echo "定时备份管理工具"
            echo
            echo "用法: $0 [选项]"
            echo
            echo "选项:"
            echo "  --execute-job <任务名>  执行指定的备份任务"
            echo "  --list-jobs            列出所有备份任务"
            echo "  --help                 显示帮助信息"
            echo
            exit 0
            ;;
    esac
}

# 主函数
main() {
    # 处理命令行参数
    if [ $# -gt 0 ]; then
        handle_command_line "$@"
    fi
    
    # 主循环
    while true; do
        show_welcome
        show_main_menu
        
        read -p "请选择操作 (0-11): " choice
        echo
        
        case $choice in
            1)
                configure_hosts
                ;;
            2)
                create_backup_job
                ;;
            3)
                manage_backup_jobs
                ;;
            4)
                print_info "测试连接功能开发中..."
                read -p "按 Enter 键继续..."
                ;;
            5)
                configure_email
                ;;
            6)
                show_backup_jobs
                echo
                read -p "请输入要执行的任务名称: " job_name
                if [ -n "$job_name" ]; then
                    execute_backup_job "$job_name"
                fi
                echo
                read -p "按 Enter 键继续..."
                ;;
            7)
                show_backup_history
                echo
                read -p "按 Enter 键继续..."
                ;;
            8)
                cleanup_old_backups_menu
                ;;
            9)
                show_backup_jobs
                echo
                read -p "按 Enter 键继续..."
                ;;
            10)
                show_system_logs
                ;;
            11)
                show_backup_statistics
                ;;
            0)
                return
                ;;
            *)
                print_warning "无效选择，请输入 0-11 之间的数字"
                read -p "按 Enter 键继续..."
                ;;
        esac
    done
}

# 信号处理
trap 'print_info "程序被中断"; exit 1' INT TERM

# 启动程序
main "$@" 