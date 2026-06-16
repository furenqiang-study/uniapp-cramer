"""网络小说路由"""
from datetime import datetime
from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from sqlalchemy import desc
from database import get_db
from models.entertainment import (
    EntNovel, EntNovelVolume, EntNovelChapter, EntNovelReadRecord,
    EntCategory, EntBanner, EntFavorite, EntHistory,
)
from schemas.entertainment import (
    NovelListItem, NovelDetail, NovelChapterItem, NovelChapterContent,
    NovelHomeData, BannerItem, CategoryItem, NovelReadProgressRequest, RankItem,
)
from schemas.user import ApiResponse
from services.auth import get_current_user
from models.user import User

router = APIRouter(prefix="/api/ent/novel", tags=["网络小说"])


@router.get("/home", response_model=ApiResponse)
def novel_home(db: Session = Depends(get_db)):
    """小说首页"""
    banners = db.query(EntBanner).filter(
        EntBanner.position == "novel", EntBanner.status == 1
    ).order_by(EntBanner.sort).limit(5).all()

    recommend = db.query(EntNovel).filter(
        EntNovel.status == 1, EntNovel.is_recommend == 1
    ).order_by(EntNovel.sort).limit(8).all()

    hot = db.query(EntNovel).filter(
        EntNovel.status == 1
    ).order_by(desc(EntNovel.read_count)).limit(8).all()

    new_novels = db.query(EntNovel).filter(
        EntNovel.status == 1
    ).order_by(desc(EntNovel.created_at)).limit(8).all()

    categories = db.query(EntCategory).filter(
        EntCategory.type == "novel", EntCategory.status == 1
    ).order_by(EntCategory.sort).all()

    data = NovelHomeData(
        banners=[BannerItem.model_validate(b) for b in banners],
        recommend=[_novel_to_item(n) for n in recommend],
        hot=[_novel_to_item(n) for n in hot],
        new=[_novel_to_item(n) for n in new_novels],
        categories=[CategoryItem.model_validate(c) for c in categories],
    )
    return ApiResponse(code=200, message="success", data=data.model_dump())


@router.get("/list", response_model=ApiResponse)
def novel_list(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    category_id: int = Query(None),
    genre: str = Query(None),
    gender: str = Query(None),
    status_text: str = Query(None),
    keyword: str = Query(None),
    sort_by: str = Query("created_at"),
    db: Session = Depends(get_db),
):
    """小说列表"""
    query = db.query(EntNovel).filter(EntNovel.status == 1)
    if category_id:
        query = query.filter(EntNovel.category_id == category_id)
    if genre:
        query = query.filter(EntNovel.genre == genre)
    if gender:
        query = query.filter(EntNovel.gender == gender)
    if status_text:
        query = query.filter(EntNovel.status_text == status_text)
    if keyword:
        query = query.filter(EntNovel.title.like(f"%{keyword}%"))

    total = query.count()
    if sort_by == "read_count":
        query = query.order_by(desc(EntNovel.read_count))
    elif sort_by == "score":
        query = query.order_by(desc(EntNovel.score))
    elif sort_by == "word_count":
        query = query.order_by(desc(EntNovel.word_count))
    elif sort_by == "update":
        query = query.order_by(desc(EntNovel.last_update))
    else:
        query = query.order_by(desc(EntNovel.created_at))

    novels = query.offset((page - 1) * page_size).limit(page_size).all()
    return ApiResponse(code=200, message="success", data={
        "total": total, "page": page, "page_size": page_size,
        "list": [_novel_to_item(n).model_dump() for n in novels],
    })


