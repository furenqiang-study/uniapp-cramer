# 小米 uni-app 后台管理系统

> 企业级后台管理系统 —— 基于 uni-app Vue3 + TypeScript（前端） + FastAPI + MySQL（后端）

## 📦 项目结构

```
xiaomi-uniapp/
├── uniapp-web/                 # 前端项目 (uni-app + Vue3 + TypeScript)
│   ├── src/
│   │   ├── api/                # 接口请求模块
│   │   │   ├── auth.ts         # 登录/认证接口
│   │   │   ├── entertainment.ts # 娱乐中心接口（游戏/音乐/视频/小说）
│   │   │   ├── home.ts         # 首页接口
│   │   │   ├── laptop.ts       # 笔记本接口
│   │   │   ├── menu.ts         # 菜单接口
│   │   │   ├── request.ts      # 请求封装（axios 拦截器）
│   │   │   └── mock/           # Mock 数据
│   │   ├── pages/              # 页面
│   │   │   ├── camera/         # 相机页面
│   │   │   ├── entertainment/  # 娱乐中心（游戏/音乐/视频/小说/15款小游戏）
│   │   │   │   ├── games/      # Vue小游戏页面（共15款）
│   │   │   │   │   ├── game2048.vue        # 2048数字合并
│   │   │   │   │   ├── gomoku.vue          # 五子棋
│   │   │   │   │   ├── match3.vue          # 消消乐
│   │   │   │   │   ├── minesweeper.vue     # 扫雷
│   │   │   │   │   ├── breakout.vue        # 打砖块
│   │   │   │   │   ├── coin-catch.vue      # 接金币
│   │   │   │   │   ├── snake.vue           # 贪吃蛇
│   │   │   │   │   ├── whack-mole.vue      # 打地鼠
│   │   │   │   │   ├── flappy-bird.vue     # 飞鸟穿越
│   │   │   │   │   ├── sliding-puzzle.vue  # 数字拼图
│   │   │   │   │   ├── balloon-shoot.vue   # 射击气球
│   │   │   │   │   ├── flag-match.vue      # 国旗配对
│   │   │   │   │   ├── checkers.vue        # 跳棋
│   │   │   │   │   ├── chinese-chess.vue   # 中国象棋
│   │   │   │   │   └── zjh-poker.vue       # 炸金花
│   │   │   │   ├── index.vue   # 娱乐中心首页
│   │   │   │   ├── game.vue    # 游戏中心
│   │   │   │   ├── music.vue   # 音乐播放
│   │   │   │   ├── video.vue   # 视频影音
│   │   │   │   └── novel.vue   # 网络小说
│   │   │   ├── home/           # 首页
│   │   │   ├── laptop/         # 笔记本智能推荐
│   │   │   ├── login/          # 登录页
│   │   │   ├── menu/           # 菜单管理
│   │   │   └── profile/        # 个人中心
│   │   ├── App.vue             # 根组件
│   │   ├── main.ts             # 入口文件
│   │   ├── pages.json          # 页面路由配置
│   │   └── manifest.json       # 应用配置
│   ├── index.html
│   ├── package.json
│   ├── tsconfig.json
│   └── vite.config.ts
│
├── uniapp-server/              # 后端项目 (FastAPI + SQLAlchemy + MySQL)
│   ├── models/                 # 数据库模型（含娱乐中心20张表）
│   ├── routers/                # 路由模块
│   │   ├── auth.py             # 认证路由
│   │   ├── menu.py             # 菜单路由
│   │   ├── home.py             # 首页路由
│   │   ├── profile.py          # 个人中心路由
│   │   ├── log.py              # 日志路由
│   │   ├── laptop.py           # 笔记本路由
│   │   ├── game.py             # 游戏中心路由
│   │   ├── music.py            # 音乐路由
│   │   ├── video.py            # 视频路由
│   │   ├── novel.py            # 小说路由
│   │   └── ent_common.py       # 娱乐公共路由
│   ├── schemas/                # 数据验证模型
│   ├── services/               # 业务逻辑层
│   ├── config.py               # 配置文件
│   ├── database.py             # 数据库连接
│   ├── main.py                 # 应用入口（含自动初始化/迁移）
│   ├── init_entertainment.py   # 娱乐中心数据初始化脚本
│   ├── requirements.txt        # Python 依赖
│   ├── Dockerfile              # Docker 构建文件
│   ├── docker-compose.yml      # Docker 编排配置
│   └── .dockerignore           # Docker 忽略文件
│
└── README.md
```

