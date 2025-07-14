# Docker 容器迁移工具

这是一个用于 Docker 容器迁移的完整解决方案，可以帮助您将 Docker 容器从一台服务器迁移到另一台服务器。

## 功能特性

- 🔍 **智能扫描**: 自动扫描系统中所有 Docker 容器（包括运行中和已停止的）
- 📋 **状态显示**: 详细显示每个容器的状态、镜像、端口映射等信息
- 🎯 **选择性导出**: 支持选择特定容器或导出所有容器
- 📦 **完整备份**: 导出镜像、配置、卷数据等完整信息
- 🚀 **一键恢复**: 在目标服务器上一键恢复选定的容器
- 🎨 **友好界面**: 彩色输出，操作简单直观

## 系统要求

### 源服务器（导出端）
- Ubuntu 20.04 或其他 Linux 发行版
- Docker 已安装并运行
- bash shell

### 目标服务器（导入端）
- Ubuntu 20.04 或其他 Linux 发行版
- Docker 已安装并运行
- jq 工具（用于解析 JSON 配置）
- bash shell

## 安装 jq 工具

```bash
# Ubuntu/Debian
sudo apt-get update && sudo apt-get install jq

# CentOS/RHEL
sudo yum install jq

# 或者使用 dnf
sudo dnf install jq
```

## 使用方法

### 第一步：在源服务器上导出容器

1. 下载导出脚本到您的 Ubuntu 服务器：
```bash
# 给脚本执行权限
chmod +x docker_export.sh
```

2. 运行导出脚本：
```bash
./docker_export.sh
```

3. 脚本会自动：
   - 扫描系统中的所有 Docker 容器
   - 显示容器列表及其状态
   - 让您选择要导出的容器
   - 导出选定容器的镜像、配置和数据
   - 创建压缩包

4. 选择容器示例：
```
序号 容器ID       容器名称              镜像                          状态            端口映射
────────────────────────────────────────────────────────────────────────────────────────────────
1    abc123456789 nginx-web            nginx:latest                 Up 2 hours      80:8080/tcp
2    def987654321 mysql-db             mysql:8.0                    Up 1 day        3306:3306/tcp
3    ghi456789123 redis-cache          redis:alpine                 Exited          6379:6379/tcp

请选择要打包的容器（多个容器用空格分隔，如: 1 3 5）：
输入 'all' 选择所有容器，输入 'q' 退出
请输入选择: 1 2
```

5. 导出完成后，会生成类似 `docker_migration_20240101_120000.tar.gz` 的压缩包

### 第二步：在目标服务器上导入容器

1. 将压缩包传输到目标服务器：
```bash
# 使用 scp
scp docker_migration_*.tar.gz user@target-server:/path/to/destination/

# 或者使用其他方式传输文件
```

2. 在目标服务器上解压：
```bash
tar -xzf docker_migration_*.tar.gz
cd docker_export_*/
```

3. 运行导入脚本：
```bash
./docker_import.sh
```

4. 脚本会：
   - 自动导入所有镜像
   - 显示可恢复的容器列表
   - 让您选择要恢复的容器
   - 恢复容器数据和配置
   - 启动选定的容器

5. 选择恢复示例：
```
序号 容器名称              镜像                          原始状态
───────────────────────────────────────────────────────────────────────
1    nginx-web            nginx:latest                 running
2    mysql-db             mysql:8.0                    running
3    redis-cache          redis:alpine                 exited

请选择要恢复的容器（多个用空格分隔，如: 1 3 5）：
输入 'all' 恢复所有容器，输入 'q' 退出
请输入选择: all
```

## 导出包结构

每个导出包包含以下文件和目录：

```
docker_export_20240101_120000/
├── images/                 # Docker 镜像文件
│   ├── nginx_latest.tar
│   ├── mysql_8.0.tar
│   └── redis_alpine.tar
├── configs/                # 容器配置文件
│   └── containers.json
├── volumes/                # 卷数据备份
│   ├── nginx-web/
│   ├── mysql-db/
│   └── redis-cache/
├── docker_import.sh        # 导入脚本
└── MANIFEST.txt           # 导出清单
```

## 注意事项

### 导出时注意
- 🔹 导出过程可能需要较长时间，取决于镜像大小和数据量
- 🔹 确保有足够的磁盘空间存储导出文件
- 🔹 建议在系统负载较低时执行导出操作

### 导入时注意
- 🔹 确保目标服务器的端口没有冲突
- 🔹 某些容器可能需要手动调整网络配置
- 🔹 数据库容器恢复后请检查数据完整性
- 🔹 如果容器名称冲突，需要先删除或重命名现有容器

### 数据安全
- 🔸 导出的压缩包可能包含敏感数据，请妥善保管
- 🔸 建议在传输过程中使用加密连接
- 🔸 导入完成后，请及时删除不需要的备份文件

## 故障排除

### 常见问题

1. **Docker 服务未运行**
```bash
sudo systemctl start docker
sudo systemctl enable docker
```

2. **权限不足**
```bash
sudo usermod -aG docker $USER
# 然后重新登录或运行
newgrp docker
```

3. **jq 未安装**
```bash
sudo apt-get install jq  # Ubuntu/Debian
sudo yum install jq      # CentOS/RHEL
```

4. **磁盘空间不足**
- 清理不需要的 Docker 镜像和容器
- 使用 `docker system prune` 清理

5. **端口冲突**
- 检查目标服务器的端口占用情况
- 修改容器的端口映射

## 高级用法

### 只导出特定类型的容器

如果您只想导出特定类型的容器，可以在脚本运行时选择相应的序号。

### 批量操作

您可以将脚本集成到自动化部署流程中：

```bash
# 导出所有容器（非交互模式需要修改脚本）
echo "all" | ./docker_export.sh

# 导入所有容器
echo "all" | ./docker_import.sh
```

### 定期备份

您可以设置定时任务来定期备份容器：

```bash
# 添加到 crontab
0 2 * * 0 /path/to/docker_export.sh
```

## 技术细节

- 使用 `docker save` 导出镜像
- 使用 `docker inspect` 获取容器配置
- 使用 `tar` 备份卷数据
- 使用 `jq` 解析 JSON 配置
- 支持 bind 挂载和命名卷的备份恢复

## 版本历史

- v1.0: 初始版本，支持基本的容器导出导入功能

## 许可证

本工具遵循 MIT 许可证。

## 支持

如果您在使用过程中遇到问题，请检查：
1. Docker 服务是否正常运行
2. 是否有足够的磁盘空间
3. 网络连接是否正常
4. 权限设置是否正确

---

**祝您迁移愉快！** 🚀 