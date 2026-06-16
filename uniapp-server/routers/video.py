"""视频影音路由"""
from datetime import datetime
from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from sqlalchemy import desc
from database import get_db
from models.entertainment import (
    EntVideo, EntVideoEpisode, EntVideoPlayRecord,
    EntCategory, EntBanner, EntFavorite, EntHistory,
)
from schemas.entertainment import (
    VideoListItem, VideoDetail, VideoEpisodeItem,
    VideoHomeData, BannerItem, CategoryItem, VideoProgressRequest, RankItem,
)
from schemas.user import ApiResponse
from services.auth import get_current_user
from models.user import User

router = APIRouter(prefix="/api/ent/video", tags=["视频影音"])


@router.get("/home", response_model=ApiResponse)
def video_home(db: Session = Depends(get_db)):
    """视频首页"""
    banners = db.query(EntBanner).filter(
        EntBanner.position == "video", EntBanner.status == 1
    ).order_by(EntBanner.sort).limit(5).all()

    hot = db.query(EntVideo).filter(
        EntVideo.status == 1, EntVideo.is_hot == 1
    ).order_by(desc(EntVideo.play_count)).limit(8).all()

    new = db.query(EntVideo).filter(
        EntVideo.status == 1, EntVideo.is_new == 1
    ).order_by(desc(EntVideo.created_at)).limit(8).all()

    anime = db.query(EntVideo).filter(
        EntVideo.status == 1, EntVideo.video_type == "anime"
    ).order_by(desc(EntVideo.play_count)).limit(8).all()

    categories = db.query(EntCategory).filter(
        EntCategory.type == "video", EntCategory.status == 1
    ).order_by(EntCategory.sort).all()

    data = VideoHomeData(
        banners=[BannerItem.model_validate(b) for b in banners],
        hot=[_video_to_item(v) for v in hot],
        new=[_video_to_item(v) for v in new],
        anime=[_video_to_item(v) for v in anime],
        categories=[CategoryItem.model_validate(c) for c in categories],
    )
    return ApiResponse(code=200, message="success", data=data.model_dump())


@router.get("/list", response_model=ApiResponse)
def video_list(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    category_id: int = Query(None),
    video_type: str = Query(None),
    region: str = Query(None),
    year: str = Query(None),
    keyword: str = Query(None),
    sort_by: str = Query("created_at"),
    db: Session = Depends(get_db),
):
    """视频列表"""
    query = db.query(EntVideo).filter(EntVideo.status == 1)
    if category_id:
        query = query.filter(EntVideo.category_id == category_id)
    if video_type:
        query = query.filter(EntVideo.video_type == video_type)
    if region:
        query = query.filter(EntVideo.region == region)
    if year:
        query = query.filter(EntVideo.year == year)
    if keyword:
        query = query.filter(EntVideo.title.like(f"%{keyword}%"))

    total = query.count()
    if sort_by == "play_count":
        query = query.order_by(desc(EntVideo.play_count))
    elif sort_by == "score":
        query = query.order_by(desc(EntVideo.score))
    elif sort_by == "new":
        query = query.order_by(desc(EntVideo.created_at))
    else:
        query = query.order_by(desc(EntVideo.created_at))

    videos = query.offset((page - 1) * page_size).limit(page_size).all()
    return ApiResponse(code=200, message="success", data={
        "total": total, "page": page, "page_size": page_size,
        "list": [_video_to_item(v).model_dump() for v in videos],
    })


