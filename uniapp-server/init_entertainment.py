"""娱乐中心初始化数据脚本"""
import sys
import os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from datetime import datetime
from database import engine, SessionLocal, Base
from models.entertainment import (
    EntCategory, EntBanner, EntGame, EntGameScreenshot,
    EntSong, EntArtist, EntAlbum, EntPlaylist, EntPlaylistSong,
    EntVideo, EntVideoEpisode,
    EntNovel, EntNovelVolume, EntNovelChapter,
)

# 创建表
Base.metadata.create_all(bind=engine)
db = SessionLocal()

try:
    # ==================== 分类数据 ====================
    print("正在创建分类数据...")

    game_categories = [
        ("休闲益智", 1), ("动作冒险", 2), ("棋牌桌游", 3),
        ("角色扮演", 4), ("竞技对战", 5), ("单机小游戏", 6),
    ]
    music_categories = [
        ("流行", 1), ("摇滚", 2), ("古风", 3), ("民谣", 4),
        ("电子", 5), ("经典老歌", 6), ("纯音乐", 7),
    ]
    video_categories = [
        ("电影", 1), ("电视剧", 2), ("综艺", 3), ("动漫", 4),
        ("纪录片", 5), ("短视频", 6),
    ]
    novel_categories = [
        ("玄幻", 1), ("仙侠", 2), ("都市", 3), ("言情", 4),
        ("悬疑", 5), ("历史", 6), ("科幻", 7), ("短篇", 8),
    ]

    for name, sort in game_categories:
        db.add(EntCategory(name=name, type="game", sort=sort))
    for name, sort in music_categories:
        db.add(EntCategory(name=name, type="music", sort=sort))
    for name, sort in video_categories:
        db.add(EntCategory(name=name, type="video", sort=sort))
    for name, sort in novel_categories:
        db.add(EntCategory(name=name, type="novel", sort=sort))

    db.flush()
    print(f"  创建了 {len(game_categories) + len(music_categories) + len(video_categories) + len(novel_categories)} 个分类")

    # ==================== 轮播图数据 ====================
    print("正在创建轮播图数据...")
    banners_data = [
        ("热门H5小游戏合集", "https://picsum.photos/800/400?random=1", "game", 1),
        ("经典俄罗斯方块", "https://picsum.photos/800/400?random=2", "game", 2),
        ("2048挑战赛", "https://picsum.photos/800/400?random=3", "game", 3),
        ("华语热歌榜", "https://picsum.photos/800/400?random=4", "music", 1),
        ("新歌首发推荐", "https://picsum.photos/800/400?random=5", "music", 2),
        ("经典影视回顾", "https://picsum.photos/800/400?random=6", "video", 1),
        ("热门动漫推荐", "https://picsum.photos/800/400?random=7", "video", 2),
        ("玄幻小说强推", "https://picsum.photos/800/400?random=8", "novel", 1),
        ("限时免费小说", "https://picsum.photos/800/400?random=9", "novel", 2),
    ]
    for title, img, pos, sort in banners_data:
        db.add(EntBanner(title=title, image_url=img, position=pos, sort=sort))
    db.flush()
    print(f"  创建了 {len(banners_data)} 个轮播图")

    # ==================== 游戏数据 ====================
    print("正在创建游戏数据...")
    games_data = [
        {
            "title": "2048数字合并",
            "cover_url": "https://picsum.photos/300/200?random=g1",
            "description": "经典的2048数字合并游戏，滑动方块合并相同数字，挑战最高分！支持键盘方向键和触屏滑动。",
            "category_id": 1, "game_type": "h5", "difficulty": "easy",
            "game_url": "/static/games/2048.html",
            "tags": "益智,数字,休闲", "play_count": 12580, "score": 4.5, "sort": 1,
        },
        {
            "title": "五子棋",
            "cover_url": "https://picsum.photos/300/200?random=g2",
            "description": "经典五子棋游戏，支持人机对战和双人对战。AI三档难度可调节，支持悔棋功能。",
            "category_id": 3, "game_type": "h5", "difficulty": "medium",
            "game_url": "/static/games/gomoku.html",
            "tags": "棋牌,策略,对战", "play_count": 8900, "score": 4.6, "sort": 2,
        },
        {
            "title": "消消乐",
            "cover_url": "https://picsum.photos/300/200?random=g3",
            "description": "经典三消游戏！交换相邻水果元素，消除3个以上相同元素得分。限时30步挑战最高分！",
            "category_id": 1, "game_type": "h5", "difficulty": "easy",
            "game_url": "/static/games/match3.html",
            "tags": "消除,休闲,益智", "play_count": 15600, "score": 4.8, "sort": 3,
        },
        {
            "title": "打砖块",
            "cover_url": "https://picsum.photos/300/200?random=g4",
            "description": "复古街机风动作小游戏！控制挡板反弹小球消除砖块，多关卡进阶，挑战你的反应力。",
            "category_id": 2, "game_type": "h5", "difficulty": "medium",
            "game_url": "/static/games/breakout.html",
            "tags": "动作,街机,经典", "play_count": 6200, "score": 4.4, "sort": 4,
        },
        {
            "title": "扫雷经典版",
            "cover_url": "https://picsum.photos/300/200?random=g5",
            "description": "Windows经典扫雷游戏！根据数字提示找出所有地雷位置。支持初级/中级/高级三种难度。",
            "category_id": 1, "game_type": "h5", "difficulty": "medium",
            "game_url": "/static/games/minesweeper.html",
            "tags": "经典,益智,策略", "play_count": 7650, "score": 4.7, "sort": 5,
        },
        {
            "title": "接金币",
            "cover_url": "https://picsum.photos/300/200?random=g6",
            "description": "鼠标控制托盘左右移动，接住从天而降的金币加分，躲避炸弹扣分，限时60秒考验手速与反应！",
            "category_id": 1, "game_type": "h5", "difficulty": "easy",
            "game_url": "/static/games/coin-catch.html",
            "tags": "休闲,反应,金币", "play_count": 9200, "score": 4.5, "sort": 6,
        },
        {
            "title": "贪吃蛇",
            "cover_url": "https://picsum.photos/300/200?random=g7",
            "description": "经典贪吃蛇游戏，控制蛇移动吃食物变长加分，撞到边界或自身游戏结束，支持三种难度。",
            "category_id": 6, "game_type": "h5", "difficulty": "easy",
            "game_url": "/static/games/snake.html",
            "tags": "经典,怀旧,休闲", "play_count": 11500, "score": 4.6, "sort": 7,
        },
        {
            "title": "打地鼠",
            "cover_url": "https://picsum.photos/300/200?random=g8",
            "description": "解压休闲小游戏！地鼠随机从洞口冒出，点击击打得分，打到扣分老鼠扣分，限时60秒。",
            "category_id": 1, "game_type": "h5", "difficulty": "easy",
            "game_url": "/static/games/whack-mole.html",
            "tags": "解压,休闲,反应", "play_count": 8700, "score": 4.4, "sort": 8,
        },
        {
            "title": "飞鸟穿越",
            "cover_url": "https://picsum.photos/300/200?random=g9",
            "description": "Flappy Bird同款玩法！点击控制小鸟向上飞行，躲避管道障碍，穿越越多得分越高。",
            "category_id": 2, "game_type": "h5", "difficulty": "hard",
            "game_url": "/static/games/flappy-bird.html",
            "tags": "躲避,闯关,挑战", "play_count": 13400, "score": 4.7, "sort": 9,
        },
        {
            "title": "数字拼图",
            "cover_url": "https://picsum.photos/300/200?random=g10",
            "description": "经典3×3数字滑块拼图，点击方块向空白位置移动，将数字按1-8顺序排列即通关，锻炼逻辑思维。",
            "category_id": 1, "game_type": "h5", "difficulty": "medium",
            "game_url": "/static/games/sliding-puzzle.html",
            "tags": "益智,拼图,逻辑", "play_count": 6800, "score": 4.5, "sort": 10,
        },
        {
            "title": "射击气球",
            "cover_url": "https://picsum.photos/300/200?random=g11",
            "description": "鼠标瞄准射击小游戏！点击射击上升气球得分，金色气球高分，避开炸弹气球，限时90秒。",
            "category_id": 2, "game_type": "h5", "difficulty": "easy",
            "game_url": "/static/games/balloon-shoot.html",
            "tags": "射击,休闲,解压", "play_count": 7900, "score": 4.3, "sort": 11,
        },
        {
            "title": "国旗配对",
            "cover_url": "https://picsum.photos/300/200?random=g12",
            "description": "全球各国国旗记忆翻牌配对游戏！翻开两张相同国旗即可消除，简单4×4/困难5×5双模式，三星评分体系。",
            "category_id": 1, "game_type": "h5", "difficulty": "easy",
            "game_url": "/static/games/flag-match.html",
            "tags": "益智,记忆,国旗", "play_count": 6500, "score": 4.4, "sort": 12,
        },
        {
            "title": "跳棋",
            "cover_url": "https://picsum.photos/300/200?random=g13",
            "description": "经典六角跳棋网页版！支持双人对战，隔子跳跃、连续连跳，将所有棋子迁移至对角营地即获胜。",
            "category_id": 3, "game_type": "h5", "difficulty": "medium",
            "game_url": "/static/games/checkers.html",
            "tags": "棋牌,策略,双人", "play_count": 5200, "score": 4.3, "sort": 13,
        },
        {
            "title": "中国象棋",
            "cover_url": "https://picsum.photos/300/200?random=g14",
            "description": "标准国标中国象棋网页版！完整还原走棋逻辑、吃子规则，支持本地双人对战，合法点位高亮提示。",
            "category_id": 3, "game_type": "h5", "difficulty": "hard",
            "game_url": "/static/games/chinese-chess.html",
            "tags": "棋牌,象棋,策略", "play_count": 9800, "score": 4.7, "sort": 14,
        },
        {
            "title": "炸金花",
            "cover_url": "https://picsum.photos/300/200?random=g15",
            "description": "单机虚拟积分版炸金花！标准扑克牌型规则，跟注/加注/弃牌/比牌，纯娱乐无赌博。",
            "category_id": 3, "game_type": "h5", "difficulty": "medium",
            "game_url": "/static/games/zjh-poker.html",
            "tags": "棋牌,卡牌,休闲", "play_count": 11200, "score": 4.5, "sort": 15,
        },
    ]

    for g in games_data:
        game = EntGame(
            title=g["title"], cover_url=g["cover_url"], description=g["description"],
            category_id=g["category_id"], game_type=g["game_type"], game_url=g["game_url"],
            difficulty=g["difficulty"], tags=g["tags"], play_count=g["play_count"],
            score=g["score"], sort=g["sort"], is_free=1,
        )
        db.add(game)

    db.flush()
    print(f"  创建了 {len(games_data)} 个游戏")

    # ==================== 歌手数据 ====================
    print("正在创建歌手数据...")
    artists = [
        ("周杰伦", "华语", 2000000),
        ("林俊杰", "华语", 1500000),
        ("邓紫棋", "华语", 1200000),
        ("薛之谦", "华语", 1000000),
        ("陈奕迅", "港台", 1800000),
        ("Taylor Swift", "欧美", 3000000),
        ("五月天", "华语", 1600000),
        ("毛不易", "华语", 800000),
    ]
    for name, region, fans in artists:
        db.add(EntArtist(name=name, avatar_url=f"https://picsum.photos/200/200?random=a{artists.index((name, region, fans))}", region=region, fan_count=fans))
    db.flush()

    # ==================== 歌曲数据 ====================
    print("正在创建歌曲数据...")
    songs_data = [
        ("晴天", "周杰伦", 1, "流行", 269, 4500000, 4.9),
        ("七里香", "周杰伦", 1, "流行", 299, 3800000, 4.8),
        ("稻香", "周杰伦", 1, "流行", 223, 4200000, 4.9),
        ("夜曲", "周杰伦", 1, "流行", 235, 3600000, 4.7),
        ("修炼爱情", "林俊杰", 2, "流行", 270, 3200000, 4.8),
        ("可惜没如果", "林俊杰", 2, "流行", 298, 2800000, 4.7),
        ("江南", "林俊杰", 2, "流行", 265, 3500000, 4.8),
        ("泡沫", "邓紫棋", 3, "流行", 262, 2500000, 4.6),
        ("光年之外", "邓紫棋", 3, "流行", 235, 3100000, 4.7),
        ("演员", "薛之谦", 4, "流行", 290, 4100000, 4.8),
        ("认真的雪", "薛之谦", 4, "流行", 248, 2600000, 4.5),
        ("十年", "陈奕迅", 5, "流行", 208, 5200000, 4.9),
        ("浮夸", "陈奕迅", 5, "粤语", 282, 4800000, 4.8),
        ("富士山下", "陈奕迅", 5, "粤语", 264, 3900000, 4.7),
        ("Love Story", "Taylor Swift", 6, "流行", 235, 6100000, 4.8),
        ("Shake It Off", "Taylor Swift", 6, "流行", 219, 5500000, 4.7),
        ("倔强", "五月天", 7, "摇滚", 275, 4300000, 4.9),
        ("知足", "五月天", 7, "摇滚", 302, 3800000, 4.8),
        ("突然好想你", "五月天", 7, "摇滚", 326, 4600000, 4.9),
        ("像我这样的人", "毛不易", 8, "民谣", 268, 3200000, 4.7),
        ("消愁", "毛不易", 8, "民谣", 285, 2900000, 4.6),
        ("平凡之路", "朴树", 0, "民谣", 290, 5800000, 4.9),
        ("起风了", "买辣椒也用券", 0, "古风", 325, 4100000, 4.7),
        ("孤勇者", "陈奕迅", 5, "流行", 262, 6800000, 4.8),
    ]

    for i, (title, artist_name, artist_id, genre, duration, play_count, score) in enumerate(songs_data):
        db.add(EntSong(
            title=title, artist_name=artist_name, artist_id=artist_id,
            cover_url=f"https://picsum.photos/300/300?random=s{i+1}",
            audio_url="", duration=duration, genre=genre,
            play_count=play_count, score=score, is_free=1,
        ))

    db.flush()
    print(f"  创建了 {len(songs_data)} 首歌曲")

    # ==================== 歌单数据 ====================
    print("正在创建歌单数据...")
    playlists_data = [
        ("华语经典500首", "精选华语流行金曲，陪伴你的每一个日夜", "编辑推荐", "华语,经典,流行", 50, 1200000, 1),
        ("深夜民谣集", "一个人的夜晚，让民谣治愈你", "音乐编辑", "民谣,安静,夜晚", 30, 680000, 1),
        ("摇滚不死", "燃烧你的热血青春", "摇滚老炮", "摇滚,热血,青春", 40, 520000, 1),
        ("古风雅韵", "穿越千年的旋律", "古风达人", "古风,国风,中国风", 35, 450000, 1),
        ("欧美热单", "当下最火的欧美流行音乐", "环球音乐", "欧美,流行,热歌", 45, 890000, 1),
        ("运动健身BGM", "燃脂必备，运动更有动力", "健身达人", "运动,电子,节奏", 25, 320000, 1),
    ]
    for i, (title, desc, creator, tags, count, plays, rec) in enumerate(playlists_data):
        db.add(EntPlaylist(
            title=title, cover_url=f"https://picsum.photos/300/300?random=p{i+1}",
            description=desc, creator_name=creator, tags=tags,
            song_count=count, play_count=plays, is_recommend=rec,
        ))
    db.flush()
    print(f"  创建了 {len(playlists_data)} 个歌单")

    # ==================== 视频数据 ====================
    print("正在创建视频数据...")
    videos_data = [
        {
            "title": "流浪地球2", "video_type": "movie", "region": "大陆",
            "year": "2023", "director": "郭帆", "actors": "吴京,刘德华,李雪健",
            "tags": "科幻,灾难,冒险", "episode_count": 1, "play_count": 8900000,
            "score": 9.3, "is_hot": 1,
            "description": "太阳即将毁灭，人类在地球表面建造出巨大的推进器，寻找新的家园。然而宇宙之路危机四伏，为了拯救地球，流浪地球时代的年轻人再次挺身而出，展开争分夺秒的生死之战。",
        },
        {
            "title": "三体", "video_type": "series", "region": "大陆",
            "year": "2023", "director": "杨磊", "actors": "张鲁一,于和伟,陈瑾",
            "tags": "科幻,悬疑,剧情", "episode_count": 30, "play_count": 12000000,
            "score": 8.7, "is_hot": 1,
            "description": "纳米材料学家汪淼被警官史强带到联合作战中心，得知地球基础科学出现了异常扰动，科学界人心惶惶。",
        },
        {
            "title": "繁花", "video_type": "series", "region": "大陆",
            "year": "2024", "director": "王家卫", "actors": "胡歌,马伊琍,唐嫣",
            "tags": "年代,剧情,商战", "episode_count": 30, "play_count": 15000000,
            "score": 8.9, "is_hot": 1, "is_new": 1,
            "description": "九十年代的上海，阿宝在时代的浪潮中抓住机遇，凭借出色的商业头脑和不懈的努力，成为了商界的后起之秀。",
        },
        {
            "title": "庆余年2", "video_type": "series", "region": "大陆",
            "year": "2024", "director": "孙皓", "actors": "张若昀,李沁,陈道明",
            "tags": "古装,权谋,喜剧", "episode_count": 36, "play_count": 18000000,
            "score": 8.5, "is_new": 1,
            "description": "范闲在经历种种磨难后，终于回到了京都。他将面临更加复杂的政治斗争和更加危险的敌人。",
        },
        {
            "title": "铃芽之旅", "video_type": "anime", "region": "日本",
            "year": "2023", "director": "新海诚", "actors": "原菜乃华,松村北斗",
            "tags": "动画,奇幻,冒险", "episode_count": 1, "play_count": 6500000,
            "score": 8.6,
            "description": "少女铃芽在偶遇神秘青年草太后，踏上了关闭灾难之门的旅程。在旅途中，她逐渐了解了关于自己和这片土地的秘密。",
        },
        {
            "title": "星际穿越", "video_type": "movie", "region": "欧美",
            "year": "2014", "director": "克里斯托弗·诺兰", "actors": "马修·麦康纳,安妮·海瑟薇",
            "tags": "科幻,冒险,剧情", "episode_count": 1, "play_count": 12000000,
            "score": 9.4,
            "description": "在不远的未来，地球气候急剧变化，农作物相继枯萎。前NASA宇航员库珀为拯救人类，穿越虫洞寻找新家园。",
        },
        {
            "title": "鬼灭之刃", "video_type": "anime", "region": "日本",
            "year": "2019", "director": "外崎春雄", "actors": "花江夏树,的場光昭",
            "tags": "动画,热血,战斗", "episode_count": 26, "play_count": 9800000,
            "score": 9.1,
            "description": "卖炭少年炭治郎的家人被鬼杀害，唯一幸存的妹妹祢豆子也变成了鬼。为了寻找让妹妹变回人类的方法，炭治郎踏上了斩鬼之路。",
        },
        {
            "title": "国家地理纪录片", "video_type": "documentary", "region": "欧美",
            "year": "2024", "director": "", "actors": "",
            "tags": "自然,探索,科学", "episode_count": 12, "play_count": 3200000,
            "score": 9.0,
            "description": "国家地理出品的年度自然纪录片，探索地球上最壮观的自然景观和最神奇的生物。",
        },
    ]

    for i, v in enumerate(videos_data):
        db.add(EntVideo(
            title=v["title"], video_type=v["video_type"], region=v["region"],
            year=v["year"], director=v.get("director", ""), actors=v.get("actors", ""),
            tags=v["tags"], episode_count=v["episode_count"], play_count=v["play_count"],
            score=v["score"], is_hot=v.get("is_hot", 0), is_new=v.get("is_new", 0),
            cover_url=f"https://picsum.photos/300/400?random=v{i+1}",
            description=v.get("description", ""),
        ))

    db.flush()

    # 为电视剧添加分集
    for v in videos_data:
        if v["episode_count"] > 1:
            video = db.query(EntVideo).filter(EntVideo.title == v["title"]).first()
            if video:
                for ep in range(1, min(v["episode_count"] + 1, 6)):  # 只创建前5集示例
                    db.add(EntVideoEpisode(
                        video_id=video.id, episode_num=ep,
                        title=f"第{ep}集",
                        video_url=f"https://example.com/video/{video.id}/ep{ep}.mp4",
                    ))

    db.flush()
    print(f"  创建了 {len(videos_data)} 个视频")

    # ==================== 小说数据 ====================
    print("正在创建小说数据...")
    novels_data = [
        {
            "title": "斗破苍穹", "author": "天蚕土豆", "genre": "玄幻",
            "gender": "male", "word_count": 5300000, "chapter_count": 1648,
            "status_text": "完本", "tags": "玄幻,热血,升级", "read_count": 28000000,
            "score": 8.8, "is_recommend": 1,
            "description": "三十年河东，三十年河西，莫欺少年穷！年仅15岁的萧炎，创造了家族空前绝后的修炼纪录。然而在这位少年的眼中，这仅仅只是一个开始。",
            "last_chapter": "第一千六百四十八章 结束，也是开始",
        },
        {
            "title": "完美世界", "author": "辰东", "genre": "玄幻",
            "gender": "male", "word_count": 5800000, "chapter_count": 2016,
            "status_text": "完本", "tags": "玄幻,热血,大帝", "read_count": 22000000,
            "score": 8.7, "is_recommend": 1,
            "description": "一粒尘可填海，一根草斩尽日月星辰。天地间，一位少年从石村走出，一切从这里开始。",
        },
        {
            "title": "全职高手", "author": "蝴蝶蓝", "genre": "都市",
            "gender": "male", "word_count": 3200000, "chapter_count": 1728,
            "status_text": "完本", "tags": "游戏,电竞,热血", "read_count": 18000000,
            "score": 9.0, "is_recommend": 1,
            "description": "网游荣耀中被誉为教科书级别的顶尖高手叶修，因为种种原因遭到俱乐部的驱逐。离开职业圈的他，在一家网吧成了一个小小的网管。",
        },
        {
            "title": "盗墓笔记", "author": "南派三叔", "genre": "悬疑",
            "gender": "male", "word_count": 4500000, "chapter_count": 980,
            "status_text": "完本", "tags": "悬疑,探险,古墓", "read_count": 25000000,
            "score": 8.9,
            "description": "五十年前，一群长沙土夫子挖到了一部战国帛书，记载了一个奇特战国古墓的位置。五十年后，其中一个土夫子的孙子在他的笔记中发现了这个秘密。",
        },
        {
            "title": "诛仙", "author": "萧鼎", "genre": "仙侠",
            "gender": "male", "word_count": 2800000, "chapter_count": 465,
            "status_text": "完本", "tags": "仙侠,经典,情感", "read_count": 20000000,
            "score": 8.6,
            "description": "天地不仁，以万物为刍狗。一个普通的少年，机缘巧合之下卷入了正邪两道的纷争之中，踏上了修真之路。",
        },
        {
            "title": "微微一笑很倾城", "author": "顾漫", "genre": "言情",
            "gender": "female", "word_count": 580000, "chapter_count": 186,
            "status_text": "完本", "tags": "言情,游戏,甜宠", "read_count": 15000000,
            "score": 8.3,
            "description": "计算机系学霸贝微微在游戏中结识了校草大神肖奈，两人从游戏中的搭档发展到现实中的恋人。",
        },
        {
            "title": "诡秘之主", "author": "爱潜水的乌贼", "genre": "玄幻",
            "gender": "male", "word_count": 4200000, "chapter_count": 1432,
            "status_text": "完本", "tags": "西幻,克苏鲁,神秘", "read_count": 16000000,
            "score": 9.2, "is_recommend": 1,
            "description": "蒸汽与机械的浪潮中，谁能触及非凡？历史和黑暗的迷雾里，又是谁在窥视？我从诡秘中醒来，步入这个不一样的世界。",
        },
        {
            "title": "雪中悍刀行", "author": "烽火戏诸侯", "genre": "仙侠",
            "gender": "male", "word_count": 4500000, "chapter_count": 1120,
            "status_text": "完本", "tags": "武侠,权谋,热血", "read_count": 14000000,
            "score": 8.5,
            "description": "北凉世子徐凤年，不愿做那笼中雀、井底蛙，他手持一柄木刀，行走于江湖庙堂之间，终成一代大侠。",
        },
        {
            "title": "大奉打更人", "author": "卖报小郎君", "genre": "玄幻",
            "gender": "male", "word_count": 5100000, "chapter_count": 1580,
            "status_text": "完本", "tags": "穿越,探案,爽文", "read_count": 19000000,
            "score": 8.8, "is_recommend": 1,
            "description": "这个世界有儒释道三教，有妖族和巫族。许七安穿越而来，从一个小人物逐步成长为举世瞩目的强者。",
        },
        {
            "title": "长月烬明", "author": "藤萍", "genre": "言情",
            "gender": "female", "word_count": 720000, "chapter_count": 210,
            "status_text": "完本", "tags": "仙侠,言情,虐恋", "read_count": 12000000,
            "score": 8.1, "is_new": 1,
            "description": "为了拯救被魔神澹台烬毁灭的世界，黎苏苏回到五百年前，化身为叶夕雾，试图阻止澹台烬的黑化之路。",
        },
        {
            "title": "赘婿", "author": "愤怒的香蕉", "genre": "历史",
            "gender": "male", "word_count": 4800000, "chapter_count": 1150,
            "status_text": "连载中", "tags": "穿越,商战,历史", "read_count": 11000000,
            "score": 8.4,
            "description": "现代金融界巨头宁毅穿越到古代，成为苏家的赘婿。凭借现代知识和商业头脑，在古代社会掀起了一场商业革命。",
            "last_chapter": "第一千一百五十章 风云再起",
        },
        {
            "title": "知否知否应是绿肥红瘦", "author": "关心则乱", "genre": "言情",
            "gender": "female", "word_count": 2100000, "chapter_count": 680,
            "status_text": "完本", "tags": "宅斗,言情,古代", "read_count": 13000000,
            "score": 8.6,
            "description": "穿越到古代的盛明兰，从一个庶女成长为当家主母的故事。宅斗权谋，家长里短，一个古代女子的奋斗史。",
        },
    ]

    for i, n in enumerate(novels_data):
        novel = EntNovel(
            title=n["title"], author=n["author"], genre=n["genre"],
            gender=n["gender"], word_count=n["word_count"], chapter_count=n["chapter_count"],
            status_text=n["status_text"], tags=n["tags"], read_count=n["read_count"],
            score=n["score"], last_chapter=n.get("last_chapter", ""),
            cover_url=f"https://picsum.photos/200/280?random=n{i+1}",
            description=n["description"],
            is_recommend=n.get("is_recommend", 0), is_new=n.get("is_new", 0),
        )
        db.add(novel)

    db.flush()

    # 为部分小说添加示例章节
    sample_novels = db.query(EntNovel).limit(3).all()
    for novel in sample_novels:
        # 添加卷
        vol = EntNovelVolume(novel_id=novel.id, title="第一卷 初出茅庐", sort=1)
        db.add(vol)
        db.flush()

        # 添加5个示例章节
        for ch_num in range(1, 6):
            content = f"这是《{novel.title}》第{ch_num}章的示例内容。\n\n"
            content += f"  {novel.author}创作的这部作品，讲述了一个精彩的故事。\n\n"
            content += "  在这个充满奇幻色彩的世界里，主人公经历了种种磨难和挑战。\n\n"
            content += "  他凭借着过人的智慧和坚韧的意志，一步步克服困难，最终实现了自己的目标。\n\n"
            content += "  这段旅程充满了欢笑与泪水，也让他收获了珍贵的友情和爱情。\n\n"
            content += "  （以上为示例内容，实际内容需要根据完整文本来填充）"

            db.add(EntNovelChapter(
                novel_id=novel.id, volume_id=vol.id,
                chapter_num=ch_num, title=f"第{ch_num}章 开始的旅程",
                content=content, word_count=len(content),
            ))

    db.flush()
    print(f"  创建了 {len(novels_data)} 部小说（含示例章节）")

    # ==================== 提交 ====================
    db.commit()
    print("\n✅ 娱乐中心初始化数据创建完成！")
    print(f"   - 分类: {len(game_categories) + len(music_categories) + len(video_categories) + len(novel_categories)} 个")
    print(f"   - 轮播图: {len(banners_data)} 个")
    print(f"   - 游戏: {len(games_data)} 个")
    print(f"   - 歌手: {len(artists)} 位")
    print(f"   - 歌曲: {len(songs_data)} 首")
    print(f"   - 歌单: {len(playlists_data)} 个")
    print(f"   - 视频: {len(videos_data)} 部")
    print(f"   - 小说: {len(novels_data)} 部")

except Exception as e:
    db.rollback()
    print(f"❌ 初始化失败: {e}")
    import traceback
    traceback.print_exc()
finally:
    db.close()