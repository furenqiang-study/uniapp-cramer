---
feature: coolcap-mobile
status: delivered
updated: 2026-01-01
branch: dev
commits: 468adb5..HEAD
---

# 化疗头皮冷却冰帽控制 APP（CoolCap）

## Report

**What was built** — 在 `dev` 分支将原后台管理端重塑为 CoolCap 化疗头皮冷却 APP：前端保留登录并新增治疗/监控/方案/档案/我的等页面；控制侧为 6 区 Mock BLE + PID/温差协调/露点/安全模拟。后端在现有库 `study_uniapp` 新增 `YL_*` 业务表与 `/api/coolcap/*` 接口（方案、会话归档、点位、报警、安全包络、指令审计、复现/导出）。

**Verification** — `npm run build:h5` **PASS**（DONE Build complete）；`models/coolcap.py` + `routers/coolcap.py` + `main` 导入 **PASS**；`scripts/init_yl_tables.py` 对现有 MySQL `create_all` **PASS**，已建 11 张 `YL_*` 表。

**Journey log** — uview-plus 需 `src/uni.scss` 注入 `theme.scss`，否则组件编译报 `$u-primary` 未定义。`therapyStore` 相对路径应为 `../types`。SQLAlchemy `Column(index=True, ForeignKey=...)` 参数顺序非法。远程库连通时用 `D:\python\Python\Python310\python.exe scripts\init_yl_tables.py`。

## [S1] Problem

化疗脱发（CIA）患者需要头皮冷却设备减少毛囊药物暴露。现有后台管理系统中的娱乐、财经、推荐等功能与本产品无关；需要在 `dev` 分支上重塑为移动端冰帽控制 APP：保留登录，删除其余业务，围绕 **真实头皮测温 + 多区 PID + 安全防护 + 治疗档案** 提供临床可用的手机端。

核心痛点（相对“测制冷片温度”的普通冰帽）：

1. 测温点在头皮侧而非 TEC 冷端，控制目标即头皮温度，消除热阻偏差。
2. 各冷却区独立 PID 功率调节，而不是通断开关。
3. 全头温差协调，主动缩小区间温差。
4. 露点防护，从源头抑制凝露滴水。
5. 多层次安全（冻伤 / 热端过温 / 传感器故障 / 脱离接触 / 过流）。
6. 手机端可视化、方案管理、档案追溯、分级报警、参数一键复现。

## [S2] Design

### 产品定位与边界

| 项 | 决策 |
|----|------|
| 产品名 | CoolCap 头皮冷却治疗系统 |
| 交付形态 | **改造现有 uni-app 工程**（Vue3 + TypeScript + Vite）；`uniapp-web` 冰帽业务重塑；`uniapp-server` 仅保留登录所需 auth 可选弱依赖，新业务不绑死后端 |
| 仓库动作 | 在现有 `dev` 分支（= master）上改造；删除登录以外的旧业务页面、路由、API mock 与静态小游戏资源 |
| 登录 | 保留账号密码登录页交互；优先本地 mock 会话，可切换对接 `uniapp-server` auth |
| BLE | 原型用 **模拟 BLE 设备层**（`MockBleDevice`）统一数据模型与协议；真实 `uni.openBluetoothAdapter` 等 API 留适配器接口，后续接入 |
| 固件算法 | PID / 温差协调 / 露点 / 保护阈值以 **设备侧模型 + APP 显示与参数配置** 呈现；APP 不替代 MCU 闭环，但可下发目标温度与安全包络 |

### 技术栈（已确认）

| 层 | 选型 | 说明 |
|----|------|------|
| 框架 | uni-app + Vue 3 + TypeScript + Vite | 沿用现有 `uniapp-web` 工程与脚本 |
| UI 库 | **uview-plus** | Vue3 版 uni-app 组件库；按钮、卡片、弹层、表单、标签页、通知等 |
| 图表 | **echarts + ec-canvas** | 实时多区温度趋势、档案回放曲线 |
| 样式 | SCSS + design tokens | 医疗冷静风；不引入重型主题包 |
| 状态 | Vue3 `ref/reactive` + 轻量 composable（或 pinio 视实现需要） | 先够用，避免过度架构 |
| 本地存储 | `uni` Storage + 本地 JSON/档案表 | 方案、会话、设置 |
| 后端 | 现有库 `study_uniapp` + **YL_ 前缀新表** | FastAPI 路由 `/api/coolcap/*`；保留 `/api/auth/*` |
| 通信 | BLE 适配层 | `MockBleDevice` 默认；预留 uni BLE API |

