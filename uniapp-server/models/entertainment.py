"""娱乐中心数据模型"""
from datetime import datetime
from sqlalchemy import Column, Integer, String, Float, Text, DateTime, SmallInteger, BigInteger, UniqueConstraint
from sqlalchemy.sql import func
from database import Base


# ==================== 公共模型 ====================

class EntCategory(Base):
    """娱乐分类表"""
    __tablename__ = "ent_category"

    id = Column(Integer, primary_key=True, autoincrement=True, comment="分类ID")
    parent_id = Column(Integer, default=0, comment="父分类ID,0为顶级")
    name = Column(String(50), nullable=False, comment="分类名称")
    type = Column(String(20), nullable=False, index=True, comment="类型: game/music/video/novel")
    icon = Column(String(255), default="", comment="分类图标")
    sort = Column(Integer, default=0, comment="排序")
    status = Column(SmallInteger, default=1, comment="状态(0禁用/1启用)")
    created_at = Column(DateTime, default=datetime.now, comment="创建时间")


class EntBanner(Base):
    """轮播图/运营位"""
    __tablename__ = "ent_banner"

    id = Column(Integer, primary_key=True, autoincrement=True, comment="ID")
    title = Column(String(100), default="", comment="标题")
    image_url = Column(String(500), nullable=False, comment="图片URL")
    link_type = Column(String(20), default="url", comment="链接类型: url/game/music/video/novel")
    link_value = Column(String(500), default="", comment="链接值")
    position = Column(String(20), nullable=False, index=True, comment="位置: game/music/video/novel/home")
    sort = Column(Integer, default=0, comment="排序")
    status = Column(SmallInteger, default=1, comment="状态(0禁用/1启用)")
    created_at = Column(DateTime, default=datetime.now, comment="创建时间")


class EntFavorite(Base):
    """统一收藏表"""
    __tablename__ = "ent_favorite"
    __table_args__ = (
        UniqueConstraint("user_id", "content_type", "content_id", name="uq_user_content_fav"),
    )

    id = Column(Integer, primary_key=True, autoincrement=True, comment="ID")
    user_id = Column(Integer, nullable=False, index=True, comment="用户ID")
    content_type = Column(String(20), nullable=False, comment="内容类型: game/music/video/novel")
    content_id = Column(Integer, nullable=False, comment="内容ID")
    created_at = Column(DateTime, default=datetime.now, comment="收藏时间")


class EntHistory(Base):
    """统一历史记录表"""
    __tablename__ = "ent_history"
    __table_args__ = (
        UniqueConstraint("user_id", "content_type", "content_id", name="uq_user_content_hist"),
    )

    id = Column(Integer, primary_key=True, autoincrement=True, comment="ID")
    user_id = Column(Integer, nullable=False, index=True, comment="用户ID")
    content_type = Column(String(20), nullable=False, comment="内容类型: game/music/video/novel")
    content_id = Column(Integer, nullable=False, comment="内容ID")
    progress = Column(String(50), default="", comment="进度信息(如小说章节/视频时间点)")
    extra_json = Column(Text, default="", comment="扩展JSON数据")
    last_at = Column(DateTime, default=datetime.now, onupdate=datetime.now, comment="最后访问时间")


# ==================== 游戏中心 ====================

class EntGame(Base):
    """游戏表"""
    __tablename__ = "ent_game"

    id = Column(Integer, primary_key=True, autoincrement=True, comment="游戏ID")
    title = Column(String(100), nullable=False, index=True, comment="游戏名称")
    cover_url = Column(String(500), default="", comment="封面图URL")
    description = Column(Text, default="", comment="游戏简介")
    category_id = Column(Integer, default=0, index=True, comment="分类ID")
    game_type = Column(String(20), default="h5", comment="游戏类型: h5/iframe/embed")
    game_url = Column(String(500), default="", comment="游戏地址/嵌入URL")
    difficulty = Column(String(20), default="easy", comment="难度: easy/medium/hard")
    is_free = Column(SmallInteger, default=1, comment="是否免费 1是0否")
    tags = Column(String(300), default="", comment="标签,逗号分隔")
    play_count = Column(Integer, default=0, comment="游玩次数")
    score = Column(Float, default=0, comment="评分")
    score_count = Column(Integer, default=0, comment="评分人数")
    sort = Column(Integer, default=0, comment="排序")
    status = Column(SmallInteger, default=1, comment="状态(0下架/1上架)")
    created_at = Column(DateTime, default=datetime.now, comment="创建时间")
    updated_at = Column(DateTime, default=datetime.now, onupdate=datetime.now, comment="更新时间")


