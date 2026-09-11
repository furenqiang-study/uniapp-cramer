"""FastAPI 应用入口 — 兼容 master 旧接口 + CoolCap(YL_) 接口"""
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from config import settings
from database import engine, Base

# 旧模块 + CoolCap 模型（全部注册到 create_all）
from models.user import User  # noqa: F401
from models.menu import Menu  # noqa: F401
from models.log import OperationLog  # noqa: F401
from models.gold import GoldPrice, GoldPrediction  # noqa: F401
from models.laptop import LaptopModel, LaptopRecommendation  # noqa: F401
from models.entertainment import (  # noqa: F401
    EntCategory, EntBanner, EntFavorite, EntHistory,
    EntGame, EntGameScreenshot, EntGamePlayRecord,
    EntArtist, EntAlbum, EntSong, EntPlaylist, EntPlaylistSong, EntSongPlayRecord,
    EntVideo, EntVideoEpisode, EntVideoPlayRecord,
    EntNovel, EntNovelVolume, EntNovelChapter, EntNovelReadRecord,
)
from models import coolcap as _coolcap_models  # noqa: F401

from routers import auth
from routers import home, profile, log, laptop, user
from routers import game, music, video, novel, ent_common, news, weather, gold
from routers import coolcap


def auto_init_data():
    """自动初始化娱乐中心数据（仅在表为空时执行；失败不影响启动）"""
    from database import SessionLocal, engine as db_engine
    from sqlalchemy import text
    from models.entertainment import EntGame, EntCategory
    db = SessionLocal()
    try:
        try:
            with db_engine.connect() as conn:
                result = conn.execute(text(
                    "SELECT COUNT(*) FROM information_schema.COLUMNS "
                    "WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='ent_novel' AND COLUMN_NAME='is_new'"
                ))
                if result.scalar() == 0:
                    conn.execute(text("ALTER TABLE ent_novel ADD COLUMN is_new SMALLINT DEFAULT 0 COMMENT '是否上新'"))
                    conn.commit()
                    print("已为 ent_novel 表添加 is_new 列")
        except Exception as e:
            print(f"表结构更新检查: {e}")

        game_count = db.query(EntGame).count()
        cat_count = db.query(EntCategory).count()
        if game_count == 0 and cat_count == 0:
            print("娱乐中心数据为空，正在自动初始化...")
            try:
                import init_entertainment
                print("娱乐中心数据初始化完成！")
            except Exception as e:
                print(f"娱乐中心初始化跳过: {e}")
        else:
            print(f"娱乐中心数据已存在: 游戏{game_count}个, 分类{cat_count}个")
    except Exception as e:
        print(f"自动初始化检查失败: {e}")
    finally:
        db.close()


if os.environ.get("CC_SKIP_DB", "0") != "1":
    try:
        Base.metadata.create_all(bind=engine)
        auto_init_data()
    except Exception as e:
        print(f"[warn] create_all skipped: {e}")

app = FastAPI(
    title="uni-app 后台 + CoolCap API",
    description="兼容 master 旧接口与 CoolCap(YL_) 冰帽接口",
    version="1.1.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ---- 旧接口（master 前端）----
app.include_router(auth.router)
app.include_router(home.router)
app.include_router(profile.router)
app.include_router(log.router)
app.include_router(laptop.router)
app.include_router(game.router)
app.include_router(music.router)
app.include_router(video.router)
app.include_router(novel.router)
app.include_router(ent_common.router)
app.include_router(news.router)
app.include_router(user.router)
app.include_router(weather.router)
app.include_router(gold.router)

# ---- 新接口（YL / CoolCap）----
app.include_router(coolcap.router)


@app.get("/", tags=["健康检查"])
def root():
    return {"message": "uni-app server is running", "version": "1.1.0"}


@app.get("/api/health", tags=["健康检查"])
def health():
    return {"code": 200, "message": "ok", "data": {"service": "uniapp+coolcap", "status": "up"}}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host=settings.HOST, port=settings.PORT, reload=True)
