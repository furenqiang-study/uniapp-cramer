# CoolCap 上线说明

## 产物

| 文件 | 说明 |
|------|------|
| `coolcap-h5-dist.zip` | H5 生产包（`uniapp-web/dist/build/h5`） |
| `deploy/nginx-coolcap.conf` | Nginx 参考配置 |
| `uniapp-server/` | FastAPI 后端源码 |

## 前端部署

1. 解压 `coolcap-h5-dist.zip` 到服务器，例如 `/var/www/coolcap/dist/`
2. 按 `deploy/nginx-coolcap.conf` 配置反代（注意 `base` 为 `/coolcap/`）
3. 访问：`http://域名/coolcap/`

## 后端部署

```bash
cd uniapp-server
# 使用你的 Python
D:\python\Python\Python310\python.exe -m pip install -r requirements.txt
D:\python\Python\Python310\python.exe -m uvicorn main:app --host 0.0.0.0 --port 8022
```

或 Docker：

```bash
cd uniapp-server
docker compose up -d --build
```

## 数据库

- 库：`study_uniapp`（现有库）
- 新表前缀：`YL_`（启动时 `create_all` 会自动建表，也可执行）
- `uniapp-server/scripts/init_yl_tables.py`
- SQL 对照：`uniapp-server/sql/YL_coolcap_tables.sql`

## 上线前检查

1. 后端可访问：`GET /api/health` → `{"code":200,...}`
2. 前端登录后能打开治疗页（mock 或真实账号）
3. 结束治疗后档案页能看到「已入库」记录
4. 生产环境建议：修改 `config.py` 中 `SECRET_KEY`；关闭或限制 `/docs`