class EntGameScreenshot(Base):
    """游戏截图表"""
    __tablename__ = "ent_game_screenshot"

    id = Column(Integer, primary_key=True, autoincrement=True, comment="ID")
    game_id = Column(Integer, nullable=False, index=True, comment="游戏ID")
    url = Column(String(500), nullable=False, comment="截图URL")
    sort = Column(Integer, default=0, comment="排序")
    created_at = Column(DateTime, default=datetime.now, comment="创建时间")


class EntGamePlayRecord(Base):
    """游戏游玩记录表"""
    __tablename__ = "ent_game_play_record"

    id = Column(Integer, primary_key=True, autoincrement=True, comment="ID")
    user_id = Column(Integer, nullable=False, index=True, comment="用户ID")
    game_id = Column(Integer, nullable=False, index=True, comment="游戏ID")
    session_id = Column(String(50), default="", comment="会话ID")
    start_at = Column(DateTime, default=datetime.now, comment="开始时间")
    end_at = Column(DateTime, nullable=True, comment="结束时间")
    duration_sec = Column(Integer, default=0, comment="游玩时长(秒)")
    created_at = Column(DateTime, default=datetime.now, comment="创建时间")


# ==================== 音乐中心 ====================

class EntArtist(Base):
    """歌手表"""
    __tablename__ = "ent_artist"

    id = Column(Integer, primary_key=True, autoincrement=True, comment="歌手ID")
    name = Column(String(100), nullable=False, index=True, comment="歌手名称")
    avatar_url = Column(String(500), default="", comment="头像URL")
    description = Column(Text, default="", comment="歌手简介")
    region = Column(String(50), default="", comment="地区: 内地/港台/海外/欧美/日韩")
    song_count = Column(Integer, default=0, comment="歌曲数")
    fan_count = Column(Integer, default=0, comment="粉丝数")
    status = Column(SmallInteger, default=1, comment="状态")
    created_at = Column(DateTime, default=datetime.now, comment="创建时间")


class EntAlbum(Base):
    """专辑表"""
    __tablename__ = "ent_album"

    id = Column(Integer, primary_key=True, autoincrement=True, comment="专辑ID")
    title = Column(String(200), nullable=False, comment="专辑名称")
    artist_id = Column(Integer, default=0, index=True, comment="歌手ID")
    cover_url = Column(String(500), default="", comment="封面URL")
    description = Column(Text, default="", comment="专辑简介")
    release_date = Column(String(20), default="", comment="发行日期")
    song_count = Column(Integer, default=0, comment="歌曲数")
    play_count = Column(BigInteger, default=0, comment="播放量")
    status = Column(SmallInteger, default=1, comment="状态")
    created_at = Column(DateTime, default=datetime.now, comment="创建时间")


class EntSong(Base):
    """歌曲表"""
    __tablename__ = "ent_song"

    id = Column(Integer, primary_key=True, autoincrement=True, comment="歌曲ID")
    title = Column(String(200), nullable=False, index=True, comment="歌曲名称")
    artist_id = Column(Integer, default=0, index=True, comment="歌手ID")
    artist_name = Column(String(100), default="", comment="歌手名称(冗余)")
    album_id = Column(Integer, default=0, comment="专辑ID")
    cover_url = Column(String(500), default="", comment="封面URL")
    audio_url = Column(String(500), default="", comment="音频URL")
    lyrics = Column(Text, default="", comment="歌词(LRC格式)")
    duration = Column(Integer, default=0, comment="时长(秒)")
    genre = Column(String(50), default="", comment="曲风: 流行/摇滚/古风/民谣/电子/经典/纯音乐")
    language = Column(String(20), default="华语", comment="语种")
    is_free = Column(SmallInteger, default=1, comment="是否免费 1是0否")
    play_count = Column(BigInteger, default=0, comment="播放量")
    score = Column(Float, default=0, comment="评分")
    status = Column(SmallInteger, default=1, comment="状态")
    sort = Column(Integer, default=0, comment="排序")
    created_at = Column(DateTime, default=datetime.now, comment="创建时间")
    updated_at = Column(DateTime, default=datetime.now, onupdate=datetime.now, comment="更新时间")