@router.get("/detail/{novel_id}", response_model=ApiResponse)
def novel_detail(
    novel_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """小说详情"""
    novel = db.query(EntNovel).filter(EntNovel.id == novel_id).first()
    if not novel:
        return ApiResponse(code=404, message="小说不存在")

    # 更新阅读量
    novel.read_count = (novel.read_count or 0) + 1

    # 章节列表
    chapters = db.query(EntNovelChapter).filter(
        EntNovelChapter.novel_id == novel_id,
        EntNovelChapter.status == 1,
    ).order_by(EntNovelChapter.chapter_num).all()

    fav = db.query(EntFavorite).filter(
        EntFavorite.user_id == current_user.id,
        EntFavorite.content_type == "novel",
        EntFavorite.content_id == novel_id,
    ).first()

    # 阅读进度
    read_record = db.query(EntNovelReadRecord).filter(
        EntNovelReadRecord.user_id == current_user.id,
        EntNovelReadRecord.novel_id == novel_id,
    ).first()

    read_progress = None
    if read_record:
        read_progress = {
            "chapter_id": read_record.chapter_id,
            "chapter_num": read_record.chapter_num,
            "progress": read_record.progress,
        }

    db.commit()

    data = NovelDetail(
        id=novel.id,
        title=novel.title,
        author=novel.author or "",
        cover_url=novel.cover_url or "",
        description=novel.description or "",
        category_id=novel.category_id or 0,
        genre=novel.genre or "",
        gender=novel.gender or "male",
        word_count=novel.word_count or 0,
        chapter_count=novel.chapter_count or 0,
        status_text=novel.status_text or "连载中",
        tags=novel.tags or "",
        is_free=novel.is_free or 1,
        read_count=novel.read_count or 0,
        score=novel.score or 0,
        last_chapter=novel.last_chapter or "",
        chapters=[NovelChapterItem(
            id=c.id, novel_id=c.novel_id,
            volume_id=c.volume_id or 0,
            chapter_num=c.chapter_num,
            title=c.title or "",
            word_count=c.word_count or 0,
            is_free=c.is_free or 1,
            is_vip=c.is_vip or 0,
        ) for c in chapters],
        is_favorited=fav is not None,
        read_progress=read_progress,
    )
    return ApiResponse(code=200, message="success", data=data.model_dump())


@router.get("/chapter/{chapter_id}", response_model=ApiResponse)
def chapter_content(
    chapter_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """获取章节内容"""
    chapter = db.query(EntNovelChapter).filter(EntNovelChapter.id == chapter_id).first()
    if not chapter:
        return ApiResponse(code=404, message="章节不存在")

    # 上一章
    prev_chapter = db.query(EntNovelChapter).filter(
        EntNovelChapter.novel_id == chapter.novel_id,
        EntNovelChapter.chapter_num == chapter.chapter_num - 1,
        EntNovelChapter.status == 1,
    ).first()

    # 下一章
    next_chapter = db.query(EntNovelChapter).filter(
        EntNovelChapter.novel_id == chapter.novel_id,
        EntNovelChapter.chapter_num == chapter.chapter_num + 1,
        EntNovelChapter.status == 1,
    ).first()

    data = NovelChapterContent(
        id=chapter.id,
        novel_id=chapter.novel_id,
        chapter_num=chapter.chapter_num,
        title=chapter.title or "",
        content=chapter.content or "",
        word_count=chapter.word_count or 0,
        prev_id=prev_chapter.id if prev_chapter else None,
        next_id=next_chapter.id if next_chapter else None,
        prev_title=prev_chapter.title if prev_chapter else "",
        next_title=next_chapter.title if next_chapter else "",
    )
    return ApiResponse(code=200, message="success", data=data.model_dump())


@router.post("/read/progress", response_model=ApiResponse)
def update_read_progress(
    req: NovelReadProgressRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """更新阅读进度"""
    record = db.query(EntNovelReadRecord).filter(
        EntNovelReadRecord.user_id == current_user.id,
        EntNovelReadRecord.novel_id == req.novel_id,
    ).first()

    if record:
        record.chapter_id = req.chapter_id
        record.chapter_num = req.chapter_num
        record.progress = req.progress
        record.updated_at = datetime.now()
    else:
        db.add(EntNovelReadRecord(
            user_id=current_user.id,
            novel_id=req.novel_id,
            chapter_id=req.chapter_id,
            chapter_num=req.chapter_num,
            progress=req.progress,
        ))

    # 更新历史
    history = db.query(EntHistory).filter(
        EntHistory.user_id == current_user.id,
        EntHistory.content_type == "novel",
        EntHistory.content_id == req.novel_id,
    ).first()
    if history:
        history.last_at = datetime.now()
        history.progress = f"第{req.chapter_num}章"
    else:
        db.add(EntHistory(
            user_id=current_user.id,
            content_type="novel",
            content_id=req.novel_id,
            progress=f"第{req.chapter_num}章",
        ))

    db.commit()
    return ApiResponse(code=200, message="阅读进度已更新")


@router.get("/rank", response_model=ApiResponse)
def novel_rank(
    rank_type: str = Query("hot"),
    limit: int = Query(20, ge=1, le=50),
    db: Session = Depends(get_db),
):
    """小说排行榜"""
    query = db.query(EntNovel).filter(EntNovel.status == 1)
    if rank_type == "hot":
        query = query.order_by(desc(EntNovel.read_count))
    elif rank_type == "new":
        query = query.order_by(desc(EntNovel.created_at))
    elif rank_type == "score":
        query = query.order_by(desc(EntNovel.score))
    elif rank_type == "update":
        query = query.order_by(desc(EntNovel.last_update))
    elif rank_type == "finish":
        query = query.filter(EntNovel.status_text == "完本").order_by(desc(EntNovel.score))
    else:
        query = query.order_by(desc(EntNovel.read_count))

    novels = query.limit(limit).all()
    result = []
    for i, n in enumerate(novels):
        result.append(RankItem(
            rank=i + 1, id=n.id, title=n.title,
            cover_url=n.cover_url or "", score=n.score or 0,
            extra=f"{n.read_count or 0}次阅读",
        ).model_dump())
    return ApiResponse(code=200, message="success", data=result)


@router.get("/my", response_model=ApiResponse)
def my_novels(
    type: str = Query("shelf"),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """我的书架"""
    if type == "shelf":
        # 已看书架（有阅读记录的）
        records = db.query(EntNovelReadRecord).filter(
            EntNovelReadRecord.user_id == current_user.id,
        ).order_by(desc(EntNovelReadRecord.updated_at)).limit(20).all()
        ids = [r.novel_id for r in records]
    elif type == "favorite":
        favs = db.query(EntFavorite).filter(
            EntFavorite.user_id == current_user.id,
            EntFavorite.content_type == "novel",
        ).order_by(desc(EntFavorite.created_at)).limit(20).all()
        ids = [f.content_id for f in favs]
    elif type == "history":
        records = db.query(EntHistory).filter(
            EntHistory.user_id == current_user.id,
            EntHistory.content_type == "novel",
        ).order_by(desc(EntHistory.last_at)).limit(20).all()
        ids = [r.content_id for r in records]
    else:
        ids = []

    if not ids:
        return ApiResponse(code=200, message="success", data=[])

    novels = db.query(EntNovel).filter(EntNovel.id.in_(ids)).all()
    nmap = {n.id: n for n in novels}
    result = [_novel_to_item(nmap[nid]).model_dump() for nid in ids if nid in nmap]
    return ApiResponse(code=200, message="success", data=result)


def _novel_to_item(n: EntNovel) -> NovelListItem:
    return NovelListItem(
        id=n.id, title=n.title,
        author=n.author or "",
        cover_url=n.cover_url or "",
        description=n.description or "",
        category_id=n.category_id or 0,
        genre=n.genre or "",
        gender=n.gender or "male",
        word_count=n.word_count or 0,
        chapter_count=n.chapter_count or 0,
        status_text=n.status_text or "连载中",
        tags=n.tags or "",
        is_free=n.is_free or 1,
        read_count=n.read_count or 0,
        score=n.score or 0,
        last_chapter=n.last_chapter or "",
    )