建议依赖安装（实现阶段执行）：

```bash
npm i uview-plus
# echarts 与 ec-canvas 按 uni-app 可用方式接入（ec-canvas 组件 + echarts 产物）
```

### 分区模型（6 区）

| 区域 ID | 名称 | 解剖位置 | 默认目标 |
|---------|------|----------|----------|
| F | 额区 | 前额发际带 | 18°C |
| TL | 左颞区 | 左侧太阳穴上方 | 16°C |
| TR | 右颞区 | 右侧太阳穴上方 | 16°C |
| P | 顶区 | 头顶 | 16°C |
| OL | 左枕区 | 左后脑 | 16°C |
| OR | 右枕区 | 右后脑 | 16°C |

每区数据通道：`scalpTemp`（头皮侧实测）、`coldSideTemp`（TEC 冷端，辅助）、`hotSideTemp`（热端）、`current`（TEC 电流）、`power`（占空比 0–100%）、`contact`（接触状态）、`fault`（故障码）、`setpoint`（目标）。

### 控制与算法（APP 侧契约）

**A. 头皮侧直接测温**

- 主控变量：各区 `scalpTemp`。
- 显示同时给出冷端温度作诊断参考，不作为目标闭环主变量。

**B. 多区独立 PID**

- 每区独立闭环状态：`idle / ramp / hold / protect / fault`。
- APP 下发：全局或分区 `targetTemp`、功率上限 `maxDuty`、斜坡速率。
- APP 上报可视化：实际功率、误差、稳定判定（|error| ≤ 0.5°C 持续 10s 视为稳定）。

**C. 全头皮温差协调**

- 协调器读取 6 区 `scalpTemp`，计算 `deltaT = max - min`。
- 策略：偏高区在本地 PID 输出上追加协调增量 `comp = k * (zoneT - meanT)`，不修改其他区目标（可微调），直至 `deltaT ≤ 1.5°C`（可配置）。
- UI 显示：全头均匀度徽章（优 / 良 / 差）与实时温差。

**D. 露点凝露防护**

- 输入：环境温湿度（传感器或手动）。
- 露点：Magnus 公式。
- 规则：`targetTemp ≥ dewPoint + margin`（默认 margin = 2.0°C）。
- 触发时：自动上调该区有效目标，或钳制最大制冷功率；事件记入日志与报警（提示级）。
- UI：环境卡片（温、湿、露点、安全余量）。

**E. 安全保护体系**

| 保护 | 判据（默认，可配置只读展示） | 动作 | 报警级 |
|------|------------------------------|------|--------|
| 低温冻伤 | `scalpTemp < lowerLimit`（默认 12°C）或热流密度代理超限 | 升目标/降功率/停该区 | 紧急 |
| 热端过温 | `hotSideTemp > 60°C` | 降功率；>65°C 停该区 | 警告→严重 |
| 传感器故障 | 开路/短路/NaN/超量程 | 该区降功率停机 | 严重 |
| 脱离接触 | 冷端-头皮温差变化率异常 + 接触阻抗模型 | 声光+推送，可暂停治疗 | 警告 |
| 过流 | `current > Imax`（如 2A） | 恒流约束/切断 | 严重 |

报警分级：`info / warning / critical`；critical 手机横幅 + 声音模拟 + 红点角标。

### 治疗方案与档案

- **方案（Protocol）**：名称、总时长、阶段列表（预冷 / 化疗 / 回温）、每阶段目标温度、功率上限、备注；内置模板 + 自定义编辑。
- **会话（Session）**：开始时间、方案快照、环境、各区时序曲线（每 5s 采样点）、报警列表、结束原因。
- **档案**：本地 IndexedDB 持久化；列表筛选、详情回放、导出 JSON/CSV（浏览器下载）；「一键复现」将方案参数写入下一次治疗。

### 页面信息架构（Tab + 栈）

```
Login
└─ Main (tabBar)
   ├─ 治疗 Home     —— 设备连接、今日状态、快捷开始/结束
   ├─ 实时监控      —— 头区热力图、分区卡片、趋势曲线、环境露点
   ├─ 方案          —— 模板列表、编辑器、一键应用到治疗
   ├─ 档案          —— 历史会话、详情、导出、复现
   └─ 我的          —— 用户、安全参数只读、关于、模拟设备开关
         └─ 报警中心（入口在 Home 顶栏角标 + 我的）
```

### UI 设计方向

