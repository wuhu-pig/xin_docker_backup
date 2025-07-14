#!/bin/bash

# 系统管理工具集 - 主菜单
# 作者: AI Assistant
# 版本: v1.0
# 用途: 集成多个系统管理工具的统一入口

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

# 工具信息
TOOL_NAME="系统管理工具集"
TOOL_VERSION="v1.0"
TOOL_AUTHOR="AI Assistant"

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

# 显示Logo和欢迎信息
show_welcome() {
    clear
    echo -e "${CYAN}${BOLD}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                     系统管理工具集                           ║
║                  System Management Tools                    ║
╠══════════════════════════════════════════════════════════════╣
║  🐳 Docker 容器迁移                                          ║
║  🔧 系统维护工具                                             ║
║  📊 系统监控                                                 ║
║  🛠️ 网络工具                                               ║
╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    print_info "欢迎使用 ${TOOL_NAME} ${TOOL_VERSION}"
    print_info "作者: ${TOOL_AUTHOR}"
    echo
}

# 显示系统信息
show_system_info() {
    print_header "系统信息"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # 基本系统信息
    echo -e "${CYAN}操作系统:${NC} $(lsb_release -d 2>/dev/null | cut -f2 || uname -s)"
    echo -e "${CYAN}内核版本:${NC} $(uname -r)"
    echo -e "${CYAN}主机名:${NC} $(hostname)"
    echo -e "${CYAN}当前用户:${NC} $(whoami)"
    echo -e "${CYAN}当前时间:${NC} $(date '+%Y-%m-%d %H:%M:%S')"
    
    # 资源使用情况
    if command -v free &> /dev/null; then
        memory_info=$(free -h | grep "Mem:" | awk '{print $3"/"$2}')
        echo -e "${CYAN}内存使用:${NC} $memory_info"
    fi
    
    if command -v df &> /dev/null; then
        disk_usage=$(df -h / | tail -1 | awk '{print $3"/"$2" ("$5")"}')
        echo -e "${CYAN}磁盘使用:${NC} $disk_usage"
    fi
    
    # Docker状态
    if command -v docker &> /dev/null; then
        if docker info &> /dev/null; then
            container_count=$(docker ps -q | wc -l)
            image_count=$(docker images -q | wc -l)
            echo -e "${CYAN}Docker状态:${NC} ${GREEN}运行中${NC} (容器: $container_count, 镜像: $image_count)"
        else
            echo -e "${CYAN}Docker状态:${NC} ${RED}未运行${NC}"
        fi
    else
        echo -e "${CYAN}Docker状态:${NC} ${YELLOW}未安装${NC}"
    fi
    
    echo
}

# 主菜单
show_main_menu() {
    print_header "主菜单"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
    echo -e "${WHITE}${BOLD}🐳 Docker 管理${NC}"
    echo "  1. Docker 容器迁移工具"
    echo "  2. Docker 容器管理"
    echo "  3. Docker 镜像管理"
    echo "  4. Docker 系统清理"
    echo
    echo -e "${WHITE}${BOLD}🔧 系统维护${NC}"
    echo "  5. 系统更新"
    echo "  6. 磁盘清理"
    echo "  7. 服务管理"
    echo "  8. 用户管理"
    echo
    echo -e "${WHITE}${BOLD}📊 系统监控${NC}"
    echo "  9. 实时系统监控"
    echo " 10. 进程管理"
    echo " 11. 网络连接"
    echo " 12. 日志查看"
    echo
    echo -e "${WHITE}${BOLD}🛠️ 网络工具${NC}"
    echo " 13. 端口扫描"
    echo " 14. 网络诊断"
    echo " 15. 防火墙管理"
    echo
    echo -e "${WHITE}${BOLD}⚙️ 工具设置${NC}"
    echo " 16. 工具配置"
    echo " 17. 关于信息"
    echo
    echo -e "${WHITE}${BOLD}其他选项${NC}"
    echo " 0. 退出程序"
    echo
}

