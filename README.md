# 系统管理工具集 (System Management Tools)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell Script](https://img.shields.io/badge/script-shell-green.svg)](https://en.wikipedia.org/wiki/Shell_script)
[![Platform](https://img.shields.io/badge/platform-Linux-blue.svg)](https://www.linux.org/)

这是一套完整的 Linux 系统管理工具集，集成了 **Docker 容器迁移**、系统维护、监控诊断等多个功能模块。核心功能是帮助您安全、高效地将 Docker 服务从一台服务器迁移到另一台服务器。

## ✨ 核心特性

### 🐳 Docker管理功能
- 🔍 **智能扫描**: 自动识别所有 Docker 容器（运行中/已停止）
- 📋 **状态显示**: 彩色显示容器状态、镜像、端口映射等详细信息
- 🎯 **选择性迁移**: 支持选择特定容器或全部迁移
- 📦 **完整备份**: 导出镜像、配置、卷数据等完整信息
- 🚀 **一键恢复**: 在目标服务器上一键恢复选定的容器
- 🔧 **容器管理**: 启动/停止/删除容器，查看日志
- 🖼️ **镜像管理**: 查看/搜索/拉取/删除镜像
- 🧹 **系统清理**: 清理Docker资源，释放磁盘空间

### 🎯 统一管理界面
- 🖥️ **主菜单系统**: 集成多个系统管理工具的统一入口
- 📊 **实时系统信息**: 显示内存、磁盘、Docker状态等信息
- 🎨 **友好界面**: 彩色输出，操作简单直观
- 🔒 **安全确认**: 危险操作需要用户确认

### 🔧 系统维护工具
- 📦 **系统更新**: 完整的系统包更新流程
- 💾 **磁盘清理**: 清理系统垃圾文件（开发中）
- ⚙️ **服务管理**: 系统服务管理（开发中）
- 👥 **用户管理**: 用户账户管理（开发中）

### 📊 监控诊断功能
- 📈 **实时监控**: htop/top系统性能监控
- 🌐 **网络诊断**: 网络接口、路由、DNS、连通性测试
- 🔍 **端口扫描**: 本地和远程端口检测（开发中）
- 📝 **日志查看**: 系统日志分析（开发中）

## 📁 项目结构

```
系统管理工具集/
├── main_menu.sh          # 🎯 主菜单脚本 - 统一管理入口（推荐）
├── docker_export.sh      # 🐳 Docker导出脚本 - 迁移功能核心
├── quick_start.sh         # 🚀 Docker迁移专用快速开始脚本
├── README.md             # 📖 项目说明文档（本文件）
└── MAIN_MENU_GUIDE.md    # 📚 主菜单详细使用指南
```

## 🚀 快速开始

### 方法一：使用主菜单脚本（强烈推荐）

```bash
# 1. 克隆项目
git clone <your-repo-url>
cd system-management-tools

# 2. 设置执行权限
chmod +x main_menu.sh docker_export.sh quick_start.sh

# 3. 启动主菜单
./main_menu.sh
```

### 方法二：直接使用Docker迁移功能

```bash
# 1. 使用Docker迁移专用脚本
./quick_start.sh

# 2. 或直接运行导出脚本
./docker_export.sh
```

## 🔄 Docker容器迁移完整流程

### 第一步：在源服务器上导出容器

1. **启动导出工具**
   ```bash
   ./main_menu.sh  # 选择 "1. Docker 容器迁移工具"
   # 或直接运行
   ./docker_export.sh
   ```

2. **选择容器**
   - 脚本会自动扫描并显示所有容器
   - 您可以选择特定容器或全部导出
   - 支持多选（如：`1 3 5`）或全选（`all`）

3. **导出示例**
   ```
   序号 容器ID       容器名称              镜像                    状态         端口映射
   ────────────────────────────────────────────────────────────────────────────
   1    abc123456789 nginx-web            nginx:latest           Up 2 hours   80:8080/tcp
   2    def987654321 mysql-db             mysql:8.0              Up 1 day     3306:3306/tcp
   3    ghi456789123 redis-cache          redis:alpine           Exited       6379:6379/tcp
   
   请选择要打包的容器（多个用空格分隔，如: 1 3 5）：
   输入 'all' 选择所有容器，输入 'q' 退出
   请输入选择: 1 2
   ```

4. **生成迁移包**
   - 导出完成后会生成压缩包（如：`docker_migration_20240714_120000.tar.gz`）
   - 包含镜像、配置、卷数据和自动导入脚本

### 第二步：传输到目标服务器

```bash
# 使用 scp 传输
scp docker_migration_*.tar.gz user@target-server:/path/to/destination/

# 或使用其他方式传输文件
```

### 第三步：在目标服务器上导入容器

1. **解压迁移包**
   ```bash
   tar -xzf docker_migration_*.tar.gz
   cd docker_export_*/
   ```

2. **安装依赖**
   ```bash
   # Ubuntu/Debian
   sudo apt-get update && sudo apt-get install jq
   
   # CentOS/RHEL
   sudo yum install jq
   ```

3. **运行导入脚本**
   ```bash
   ./docker_import.sh
   ```

4. **选择要恢复的容器**
   ```
   序号 容器名称              镜像                    原始状态
   ──────────────────────────────────────────────────────────
   1    nginx-web            nginx:latest           running
   2    mysql-db             mysql:8.0              running
   
   请选择要恢复的容器（多个用空格分隔，如: 1 3 5）：
   输入 'all' 恢复所有容器，输入 'q' 退出
   请输入选择: all
   ```

## 📦 导出包结构

每个迁移包包含以下内容：

```
docker_export_20240714_120000/
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
├── docker_import.sh        # 自动生成的导入脚本
└── MANIFEST.txt           # 导出清单和说明
```

## 💻 主菜单界面预览

```
╔══════════════════════════════════════════════════════════════╗
║                     系统管理工具集                           ║
║                  System Management Tools                    ║
╠══════════════════════════════════════════════════════════════╣
║  🐳 Docker 容器迁移                                          ║
║  🔧 系统维护工具                                             ║
║  📊 系统监控                                                 ║
║  🛠️ 网络工具                                               ║
╚══════════════════════════════════════════════════════════════╝

系统信息
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
操作系统: Ubuntu 20.04.6 LTS
内核版本: 5.4.0-192-generic
主机名: ubuntu-server
当前用户: user
当前时间: 2024-07-14 12:00:00
内存使用: 2.1G/8.0G
磁盘使用: 45G/100G (45%)
Docker状态: 运行中 (容器: 3, 镜像: 15)

主菜单
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🐳 Docker 管理
  1. Docker 容器迁移工具    # 完整的容器迁移解决方案
  2. Docker 容器管理        # 启动/停止/删除容器
  3. Docker 镜像管理        # 查看/搜索/拉取/删除镜像
  4. Docker 系统清理        # 清理Docker资源

🔧 系统维护
  5. 系统更新              # 更新系统软件包
  6. 磁盘清理              # 清理系统垃圾文件
  7. 服务管理              # 管理系统服务
  8. 用户管理              # 用户账户管理

📊 系统监控
  9. 实时系统监控          # htop/top性能监控
 10. 进程管理              # 进程查看和管理
 11. 网络连接              # 网络连接状态
 12. 日志查看              # 系统日志分析

🛠️ 网络工具
 13. 端口扫描              # 本地/远程端口检测
 14. 网络诊断              # 网络接口/路由/DNS测试
 15. 防火墙管理            # 防火墙状态和规则管理

⚙️ 工具设置
 16. 工具配置              # 个性化设置
 17. 关于信息              # 版本信息和帮助

其他选项
 0. 退出程序
```

## 🔧 系统要求

### 源服务器（导出端）
- **操作系统**: Ubuntu 20.04+ / Debian 10+ / CentOS 8+ / 其他 Linux 发行版
- **Docker**: 已安装并运行
- **Shell**: bash 4.0+
- **权限**: 用户需在 docker 组中

### 目标服务器（导入端）
- **操作系统**: Ubuntu 20.04+ / Debian 10+ / CentOS 8+ / 其他 Linux 发行版
- **Docker**: 已安装并运行
- **工具**: jq（用于解析 JSON 配置）
- **Shell**: bash 4.0+
- **权限**: 用户需在 docker 组中

### 安装 Docker

```bash
# 使用官方安装脚本
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 将用户添加到 docker 组
sudo usermod -aG docker $USER

# 重新登录或运行
newgrp docker
```

### 安装 jq 工具

```bash
# Ubuntu/Debian
sudo apt-get update && sudo apt-get install jq

# CentOS/RHEL 7
sudo yum install jq

# CentOS/RHEL 8+
sudo dnf install jq

# Alpine Linux
sudo apk add jq
```

## ⚠️ 注意事项

### 导出时注意
- 🔹 导出过程可能需要较长时间，取决于镜像大小和数据量
- 🔹 确保有足够的磁盘空间存储导出文件
- 🔹 建议在系统负载较低时执行导出操作
- 🔹 大型数据库建议先停止服务再导出以确保数据一致性

### 导入时注意
- 🔹 确保目标服务器的端口没有冲突
- 🔹 某些容器可能需要手动调整网络配置
- 🔹 数据库容器恢复后请检查数据完整性
- 🔹 如果容器名称冲突，需要先删除或重命名现有容器

### 数据安全
- 🔸 导出的压缩包可能包含敏感数据，请妥善保管
- 🔸 建议在传输过程中使用加密连接（如 SSH/SCP）
- 🔸 导入完成后，请及时删除不需要的备份文件
- 🔸 重要生产环境建议先在测试环境验证迁移流程

## 🛠️ 故障排除

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
   ```bash
   # 清理不需要的 Docker 镜像和容器
   docker system prune -a
   
   # 查看磁盘使用情况
   df -h
   du -sh /var/lib/docker
   ```

5. **端口冲突**
   ```bash
   # 检查端口占用情况
   ss -tlnp | grep :端口号
   netstat -tlnp | grep :端口号
   ```

6. **容器启动失败**
   ```bash
   # 查看容器日志
   docker logs 容器名称
   
   # 检查容器配置
   docker inspect 容器名称
   ```

## 🎯 高级用法

### 批量操作

如果您需要自动化批量操作，可以修改脚本以支持非交互模式：

```bash
# 示例：自动导出所有容器
echo "all" | ./docker_export.sh

# 示例：自动导入所有容器
echo "all" | ./docker_import.sh
```

### 定期备份

您可以设置 cron 任务来定期备份 Docker 容器：

```bash
# 编辑 crontab
crontab -e

# 添加定时任务（每周日凌晨2点执行备份）
0 2 * * 0 /path/to/docker_export.sh > /var/log/docker_backup.log 2>&1
```

### 网络存储

对于大型环境，可以直接将备份存储到网络位置：

```bash
# 挂载网络存储
sudo mount -t nfs server:/backup /mnt/backup

# 修改脚本中的导出路径指向网络存储
```

## 🤝 贡献

欢迎贡献代码和提出建议！

### 贡献方式
1. Fork 本项目
2. 创建您的功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交您的更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开一个 Pull Request

### 功能建议
- 备份恢复工具
- 数据库管理模块
- Web 服务管理
- 安全检查工具
- 性能优化工具

## 📄 许可证

本项目采用 MIT 许可证。

## 🆘 技术支持

如果您在使用过程中遇到问题，请：

1. 查看本文档的故障排除部分
2. 检查 [MAIN_MENU_GUIDE.md](MAIN_MENU_GUIDE.md) 获取详细使用说明
3. 在 GitHub Issues 中提交问题
4. 确保提供详细的错误信息和系统环境

### 环境检查清单
- [ ] Docker 服务是否正常运行
- [ ] 用户是否在 docker 组中
- [ ] 是否有足够的磁盘空间
- [ ] 网络连接是否正常
- [ ] jq 工具是否已安装（导入时）

## 🌟 Star History

如果这个工具对您有帮助，请给项目点个 ⭐️ 支持一下！

---

**开始您的高效系统管理之旅！** 🚀 