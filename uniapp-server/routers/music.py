"""音乐中心路由"""
from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from sqlalchemy import desc
from database import get_db
from models.entertainment import (
    EntSong, EntArtist, EntAlbum, EntPlaylist, EntPlaylistSong,
    EntCategory, EntBanner, EntFavorite, EntHistory, EntSongPlayRecord,
)
from schemas.entertainment import (
    SongItem, SongDetail, PlaylistItem, PlaylistDetail, ArtistItem,
    MusicHomeData, BannerItem, CategoryItem, RankItem,
)
from schemas.user import ApiResponse
from services.auth import get_current_user
from models.user import User

router = APIRouter(prefix="/api/ent/music", tags=["音乐中心"])


@router.get("/home", response_model=ApiResponse)
def music_home(db: Session = Depends(get_db)):
    """音乐首页"""
    banners = db.query(EntBanner).filter(
        EntBanner.position == "music", EntBanner.status == 1
    ).order_by(EntBanner.sort).limit(5).all()

    recommend_playlists = db.query(EntPlaylist).filter(
        EntPlaylist.status == 1, EntPlaylist.is_recommend == 1
    ).order_by(EntPlaylist.sort).limit(6).all()

    hot_songs = db.query(EntSong).filter(
        EntSong.status == 1
    ).order_by(desc(EntSong.play_count)).limit(10).all()

    new_songs = db.query(EntSong).filter(
        EntSong.status == 1
    ).order_by(desc(EntSong.created_at)).limit(10).all()

    categories = db.query(EntCategory).filter(
        EntCategory.type == "music", EntCategory.status == 1
    ).order_by(EntCategory.sort).all()

    data = MusicHomeData(
        banners=[BannerItem.model_validate(b) for b in banners],
        recommend_playlists=[_playlist_to_item(p) for p in recommend_playlists],
        hot_songs=[_song_to_item(s) for s in hot_songs],
        new_songs=[_song_to_item(s) for s in new_songs],
        categories=[CategoryItem.model_validate(c) for c in categories],
    )
    return ApiResponse(code=200, message="success", data=data.model_dump())


@router.get("/songs", response_model=ApiResponse)
def song_list(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    category_id: int = Query(None),
    genre: str = Query(None),
    language: str = Query(None),
    keyword: str = Query(None),
    sort_by: str = Query("created_at"),
    db: Session = Depends(get_db),
):
    """歌曲列表"""
    query = db.query(EntSong).filter(EntSong.status == 1)
    if genre:
        query = query.filter(EntSong.genre == genre)
    if language:
        query = query.filter(EntSong.language == language)
    if keyword:
        query = query.filter(EntSong.title.like(f"%{keyword}%"))

    total = query.count()
    if sort_by == "play_count":
        query = query.order_by(desc(EntSong.play_count))
    elif sort_by == "score":
        query = query.order_by(desc(EntSong.score))
    else:
        query = query.order_by(desc(EntSong.created_at))

    songs = query.offset((page - 1) * page_size).limit(page_size).all()
    return ApiResponse(code=200, message="success", data={
        "total": total, "page": page, "page_size": page_size,
        "list": [_song_to_item(s).model_dump() for s in songs],
    })