# Docker容器迁移工具
docker_migration() {
    print_header "🐳 Docker 容器迁移工具"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
    
    if [ -f "quick_start.sh" ]; then
        print_info "启动 Docker 容器迁移快速开始脚本..."
        echo
        ./quick_start.sh
    elif [ -f "docker_export.sh" ]; then
        print_info "启动 Docker 容器导出脚本..."
        echo
        ./docker_export.sh
    else
        print_error "找不到 Docker 迁移工具脚本文件"
        print_info "请确保以下文件存在："
        echo "  - quick_start.sh"
        echo "  - docker_export.sh"
        echo
        read -p "按 Enter 键返回主菜单..."
    fi
}

# Docker容器管理
docker_container_management() {
    print_header "🐳 Docker 容器管理"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker 未安装"
        read -p "按 Enter 键返回主菜单..."
        return
    fi
    
    echo -e "${CYAN}选择操作:${NC}"
    echo "1. 查看所有容器"
    echo "2. 查看运行中的容器"
    echo "3. 启动容器"
    echo "4. 停止容器"
    echo "5. 删除容器"
    echo "6. 查看容器日志"
    echo "0. 返回主菜单"
    echo
    
    read -p "请选择 (0-6): " choice
    
    case $choice in
        1)
            echo
            print_info "所有容器:"
            docker ps -a --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"
            ;;
        2)
            echo
            print_info "运行中的容器:"
            docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"
            ;;
        3)
            echo
            docker ps -a --format "table {{.Names}}\t{{.Status}}"
            echo
            read -p "请输入要启动的容器名称: " container_name
            if [ -n "$container_name" ]; then
                docker start "$container_name" && print_success "容器 $container_name 启动成功"
            fi
            ;;
        4)
            echo
            docker ps --format "table {{.Names}}\t{{.Status}}"
            echo
            read -p "请输入要停止的容器名称: " container_name
            if [ -n "$container_name" ]; then
                docker stop "$container_name" && print_success "容器 $container_name 停止成功"
            fi
            ;;
        5)
            echo
            docker ps -a --format "table {{.Names}}\t{{.Status}}"
            echo
            read -p "请输入要删除的容器名称: " container_name
            if [ -n "$container_name" ]; then
                read -p "确认删除容器 $container_name? (y/N): " confirm
                if [[ $confirm =~ ^[Yy]$ ]]; then
                    docker rm "$container_name" && print_success "容器 $container_name 删除成功"
                fi
            fi
            ;;
        6)
            echo
            docker ps -a --format "table {{.Names}}\t{{.Status}}"
            echo
            read -p "请输入要查看日志的容器名称: " container_name
            if [ -n "$container_name" ]; then
                print_info "显示容器 $container_name 的最近100行日志:"
                docker logs --tail 100 "$container_name"
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

# Docker镜像管理
docker_image_management() {
    print_header "🐳 Docker 镜像管理"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker 未安装"
        read -p "按 Enter 键返回主菜单..."
        return
    fi
    
    echo -e "${CYAN}选择操作:${NC}"
    echo "1. 查看所有镜像"
    echo "2. 搜索镜像"
    echo "3. 拉取镜像"
    echo "4. 删除镜像"
    echo "5. 清理悬空镜像"
    echo "0. 返回主菜单"
    echo
    
    read -p "请选择 (0-5): " choice
    
    case $choice in
        1)
            echo
            print_info "所有镜像:"
            docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"
            ;;
        2)
            echo
            read -p "请输入要搜索的镜像名称: " image_name
            if [ -n "$image_name" ]; then
                print_info "搜索结果:"
                docker search "$image_name" | head -10
            fi
            ;;
        3)
            echo
            read -p "请输入要拉取的镜像名称 (如: nginx:latest): " image_name
            if [ -n "$image_name" ]; then
                docker pull "$image_name" && print_success "镜像 $image_name 拉取成功"
            fi
            ;;
        4)
            echo
            docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
            echo
            read -p "请输入要删除的镜像名称:标签: " image_name
            if [ -n "$image_name" ]; then
                read -p "确认删除镜像 $image_name? (y/N): " confirm
                if [[ $confirm =~ ^[Yy]$ ]]; then
                    docker rmi "$image_name" && print_success "镜像 $image_name 删除成功"
                fi
            fi
            ;;
        5)
            echo
            print_warning "此操作将删除所有悬空镜像"
            read -p "确认继续? (y/N): " confirm
            if [[ $confirm =~ ^[Yy]$ ]]; then
                docker image prune -f && print_success "悬空镜像清理完成"
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