class EntPlaylist(Base):
    """歌单表"""
    __tablename__ = "ent_playlist"

    id = Column(Integer, primary_key=True, autoincrement=True, comment="歌单ID")
    title = Column(String(200), nullable=False, comment="歌单名称")
    cover_url = Column(String(500), default="", comment="封面URL")
    description = Column(Text, default="", comment="歌单简介")
    creator_name = Column(String(50), default="", comment="创建者名称")
    creator_id = Column(Integer, default=0, comment="创建者ID")
    tags = Column(String(200), default="", comment="标签,逗号分隔")
    song_count = Column(Integer, default=0, comment="歌曲数")
    play_count = Column(BigInteger, default=0, comment="播放量")
    is_recommend = Column(SmallInteger, default=0, comment="是否推荐")
    status = Column(SmallInteger, default=1, comment="状态")
    sort = Column(Integer, default=0, comment="排序")
    created_at = Column(DateTime, default=datetime.now, comment="创建时间")
    updated_at = Column(DateTime, default=datetime.now, onupdate=datetime.now, comment="更新时间")


class EntPlaylistSong(Base):
    """歌单-歌曲关联表"""
    __tablename__ = "ent_playlist_song"

    id = Column(Integer, primary_key=True, autoincrement=True, comment="ID")
    playlist_id = Column(Integer, nullable=False, index=True, comment="歌单ID")
    song_id = Column(Integer, nullable=False, comment="歌曲ID")
    sort = Column(Integer, default=0, comment="排序")
    added_at = Column(DateTime, default=datetime.now, comment="添加时间")


class EntSongPlayRecord(Base):
    """歌曲播放记录表"""
    __tablename__ = "ent_song_play_record"

    id = Column(Integer, primary_key=True, autoincrement=True, comment="ID")
    user_id = Column(Integer, nullable=False, index=True, comment="用户ID")
    song_id = Column(Integer, nullable=False, index=True, comment="歌曲ID")
    play_duration = Column(Integer, default=0, comment="播放时长(秒)")
    created_at = Column(DateTime, default=datetime.now, comment="播放时间")


# ==================== 视频影音 ====================

class EntVideo(Base):
    """视频/影视表"""
    __tablename__ = "ent_video"

    id = Column(Integer, primary_key=True, autoincrement=True, comment="视频ID")
    title = Column(String(200), nullable=False, index=True, comment="标题")
    cover_url = Column(String(500), default="", comment="封面URL")
    description = Column(Text, default="", comment="简介")
    category_id = Column(Integer, default=0, index=True, comment="分类ID")
    video_type = Column(String(20), default="movie", comment="类型: movie/series/variety/anime/documentary/short")
    region = Column(String(50), default="", comment="地区")
    year = Column(String(10), default="", comment="年份")
    director = Column(String(100), default="", comment="导演")
    actors = Column(String(500), default="", comment="演员,逗号分隔")
    tags = Column(String(300), default="", comment="标签,逗号分隔")
    episode_count = Column(Integer, default=1, comment="总集数")
    status_text = Column(String(20), default="完结", comment="状态: 完结/连载中")
    is_free = Column(SmallInteger, default=1, comment="是否免费")
    play_count = Column(BigInteger, default=0, comment="播放量")
    score = Column(Float, default=0, comment="评分")
    score_count = Column(Integer, default=0, comment="评分人数")
    is_hot = Column(SmallInteger, default=0, comment="是否热播")
    is_new = Column(SmallInteger, default=0, comment="是否上新")
    sort = Column(Integer, default=0, comment="排序")
    status = Column(SmallInteger, default=1, comment="状态(0下架/1上架)")
    created_at = Column(DateTime, default=datetime.now, comment="创建时间")
    updated_at = Column(DateTime, default=datetime.now, onupdate=datetime.now, comment="更新时间")


class EntVideoEpisode(Base):
    """视频分集表"""
    __tablename__ = "ent_video_episode"

    id = Column(Integer, primary_key=True, autoincrement=True, comment="ID")
    video_id = Column(Integer, nullable=False, index=True, comment="视频ID")
    episode_num = Column(Integer, default=1, comment="集数")
    title = Column(String(200), default="", comment="分集标题")
    cover_url = Column(String(500), default="", comment="分集封面")
    video_url = Column(String(500), default="", comment="视频URL")
    duration = Column(Integer, default=0, comment="时长(秒)")
    is_free = Column(SmallInteger, default=1, comment="是否免费")
    status = Column(SmallInteger, default=1, comment="状态")
    created_at = Column(DateTime, default=datetime.now, comment="创建时间")


