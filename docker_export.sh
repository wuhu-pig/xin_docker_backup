#!/bin/bash

# Docker服务迁移工具 - 导出脚本
# 作者: AI Assistant
# 用途: 扫描、选择并打包Docker服务以便迁移

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的信息
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

# 检查Docker是否安装并运行
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker未安装，请先安装Docker"
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        print_error "Docker服务未运行，请启动Docker服务"
        exit 1
    fi
    
    print_success "Docker环境检查通过"
}

# 获取所有容器信息
get_containers() {
    print_info "正在扫描Docker容器..."
    
    # 获取所有容器（包括停止的）
    containers=$(docker ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}")
    
    if [ -z "$containers" ] || [ "$(echo "$containers" | wc -l)" -eq 1 ]; then
        print_warning "未发现任何Docker容器"
        exit 0
    fi
    
    echo "$containers"
}

# 显示容器列表供用户选择
show_container_selection() {
    echo
    print_info "发现以下Docker容器："
    echo
    
    # 显示表头
    printf "%-4s %-12s %-20s %-30s %-15s %-20s\n" "序号" "容器ID" "容器名称" "镜像" "状态" "端口映射"
    echo "────────────────────────────────────────────────────────────────────────────────────────────────"
    
    # 获取容器信息并编号
    container_info=$(docker ps -a --format "{{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}")
    
    index=1
    declare -g -a container_ids=()
    declare -g -a container_names=()
    declare -g -a container_images=()
    declare -g -a container_status=()
    
    while IFS=$'\t' read -r id name image status ports; do
        container_ids+=("$id")
        container_names+=("$name")
        container_images+=("$image")
        container_status+=("$status")
        
        # 截断长字符串以适应显示
        short_id="${id:0:12}"
        short_name="${name:0:20}"
        short_image="${image:0:30}"
        short_status="${status:0:15}"
        short_ports="${ports:0:20}"
        
        # 根据状态设置颜色
        if [[ "$status" == *"Up"* ]]; then
            status_color="${GREEN}"
        else
            status_color="${RED}"
        fi
        
        printf "%-4s %-12s %-20s %-30s ${status_color}%-15s${NC} %-20s\n" \
            "$index" "$short_id" "$short_name" "$short_image" "$short_status" "$short_ports"
        
        ((index++))
    done <<< "$container_info"
}