# Docker系统清理
docker_system_cleanup() {
    print_header "🐳 Docker 系统清理"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker 未安装"
        read -p "按 Enter 键返回主菜单..."
        return
    fi
    
    print_warning "此操作将清理Docker系统中的未使用资源"
    print_info "包括: 停止的容器、未使用的网络、悬空镜像、构建缓存"
    echo
    
    # 显示当前资源使用情况
    print_info "当前Docker资源使用情况:"
    docker system df
    echo
    
    read -p "确认继续清理? (y/N): " confirm
    if [[ $confirm =~ ^[Yy]$ ]]; then
        print_info "正在清理Docker系统..."
        docker system prune -f
        print_success "Docker系统清理完成"
        
        echo
        print_info "清理后的资源使用情况:"
        docker system df
    else
        print_info "取消清理操作"
    fi
    
    echo
    read -p "按 Enter 键返回主菜单..."
}

# 系统更新
system_update() {
    print_header "🔧 系统更新"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
    
    print_warning "此操作将更新系统软件包"
    read -p "确认继续? (y/N): " confirm
    
    if [[ $confirm =~ ^[Yy]$ ]]; then
        print_info "正在更新软件包列表..."
        sudo apt-get update
        
        echo
        print_info "正在升级系统软件包..."
        sudo apt-get upgrade -y
        
        echo
        print_info "正在清理软件包缓存..."
        sudo apt-get autoremove -y
        sudo apt-get autoclean
        
        print_success "系统更新完成"
    else
        print_info "取消系统更新"
    fi
    
    echo
    read -p "按 Enter 键返回主菜单..."
}

# 实时系统监控
system_monitor() {
    print_header "📊 实时系统监控"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
    
    print_info "启动实时系统监控 (按 Ctrl+C 退出)"
    echo
    
    if command -v htop &> /dev/null; then
        htop
    elif command -v top &> /dev/null; then
        top
    else
        print_error "未找到系统监控工具 (htop/top)"
        read -p "按 Enter 键返回主菜单..."
    fi
}

# 网络诊断
network_diagnostic() {
    print_header "🛠️ 网络诊断"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
    
    echo -e "${CYAN}选择诊断类型:${NC}"
    echo "1. 网络接口信息"
    echo "2. 路由表"
    echo "3. DNS 解析测试"
    echo "4. 连通性测试"
    echo "5. 端口监听"
    echo "0. 返回主菜单"
    echo
    
    read -p "请选择 (0-5): " choice
    
    case $choice in
        1)
            echo
            print_info "网络接口信息:"
            ip addr show || ifconfig
            ;;
        2)
            echo
            print_info "路由表:"
            ip route show || route -n
            ;;
        3)
            echo
            read -p "请输入要解析的域名 (默认: google.com): " domain
            domain=${domain:-google.com}
            print_info "DNS解析测试 - $domain:"
            nslookup "$domain" || dig "$domain"
            ;;
        4)
            echo
            read -p "请输入要测试的主机 (默认: 8.8.8.8): " host
            host=${host:-8.8.8.8}
            print_info "连通性测试 - $host:"
            ping -c 4 "$host"
            ;;
        5)
            echo
            print_info "当前监听的端口:"
            ss -tlnp || netstat -tlnp
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

