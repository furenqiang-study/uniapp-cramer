"""娱乐中心公共路由（收藏、历史、搜索、分类、轮播图）"""
from datetime import datetime
from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from sqlalchemy import desc
from database import get_db
from models.entertainment import (
    EntCategory, EntBanner, EntFavorite, EntHistory,
    EntGame, EntSong, EntVideo, EntNovel,
)
from schemas.entertainment import FavoriteRequest, CategoryItem, BannerItem
from schemas.user import ApiResponse
from services.auth import get_current_user
from models.user import User

router = APIRouter(prefix="/api/ent", tags=["娱乐中心-公共"])


# ==================== 分类 ====================

@router.get("/categories/{type}", response_model=ApiResponse)
def get_categories(type: str, db: Session = Depends(get_db)):
    """获取分类列表"""
    categories = db.query(EntCategory).filter(
        EntCategory.type == type,
        EntCategory.status == 1,
    ).order_by(EntCategory.sort).all()

    result = []
    for c in categories:
        result.append(CategoryItem.model_validate(c).model_dump())

    return ApiResponse(code=200, message="success", data=result)


# ==================== 轮播图 ====================

@router.get("/banners/{position}", response_model=ApiResponse)
def get_banners(position: str, db: Session = Depends(get_db)):
    """获取轮播图"""
    banners = db.query(EntBanner).filter(
        EntBanner.position == position,
        EntBanner.status == 1,
    ).order_by(EntBanner.sort).limit(10).all()

    result = [BannerItem.model_validate(b).model_dump() for b in banners]
    return ApiResponse(code=200, message="success", data=result)


# ==================== 收藏 ====================

