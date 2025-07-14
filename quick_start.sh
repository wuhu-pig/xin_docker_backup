#!/bin/bash

# Docker 迁移工具 - 快速开始脚本
# 用于快速设置环境和运行迁移工具

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

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
    echo -e "${CYAN}$1${NC}"
}

# 显示欢迎信息
show_welcome() {
    clear
    print_header "=========================================="
    print_header "    Docker 容器迁移工具 - 快速开始"
    print_header "=========================================="
    echo
    print_info "此工具将帮助您快速设置和使用 Docker 容器迁移功能"
    echo
}

# 检查系统环境
check_system() {
    print_info "正在检查系统环境..."
    
    # 检查操作系统
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        print_success "操作系统: Linux"
    else
        print_warning "警告: 此工具主要为 Linux 系统设计"
    fi
    
    # 检查 bash 版本
    if [ "${BASH_VERSION%%.*}" -ge 4 ]; then
        print_success "Bash 版本: $BASH_VERSION"
    else
        print_warning "建议使用 Bash 4.0 或更高版本"
    fi
}

# 检查 Docker
check_docker() {
    print_info "检查 Docker 环境..."
    
    if command -v docker &> /dev/null; then
        docker_version=$(docker --version)
        print_success "Docker 已安装: $docker_version"
        
        if docker info &> /dev/null; then
            print_success "Docker 服务正在运行"
        else
            print_error "Docker 服务未运行"
            print_info "请运行: sudo systemctl start docker"
            return 1
        fi
    else
        print_error "Docker 未安装"
        print_info "请先安装 Docker："
        echo "  curl -fsSL https://get.docker.com -o get-docker.sh"
        echo "  sudo sh get-docker.sh"
        return 1
    fi
}

# 检查 jq（导入时需要）
check_jq() {
    print_info "检查 jq 工具..."
    
    if command -v jq &> /dev/null; then
        jq_version=$(jq --version)
        print_success "jq 已安装: $jq_version"
    else
        print_warning "jq 未安装（导入时需要）"
        print_info "安装命令："
        echo "  # Ubuntu/Debian:"
        echo "  sudo apt-get update && sudo apt-get install jq"
        echo "  # CentOS/RHEL:"
        echo "  sudo yum install jq"
        echo
    fi
}

# 检查权限
check_permissions() {
    print_info "检查 Docker 权限..."
    
    if groups $USER | grep -q '\bdocker\b'; then
        print_success "用户已在 docker 组中"
    else
        print_warning "用户不在 docker 组中"
        print_info "建议添加到 docker 组："
        echo "  sudo usermod -aG docker $USER"
        echo "  然后重新登录或运行: newgrp docker"
        echo
    fi
}

# 显示可用操作
show_menu() {
    echo
    print_header "请选择操作:"
    echo "1. 🔍 扫描并导出 Docker 容器（在源服务器上运行）"
    echo "2. 📦 导入 Docker 容器（在目标服务器上运行）"
    echo "3. 📋 查看系统中的 Docker 容器"
    echo "4. 🧹 清理 Docker 系统"
    echo "5. 📖 查看使用说明"
    echo "6. ❌ 退出"
    echo
}

# 扫描 Docker 容器
scan_containers() {
    print_info "扫描系统中的 Docker 容器..."
    echo
    
    if ! docker ps -a --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}" | head -20; then
        print_error "无法获取容器信息"
        return 1
    fi
    
    echo
    read -p "按 Enter 键继续..."
}

# 清理 Docker 系统
cleanup_docker() {
    print_warning "此操作将清理未使用的 Docker 资源"
    print_info "包括: 停止的容器、未使用的网络、悬空镜像、构建缓存"
    echo
    
    read -p "确认继续吗？(y/N): " confirm
    if [[ $confirm =~ ^[Yy]$ ]]; then
        print_info "正在清理..."
        docker system prune -f
        print_success "清理完成"
    else
        print_info "取消清理操作"
    fi
    
    echo
    read -p "按 Enter 键继续..."
}

# 显示使用说明
show_help() {
    print_header "=== Docker 容器迁移工具使用说明 ==="
    echo
    echo "💡 基本流程："
    echo "  1. 在源服务器上运行导出脚本"
    echo "  2. 将生成的压缩包传输到目标服务器"
    echo "  3. 在目标服务器上运行导入脚本"
    echo
    echo "📝 详细步骤："
    echo "  源服务器："
    echo "    ./docker_export.sh"
    echo
    echo "  目标服务器："
    echo "    tar -xzf docker_migration_*.tar.gz"
    echo "    cd docker_export_*/"
    echo "    ./docker_import.sh"
    echo
    echo "🔧 系统要求："
    echo "  - Linux 系统（Ubuntu 20.04 推荐）"
    echo "  - Docker 已安装并运行"
    echo "  - jq 工具（导入时需要）"
    echo "  - 足够的磁盘空间"
    echo
    echo "⚠️ 注意事项："
    echo "  - 导出可能需要较长时间"
    echo "  - 确保目标服务器端口不冲突"
    echo "  - 数据库容器恢复后请检查数据"
    echo
    echo "📚 更多信息请查看 README.md"
    echo
    read -p "按 Enter 键继续..."
}

# 运行导出脚本
run_export() {
    if [ ! -f "docker_export.sh" ]; then
        print_error "找不到 docker_export.sh 脚本"
        print_info "请确保脚本文件在当前目录中"
        return 1
    fi
    
    if [ ! -x "docker_export.sh" ]; then
        print_info "设置脚本执行权限..."
        chmod +x docker_export.sh
    fi
    
    print_info "启动 Docker 容器导出工具..."
    echo
    ./docker_export.sh
}

# 运行导入脚本
run_import() {
    # 查找导入脚本
    import_script=""
    
    if [ -f "docker_import.sh" ]; then
        import_script="docker_import.sh"
    elif [ -f "*/docker_import.sh" ]; then
        import_script=$(find . -name "docker_import.sh" -type f | head -1)
    fi
    
    if [ -z "$import_script" ]; then
        print_error "找不到 docker_import.sh 脚本"
        print_info "请确保已解压迁移包并在正确目录中运行"
        echo
        print_info "正确的操作步骤："
        echo "  1. tar -xzf docker_migration_*.tar.gz"
        echo "  2. cd docker_export_*/"
        echo "  3. ./quick_start.sh"
        return 1
    fi
    
    if [ ! -x "$import_script" ]; then
        print_info "设置脚本执行权限..."
        chmod +x "$import_script"
    fi
    
    print_info "启动 Docker 容器导入工具..."
    echo
    ./"$import_script"
}

# 主函数
main() {
    show_welcome
    check_system
    check_docker || exit 1
    check_jq
    check_permissions
    
    while true; do
        show_menu
        read -p "请选择操作 (1-6): " choice
        
        case $choice in
            1)
                echo
                run_export
                ;;
            2)
                echo
                run_import
                ;;
            3)
                echo
                scan_containers
                ;;
            4)
                echo
                cleanup_docker
                ;;
            5)
                echo
                show_help
                ;;
            6)
                print_info "感谢使用 Docker 容器迁移工具！"
                exit 0
                ;;
            *)
                print_warning "无效选择，请输入 1-6"
                ;;
        esac
    done
}

# 检查脚本是否以 root 用户运行
if [ "$EUID" -eq 0 ]; then
    print_warning "不建议以 root 用户运行此脚本"
    print_info "请使用普通用户（已加入 docker 组）运行"
    echo
    read -p "仍要继续吗？(y/N): " confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# 运行主函数
main "$@" 