## 🚀 技术栈

### 前端

| 技术 | 说明 |
|------|------|
| [uni-app](https://uniapp.dcloud.net.cn/) | 跨平台应用框架 |
| [Vue 3](https://vuejs.org/) | 渐进式 JavaScript 框架 |
| [TypeScript](https://www.typescriptlang.org/) | 类型安全的 JavaScript 超集 |
| [Vite](https://vitejs.dev/) | 下一代前端构建工具 |
| [Sass](https://sass-lang.com/) | CSS 预处理器 |

### 后端

| 技术 | 说明 |
|------|------|
| [FastAPI](https://fastapi.tiangolo.com/) | 高性能 Python Web 框架 |
| [SQLAlchemy](https://www.sqlalchemy.org/) | Python ORM 框架 |
| [MySQL](https://www.mysql.com/) | 关系型数据库 |
| [Pydantic](https://docs.pydantic.dev/) | 数据验证和设置管理 |
| [python-jose](https://github.com/mpdavis/python-jose) | JWT 令牌生成与验证 |

## ✨ 功能特性

| 模块 | 说明 |
|------|------|
| 首页 | 数据概览、快捷操作、最近动态 |
| 菜单管理 | 菜单的增删改查 |
| 笔记本智能推荐 | 根据需求智能推荐笔记本电脑 |
| 相机拍照 | 调用设备摄像头拍照 |
| **娱乐中心** | 综合线上娱乐平台，包含以下四个子模块： |
| 　├ 游戏中心 | 15款Vue原生小游戏，免下载即点即玩，分类筛选、排行榜 |
| 　├ 音乐播放 | 在线音乐播放、歌单推荐、底部播放器、热歌榜 |
| 　├ 视频影音 | 影视剧/电影/综艺/动漫浏览、热播推荐、多维度筛选 |
| 　└ 网络小说 | 网文阅读、编辑推荐、人气排行榜、分类浏览 |

### 🎮 游戏中心小游戏列表（共15款）

| 游戏 | 类型 | 说明 |
|------|------|------|
| 2048数字合并 | 益智休闲 | 经典2048，滑动方块合并数字 |
| 五子棋 | 棋牌对战 | 双人对战，支持悔棋 |
| 消消乐 | 休闲消除 | 8×8三消，限时30步 |
| 扫雷经典版 | 益智策略 | 9×9棋盘，10颗雷，长按插旗 |
| 打砖块 | 动作街机 | 复古弹球，多关卡进阶 |
| 接金币 | 休闲反应 | 限时60秒，接金币躲炸弹 |
| 贪吃蛇 | 经典怀旧 | 三档难度，方格贪吃蛇 |
| 打地鼠 | 解压休闲 | 限时60秒，击打地鼠得分 |
| 飞鸟穿越 | 躲避闯关 | Flappy Bird同款，躲避管道 |
| 数字拼图 | 益智闯关 | 3×3数字滑块，星级评分 |
| 射击气球 | 射击休闲 | 限时90秒，射击气球得分 |
| 国旗配对 | 记忆益智 | 翻牌配对，4×4/5×5双难度 |
| 跳棋 | 棋牌策略 | 六角跳棋，双人对战 |
| 中国象棋 | 棋牌策略 | 国标象棋，完整走棋规则 |
| 炸金花 | 棋牌卡牌 | 虚拟积分版，跟注/加注/比牌 |

## 🗄️ 数据库设计

娱乐中心共设计20张数据表，通过 `main.py` 启动时自动建表和初始化：

| 模块 | 核心表 | 说明 |
|------|--------|------|
| 公共 | ent_category, ent_banner, ent_favorite, ent_history, ent_feedback | 分类/轮播图/收藏/历史/反馈 |
| 游戏 | ent_game, ent_game_screenshot, ent_game_play_record | 游戏/截图/游玩记录 |
| 音乐 | ent_song, ent_artist, ent_album, ent_playlist, ent_playlist_song | 歌曲/歌手/专辑/歌单 |
| 视频 | ent_video, ent_video_episode | 视频/分集 |
| 小说 | ent_novel, ent_novel_volume, ent_novel_chapter | 小说/卷/章节 |

## 🛠️ 本地开发

### 环境要求

- **Node.js** >= 16
- **Python** >= 3.11
- **MySQL** >= 5.7

### 前端启动

```bash
# 进入前端目录
cd uniapp-web

# 安装依赖
npm install

# 启动 H5 开发服务器
npm run dev:h5
```

浏览器访问 `http://localhost:5173/uniapp-cramer/`

### 后端启动

```bash
# 进入后端目录
cd uniapp-server

# 创建虚拟环境（推荐）
python -m venv venv
venv\Scripts\activate        # Windows
# source venv/bin/activate   # Linux/Mac

# 安装依赖
pip install -r requirements.txt

# 启动服务（首次启动自动建表+初始化数据）
python main.py
```

API 服务运行在 `http://localhost:8022`，API 文档地址：`http://localhost:8022/docs`

## 📋 可用脚本

### 前端 (uniapp-web)

| 命令 | 说明 |
|------|------|
| `npm run dev:h5` | H5 开发模式 |
| `npm run build:h5` | H5 生产打包 |
| `npm run dev:mp-weixin` | 微信小程序开发模式 |
| `npm run build:mp-weixin` | 微信小程序生产打包 |
| `npm run dev:app` | App 开发模式 |
| `npm run build:app` | App 生产打包 |

## 🚢 部署

### 前端部署

前端单独部署，打包命令：

```bash
cd uniapp-web
npm run build:h5
```

将 `uniapp-web/dist/build/h5/` 目录下的文件部署到 Nginx 或任意静态文件服务器。

**Nginx 配置示例：**

```nginx
server {
    listen 80;
    server_name your-domain.com;

    root /path/to/uniapp-web/dist/build/h5;
    index index.html;

    location /uniapp-cramer/ {
        try_files $uri $uri/ /uniapp-cramer/index.html;
    }

    location /api/ {
        proxy_pass http://127.0.0.1:8022/api/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

### 后端部署

#### 方式一：手动部署

```bash
cd uniapp-server

# 创建虚拟环境（推荐）
python -m venv venv
source venv/bin/activate

# 安装依赖
pip install -r requirements.txt

# 直接使用 python 启动（内部已集成 uvicorn）
python main.py
```

##### 使用 pm2 管理进程（推荐生产环境）

```bash
# 安装 pm2（如未安装）
npm install -g pm2

# 使用 pm2 启动 Python 服务
pm2 start main.py --name uniapp-api --interpreter ~/venv/bin/python -- --host 0.0.0.0 --port 8022

# 常用 pm2 命令
pm2 list              # 查看所有进程
pm2 logs uniapp-api   # 查看日志
pm2 restart uniapp-api # 重启服务
pm2 stop uniapp-api   # 停止服务
pm2 delete uniapp-api # 删除进程

# 设置开机自启
pm2 save
pm2 startup
```

#### 方式二：Docker 容器部署（推荐）

将 `uniapp-server/` 目录上传到服务器，然后执行：

```bash
cd uniapp-server
docker-compose up -d --build
```

```bash
# 在源服务器保存镜像
docker save -o xiaomi-uniapp-api.tar xiaomi-uniapp-api

# 在目标服务器加载镜像
docker load -i xiaomi-uniapp-api.tar

# 在目标服务器启动容器（对外端口 8022）
docker run -d \
  --name uniapp-api \
  -p 8022:8022 \
  -e DB_HOST=120.48.35.111 \
  -e DB_PORT=3306 \
  -e DB_USER=root \
  -e DB_PASSWORD=123321Frq \
  -e DB_NAME=study_uniapp \
  --restart always \
  uniapp-server_api:latest
```

常用 Docker 命令：

```bash
# 查看容器状态
docker ps

# 查看日志
docker logs xiaomi-uniapp-api

# 停止服务
docker-compose down

# 重新构建并启动
docker-compose up -d --build
```

#### 访问地址

| 服务 | 地址 |
|------|------|
| 后端 API | `http://服务器IP:8022/api/` |
| API 文档 | `http://服务器IP:8022/docs` |

### 环境变量配置

后端支持通过 `.env` 文件或环境变量覆盖默认配置：

| 变量名 | 说明 | 默认值 |
|--------|------|--------|
| `DB_HOST` | 数据库地址 | `localhost` |
| `DB_PORT` | 数据库端口 | `3306` |
| `DB_USER` | 数据库用户名 | `root` |
| `DB_PASSWORD` | 数据库密码 | - |
| `DB_NAME` | 数据库名 | `study_uniapp` |
| `SECRET_KEY` | JWT 密钥 | - |
| `HOST` | 服务监听地址 | `0.0.0.0` |
| `PORT` | 服务端口 | `8022` |

## 📄 License

MIT