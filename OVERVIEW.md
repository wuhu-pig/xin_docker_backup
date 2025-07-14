# Docker 容器迁移工具概览

## 工具功能
这是一套完整的 Docker 容器迁移解决方案，帮助您将 Docker 服务从一台服务器安全迁移到另一台服务器。

## 文件结构
```
系统管理工具集/
├── main_menu.sh          # 🎯 主菜单脚本 - 统一入口（推荐）
├── docker_export.sh      # 🐳 Docker导出脚本 - 扫描、选择、打包容器
├── quick_start.sh         # 🚀 快速开始脚本 - Docker迁移专用引导
├── README.md             # 📖 详细使用说明
└── OVERVIEW.md           # 📋 此概览文件
```

## 快速开始

### 方法一：使用主菜单脚本（强烈推荐）
```bash
# 设置执行权限
chmod +x main_menu.sh docker_export.sh quick_start.sh

# 运行主菜单脚本 - 统一管理界面
./main_menu.sh
```

### 方法二：使用Docker迁移专用脚本
```bash
# 设置执行权限
chmod +x quick_start.sh docker_export.sh

# 运行Docker迁移快速开始脚本
./quick_start.sh
```

### 方法三：直接使用导出脚本
```bash
# 设置执行权限
chmod +x docker_export.sh

# 运行导出脚本
./docker_export.sh
```

## 完整迁移流程

### 在源服务器上（Ubuntu 20.04）
1. 运行导出工具: `./docker_export.sh`
2. 选择要迁移的容器
3. 等待打包完成，获得压缩包

### 传输到目标服务器
```bash
scp docker_migration_*.tar.gz user@target-server:/path/to/destination/
```

### 在目标服务器上
1. 解压迁移包: `tar -xzf docker_migration_*.tar.gz`
2. 进入目录: `cd docker_export_*/`
3. 安装jq: `sudo apt-get install jq`
4. 运行导入: `./docker_import.sh`
5. 选择要恢复的容器

## 工具特色

### 🎯 统一管理界面
- 集成多个系统管理工具的统一入口
- 实时显示系统信息（内存、磁盘、Docker状态等）
- 模块化设计，易于扩展新功能

### 🐳 Docker管理功能
- 智能扫描所有Docker容器（运行中/已停止）
- 彩色状态显示
- 选择性导出和迁移
- 完整备份（镜像+配置+数据）
- 一键恢复
- 容器/镜像管理
- 系统清理

### 🔧 系统维护工具
- 系统更新
- 磁盘清理（开发中）
- 服务管理（开发中）
- 用户管理（开发中）

### 📊 监控诊断功能
- 实时系统监控（htop/top）
- 网络诊断工具
- 进程管理（开发中）
- 日志查看（开发中）

### 🛠️ 网络工具
- 端口扫描（开发中）
- 网络诊断
- 防火墙管理（开发中）

### ✨ 用户体验
- 友好的彩色界面
- 完善的错误处理
- 操作确认机制
- 详细的状态反馈

## 系统要求
- Ubuntu 20.04 或其他 Linux 发行版
- Docker 已安装并运行
- jq 工具（导入时需要）
- 用户在 docker 组中
- 足够的磁盘空间

## 注意事项
- 导出时间取决于镜像大小和数据量
- 确保目标服务器端口不冲突
- 数据库容器恢复后请检查数据完整性
- 敏感数据请妥善保管传输