@router.get("/detail/{video_id}", response_model=ApiResponse)
def video_detail(
    video_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """视频详情"""
    video = db.query(EntVideo).filter(EntVideo.id == video_id).first()
    if not video:
        return ApiResponse(code=404, message="视频不存在")

    episodes = db.query(EntVideoEpisode).filter(
        EntVideoEpisode.video_id == video_id
    ).order_by(EntVideoEpisode.episode_num).all()

    fav = db.query(EntFavorite).filter(
        EntFavorite.user_id == current_user.id,
        EntFavorite.content_type == "video",
        EntFavorite.content_id == video_id,
    ).first()

    # 观看进度
    play_record = db.query(EntVideoPlayRecord).filter(
        EntVideoPlayRecord.user_id == current_user.id,
        EntVideoPlayRecord.video_id == video_id,
    ).order_by(desc(EntVideoPlayRecord.updated_at)).first()

    watch_progress = None
    if play_record:
        watch_progress = {
            "episode_id": play_record.episode_id,
            "episode_num": play_record.episode_num,
            "progress_sec": play_record.progress_sec,
        }

    data = VideoDetail(
        id=video.id,
        title=video.title,
        cover_url=video.cover_url or "",
        description=video.description or "",
        category_id=video.category_id or 0,
        video_type=video.video_type or "movie",
        region=video.region or "",
        year=video.year or "",
        actors=video.actors or "",
        tags=video.tags or "",
        episode_count=video.episode_count or 1,
        status_text=video.status_text or "完结",
        is_free=video.is_free or 1,
        play_count=video.play_count or 0,
        score=video.score or 0,
        director=video.director or "",
        episodes=[VideoEpisodeItem(
            id=e.id, video_id=e.video_id, episode_num=e.episode_num,
            title=e.title or "", cover_url=e.cover_url or "",
            video_url=e.video_url or "", duration=e.duration or 0,
            is_free=e.is_free or 1,
        ) for e in episodes],
        is_favorited=fav is not None,
        watch_progress=watch_progress,
    )
    return ApiResponse(code=200, message="success", data=data.model_dump())


@router.post("/progress", response_model=ApiResponse)
def update_progress(
    req: VideoProgressRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """更新播放进度"""
    record = db.query(EntVideoPlayRecord).filter(
        EntVideoPlayRecord.user_id == current_user.id,
        EntVideoPlayRecord.video_id == req.video_id,
    ).first()

    if record:
        record.episode_id = req.episode_id
        record.episode_num = req.episode_num
        record.progress_sec = req.progress_sec
        record.updated_at = datetime.now()
    else:
        db.add(EntVideoPlayRecord(
            user_id=current_user.id,
            video_id=req.video_id,
            episode_id=req.episode_id,
            episode_num=req.episode_num,
            progress_sec=req.progress_sec,
        ))

    # 更新历史
    history = db.query(EntHistory).filter(
        EntHistory.user_id == current_user.id,
        EntHistory.content_type == "video",
        EntHistory.content_id == req.video_id,
    ).first()
    if history:
        history.last_at = datetime.now()
        history.progress = f"第{req.episode_num}集 {req.progress_sec}秒"
    else:
        db.add(EntHistory(
            user_id=current_user.id,
            content_type="video",
            content_id=req.video_id,
            progress=f"第{req.episode_num}集 {req.progress_sec}秒",
        ))

    db.commit()
    return ApiResponse(code=200, message="进度已更新")


@router.get("/rank", response_model=ApiResponse)
def video_rank(
    rank_type: str = Query("hot"),
    limit: int = Query(20, ge=1, le=50),
    db: Session = Depends(get_db),
):
    """视频排行榜"""
    query = db.query(EntVideo).filter(EntVideo.status == 1)
    if rank_type == "hot":
        query = query.order_by(desc(EntVideo.play_count))
    elif rank_type == "new":
        query = query.order_by(desc(EntVideo.created_at))
    elif rank_type == "score":
        query = query.order_by(desc(EntVideo.score))
    else:
        query = query.order_by(desc(EntVideo.play_count))

    videos = query.limit(limit).all()
    result = []
    for i, v in enumerate(videos):
        result.append(RankItem(
            rank=i + 1, id=v.id, title=v.title,
            cover_url=v.cover_url or "", score=v.score or 0,
            extra=f"{v.play_count or 0}次播放",
        ).model_dump())
    return ApiResponse(code=200, message="success", data=result)


@router.get("/my", response_model=ApiResponse)
def my_videos(
    type: str = Query("history"),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """我的影音"""
    if type == "history":
        records = db.query(EntHistory).filter(
            EntHistory.user_id == current_user.id,
            EntHistory.content_type == "video",
        ).order_by(desc(EntHistory.last_at)).limit(20).all()
        ids = [r.content_id for r in records]
    elif type == "favorite":
        favs = db.query(EntFavorite).filter(
            EntFavorite.user_id == current_user.id,
            EntFavorite.content_type == "video",
        ).order_by(desc(EntFavorite.created_at)).limit(20).all()
        ids = [f.content_id for f in favs]
    else:
        ids = []

    if not ids:
        return ApiResponse(code=200, message="success", data=[])

    videos = db.query(EntVideo).filter(EntVideo.id.in_(ids)).all()
    vmap = {v.id: v for v in videos}
    result = [_video_to_item(vmap[vid]).model_dump() for vid in ids if vid in vmap]
    return ApiResponse(code=200, message="success", data=result)


def _video_to_item(v: EntVideo) -> VideoListItem:
    return VideoListItem(
        id=v.id, title=v.title,
        cover_url=v.cover_url or "",
        description=v.description or "",
        category_id=v.category_id or 0,
        video_type=v.video_type or "movie",
        region=v.region or "",
        year=v.year or "",
        actors=v.actors or "",
        tags=v.tags or "",
        episode_count=v.episode_count or 1,
        status_text=v.status_text or "完结",
        is_free=v.is_free or 1,
        play_count=v.play_count or 0,
        score=v.score or 0,
    )