| 维度 | 规范 |
|------|------|
| 风格锚点 | 现代医疗设备伴侣 APP（冷静、可信、低装饰）；类似动态血糖仪 / 临床冷却治疗仪表盘，非消费娱乐风 |
| 背景 | `#F4F7FB` 冷灰蓝底；卡片纯白 `#FFFFFF` |
| 主墨色 | 深蓝黑 `#0F172A` / 次级灰 `#64748B` |
| 主色（冰疗蓝） | `#0EA5E9` → 渐变辅助 `#38BDF8` |
| 安全色 | 成功 `#10B981`、警告 `#F59E0B`、严重 `#EF4444` |
| 强调（设备态） | 已连接绿点、未连接灰、报警红呼吸 |
| 字体 | 系统栈：`-apple-system, "PingFang SC", "Microsoft YaHei", sans-serif`；数字用 tabular 等宽感 |
| 尺度 | 小节标题 17/600；正文 14/400；温度大数 28/700；标注 12/400 |
| 圆角与密度 | 卡片 16px、按钮 12px；页边距 16px；卡片间距 12px；移动优先 375 宽 |
| 图形语言 | 头区俯视 SVG 示意（6 色块按温度映射）；细线趋势图；无重型阴影，仅 `0 1px 2px` 轻投影 |

**签名瞬间（Signature moments）**

1. **实时头区热力图**：俯视头部轮廓 + 6 区填充色随温度平滑过渡，稳定区出现细微“冰晶”完成环。
2. **温差协调脉冲**：当某区进入协调补偿时，该区边框一次青色脉冲，文案提示「已加大制冷」。
3. **露点安全条**：环境卡片中安全余量进度条，接近阈值时由绿变黄并抑制启动。

**关键屏规格**

1. **登录**：上半品牌区（冰晶标志 + CoolCap + 副标「化疗头皮冷却治疗」）；卡片表单：账号、密码、记住我；主按钮「登录」。保留原登录结构与校验，替换文案与视觉。
2. **治疗 Home**：顶栏设备芯片（BLE 名/状态）；大卡片：待机/治疗中状态、已进行时长、全头均匀度；安全摘要三小卡（露点余量、最低温、报警数）；主操作「开始治疗」/「结束并归档」；报警角标。
3. **实时监控**：顶部连接条；左热力图右关键指标；环境条；6 区网格（目标/实测/功率）；底部 30 分钟趋势多线（可点选区）。
4. **方案**：列表（模板+自定义）；编辑器：阶段时间轴、每阶段温度滑杆 10–25°C、功率上限、保存/应用。
5. **档案**：搜索+日期筛选；卡片列表（时长、方案名、最高/最低温、报警数）；详情：时间轴回放条、曲线、导出、复现按钮。
6. **我的**：账户信息；模拟设备开关与环境设置；安全包络只读表；报警历史入口；退出登录。

### 数据库（已有库 `study_uniapp`，新表前缀 `YL_`）

| 表 | 用途 |
|----|------|
| `YL_PATIENT` | 患者档案 |
| `YL_DEVICE` | 冰帽设备绑定 |
| `YL_PROTOCOL` / `YL_PROTOCOL_STAGE` | 时序方案与阶段 |
| `YL_SAFETY_PROFILE` | 安全包络阈值 |
| `YL_SESSION` | 治疗会话主档案 |
| `YL_SESSION_POINT` | 温度/功率时序采样 |
| `YL_SESSION_ZONE` | 分区汇总 |
| `YL_ALARM` | 分级报警 |
| `YL_ENV_SAMPLE` | 环境温湿度采样 |
| `YL_CONTROL_COMMAND` | 下行控制指令审计 |

SQL 对照：`uniapp-server/sql/YL_coolcap_tables.sql`；模型：`models/coolcap.py`；启动 `Base.metadata.create_all` 自动建表。

**主要接口（前缀 `/api/coolcap`）**

| 方法 | 路径 | 说明 |
|------|------|------|
| GET/POST/PUT | `/patients` | 患者 |
| GET/POST | `/devices` | 设备绑定 |
| GET/POST/PUT/DELETE | `/protocols` | 方案 CRUD（内置只读） |
| GET | `/sessions` | 档案列表（分页/搜索） |
| POST | `/sessions/start` | 开始会话（含露点计算） |
| GET | `/sessions/{id}` | 档案详情（点位+报警） |
| POST | `/sessions/{id}/finish` | 结束归档（批量写入采样点） |
| GET | `/sessions/{id}/export` | 临床追溯导出 |
| POST | `/sessions/{id}/reproduce` | 一键复现参数 |
| GET/POST | `/alarms` | 报警 |
| POST | `/alarms/{id}/ack` | 确认报警 |
| GET/POST | `/env/*` | 环境采样 |
| GET | `/safety` | 安全包络 |
| POST | `/commands` | 控制指令审计 |