# 关于信息
show_about() {
    print_header "📖 关于信息"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
    echo -e "${CYAN}${BOLD}工具名称:${NC} ${TOOL_NAME}"
    echo -e "${CYAN}${BOLD}版本号:${NC} ${TOOL_VERSION}"
    echo -e "${CYAN}${BOLD}作者:${NC} ${TOOL_AUTHOR}"
    echo -e "${CYAN}${BOLD}创建时间:${NC} $(date '+%Y-%m-%d')"
    echo
    echo -e "${CYAN}${BOLD}功能模块:${NC}"
    echo "  🐳 Docker 容器迁移工具"
    echo "  🐳 Docker 容器管理"
    echo "  🐳 Docker 镜像管理"
    echo "  🐳 Docker 系统清理"
    echo "  🔧 系统更新"
    echo "  📊 系统监控"
    echo "  🛠️ 网络诊断工具"
    echo
    echo -e "${CYAN}${BOLD}支持的系统:${NC}"
    echo "  • Ubuntu 20.04+"
    echo "  • Debian 10+"
    echo "  • CentOS 8+"
    echo "  • 其他Linux发行版"
    echo
    echo -e "${CYAN}${BOLD}许可证:${NC} MIT License"
    echo
    read -p "按 Enter 键返回主菜单..."
}

# 错误处理函数
handle_error() {
    print_error "发生错误: $1"
    echo
    read -p "按 Enter 键继续..."
}

# 检查必要的依赖
check_dependencies() {
    local missing_deps=()
    
    # 检查基本命令
    for cmd in grep awk sed cut; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_deps+=("$cmd")
        fi
    done
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        print_warning "缺少必要的系统工具: ${missing_deps[*]}"
        print_info "请安装这些工具后再运行此脚本"
        return 1
    fi
    
    return 0
}

# 主函数
main() {
    # 检查依赖
    if ! check_dependencies; then
        exit 1
    fi
    
    # 主循环
    while true; do
        show_welcome
        show_system_info
        show_main_menu
        
        read -p "请选择操作 (0-17): " choice
        echo
        
        case $choice in
            1)
                docker_migration
                ;;
            2)
                docker_container_management
                ;;
            3)
                docker_image_management
                ;;
            4)
                docker_system_cleanup
                ;;
            5)
                system_update
                ;;
            6)
                print_info "磁盘清理功能开发中..."
                read -p "按 Enter 键返回主菜单..."
                ;;
            7)
                print_info "服务管理功能开发中..."
                read -p "按 Enter 键返回主菜单..."
                ;;
            8)
                print_info "用户管理功能开发中..."
                read -p "按 Enter 键返回主菜单..."
                ;;
            9)
                system_monitor
                ;;
            10)
                print_info "进程管理功能开发中..."
                read -p "按 Enter 键返回主菜单..."
                ;;
            11)
                print_info "网络连接功能开发中..."
                read -p "按 Enter 键返回主菜单..."
                ;;
            12)
                print_info "日志查看功能开发中..."
                read -p "按 Enter 键返回主菜单..."
                ;;
            13)
                print_info "端口扫描功能开发中..."
                read -p "按 Enter 键返回主菜单..."
                ;;
            14)
                network_diagnostic
                ;;
            15)
                print_info "防火墙管理功能开发中..."
                read -p "按 Enter 键返回主菜单..."
                ;;
            16)
                print_info "工具配置功能开发中..."
                read -p "按 Enter 键返回主菜单..."
                ;;
            17)
                show_about
                ;;
            0)
                print_success "感谢使用 ${TOOL_NAME}！"
                exit 0
                ;;
            *)
                print_warning "无效选择，请输入 0-17 之间的数字"
                read -p "按 Enter 键继续..."
                ;;
        esac
    done
}

# 信号处理
trap 'print_info "程序被中断"; exit 1' INT TERM

# 检查是否以root用户运行某些功能的警告
check_root_warning() {
    if [ "$EUID" -eq 0 ]; then
        print_warning "当前以root用户运行"
        print_info "某些功能可能需要特殊注意"
        echo
    fi
}

# 启动程序
check_root_warning
main "$@" 