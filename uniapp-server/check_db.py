import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from database import SessionLocal
from models.entertainment import EntGame, EntCategory, EntSong, EntVideo, EntNovel

db = SessionLocal()
try:
    games = db.query(EntGame).count()
    cats = db.query(EntCategory).count()
    songs = db.query(EntSong).count()
    videos = db.query(EntVideo).count()
    novels = db.query(EntNovel).count()
    print(f"分类: {cats}")
    print(f"游戏: {games}")
    print(f"歌曲: {songs}")
    print(f"视频: {videos}")
    print(f"小说: {novels}")
    if games == 0:
        print("数据库为空，需要运行 init_entertainment.py")
    else:
        print("数据库已有数据！")
except Exception as e:
    print(f"连接失败: {e}")
finally:
    db.close()