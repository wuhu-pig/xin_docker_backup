# 系统管理工具集 (System Management Tools)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell Script](https://img.shields.io/badge/script-shell-green.svg)](https://en.wikipedia.org/wiki/Shell_script)
[![Platform](https://img.shields.io/badge/platform-Linux-blue.svg)](https://www.linux.org/)

这是一套完整的 Linux 系统管理工具集，集成了 **Docker 容器迁移**、**定时备份系统**、系统维护、监控诊断等多个功能模块。提供统一的管理界面，让您轻松管理各种系统任务。

## ✨ 核心特性

### 🐳 Docker容器迁移
- 🔍 **智能扫描**: 自动识别所有 Docker 容器（运行中/已停止）
- 📦 **完整备份**: 导出镜像、配置、卷数据等完整信息
- 🚀 **一键恢复**: 在目标服务器上一键恢复选定的容器
- 🎯 **选择性迁移**: 支持选择特定容器或全部迁移

### 📅 定时备份系统
- 🔄 **自动化备份**: 主机从机配置，自动定时备份
- ⏰ **灵活调度**: 支持每小时/每天/每周/自定义cron表达式
- 📧 **邮件通知**: 支持QQ/163/Gmail等主流邮箱SMTP通知
- 🛠️ **服务管理**: 完整的后台服务启停控制
- 👥 **用户管理**: 自动创建备份专用用户，SSH密钥认证
- 🔄 **断点续传**: 支持网络中断后继续传输
- 📊 **日志记录**: 完整的系统和任务级日志

### 🎯 统一管理界面
- 🖥️ **主菜单系统**: 集成所有功能的统一入口
- 📊 **实时系统信息**: 显示内存、磁盘、Docker状态等信息
- 🎨 **友好界面**: 彩色输出，操作简单直观
- 🔒 **安全确认**: 危险操作需要用户确认

### 🔧 系统维护工具
- 📦 **系统更新**: 完整的系统包更新流程
- 💾 **磁盘清理**: 清理系统垃圾文件
- ⚙️ **服务管理**: 系统服务管理
- 👥 **用户管理**: 用户账户管理

### 📊 监控诊断功能
- 📈 **实时监控**: htop/top系统性能监控
- 🌐 **网络诊断**: 网络接口、路由、DNS、连通性测试
- 🔍 **端口扫描**: 本地和远程端口检测
- 📝 **日志查看**: 系统日志分析

## 📁 项目结构

```
系统管理工具集/
├── main_menu.sh          # 🎯 主菜单脚本 - 统一管理入口（推荐）
├── docker_export.sh      # 🐳 Docker导出脚本 - 迁移功能核心
├── backup_manager.sh     # 📅 定时备份管理 - 备份系统核心
├── service_manager.sh    # 🛠️ 后台服务管理 - 服务控制
├── quick_start.sh         # 🚀 Docker迁移专用快速开始脚本
└── README.md             # 📖 项目说明文档（本文件）

运行时创建的目录:
├── backup_configs/        # 备份系统配置文件
│   ├── backup_config.conf # 主配置文件
│   ├── hosts.conf         # 主机配置信息
│   ├── backup_jobs.conf   # 备份任务配置
│   ├── email_config.conf  # 邮件配置（敏感信息）
│   ├── backup_rsa         # SSH私钥（自动生成）
│   ├── backup_rsa.pub     # SSH公钥（自动生成）
│   └── services/          # 服务脚本目录
├── backup_data/           # 本地备份存储
│   └── {任务名}/          # 按任务名分类存储
└── backup_logs/           # 日志文件目录
    ├── backup_system.log  # 系统级日志
    └── {任务}_{时间}.log   # 任务级日志
```

## 🚀 快速开始

### 安装和设置

```bash
# 1. 克隆项目
git clone https://github.com/yourusername/system-management-tools.git
cd system-management-tools

# 2. 设置执行权限
chmod +x main_menu.sh docker_export.sh backup_manager.sh service_manager.sh quick_start.sh

# 3. 启动主菜单
./main_menu.sh
```

### 主菜单界面

```
╔══════════════════════════════════════════════════════════════╗
║                     系统管理工具集                           ║
║                  System Management Tools                    ║
╠══════════════════════════════════════════════════════════════╣
║  🐳 Docker 容器迁移                                          ║
║  📅 定时备份系统                                             ║
║  🔧 系统维护工具                                             ║
║  📊 系统监控                                                 ║
║  🛠️ 网络工具                                               ║
╚══════════════════════════════════════════════════════════════╝

主菜单
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🐳 Docker 管理
  1. Docker 容器迁移工具    # 完整的容器迁移解决方案
  2. Docker 容器管理        # 启动/停止/删除容器
  3. Docker 镜像管理        # 查看/搜索/拉取/删除镜像
  4. Docker 系统清理        # 清理Docker资源

📅 备份管理
  5. 定时备份管理          # 创建和管理定时备份任务
  6. 后台服务管理          # 管理备份服务的启停

🔧 系统维护
  7. 系统更新              # 更新系统软件包
  8. 磁盘清理              # 清理系统垃圾文件
  9. 服务管理              # 管理系统服务
 10. 用户管理              # 用户账户管理

📊 系统监控
 11. 实时系统监控          # htop/top性能监控
 12. 进程管理              # 进程查看和管理
 13. 网络连接              # 网络连接状态
 14. 日志查看              # 系统日志分析

🛠️ 网络工具
 15. 端口扫描              # 本地/远程端口检测
 16. 网络诊断              # 网络接口/路由/DNS测试
 17. 防火墙管理            # 防火墙状态和规则管理

⚙️ 工具设置
 18. 工具配置              # 个性化设置
 19. 关于信息              # 版本信息和帮助

其他选项
 0. 退出程序
```

## 🐳 Docker容器迁移完整流程

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

## 📅 定时备份系统使用指南

### 快速配置流程

#### 1. 配置主机信息
选择 **5. 定时备份管理** → **1. 配置主机信息**

```bash
# 添加从机（备份源）
主机名称: web-server-1
IP地址: 192.168.1.10
SSH端口: 22
用户名: root
角色: 从机

# 添加主机（备份目标）
主机名称: backup-server
IP地址: 192.168.1.100
SSH端口: 22
用户名: root
角色: 主机
```

#### 2. 配置邮件通知（可选）
选择 **5. 配置邮件通知**

```bash
# QQ邮箱配置示例
邮箱类型: 1 (QQ邮箱)
发送邮箱: your_email@qq.com
密码/授权码: abcd1234abcd1234  # QQ邮箱授权码
接收邮箱: admin@company.com
```

支持的邮箱类型：
- **QQ邮箱**: smtp.qq.com:587 (支持授权码)
- **163邮箱**: smtp.163.com:465 (支持授权码)
- **Gmail**: smtp.gmail.com:587 (支持应用专用密码)
- **自定义**: 手动输入SMTP服务器信息

#### 3. 创建备份任务
选择 **2. 创建备份任务**

```bash
1. 选择从机: web-server-1
2. 选择主机: backup-server
3. 备份路径: /var/www/html
4. 任务名称: website-backup

# 定时配置
备份频率选择:
1. 每小时备份     → 0 * * * *
2. 每天备份       → 0 2 * * *  (凌晨2点)
3. 每周备份       → 0 2 * * 0  (周日凌晨2点)
4. 自定义         → 0 */6 * * * (每6小时)

# 执行方式
1. 立即执行备份   → 马上开始备份
2. 设置为定时任务 → 根据计划自动执行
3. 仅保存配置     → 稍后手动启动
```

#### 4. 管理后台服务
选择 **6. 后台服务管理**

```bash
1. 查看所有服务状态    # 查看运行中的备份任务
2. 启动服务           # 启动指定的备份任务
3. 停止服务           # 停止运行中的任务
4. 重启服务           # 重新加载配置
5. 查看服务日志       # 查看执行日志和错误信息
6. 删除系统服务       # 完全删除服务和配置
```

### 高级功能特性

#### 🔐 自动用户管理
- 系统会在主机和从机上自动创建 `backup_user` 用户
- 自动生成SSH密钥对并配置免密登录
- 设置适当的目录权限和安全配置

#### 🔄 断点续传支持
- 使用 rsync 的断点续传功能 (`--partial --inplace`)
- 网络中断后可以继续传输，不会重新开始
- 支持大文件的可靠传输

#### 📧 智能邮件通知
- **成功通知**: 包含备份大小、时间、路径等详细信息
- **失败通知**: 附带错误日志文件
- **测试邮件**: 验证邮件配置是否正确

#### 📊 完善的日志系统
- **系统日志**: 记录所有操作和状态变化
- **任务日志**: 每个备份任务的详细执行记录
- **错误日志**: SystemD服务的错误输出
- **日志轮转**: 自动管理日志文件大小

#### 🛠️ 双重服务支持
- **SystemD服务**（推荐）: 更稳定，支持自动重启，系统级管理
- **Cron任务**: 轻量级，传统方式，用户级管理

### 使用场景示例

#### 场景1: 网站数据备份
```bash
从机: Web服务器 (192.168.1.10)
备份路径: /var/www/html
主机: 备份服务器 (192.168.1.100)
频率: 每天凌晨2点
任务名: website-daily-backup
通知: QQ邮箱通知管理员
```

#### 场景2: 数据库备份
```bash
从机: 数据库服务器 (192.168.1.20)
备份路径: /var/lib/mysql/backup
主机: 备份服务器 (192.168.1.100)
频率: 每6小时 (0 */6 * * *)
任务名: database-backup
通知: 163邮箱通知DBA团队
```

#### 场景3: 配置文件备份
```bash
从机: 生产服务器 (192.168.1.30)
备份路径: /etc
主机: 备份服务器 (192.168.1.100)
频率: 每周日凌晨 (0 2 * * 0)
任务名: config-weekly-backup
通知: Gmail通知运维团队
```

## 🔧 系统要求

### 通用要求
- **操作系统**: Ubuntu 20.04+ / Debian 10+ / CentOS 8+ / 其他 Linux 发行版
- **Shell**: bash 4.0+
- **权限**: 用户需在 docker 组中（Docker功能）或具有sudo权限（备份功能）

### Docker功能要求
- **Docker**: 已安装并运行
- **工具**: jq（用于解析 JSON 配置）

### 备份功能要求
- **SSH**: 支持密钥认证
- **rsync**: 支持断点续传
- **Python3**: 邮件通知功能
- **sudo**: 创建备份用户权限

### 依赖安装

#### Docker 安装
```bash
# 使用官方安装脚本
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 将用户添加到 docker 组
sudo usermod -aG docker $USER
newgrp docker
```

#### 基础工具安装
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install jq rsync openssh-client python3 python3-pip

# CentOS/RHEL
sudo yum install jq rsync openssh-clients python3 python3-pip
```

#### Python邮件依赖
```bash
pip3 install smtplib email
```

## 🛠️ 故障排除

### Docker相关问题

1. **Docker 服务未运行**
   ```bash
   sudo systemctl start docker
   sudo systemctl enable docker
   ```

2. **权限不足**
   ```bash
   sudo usermod -aG docker $USER
   newgrp docker
   ```

3. **jq 未安装**
   ```bash
   sudo apt-get install jq  # Ubuntu/Debian
   sudo yum install jq      # CentOS/RHEL
   ```

### 备份功能问题

1. **SSH连接失败**
   ```bash
   # 检查SSH连通性
   ssh -p 22 user@host "echo 'Connection successful'"
   
   # 检查SSH密钥
   ssh-add -l
   ```

2. **权限错误**
   ```bash
   # 检查备份用户
   id backup_user
   
   # 检查目录权限
   ls -la backup_data/
   ```

3. **邮件发送失败**
   ```bash
   # 测试SMTP连接
   telnet smtp.qq.com 587
   
   # 检查防火墙设置
   sudo ufw status
   ```

4. **服务启动失败**
   ```bash
   # 查看SystemD服务状态
   systemctl status backup-taskname.service
   
   # 查看服务日志
   journalctl -u backup-taskname.service -f
   
   # 查看Cron任务
   crontab -l | grep taskname
   ```

### 常用诊断命令

```bash
# 查看系统日志
tail -f backup_logs/backup_system.log

# 查看任务日志
tail -f backup_logs/taskname_*.log

# 检查磁盘空间
df -h

# 查看网络连接
ss -tlnp | grep :22

# 检查进程
ps aux | grep backup
```

## 📊 功能验证清单

### ✅ Docker迁移功能 (100% 完成)
- [x] 智能容器扫描和选择
- [x] 完整的镜像、配置、数据导出
- [x] 自动生成导入脚本
- [x] 一键恢复功能
- [x] 容器管理（启动/停止/删除）
- [x] 镜像管理（查看/搜索/拉取/删除）
- [x] 系统清理功能

### ✅ 定时备份功能 (100% 完成)
- [x] 主机从机配置管理
- [x] 备份任务创建和管理
- [x] 多种定时方式支持
- [x] 立即执行和后台运行
- [x] 自动用户创建和SSH配置
- [x] 断点续传支持
- [x] SMTP邮件通知（QQ/163/Gmail）
- [x] 完整的日志记录系统
- [x] SystemD和Cron双重服务支持
- [x] 后台服务管理界面

### ✅ 系统管理功能
- [x] 统一主菜单界面
- [x] 实时系统信息显示
- [x] 网络诊断工具
- [x] 系统监控功能
- [x] 用户友好的彩色界面

| 功能类别 | 已实现 | 总计 | 完成度 |
|---------|-------|------|--------|
| Docker迁移功能 | 7/7 | 7 | 100% |
| 定时备份功能 | 10/10 | 10 | 100% |
| 系统管理功能 | 5/5 | 5 | 100% |
| **总计** | **22/22** | **22** | **100%** |

## 🎯 高级用法

### 批量操作

```bash
# 非交互模式导出所有Docker容器
echo "all" | ./docker_export.sh

# 自动导入所有容器
echo "all" | ./docker_import.sh

# 手动执行备份任务
./backup_manager.sh --execute-job "taskname"
```

### 定期维护

```bash
# 设置定期Docker清理
echo "0 2 * * 0 /path/to/docker_export.sh --cleanup" | crontab -

# 查看所有备份任务状态
./service_manager.sh --status-all

# 批量重启所有备份服务
./service_manager.sh --restart-all
```

### 网络存储集成

```bash
# 挂载网络存储作为备份目标
sudo mount -t nfs backup-server:/storage /mnt/backup

# 配置备份到网络存储
# 在主机配置中设置IP为网络存储地址
```

## 🤝 贡献指南

欢迎贡献代码和提出建议！

### 贡献流程
1. Fork 本项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

### 开发建议
- 保持脚本的模块化设计
- 添加详细的日志记录
- 确保向后兼容性
- 提供充分的错误处理
- 更新相关文档

### 功能建议
- Web管理界面
- 数据库自动备份
- 监控告警系统
- 多云存储支持
- 加密备份功能

## 📄 许可证

本项目采用 MIT 许可证。详见 [LICENSE](LICENSE) 文件。

## 🆘 技术支持

### 获取帮助
1. 查看本文档的故障排除部分
2. 检查日志文件获取详细错误信息
3. 在 GitHub Issues 中提交问题
4. 确保提供详细的错误信息和系统环境

### 问题报告清单
在提交问题时，请提供：
- [ ] 操作系统版本和发行版
- [ ] 脚本版本和Git提交哈希
- [ ] 详细的错误信息和日志
- [ ] 重现问题的具体步骤
- [ ] 相关的配置文件内容

### 系统环境检查
```bash
# 系统信息
uname -a
lsb_release -a

# Docker状态（如适用）
docker --version
docker info

# 工具版本
jq --version
rsync --version
python3 --version

# 权限检查
groups
sudo -l
```

## 🌟 致谢

感谢所有贡献者和用户的支持！

如果这个工具对您有帮助，请：
- ⭐ 给项目点个星
- 🍴 Fork 项目进行定制
- 📢 推荐给更多人使用
- 🐛 报告问题和建议

---

**开始您的高效系统管理之旅！** 🚀

## 📞 联系方式

- **项目主页**: https://github.com/yourusername/system-management-tools
- **问题反馈**: https://github.com/yourusername/system-management-tools/issues
- **讨论社区**: https://github.com/yourusername/system-management-tools/discussions

---

*最后更新: 2024-07-16* 