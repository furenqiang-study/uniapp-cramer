# CoolCap 化疗头皮冷却冰帽系统（YL 分支）

> 基于 uni-app Vue3 + TypeScript（前端）+ FastAPI + MySQL（后端）  
> **YL 分支**：移动端冰帽治疗 APP + `YL_*` 医疗业务接口  
> **master 分支**：原企业后台管理系统（前端仍可对接本后端旧接口）

## 分支说明

| 分支 | 内容 |
|------|------|
| `master` | 原后台管理系统前端与文档（本 README/学习文档以 YL 为准，master 侧请以 master 文件为准） |
| `YL` | CoolCap 冰帽 APP 前端重塑；后端同时兼容旧接口与 CoolCap 新接口 |

两套前端可部署在同一后端 `uniapp-server` 上：

- master 前端 → `/api/auth`、`/api/ent/*`、`/api/gold/*`、`/api/laptops/*` 等旧接口  
- YL 前端 → `/api/auth` + `/api/coolcap/*`

## 项目结构（YL）

```
xiaomi-uniapp/
├── uniapp-web/                    # 前端（CoolCap APP）
│   ├── src/
│   │   ├── api/
│   │   │   ├── request.ts         # 请求封装（mock 会话不因后端 401 踢出）
│   │   │   ├── auth.ts            # 登录
│   │   │   └── coolcap.ts         # 冰帽业务接口
│   │   ├── pages/
│   │   │   ├── login/             # 登录
│   │   │   ├── home/              # 治疗首页（连接/开始/治疗历史）
│   │   │   ├── monitor/           # 实时监控（热力图/曲线/露点）
│   │   │   ├── protocol/          # 方案列表 + 编辑
│   │   │   ├── archive/           # 档案列表 + 详情/导出/复现
│   │   │   ├── alarm/             # 报警中心
│   │   │   └── profile/           # 我的
│   │   ├── components/            # 分区卡片、热力图、露点卡、返回按钮等
│   │   └── services/              # Mock BLE、PID/协调/露点/安全、本地存储
│   └── vite.config.ts             # base: /coolcap/
│
├── uniapp-server/                 # 后端（旧接口 + CoolCap）
│   ├── models/
│   │   ├── coolcap.py             # YL_PATIENT / YL_DEVICE / YL_PROTOCOL / YL_SESSION ...
│   │   ├── user.py / log.py       # 认证与日志
│   │   └── ...                    # master 旧模型仍保留（娱乐/黄金/笔记本等）
│   ├── routers/
│   │   ├── coolcap.py             # /api/coolcap/*
│   │   ├── auth.py                # /api/auth/*
│   │   └── ...                    # home/game/gold/laptop/weather/news 等旧路由
│   ├── sql/YL_coolcap_tables.sql  # YL_ 表结构对照
│   ├── scripts/init_yl_tables.py  # 建表脚本
│   └── main.py                    # 同时挂载新旧路由
│
├── deploy/                        # 上线 Nginx 与说明
├── docs/compose/spec/             # CoolCap 设计文档
└── coolcap-h5-dist.zip            # H5 生产包（如有）
```

## 功能特性（CoolCap）

| 模块 | 说明 |
|------|------|
| 登录 | 优先真实 `/api/auth/login`，失败回退本地 mock |
| 治疗 | BLE 连接（模拟）、开始/结束、全头均匀度、治疗历史入库展示 |
| 监控 | 6 区头皮侧温度热力图、功率、趋势曲线、露点防护 |
| 方案 | 内置模板 + 自定义阶段（时长/目标温度/功率上限） |
| 档案 | 列表搜索、详情回放、JSON/CSV 导出、一键复现 |
| 报警 | 信息/警告/严重分级；冻伤/热端/传感器/脱离/过流等 |
| 我的 | 环境温湿度模拟、安全包络只读、退出登录 |

### 控制算法特点（APP 侧呈现）

1. **头皮侧直接测温**（主控变量，非 TEC 冷端）  
2. **多区独立 PID** 状态：idle / ramp / hold / protect / fault  
3. **全头温差协调**：偏高区追加补偿，均匀度徽章  
4. **基于露点的凝露防护**：目标 ≥ 露点 + 余量，自动钳制  
5. **多层次安全**：冻伤下限、热端过温、传感器故障、接触异常、过流  

## 技术栈

### 前端（YL）
- uni-app + Vue 3 + TypeScript + Vite  
- uview-plus  
- Canvas 热力图 / 趋势图（本地组件；未强绑 echarts 也可运行）

### 后端
- FastAPI + SQLAlchemy + MySQL（库：`study_uniapp`）  
- JWT 认证  
- CoolCap 新表前缀：**`YL_`**

## 数据库（YL_）

| 表 | 用途 |
|----|------|
| `YL_PATIENT` | 患者 |
| `YL_DEVICE` | 设备 |
| `YL_PROTOCOL` / `YL_PROTOCOL_STAGE` | 治疗方案 |
| `YL_SAFETY_PROFILE` | 安全包络 |
| `YL_SESSION` / `YL_SESSION_POINT` / `YL_SESSION_ZONE` | 治疗档案与采样 |
| `YL_ALARM` | 报警 |
| `YL_ENV_SAMPLE` | 环境采样 |
| `YL_CONTROL_COMMAND` | 指令审计 |

建表：

```bash
# Python 建议：D:\python\Python\Python310\python.exe
cd uniapp-server
python scripts/init_yl_tables.py
# 或启动 main.py 时 create_all
```

## 本地启动

```bash
# 后端
cd uniapp-server
python -m uvicorn main:app --host 0.0.0.0 --port 8022

# 前端（开发）
cd uniapp-web
npm install
npm run dev:h5
# http://localhost:5173/coolcap/

# 前端（生产）
npm run build:h5
# 产物：uniapp-web/dist/build/h5/
```

演示登录（YL）：`admin` / 任意 ≥4 位密码（后端可用时会优先走真实登录）。

## 上线要点

1. 前端 `base` 为 `/coolcap/`  
2. Nginx 将 `/uniapp-api/` 反代到后端 `:8022`  
3. 详见 `deploy/README.md`、`deploy/nginx-coolcap.conf`  
4. 生产请修改 `config.py` 的 `SECRET_KEY`

## 设计文档

- `docs/compose/spec/coolcap-mobile.md`  
- 学习文档：`学习.md`  