class EntVideoPlayRecord(Base):
    """视频播放记录表"""
    __tablename__ = "ent_video_play_record"

    id = Column(Integer, primary_key=True, autoincrement=True, comment="ID")
    user_id = Column(Integer, nullable=False, index=True, comment="用户ID")
    video_id = Column(Integer, nullable=False, index=True, comment="视频ID")
    episode_id = Column(Integer, default=0, comment="分集ID")
    episode_num = Column(Integer, default=1, comment="播放到第几集")
    progress_sec = Column(Integer, default=0, comment="播放进度(秒)")
    created_at = Column(DateTime, default=datetime.now, comment="记录时间")
    updated_at = Column(DateTime, default=datetime.now, onupdate=datetime.now, comment="更新时间")


# ==================== 网络小说 ====================

class EntNovel(Base):
    """小说表"""
    __tablename__ = "ent_novel"

    id = Column(Integer, primary_key=True, autoincrement=True, comment="小说ID")
    title = Column(String(200), nullable=False, index=True, comment="书名")
    author = Column(String(100), default="", comment="作者")
    cover_url = Column(String(500), default="", comment="封面URL")
    description = Column(Text, default="", comment="简介")
    category_id = Column(Integer, default=0, index=True, comment="分类ID")
    genre = Column(String(50), default="", comment="类型: 玄幻/仙侠/都市/言情/悬疑/历史/科幻/短篇")
    gender = Column(String(10), default="male", comment="频道: male/female")
    word_count = Column(BigInteger, default=0, comment="总字数")
    chapter_count = Column(Integer, default=0, comment="总章节数")
    status_text = Column(String(20), default="连载中", comment="状态: 连载中/完本")
    tags = Column(String(300), default="", comment="标签,逗号分隔")
    is_free = Column(SmallInteger, default=1, comment="是否免费")
    is_vip = Column(SmallInteger, default=0, comment="是否VIP")
    read_count = Column(BigInteger, default=0, comment="阅读量")
    score = Column(Float, default=0, comment="评分")
    score_count = Column(Integer, default=0, comment="评分人数")
    last_chapter = Column(String(200), default="", comment="最新章节名")
    last_update = Column(DateTime, nullable=True, comment="最后更新时间")
    is_recommend = Column(SmallInteger, default=0, comment="是否推荐")
    is_new = Column(SmallInteger, default=0, comment="是否上新")
    sort = Column(Integer, default=0, comment="排序")
    status = Column(SmallInteger, default=1, comment="状态(0下架/1上架)")
    created_at = Column(DateTime, default=datetime.now, comment="创建时间")
    updated_at = Column(DateTime, default=datetime.now, onupdate=datetime.now, comment="更新时间")


class EntNovelVolume(Base):
    """小说卷表"""
    __tablename__ = "ent_novel_volume"

    id = Column(Integer, primary_key=True, autoincrement=True, comment="ID")
    novel_id = Column(Integer, nullable=False, index=True, comment="小说ID")
    title = Column(String(200), default="", comment="卷名")
    sort = Column(Integer, default=0, comment="排序")
    created_at = Column(DateTime, default=datetime.now, comment="创建时间")


class EntNovelChapter(Base):
    """小说章节表"""
    __tablename__ = "ent_novel_chapter"

    id = Column(Integer, primary_key=True, autoincrement=True, comment="章节ID")
    novel_id = Column(Integer, nullable=False, index=True, comment="小说ID")
    volume_id = Column(Integer, default=0, comment="卷ID")
    chapter_num = Column(Integer, default=1, comment="章节序号")
    title = Column(String(200), default="", comment="章节标题")
    content = Column(Text, default="", comment="章节内容")
    word_count = Column(Integer, default=0, comment="字数")
    is_free = Column(SmallInteger, default=1, comment="是否免费")
    is_vip = Column(SmallInteger, default=0, comment="是否VIP章节")
    status = Column(SmallInteger, default=1, comment="状态")
    created_at = Column(DateTime, default=datetime.now, comment="创建时间")


class EntNovelReadRecord(Base):
    """小说阅读记录表"""
    __tablename__ = "ent_novel_read_record"

    id = Column(Integer, primary_key=True, autoincrement=True, comment="ID")
    user_id = Column(Integer, nullable=False, index=True, comment="用户ID")
    novel_id = Column(Integer, nullable=False, index=True, comment="小说ID")
    chapter_id = Column(Integer, default=0, comment="当前章节ID")
    chapter_num = Column(Integer, default=1, comment="当前章节序号")
    progress = Column(Float, default=0, comment="章节内阅读进度(0-1)")
    created_at = Column(DateTime, default=datetime.now, comment="记录时间")
    updated_at = Column(DateTime, default=datetime.now, onupdate=datetime.now, comment="更新时间")