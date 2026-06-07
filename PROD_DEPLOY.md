# 生产发布说明

## 一、部署结构

生产部署目录：`/opt/bidding-system`

服务组成：
- `mysql`：MySQL 8，Docker Compose 内置。
- `redis`：Redis 7，Docker Compose 内置。
- `backend`：Java 17 JRE 运行 `release/backend/app.jar`。
- `nginx`：托管 `release/frontend/dist`，代理 `/api/` 和 `/files/` 到后端。

后端端口 `8889` 只在 Docker 网络内使用，对外只暴露 Nginx `80`。

## 二、首次部署

在本地或 CI 生成发布产物：

```bash
bash scripts/package-prod.sh
```

首次生产初始化需要先导出全量结构和数据，打成和参考项目一致的初始化压缩包：

```bash
SOURCE_DB_HOST=127.0.0.1 \
SOURCE_DB_PORT=13306 \
SOURCE_DB_NAME=bia \
SOURCE_DB_USER=root \
SOURCE_DB_PASSWORD=<源库密码> \
bash scripts/package-init.sh
```

默认输出完整初始化包：

```text
dist/INIT.bidding-system.zip
```

初始化包内包含：

```text
.env.example
docker-compose.yml
deploy.sh
PROD_DEPLOY.md
nginx/
scripts/
release/backend/app.jar
release/frontend/dist/
sql/INIT.sql.zip
```

其中 `sql/INIT.sql.zip` 内部固定文件名：

```text
init.sql
```

只单独生成数据库初始化压缩包时，也可以执行：

```bash
bash scripts/db-export-initial.sh
```

如源库地址不同，可以这样指定：

```bash
SOURCE_DB_HOST=127.0.0.1 \
SOURCE_DB_PORT=13306 \
SOURCE_DB_NAME=bia \
SOURCE_DB_USER=root \
SOURCE_DB_PASSWORD=<源库密码> \
bash scripts/db-export-initial.sh
```

提交发布脚本和 release 产物后，在生产服务器执行：

```bash
cd /opt
git clone <你的仓库地址> bidding-system
cd /opt/bidding-system
cp .env.example .env
```

编辑 `.env`，替换所有 `CHANGE_ME` 占位值。生产 `.env` 不要提交到 Git。

生成 JWT 密钥：

```bash
openssl rand -hex 32
```

`BIA_JWT_SECRET` 和 `BIA_MAIL_CONFIG_SECRET` 建议分别生成，不要共用同一个值。`BIA_MAIL_CONFIG_SECRET` 用于加密后台邮件配置中的敏感字段。

如果服务器未安装 Docker，可以执行：

```bash
sudo bash deploy.sh
```

阿里云 Ubuntu 22 服务器如果访问 Docker 官方源较慢，可以指定 Docker apt 镜像源：

```bash
DOCKER_APT_MIRROR=https://mirrors.aliyun.com/docker-ce/linux/ubuntu sudo -E bash deploy.sh
```

如果 Docker 已安装，可以直接执行：

```bash
bash scripts/prod-deploy.sh
```

如果是第一次初始化生产库，把 `dist/INIT.bidding-system.zip` 上传到生产服务器，然后：

```bash
mkdir -p /opt/bidding-system
unzip INIT.bidding-system.zip -d /opt/bidding-system
cd /opt/bidding-system
cp .env.example .env
vi .env
bash scripts/prod-deploy.sh
```

发布脚本会自动：

```text
1. 展开 sql/INIT.sql.zip 到 data/sql/init.sql
2. 启动 MySQL
3. MySQL 首次发现 data/mysql 为空时，自动执行 /docker-entrypoint-initdb.d/init.sql
4. 启动 Redis、后端、Nginx
```

如果 `data/sql/init.sql` 已存在，脚本默认不覆盖。确实要覆盖时执行：

```bash
bash scripts/prod-deploy.sh yes
```

注意：MySQL 官方镜像只会在 `/opt/bidding-system/data/mysql` 为空的首次启动时执行 `data/sql/init.sql`。如果 `data/mysql` 已经有数据，脚本即使重新展开 `init.sql`，也不会自动导入到已有数据库。

## 三、日常发布

本地或 CI：

```bash
bash scripts/package-prod.sh
git status --short .env.example docker-compose.yml nginx scripts release PROD_DEPLOY.md
git add .env.example docker-compose.yml nginx scripts release PROD_DEPLOY.md deploy.sh .gitignore openspec/changes/add-prod-deploy-scripts
git commit -m "chore: add production deploy scripts"
git push
```

生产服务器：

```bash
cd /opt/bidding-system
bash scripts/prod-deploy.sh
```

发布前如果 MySQL 容器正在运行，脚本会先导出逻辑备份。备份失败时默认中止发布，避免没有数据库备份还继续上线。确认本次可以跳过数据库备份时，才使用：

```bash
SKIP_DB_BACKUP=1 bash scripts/prod-deploy.sh
```