@router.get("/song/{song_id}", response_model=ApiResponse)
def song_detail(
    song_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """歌曲详情"""
    song = db.query(EntSong).filter(EntSong.id == song_id).first()
    if not song:
        return ApiResponse(code=404, message="歌曲不存在")

    fav = db.query(EntFavorite).filter(
        EntFavorite.user_id == current_user.id,
        EntFavorite.content_type == "music",
        EntFavorite.content_id == song_id,
    ).first()

    data = SongDetail(
        id=song.id,
        title=song.title,
        artist_name=song.artist_name or "",
        artist_id=song.artist_id or 0,
        album_id=song.album_id or 0,
        cover_url=song.cover_url or "",
        audio_url=song.audio_url or "",
        duration=song.duration or 0,
        genre=song.genre or "",
        language=song.language or "华语",
        is_free=song.is_free or 1,
        play_count=song.play_count or 0,
        score=song.score or 0,
        lyrics=song.lyrics or "",
        is_favorited=fav is not None,
    )
    return ApiResponse(code=200, message="success", data=data.model_dump())


@router.post("/song/{song_id}/play", response_model=ApiResponse)
def song_play(
    song_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """播放歌曲（记录播放）"""
    song = db.query(EntSong).filter(EntSong.id == song_id).first()
    if not song:
        return ApiResponse(code=404, message="歌曲不存在")

    song.play_count = (song.play_count or 0) + 1
    db.add(EntSongPlayRecord(user_id=current_user.id, song_id=song_id))

    history = db.query(EntHistory).filter(
        EntHistory.user_id == current_user.id,
        EntHistory.content_type == "music",
        EntHistory.content_id == song_id,
    ).first()
    if history:
        from datetime import datetime
        history.last_at = datetime.now()
    else:
        from datetime import datetime
        db.add(EntHistory(user_id=current_user.id, content_type="music", content_id=song_id))

    db.commit()
    return ApiResponse(code=200, message="播放记录已更新")


@router.get("/playlists", response_model=ApiResponse)
def playlist_list(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    keyword: str = Query(None),
    sort_by: str = Query("created_at"),
    db: Session = Depends(get_db),
):
    """歌单列表"""
    query = db.query(EntPlaylist).filter(EntPlaylist.status == 1)
    if keyword:
        query = query.filter(EntPlaylist.title.like(f"%{keyword}%"))

    total = query.count()
    if sort_by == "play_count":
        query = query.order_by(desc(EntPlaylist.play_count))
    else:
        query = query.order_by(desc(EntPlaylist.created_at))

    playlists = query.offset((page - 1) * page_size).limit(page_size).all()
    return ApiResponse(code=200, message="success", data={
        "total": total, "page": page, "page_size": page_size,
        "list": [_playlist_to_item(p).model_dump() for p in playlists],
    })


@router.get("/playlist/{playlist_id}", response_model=ApiResponse)
def playlist_detail(
    playlist_id: int,
    db: Session = Depends(get_db),
):
    """歌单详情"""
    playlist = db.query(EntPlaylist).filter(EntPlaylist.id == playlist_id).first()
    if not playlist:
        return ApiResponse(code=404, message="歌单不存在")

    # 获取歌单中的歌曲
    ps = db.query(EntPlaylistSong).filter(
        EntPlaylistSong.playlist_id == playlist_id
    ).order_by(EntPlaylistSong.sort).all()

    song_ids = [p.song_id for p in ps]
    songs = []
    if song_ids:
        song_list = db.query(EntSong).filter(EntSong.id.in_(song_ids)).all()
        song_map = {s.id: s for s in song_list}
        for sid in song_ids:
            if sid in song_map:
                songs.append(_song_to_item(song_map[sid]))

    data = PlaylistDetail(
        id=playlist.id,
        title=playlist.title,
        cover_url=playlist.cover_url or "",
        description=playlist.description or "",
        creator_name=playlist.creator_name or "",
        tags=playlist.tags or "",
        song_count=playlist.song_count or 0,
        play_count=playlist.play_count or 0,
        songs=songs,
    )
    return ApiResponse(code=200, message="success", data=data.model_dump())


@router.get("/artists", response_model=ApiResponse)
def artist_list(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    region: str = Query(None),
    keyword: str = Query(None),
    db: Session = Depends(get_db),
):
    """歌手列表"""
    query = db.query(EntArtist).filter(EntArtist.status == 1)
    if region:
        query = query.filter(EntArtist.region == region)
    if keyword:
        query = query.filter(EntArtist.name.like(f"%{keyword}%"))

    total = query.count()
    query = query.order_by(desc(EntArtist.fan_count))
    artists = query.offset((page - 1) * page_size).limit(page_size).all()

    return ApiResponse(code=200, message="success", data={
        "total": total, "page": page, "page_size": page_size,
        "list": [_artist_to_item(a).model_dump() for a in artists],
    })


@router.get("/artist/{artist_id}", response_model=ApiResponse)
def artist_detail(
    artist_id: int,
    db: Session = Depends(get_db),
):
    """歌手详情"""
    artist = db.query(EntArtist).filter(EntArtist.id == artist_id).first()
    if not artist:
        return ApiResponse(code=404, message="歌手不存在")

    songs = db.query(EntSong).filter(
        EntSong.artist_id == artist_id, EntSong.status == 1
    ).order_by(desc(EntSong.play_count)).limit(50).all()

    data = {
        "artist": _artist_to_item(artist).model_dump(),
        "songs": [_song_to_item(s).model_dump() for s in songs],
    }
    return ApiResponse(code=200, message="success", data=data)


@router.get("/rank", response_model=ApiResponse)
def music_rank(
    rank_type: str = Query("hot"),
    limit: int = Query(20, ge=1, le=50),
    db: Session = Depends(get_db),
):
    """音乐排行榜"""
    query = db.query(EntSong).filter(EntSong.status == 1)
    if rank_type == "hot":
        query = query.order_by(desc(EntSong.play_count))
    elif rank_type == "new":
        query = query.order_by(desc(EntSong.created_at))
    elif rank_type == "score":
        query = query.order_by(desc(EntSong.score))
    else:
        query = query.order_by(desc(EntSong.play_count))

    songs = query.limit(limit).all()
    result = []
    for i, s in enumerate(songs):
        result.append(RankItem(
            rank=i + 1, id=s.id, title=s.title,
            cover_url=s.cover_url or "", score=s.score or 0,
            extra=f"{s.play_count or 0}次播放",
        ).model_dump())
    return ApiResponse(code=200, message="success", data=result)


@router.get("/my", response_model=ApiResponse)
def my_music(
    type: str = Query("recent"),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """我的音乐"""
    if type == "recent":
        records = db.query(EntHistory).filter(
            EntHistory.user_id == current_user.id,
            EntHistory.content_type == "music",
        ).order_by(desc(EntHistory.last_at)).limit(20).all()
        song_ids = [r.content_id for r in records]
    elif type == "favorite":
        favs = db.query(EntFavorite).filter(
            EntFavorite.user_id == current_user.id,
            EntFavorite.content_type == "music",
        ).order_by(desc(EntFavorite.created_at)).limit(20).all()
        song_ids = [f.content_id for f in favs]
    else:
        song_ids = []

    if not song_ids:
        return ApiResponse(code=200, message="success", data=[])

    songs = db.query(EntSong).filter(EntSong.id.in_(song_ids)).all()
    song_map = {s.id: s for s in songs}
    result = [_song_to_item(song_map[sid]).model_dump() for sid in song_ids if sid in song_map]
    return ApiResponse(code=200, message="success", data=result)


def _song_to_item(song: EntSong) -> SongItem:
    return SongItem(
        id=song.id, title=song.title,
        artist_name=song.artist_name or "",
        artist_id=song.artist_id or 0,
        album_id=song.album_id or 0,
        cover_url=song.cover_url or "",
        audio_url=song.audio_url or "",
        duration=song.duration or 0,
        genre=song.genre or "",
        language=song.language or "华语",
        is_free=song.is_free or 1,
        play_count=song.play_count or 0,
        score=song.score or 0,
    )


def _playlist_to_item(p: EntPlaylist) -> PlaylistItem:
    return PlaylistItem(
        id=p.id, title=p.title,
        cover_url=p.cover_url or "",
        description=p.description or "",
        creator_name=p.creator_name or "",
        tags=p.tags or "",
        song_count=p.song_count or 0,
        play_count=p.play_count or 0,
    )


def _artist_to_item(a: EntArtist) -> ArtistItem:
    return ArtistItem(
        id=a.id, name=a.name,
        avatar_url=a.avatar_url or "",
        description=a.description or "",
        region=a.region or "",
        song_count=a.song_count or 0,
        fan_count=a.fan_count or 0,
    )