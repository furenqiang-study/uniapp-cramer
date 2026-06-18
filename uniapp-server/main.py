"""FastAPI 应用入口"""
import sys
import os

# 将当前目录加入 Python 路径
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from config import settings
from database import engine, Base
from routers import auth, menu, home, profile, log, laptop, user
from routers import game, music, video, novel, ent_common, news

# 创建数据库表
Base.metadata.create_all(bind=engine)


def auto_init_data():
    """自动初始化娱乐中心数据（仅在表为空时执行）"""
    from database import SessionLocal, engine as db_engine
    from sqlalchemy import text
    from models.entertainment import EntGame, EntCategory
    db = SessionLocal()
    try:
        # 确保所有表结构是最新的（处理新增列的情况）
        try:
            with db_engine.connect() as conn:
                # 检查 ent_novel 表是否有 is_new 列，没有则添加
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

        # 更新旧的游戏URL为新的静态资源路径
        try:
            from models.entertainment import EntGame as _EntGame
            old_games = db.query(_EntGame).filter(_EntGame.game_url.like('/games/%')).all()
            if old_games:
                for g in old_games:
                    g.game_url = g.game_url.replace('/games/', '/static/games/')
                db.commit()
                print(f"已更新 {len(old_games)} 个游戏的URL路径")
        except Exception as e:
            print(f"游戏URL更新检查: {e}")

        game_count = db.query(EntGame).count()
        cat_count = db.query(EntCategory).count()
        if game_count == 0 and cat_count == 0:
            print("娱乐中心数据为空，正在自动初始化...")
            import init_entertainment
            print("娱乐中心数据初始化完成！")
        else:
            print(f"娱乐中心数据已存在: 游戏{game_count}个, 分类{cat_count}个")
            # 自动添加缺失的新游戏
            new_games = [
                ("接金币", "鼠标控制托盘接金币躲炸弹，限时60秒", 1, "/static/games/coin-catch.html", "休闲,反应", 9200, 4.5, 6),
                ("贪吃蛇", "经典贪吃蛇，三档难度可选", 6, "/static/games/snake.html", "经典,怀旧", 11500, 4.6, 7),
                ("打地鼠", "点击击打冒出地鼠，限时60秒", 1, "/static/games/whack-mole.html", "解压,休闲", 8700, 4.4, 8),
                ("飞鸟穿越", "Flappy Bird同款，躲避管道障碍", 2, "/static/games/flappy-bird.html", "躲避,闯关", 13400, 4.7, 9),
                ("数字拼图", "3×3数字滑块拼图，锻炼逻辑", 1, "/static/games/sliding-puzzle.html", "益智,拼图", 6800, 4.5, 10),
                ("射击气球", "射击上升气球，限时90秒", 2, "/static/games/balloon-shoot.html", "射击,休闲", 7900, 4.3, 11),
                ("国旗配对", "记忆翻牌配对游戏，双难度", 1, "/static/games/flag-match.html", "益智,记忆", 6500, 4.4, 12),
                ("跳棋", "经典六角跳棋，双人对战", 3, "/static/games/checkers.html", "棋牌,策略", 5200, 4.3, 13),
                ("中国象棋", "国标象棋，完整走棋规则", 3, "/static/games/chinese-chess.html", "棋牌,象棋", 9800, 4.7, 14),
                ("炸金花", "虚拟积分版卡牌对战", 3, "/static/games/zjh-poker.html", "棋牌,卡牌", 11200, 4.5, 15),
            ]
            added = 0
            for title, desc, cat_id, url, tags, plays, score, sort in new_games:
                exists = db.query(_EntGame).filter(_EntGame.title == title).first()
                if not exists:
                    db.add(_EntGame(
                        title=title, cover_url=f"https://picsum.photos/300/200?random={sort}",
                        description=desc, category_id=cat_id, game_type="h5",
                        game_url=url, difficulty="easy", tags=tags,
                        play_count=plays, score=score, sort=sort, is_free=1,
                    ))
                    added += 1
            if added:
                db.commit()
                print(f"已自动添加 {added} 个新游戏")
    except Exception as e:
        print(f"自动初始化检查失败: {e}")
    finally:
        db.close()


auto_init_data()

app = FastAPI(
    title="小米 uni-app 后台管理系统 API",
    description="基于 FastAPI + SQLAlchemy 的小程序后台接口",
    version="1.0.0",
)

# CORS 跨域配置
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 注册路由
app.include_router(auth.router)
app.include_router(menu.router)
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


@app.get("/", tags=["健康检查"])
def root():
    return {"message": "uni-app server is running", "version": "1.0.0"}


@app.get("/api/health", tags=["健康检查"])
def health():
    return {"status": "ok"}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host=settings.HOST, port=settings.PORT, reload=True)