生产服务器不会执行 Maven 或 npm build，只部署 `release` 产物。

日常发布不再导入全量数据，只提交新的 Flyway DDL migration，例如：

```text
api/src/main/resources/db/migration/V26__xxx.sql
```

后端启动时会自动执行尚未执行过的 migration。

## 四、关键配置

`.env` 必须配置：

```dotenv
APP_NAME=bidding-system
DEPLOY_DIR=/opt/bidding-system
COMPOSE_PROJECT_NAME=bidding-system
NGINX_HTTP_PORT=80

MYSQL_DB=bia
MYSQL_USER=bia
MYSQL_PASSWORD=<生产 MySQL 用户密码>
MYSQL_ROOT_PASSWORD=<生产 MySQL root 密码>

REDIS_PASSWORD=<生产 Redis 密码>

BIA_API_PORT=8889
BIA_DB_USERNAME=bia
BIA_DB_PASSWORD=<生产 MySQL 用户密码>
BIA_REDIS_DATABASE=1
BIA_UPLOAD_ROOT=/app/files
BIA_JWT_SECRET=<openssl rand -hex 32 生成的值>
BIA_MAIL_CONFIG_SECRET=<openssl rand -hex 32 生成的值>
BIA_AUTH_SMS_TEST_BYPASS_ENABLED=false
```

后续有域名后，将 [nginx/default.conf](/Users/liuweiliang/Workspace/02study/all/zcc-bidding-system/nginx/default.conf) 中的 `server_name _;` 改为正式域名，并按服务器证书方案补充 HTTPS。

## 五、验证命令

```bash
cd /opt/bidding-system
docker compose --env-file .env ps
curl -I http://127.0.0.1/
curl -i http://127.0.0.1/api/admin/v1/auth/captcha
docker compose --env-file .env logs --tail=200 backend
docker compose --env-file .env logs --tail=200 nginx
```

浏览器访问：

```text
http://服务器IP/
```

## 六、数据和附件

MySQL 与 Redis 使用宿主机目录持久化：
- MySQL 物理数据目录：`/opt/bidding-system/data/mysql`
- Redis 物理数据目录：`/opt/bidding-system/data/redis`

数据库表结构来源：
- 源码目录：`api/src/main/resources/db/migration/V*.sql`
- 发布后位置：`release/backend/app.jar` 内的 `BOOT-INF/classes/db/migration/V*.sql`
- 执行方式：后端启动时由 Flyway 自动执行，配置位于 `application.yaml` 的 `spring.flyway.locations=classpath:db/migration`

注意：当前发布方案没有单独的 `init.sql` 文件。表结构和必要种子数据分散在 Flyway migration 文件里，文件名类似：

```text
V1__init_bia_admin_rbac.sql
V25__add_supplier_bid_attachment.sql
```

每次生产发布前，如果 MySQL 容器正在运行，脚本会导出一份逻辑备份，包含结构和数据：

```text
/opt/bidding-system/backup/yyyyMMddHHmmss/database/bidding-system_mysql_yyyyMMddHHmmss.sql.gz
```

上传附件持久化在：

```text
/opt/bidding-system/data/files
```

容器内对应：

```text
/app/files
```

## 七、回滚

每次执行 `scripts/prod-deploy.sh` 前会备份当前运行文件：

```text
/opt/bidding-system/backup/yyyyMMddHHmmss
```

其中数据库逻辑备份文件在：

```text
/opt/bidding-system/backup/yyyyMMddHHmmss/database/bidding-system_mysql_yyyyMMddHHmmss.sql.gz
```

回滚示例：

```bash
cd /opt/bidding-system
cp backup/<备份时间>/app.jar release/backend/app.jar
rm -rf release/frontend/dist
mkdir -p release/frontend
tar -xzf backup/<备份时间>/frontend-dist.tar.gz -C release/frontend
cp backup/<备份时间>/docker-compose.yml docker-compose.yml
cp backup/<备份时间>/default.conf nginx/default.conf
docker compose --env-file .env up -d backend nginx
docker compose --env-file .env restart backend nginx
```

数据库迁移由 Flyway 管理。若新版本已经执行了不可逆数据库迁移，回滚代码前必须单独评估数据库回滚方案。

## 八、注意事项

- `.env` 不允许提交到 Git。
- `sql/INIT.sql.zip`、`init.sql.zip` 和 `*.sql.zip` 默认被 `.gitignore` 忽略；如果初始化包包含真实客户数据，不要提交到 GitHub，建议通过服务器安全通道单独上传。
- 生产必须保持 `BIA_AUTH_SMS_TEST_BYPASS_ENABLED=false`。
- 发布脚本不会覆盖 MySQL 数据卷、Redis 数据卷和附件目录。
- 如果换成外部 MySQL 或 Redis，需要同步调整 `docker-compose.yml` 和 `.env`，不要直接连错生产库。
