"""娱乐中心数据模型（Pydantic Schemas）"""
from datetime import datetime
from typing import Optional, List
from pydantic import BaseModel


# ==================== 公共 ====================

class CategoryItem(BaseModel):
    """分类项"""
    id: int
    parent_id: int = 0
    name: str
    type: str
    icon: str = ""
    sort: int = 0
    status: int = 1

    class Config:
        from_attributes = True


class BannerItem(BaseModel):
    """轮播图项"""
    id: int
    title: str = ""
    image_url: str
    link_type: str = "url"
    link_value: str = ""
    position: str

    class Config:
        from_attributes = True


class PageRequest(BaseModel):
    """分页请求"""
    page: int = 1
    page_size: int = 20
    keyword: Optional[str] = None
    category_id: Optional[int] = None
    sort_by: Optional[str] = "created_at"
    sort_order: Optional[str] = "desc"


class FavoriteRequest(BaseModel):
    """收藏请求"""
    content_type: str  # game/music/video/novel
    content_id: int


# ==================== 游戏中心 ====================

class GameListItem(BaseModel):
    """游戏列表项"""
    id: int
    title: str
    cover_url: str = ""
    description: str = ""
    category_id: int = 0
    game_type: str = "h5"
    game_url: str = ""
    difficulty: str = "easy"
    is_free: int = 1
    tags: str = ""
    play_count: int = 0
    score: float = 0

    class Config:
        from_attributes = True


class GameDetail(BaseModel):
    """游戏详情"""
    id: int
    title: str
    cover_url: str = ""
    description: str = ""
    category_id: int = 0
    game_type: str = "h5"
    game_url: str = ""
    difficulty: str = "easy"
    is_free: int = 1
    tags: str = ""
    play_count: int = 0
    score: float = 0
    score_count: int = 0
    screenshots: List[str] = []
    category_name: str = ""
    is_favorited: bool = False

    class Config:
        from_attributes = True


class GamePlayStartRequest(BaseModel):
    """开始游戏请求"""
    pass


class GamePlayEndRequest(BaseModel):
    """结束游戏请求"""
    session_id: str = ""
    duration_sec: int = 0


class GameHomeData(BaseModel):
    """游戏首页数据"""
    banners: List[BannerItem] = []
    recommend: List[GameListItem] = []
    hot: List[GameListItem] = []
    new: List[GameListItem] = []
    categories: List[CategoryItem] = []


# ==================== 音乐中心 ====================

class SongItem(BaseModel):
    """歌曲列表项"""
    id: int
    title: str
    artist_name: str = ""
    artist_id: int = 0
    album_id: int = 0
    cover_url: str = ""
    audio_url: str = ""
    duration: int = 0
    genre: str = ""
    language: str = "华语"
    is_free: int = 1
    play_count: int = 0
    score: float = 0

    class Config:
        from_attributes = True


class SongDetail(SongItem):
    """歌曲详情"""
    lyrics: str = ""
    is_favorited: bool = False


class PlaylistItem(BaseModel):
    """歌单列表项"""
    id: int
    title: str
    cover_url: str = ""
    description: str = ""
    creator_name: str = ""
    tags: str = ""
    song_count: int = 0
    play_count: int = 0

    class Config:
        from_attributes = True


class PlaylistDetail(PlaylistItem):
    """歌单详情"""
    songs: List[SongItem] = []


class ArtistItem(BaseModel):
    """歌手列表项"""
    id: int
    name: str
    avatar_url: str = ""
    description: str = ""
    region: str = ""
    song_count: int = 0
    fan_count: int = 0

    class Config:
        from_attributes = True


class MusicHomeData(BaseModel):
    """音乐首页数据"""
    banners: List[BannerItem] = []
    recommend_playlists: List[PlaylistItem] = []
    hot_songs: List[SongItem] = []
    new_songs: List[SongItem] = []
    categories: List[CategoryItem] = []


# ==================== 视频影音 ====================

class VideoListItem(BaseModel):
    """视频列表项"""
    id: int
    title: str
    cover_url: str = ""
    description: str = ""
    category_id: int = 0
    video_type: str = "movie"
    region: str = ""
    year: str = ""
    actors: str = ""
    tags: str = ""
    episode_count: int = 1
    status_text: str = "完结"
    is_free: int = 1
    play_count: int = 0
    score: float = 0

    class Config:
        from_attributes = True


class VideoEpisodeItem(BaseModel):
    """视频分集项"""
    id: int
    video_id: int
    episode_num: int = 1
    title: str = ""
    cover_url: str = ""
    video_url: str = ""
    duration: int = 0
    is_free: int = 1

    class Config:
        from_attributes = True


class VideoDetail(VideoListItem):
    """视频详情"""
    director: str = ""
    episodes: List[VideoEpisodeItem] = []
    is_favorited: bool = False
    watch_progress: Optional[dict] = None


class VideoHomeData(BaseModel):
    """视频首页数据"""
    banners: List[BannerItem] = []
    hot: List[VideoListItem] = []
    new: List[VideoListItem] = []
    anime: List[VideoListItem] = []
    categories: List[CategoryItem] = []


class VideoProgressRequest(BaseModel):
    """视频播放进度上报"""
    video_id: int
    episode_id: int = 0
    episode_num: int = 1
    progress_sec: int = 0


# ==================== 网络小说 ====================

class NovelListItem(BaseModel):
    """小说列表项"""
    id: int
    title: str
    author: str = ""
    cover_url: str = ""
    description: str = ""
    category_id: int = 0
    genre: str = ""
    gender: str = "male"
    word_count: int = 0
    chapter_count: int = 0
    status_text: str = "连载中"
    tags: str = ""
    is_free: int = 1
    read_count: int = 0
    score: float = 0
    last_chapter: str = ""

    class Config:
        from_attributes = True


class NovelChapterItem(BaseModel):
    """小说章节列表项"""
    id: int
    novel_id: int
    volume_id: int = 0
    chapter_num: int = 1
    title: str = ""
    word_count: int = 0
    is_free: int = 1
    is_vip: int = 0

    class Config:
        from_attributes = True


class NovelChapterContent(BaseModel):
    """小说章节内容"""
    id: int
    novel_id: int
    chapter_num: int = 1
    title: str = ""
    content: str = ""
    word_count: int = 0
    prev_id: Optional[int] = None
    next_id: Optional[int] = None
    prev_title: str = ""
    next_title: str = ""


class NovelDetail(NovelListItem):
    """小说详情"""
    chapters: List[NovelChapterItem] = []
    is_favorited: bool = False
    read_progress: Optional[dict] = None


class NovelHomeData(BaseModel):
    """小说首页数据"""
    banners: List[BannerItem] = []
    recommend: List[NovelListItem] = []
    hot: List[NovelListItem] = []
    new: List[NovelListItem] = []
    categories: List[CategoryItem] = []


class NovelReadProgressRequest(BaseModel):
    """小说阅读进度上报"""
    novel_id: int
    chapter_id: int = 0
    chapter_num: int = 1
    progress: float = 0


# ==================== 排行榜 ====================

class RankItem(BaseModel):
    """排行榜项"""
    rank: int
    id: int
    title: str
    cover_url: str = ""
    score: float = 0
    extra: str = ""  # 额外信息如播放量/阅读量等