### 数据与本地存储

- uni Storage：用户会话、设置、方案 JSON。
- 档案时序：先以 Storage/本地模块持久化，必要时升 IndexedDB。
- Mock 生成器：正弦扰动 + 噪声模拟降温曲线，保证无硬件可演示。

### 工程文件规划（实现阶段）

```
uniapp-web/
├── src/
│   ├── pages/
│   │   ├── login/login.vue          # 保留并改版
│   │   ├── home/home.vue            # 治疗首页
│   │   ├── monitor/monitor.vue      # 实时监控
│   │   ├── protocol/protocol.vue    # 方案列表
│   │   ├── protocol/edit.vue        # 方案编辑
│   │   ├── archive/archive.vue      # 档案列表
│   │   ├── archive/detail.vue       # 档案详情/导出/复现
│   │   ├── alarm/alarm.vue          # 报警中心
│   │   └── profile/profile.vue      # 我的
│   ├── components/
│   │   ├── ZoneHeatmap.vue          # 头区热力图（SVG/Canvas）
│   │   ├── ZoneCard.vue
│   │   ├── EnvDewpointCard.vue
│   │   ├── TempTrendChart.vue       # ec-canvas 封装
│   │   └── StatusChip.vue
│   ├── services/
│   │   ├── ble/device.ts            # 接口 + MockBleDevice
│   │   ├── control/pidSim.ts
│   │   ├── control/coordination.ts
│   │   ├── control/dewpoint.ts
│   │   ├── control/safety.ts
│   │   └── store/therapyStore.ts
│   ├── api/auth.ts                  # 保留/精简
│   └── pages.json                   # 仅新页面 + tabBar
└── package.json                     # + uview-plus, echarts, ec-canvas
```

删除范围（实现时）：`entertainment/*`、`gold/*`、`laptop/*`、`camera/*`、`earth/*`、`news/*`、`weather/*`、`menu/*`、`user/*` 及对应 api/mock/static/games；`uni` 根目录遗留单页 Vue 草稿一并清理或移出产品路径。

## [S3] Out of Scope

- 不实现真实固件 / MCU 代码。
- 不调用真实 BLE 硬件（保留接口与模拟开关）。
- 不对接现网业务表（黄金/娱乐等）；登录可 mock，auth 对接为可选。
- 不做医生工作站 / 多角色后台 / 云同步。
- 不做支付、推送厂商 SDK、应用商店上架物料。
- 不修改 master 分支。
- 不在此阶段完成真机 BLE 联调（仅适配层 + 模拟设备）。

## Tasks

- [ ] T0: 工程瘦身与依赖引入 — acceptance: 安装 uview-plus/echarts/ec-canvas；pages.json 仅含新页面；旧业务页与资源不再被路由引用；`npm run dev:h5` 可启动 (covers: S2 技术栈、交付形态)
- [ ] T1: 应用骨架与主题 — acceptance: 登录后进入 tabBar 主框架；design tokens 落地；无旧功能入口 (covers: S2 UI、页面信息架构)
- [ ] T2: 登录与会话 — acceptance: 账号密码校验、记住我、会话持久化、登出后回登录 (covers: S2 登录)
- [ ] T3: Mock BLE 与实时监控 — acceptance: 模拟连接 6 区设备；热力图与分区卡片按模拟温度更新；echarts 趋势滚动 (covers: S2 分区模型、实时监控)
- [ ] T4: 控制模拟与温差协调展示 — acceptance: 下发目标后进入 ramp→hold；温差超阈值时偏高区显示协调增量与均匀度徽章变化 (covers: S2 B/C)
- [ ] T5: 露点防护与安全报警 — acceptance: 可配置环境温湿度；露点余量不足时自动钳制目标并提示；触发保护时分级报警与角标 (covers: S2 D/E)
- [ ] T6: 方案管理 — acceptance: 内置模板可应用；可新建/编辑阶段并保存 (covers: S2 治疗方案)
- [ ] T7: 档案与导出复现 — acceptance: 结束治疗生成档案；可查看曲线、导出 JSON/CSV、一键复现参数 (covers: S2 档案)
- [ ] T8: 我的与打磨 — acceptance: 设置/只读安全参数/关于完整；H5 与小程序布局无横向滚动；关键路径可演示 (covers: S2 UI、我的)