# 用户选择要导出的容器
select_containers() {
    echo
    print_info "请选择要打包的容器（多个容器用空格分隔，如: 1 3 5）："
    print_info "输入 'all' 选择所有容器，输入 'q' 退出"
    
    read -p "请输入选择: " selection
    
    if [ "$selection" = "q" ]; then
        print_info "用户取消操作"
        exit 0
    fi
    
    declare -g -a selected_indices=()
    
    if [ "$selection" = "all" ]; then
        for i in $(seq 0 $((${#container_ids[@]} - 1))); do
            selected_indices+=("$i")
        done
    else
        for num in $selection; do
            if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le "${#container_ids[@]}" ]; then
                selected_indices+=($((num - 1)))
            else
                print_warning "无效选择: $num，已忽略"
            fi
        done
    fi
    
    if [ "${#selected_indices[@]}" -eq 0 ]; then
        print_error "未选择任何有效的容器"
        exit 1
    fi
    
    echo
    print_info "已选择以下容器进行打包："
    for i in "${selected_indices[@]}"; do
        echo "  - ${container_names[$i]} (${container_ids[$i]:0:12})"
    done
}

# 创建导出目录
create_export_directory() {
    export_dir="docker_export_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$export_dir"/{images,configs,volumes}
    
    print_info "创建导出目录: $export_dir"
}

# 导出容器镜像
export_images() {
    print_info "正在导出Docker镜像..."
    
    declare -g -a exported_images=()
    
    for i in "${selected_indices[@]}"; do
        container_id="${container_ids[$i]}"
        container_name="${container_names[$i]}"
        image_name="${container_images[$i]}"
        
        print_info "导出容器 $container_name 的镜像: $image_name"
        
        # 清理镜像名称以用作文件名
        safe_image_name=$(echo "$image_name" | sed 's/[\/:]/_/g')
        image_file="$export_dir/images/${safe_image_name}.tar"
        
        if docker save -o "$image_file" "$image_name"; then
            exported_images+=("$image_name")
            print_success "镜像导出成功: $image_file"
        else
            print_error "镜像导出失败: $image_name"
        fi
    done
}

# 导出容器配置
export_configs() {
    print_info "正在导出容器配置..."
    
    config_file="$export_dir/configs/containers.json"
    echo "[" > "$config_file"
    
    for i in "${selected_indices[@]}"; do
        container_id="${container_ids[$i]}"
        container_name="${container_names[$i]}"
        
        print_info "导出容器配置: $container_name"
        
        # 获取容器详细信息
        docker inspect "$container_id" >> "$config_file"
        
        # 如果不是最后一个容器，添加逗号
        if [ "$i" != "${selected_indices[-1]}" ]; then
            echo "," >> "$config_file"
        fi
    done
    
    echo "]" >> "$config_file"
    print_success "容器配置导出完成"
}

# 导出卷数据
export_volumes() {
    print_info "正在导出卷数据..."
    
    for i in "${selected_indices[@]}"; do
        container_id="${container_ids[$i]}"
        container_name="${container_names[$i]}"
        
        # 获取容器的卷挂载信息
        mounts=$(docker inspect "$container_id" --format '{{range .Mounts}}{{.Source}}:{{.Destination}}:{{.Type}} {{end}}')
        
        if [ -n "$mounts" ]; then
            print_info "导出容器 $container_name 的卷数据"
            
            volume_dir="$export_dir/volumes/$container_name"
            mkdir -p "$volume_dir"
            
            for mount in $mounts; do
                IFS=':' read -r source dest type <<< "$mount"
                
                if [ "$type" = "bind" ] && [ -d "$source" ]; then
                    safe_dest=$(echo "$dest" | sed 's/\//_/g')
                    tar -czf "$volume_dir/bind_${safe_dest}.tar.gz" -C "$(dirname "$source")" "$(basename "$source")" 2>/dev/null || true
                elif [ "$type" = "volume" ]; then
                    volume_name=$(basename "$source")
                    docker run --rm -v "$volume_name:/source" -v "$PWD/$volume_dir:/backup" alpine tar -czf "/backup/volume_${volume_name}.tar.gz" -C /source . 2>/dev/null || true
                fi
            done
        fi
    done
}

# 创建恢复脚本
create_restore_script() {
    print_info "创建恢复脚本..."
    
    restore_script="$export_dir/docker_import.sh"
    
    cat > "$restore_script" << 'EOF'
#!/bin/bash

# Docker服务迁移工具 - 导入脚本
# 自动生成的恢复脚本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

# 检查Docker环境
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker未安装，请先安装Docker"
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        print_error "Docker服务未运行，请启动Docker服务"
        exit 1
    fi
    
    print_success "Docker环境检查通过"
}

# 显示可用的容器
show_available_containers() {
    print_info "可导入的容器："
    echo
    
    if [ ! -f "configs/containers.json" ]; then
        print_error "未找到容器配置文件"
        exit 1
    fi
    
    # 解析容器信息
    container_count=$(jq length configs/containers.json)
    
    printf "%-4s %-20s %-30s %-15s\n" "序号" "容器名称" "镜像" "原始状态"
    echo "───────────────────────────────────────────────────────────────────────"
    
    for i in $(seq 0 $((container_count - 1))); do
        name=$(jq -r ".[$i].Name" configs/containers.json | sed 's/^\///')
        image=$(jq -r ".[$i].Config.Image" configs/containers.json)
        state=$(jq -r ".[$i].State.Status" configs/containers.json)
        
        printf "%-4s %-20s %-30s %-15s\n" "$((i + 1))" "$name" "$image" "$state"
    done
}

# 导入镜像
import_images() {
    print_info "正在导入Docker镜像..."
    
    for image_file in images/*.tar; do
        if [ -f "$image_file" ]; then
            print_info "导入镜像: $(basename "$image_file")"
            docker load -i "$image_file"
        fi
    done
    
    print_success "镜像导入完成"
}

# 恢复卷数据
restore_volumes() {
    local container_name="$1"
    
    volume_dir="volumes/$container_name"
    if [ -d "$volume_dir" ]; then
        print_info "恢复容器 $container_name 的卷数据"
        
        for volume_file in "$volume_dir"/*.tar.gz; do
            if [ -f "$volume_file" ]; then
                filename=$(basename "$volume_file")
                if [[ "$filename" == bind_* ]]; then
                    # 处理bind挂载
                    print_info "恢复bind挂载: $filename"
                elif [[ "$filename" == volume_* ]]; then
                    # 处理命名卷
                    volume_name=${filename#volume_}
                    volume_name=${volume_name%.tar.gz}
                    print_info "恢复命名卷: $volume_name"
                    
                    docker volume create "$volume_name" || true
                    docker run --rm -v "$volume_name:/target" -v "$PWD/$volume_dir:/backup" alpine tar -xzf "/backup/$filename" -C /target
                fi
            fi
        done
    fi
}

# 创建并启动容器
create_container() {
    local index="$1"
    
    # 从JSON配置中提取容器信息
    name=$(jq -r ".[$index].Name" configs/containers.json | sed 's/^\///')
    image=$(jq -r ".[$index].Config.Image" configs/containers.json)
    
    print_info "创建容器: $name"
    
    # 恢复卷数据
    restore_volumes "$name"
    
    # 构建docker run命令
    cmd="docker run -d --name $name"
    
    # 添加端口映射
    ports=$(jq -r ".[$index].NetworkSettings.Ports | to_entries[] | select(.value != null) | .value[0].HostPort + \":\" + .key" configs/containers.json 2>/dev/null || true)
    if [ -n "$ports" ]; then
        while IFS= read -r port; do
            cmd="$cmd -p $port"
        done <<< "$ports"
    fi
    
    # 添加环境变量
    envs=$(jq -r ".[$index].Config.Env[]?" configs/containers.json 2>/dev/null || true)
    if [ -n "$envs" ]; then
        while IFS= read -r env; do
            cmd="$cmd -e \"$env\""
        done <<< "$envs"
    fi
    
    # 添加卷挂载
    mounts=$(jq -r ".[$index].Mounts[]? | .Source + \":\" + .Destination" configs/containers.json 2>/dev/null || true)
    if [ -n "$mounts" ]; then
        while IFS= read -r mount; do
            cmd="$cmd -v $mount"
        done <<< "$mounts"
    fi
    
    # 添加镜像名
    cmd="$cmd $image"
    
    # 添加启动命令
    start_cmd=$(jq -r ".[$index].Config.Cmd[]?" configs/containers.json 2>/dev/null | tr '\n' ' ' || true)
    if [ -n "$start_cmd" ]; then
        cmd="$cmd $start_cmd"
    fi
    
    print_info "执行命令: $cmd"
    
    # 执行创建命令
    if eval "$cmd"; then
        print_success "容器 $name 创建并启动成功"
    else
        print_error "容器 $name 创建失败"
    fi
}

# 主函数
main() {
    print_info "Docker服务导入工具"
    echo
    
    check_docker
    import_images
    
    show_available_containers
    
    echo
    print_info "请选择要恢复的容器（多个用空格分隔，如: 1 3 5）："
    print_info "输入 'all' 恢复所有容器，输入 'q' 退出"
    
    read -p "请输入选择: " selection
    
    if [ "$selection" = "q" ]; then
        print_info "用户取消操作"
        exit 0
    fi
    
    container_count=$(jq length configs/containers.json)
    
    if [ "$selection" = "all" ]; then
        for i in $(seq 0 $((container_count - 1))); do
            create_container "$i"
        done
    else
        for num in $selection; do
            if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le "$container_count" ]; then
                create_container $((num - 1))
            else
                print_warning "无效选择: $num，已忽略"
            fi
        done
    fi
    
    print_success "容器恢复完成！"
    print_info "使用 'docker ps' 查看运行状态"
}

# 检查是否有jq工具
if ! command -v jq &> /dev/null; then
    print_error "需要安装jq工具来解析JSON配置"
    print_info "Ubuntu/Debian: sudo apt-get install jq"
    print_info "CentOS/RHEL: sudo yum install jq"
    exit 1
fi

main "$@"
EOF

    chmod +x "$restore_script"
    print_success "恢复脚本创建完成: $restore_script"
}

# 创建清单文件
create_manifest() {
    print_info "创建导出清单..."
    
    manifest_file="$export_dir/MANIFEST.txt"
    
    cat > "$manifest_file" << EOF
Docker容器导出清单
==================

导出时间: $(date '+%Y-%m-%d %H:%M:%S')
导出主机: $(hostname)
Docker版本: $(docker --version)

导出的容器:
EOF

    for i in "${selected_indices[@]}"; do
        container_name="${container_names[$i]}"
        container_image="${container_images[$i]}"
        container_status="${container_status[$i]}"
        
        cat >> "$manifest_file" << EOF

容器名称: $container_name
镜像: $container_image
状态: $container_status
容器ID: ${container_ids[$i]}
EOF
    done
    
    cat >> "$manifest_file" << EOF

文件结构:
- images/: Docker镜像文件
- configs/: 容器配置文件
- volumes/: 卷数据备份
- docker_import.sh: 导入脚本
- MANIFEST.txt: 此清单文件

使用方法:
1. 将整个 $export_dir 目录复制到目标服务器
2. 在目标服务器上运行: ./docker_import.sh
3. 按提示选择要恢复的容器

注意事项:
- 确保目标服务器已安装Docker和jq
- 某些容器可能需要手动调整网络配置
- 数据库容器恢复后请检查数据完整性
EOF

    print_success "清单文件创建完成: $manifest_file"
}

# 打包导出文件
create_archive() {
    print_info "正在创建压缩包..."
    
    archive_name="docker_migration_$(date +%Y%m%d_%H%M%S).tar.gz"
    
    tar -czf "$archive_name" "$export_dir"
    
    if [ $? -eq 0 ]; then
        print_success "压缩包创建成功: $PWD/$archive_name"
        print_info "压缩包大小: $(du -h "$archive_name" | cut -f1)"
        
        # 清理临时目录
        rm -rf "$export_dir"
        
        echo
        print_success "导出完成！"
        print_info "请将压缩包 $archive_name 下载到目标服务器"
        print_info "在目标服务器上解压并运行 docker_import.sh 即可恢复容器"
    else
        print_error "压缩包创建失败"
        exit 1
    fi
}

# 主函数
main() {
    echo "================================="
    echo "   Docker容器迁移工具 - 导出"
    echo "================================="
    echo
    
    check_docker
    get_containers
    show_container_selection
    select_containers
    create_export_directory
    export_images
    export_configs
    export_volumes
    create_restore_script
    create_manifest
    create_archive
}

# 运行主函数
main "$@" 