@router.post("/favorite", response_model=ApiResponse)
def add_favorite(
    req: FavoriteRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """添加收藏"""
    existing = db.query(EntFavorite).filter(
        EntFavorite.user_id == current_user.id,
        EntFavorite.content_type == req.content_type,
        EntFavorite.content_id == req.content_id,
    ).first()

    if existing:
        return ApiResponse(code=200, message="已收藏")

    db.add(EntFavorite(
        user_id=current_user.id,
        content_type=req.content_type,
        content_id=req.content_id,
    ))
    db.commit()
    return ApiResponse(code=200, message="收藏成功")


@router.delete("/favorite", response_model=ApiResponse)
def remove_favorite(
    content_type: str = Query(...),
    content_id: int = Query(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """取消收藏"""
    fav = db.query(EntFavorite).filter(
        EntFavorite.user_id == current_user.id,
        EntFavorite.content_type == content_type,
        EntFavorite.content_id == content_id,
    ).first()

    if fav:
        db.delete(fav)
        db.commit()

    return ApiResponse(code=200, message="取消收藏成功")


@router.get("/favorite/check", response_model=ApiResponse)
def check_favorite(
    content_type: str = Query(...),
    content_id: int = Query(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """检查是否已收藏"""
    fav = db.query(EntFavorite).filter(
        EntFavorite.user_id == current_user.id,
        EntFavorite.content_type == content_type,
        EntFavorite.content_id == content_id,
    ).first()

    return ApiResponse(code=200, message="success", data={"is_favorited": fav is not None})


@router.get("/favorites", response_model=ApiResponse)
def get_favorites(
    content_type: str = Query(...),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """获取收藏列表"""
    query = db.query(EntFavorite).filter(
        EntFavorite.user_id == current_user.id,
        EntFavorite.content_type == content_type,
    )

    total = query.count()
    favs = query.order_by(desc(EntFavorite.created_at)).offset(
        (page - 1) * page_size
    ).limit(page_size).all()

    content_ids = [f.content_id for f in favs]
    items = []

    if content_ids:
        if content_type == "game":
            records = db.query(EntGame).filter(EntGame.id.in_(content_ids)).all()
            rmap = {r.id: r for r in records}
            for cid in content_ids:
                if cid in rmap:
                    g = rmap[cid]
                    items.append({
                        "id": g.id, "title": g.title,
                        "cover_url": g.cover_url or "",
                        "score": g.score or 0,
                        "play_count": g.play_count or 0,
                    })
        elif content_type == "music":
            records = db.query(EntSong).filter(EntSong.id.in_(content_ids)).all()
            rmap = {r.id: r for r in records}
            for cid in content_ids:
                if cid in rmap:
                    s = rmap[cid]
                    items.append({
                        "id": s.id, "title": s.title,
                        "cover_url": s.cover_url or "",
                        "artist_name": s.artist_name or "",
                        "duration": s.duration or 0,
                    })
        elif content_type == "video":
            records = db.query(EntVideo).filter(EntVideo.id.in_(content_ids)).all()
            rmap = {r.id: r for r in records}
            for cid in content_ids:
                if cid in rmap:
                    v = rmap[cid]
                    items.append({
                        "id": v.id, "title": v.title,
                        "cover_url": v.cover_url or "",
                        "score": v.score or 0,
                        "episode_count": v.episode_count or 1,
                    })
        elif content_type == "novel":
            records = db.query(EntNovel).filter(EntNovel.id.in_(content_ids)).all()
            rmap = {r.id: r for r in records}
            for cid in content_ids:
                if cid in rmap:
                    n = rmap[cid]
                    items.append({
                        "id": n.id, "title": n.title,
                        "cover_url": n.cover_url or "",
                        "author": n.author or "",
                        "last_chapter": n.last_chapter or "",
                    })

    return ApiResponse(code=200, message="success", data={
        "total": total, "page": page, "page_size": page_size,
        "list": items,
    })


# ==================== 历史记录 ====================

@router.get("/history", response_model=ApiResponse)
def get_history(
    content_type: str = Query(...),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """获取历史记录"""
    query = db.query(EntHistory).filter(
        EntHistory.user_id == current_user.id,
        EntHistory.content_type == content_type,
    )

    total = query.count()
    records = query.order_by(desc(EntHistory.last_at)).offset(
        (page - 1) * page_size
    ).limit(page_size).all()

    content_ids = [r.content_id for r in records]
    items = []

    if content_ids:
        if content_type == "game":
            games = db.query(EntGame).filter(EntGame.id.in_(content_ids)).all()
            gmap = {g.id: g for g in games}
            for r in records:
                if r.content_id in gmap:
                    g = gmap[r.content_id]
                    items.append({
                        "id": g.id, "title": g.title,
                        "cover_url": g.cover_url or "",
                        "last_at": str(r.last_at) if r.last_at else "",
                    })
        elif content_type == "music":
            songs = db.query(EntSong).filter(EntSong.id.in_(content_ids)).all()
            smap = {s.id: s for s in songs}
            for r in records:
                if r.content_id in smap:
                    s = smap[r.content_id]
                    items.append({
                        "id": s.id, "title": s.title,
                        "cover_url": s.cover_url or "",
                        "artist_name": s.artist_name or "",
                        "last_at": str(r.last_at) if r.last_at else "",
                    })
        elif content_type == "video":
            videos = db.query(EntVideo).filter(EntVideo.id.in_(content_ids)).all()
            vmap = {v.id: v for v in videos}
            for r in records:
                if r.content_id in vmap:
                    v = vmap[r.content_id]
                    items.append({
                        "id": v.id, "title": v.title,
                        "cover_url": v.cover_url or "",
                        "progress": r.progress or "",
                        "last_at": str(r.last_at) if r.last_at else "",
                    })
        elif content_type == "novel":
            novels = db.query(EntNovel).filter(EntNovel.id.in_(content_ids)).all()
            nmap = {n.id: n for n in novels}
            for r in records:
                if r.content_id in nmap:
                    n = nmap[r.content_id]
                    items.append({
                        "id": n.id, "title": n.title,
                        "cover_url": n.cover_url or "",
                        "author": n.author or "",
                        "progress": r.progress or "",
                        "last_at": str(r.last_at) if r.last_at else "",
                    })

    return ApiResponse(code=200, message="success", data={
        "total": total, "page": page, "page_size": page_size,
        "list": items,
    })


@router.delete("/history", response_model=ApiResponse)
def clear_history(
    content_type: str = Query(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """清空历史记录"""
    db.query(EntHistory).filter(
        EntHistory.user_id == current_user.id,
        EntHistory.content_type == content_type,
    ).delete()
    db.commit()
    return ApiResponse(code=200, message="历史记录已清空")


# ==================== 全局搜索 ====================

@router.get("/search", response_model=ApiResponse)
def global_search(
    keyword: str = Query(..., min_length=1),
    type: str = Query("all"),  # all/game/music/video/novel
    db: Session = Depends(get_db),
):
    """全局搜索"""
    result = {}

    if type in ("all", "game"):
        games = db.query(EntGame).filter(
            EntGame.status == 1,
            EntGame.title.like(f"%{keyword}%"),
        ).order_by(desc(EntGame.play_count)).limit(10).all()
        result["games"] = [{
            "id": g.id, "title": g.title,
            "cover_url": g.cover_url or "",
            "type": "game",
        } for g in games]

    if type in ("all", "music"):
        songs = db.query(EntSong).filter(
            EntSong.status == 1,
            EntSong.title.like(f"%{keyword}%"),
        ).order_by(desc(EntSong.play_count)).limit(10).all()
        result["songs"] = [{
            "id": s.id, "title": s.title,
            "cover_url": s.cover_url or "",
            "artist_name": s.artist_name or "",
            "type": "music",
        } for s in songs]

    if type in ("all", "video"):
        videos = db.query(EntVideo).filter(
            EntVideo.status == 1,
            EntVideo.title.like(f"%{keyword}%"),
        ).order_by(desc(EntVideo.play_count)).limit(10).all()
        result["videos"] = [{
            "id": v.id, "title": v.title,
            "cover_url": v.cover_url or "",
            "type": "video",
        } for v in videos]

    if type in ("all", "novel"):
        novels = db.query(EntNovel).filter(
            EntNovel.status == 1,
            EntNovel.title.like(f"%{keyword}%"),
        ).order_by(desc(EntNovel.read_count)).limit(10).all()
        result["novels"] = [{
            "id": n.id, "title": n.title,
            "cover_url": n.cover_url or "",
            "author": n.author or "",
            "type": "novel",
        } for n in novels]

    return ApiResponse(code=200, message="success", data=result)