# Docker 容器迁移工具概览

## 工具功能
这是一套完整的 Docker 容器迁移解决方案，帮助您将 Docker 服务从一台服务器安全迁移到另一台服务器。

## 文件结构
```
Docker迁移工具/
├── docker_export.sh      # 主导出脚本 - 扫描、选择、打包容器
├── quick_start.sh         # 快速开始脚本 - 智能引导工具
├── README.md             # 详细使用说明
└── OVERVIEW.md           # 此概览文件
```

## 快速开始

### 使用快速开始脚本（推荐）
```bash
# 设置执行权限
chmod +x quick_start.sh docker_export.sh

# 运行快速开始脚本
./quick_start.sh
```

### 直接使用导出脚本
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
- 智能扫描所有Docker容器
- 彩色状态显示
- 选择性导出
- 完整备份（镜像+配置+数据）
- 一键恢复
- 友好界面

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