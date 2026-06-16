"""游戏中心路由"""
import uuid
from datetime import datetime
from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from sqlalchemy import desc, func
from database import get_db
from models.entertainment import (
    EntGame, EntGameScreenshot, EntGamePlayRecord,
    EntCategory, EntBanner, EntFavorite, EntHistory,
)
from schemas.entertainment import (
    GameListItem, GameDetail, GamePlayEndRequest,
    GameHomeData, BannerItem, CategoryItem, PageRequest, RankItem,
)
from schemas.user import ApiResponse
from services.auth import get_current_user
from models.user import User

router = APIRouter(prefix="/api/ent/game", tags=["游戏中心"])


@router.get("/home", response_model=ApiResponse)
def game_home(
    db: Session = Depends(get_db),
):
    """游戏首页数据"""
    # 轮播图
    banners = db.query(EntBanner).filter(
        EntBanner.position == "game",
        EntBanner.status == 1,
    ).order_by(EntBanner.sort).limit(5).all()

    # 推荐游戏
    recommend = db.query(EntGame).filter(
        EntGame.status == 1,
        EntGame.sort > 0,
    ).order_by(EntGame.sort).limit(8).all()

    # 热门游戏
    hot = db.query(EntGame).filter(
        EntGame.status == 1,
    ).order_by(desc(EntGame.play_count)).limit(8).all()

    # 新游戏
    new_games = db.query(EntGame).filter(
        EntGame.status == 1,
    ).order_by(desc(EntGame.created_at)).limit(8).all()

    # 分类
    categories = db.query(EntCategory).filter(
        EntCategory.type == "game",
        EntCategory.status == 1,
    ).order_by(EntCategory.sort).all()

    data = GameHomeData(
        banners=[BannerItem.model_validate(b) for b in banners],
        recommend=[_game_to_item(g) for g in recommend],
        hot=[_game_to_item(g) for g in hot],
        new=[_game_to_item(g) for g in new_games],
        categories=[CategoryItem.model_validate(c) for c in categories],
    )
    return ApiResponse(code=200, message="success", data=data.model_dump())


@router.get("/list", response_model=ApiResponse)
def game_list(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    category_id: int = Query(None),
    keyword: str = Query(None),
    sort_by: str = Query("created_at"),
    is_free: int = Query(None),
    db: Session = Depends(get_db),
):
    """游戏列表"""
    query = db.query(EntGame).filter(EntGame.status == 1)

    if category_id:
        query = query.filter(EntGame.category_id == category_id)
    if keyword:
        query = query.filter(EntGame.title.like(f"%{keyword}%"))
    if is_free is not None:
        query = query.filter(EntGame.is_free == is_free)

    total = query.count()

    # 排序
    if sort_by == "play_count":
        query = query.order_by(desc(EntGame.play_count))
    elif sort_by == "score":
        query = query.order_by(desc(EntGame.score))
    elif sort_by == "new":
        query = query.order_by(desc(EntGame.created_at))
    else:
        query = query.order_by(desc(EntGame.created_at))

    games = query.offset((page - 1) * page_size).limit(page_size).all()

    data = {
        "total": total,
        "page": page,
        "page_size": page_size,
        "list": [_game_to_item(g).model_dump() for g in games],
    }
    return ApiResponse(code=200, message="success", data=data)


@router.get("/detail/{game_id}", response_model=ApiResponse)
def game_detail(
    game_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """游戏详情"""
    game = db.query(EntGame).filter(EntGame.id == game_id).first()
    if not game:
        return ApiResponse(code=404, message="游戏不存在")

    # 截图
    screenshots = db.query(EntGameScreenshot).filter(
        EntGameScreenshot.game_id == game_id
    ).order_by(EntGameScreenshot.sort).all()

    # 分类名
    category_name = ""
    if game.category_id:
        cat = db.query(EntCategory).filter(EntCategory.id == game.category_id).first()
        if cat:
            category_name = cat.name

    # 是否已收藏
    fav = db.query(EntFavorite).filter(
        EntFavorite.user_id == current_user.id,
        EntFavorite.content_type == "game",
        EntFavorite.content_id == game_id,
    ).first()

    data = GameDetail(
        id=game.id,
        title=game.title,
        cover_url=game.cover_url or "",
        description=game.description or "",
        category_id=game.category_id or 0,
        game_type=game.game_type or "h5",
        game_url=game.game_url or "",
        difficulty=game.difficulty or "easy",
        is_free=game.is_free or 1,
        tags=game.tags or "",
        play_count=game.play_count or 0,
        score=game.score or 0,
        score_count=game.score_count or 0,
        screenshots=[s.url for s in screenshots],
        category_name=category_name,
        is_favorited=fav is not None,
    )
    return ApiResponse(code=200, message="success", data=data.model_dump())


@router.post("/play/{game_id}", response_model=ApiResponse)
def game_play_start(
    game_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """开始游戏 - 创建游玩会话"""
    game = db.query(EntGame).filter(EntGame.id == game_id).first()
    if not game:
        return ApiResponse(code=404, message="游戏不存在")

    session_id = str(uuid.uuid4())[:16]
    record = EntGamePlayRecord(
        user_id=current_user.id,
        game_id=game_id,
        session_id=session_id,
        start_at=datetime.now(),
    )
    db.add(record)

    # 更新游玩次数
    game.play_count = (game.play_count or 0) + 1

    # 更新历史记录
    history = db.query(EntHistory).filter(
        EntHistory.user_id == current_user.id,
        EntHistory.content_type == "game",
        EntHistory.content_id == game_id,
    ).first()
    if history:
        history.last_at = datetime.now()
    else:
        db.add(EntHistory(
            user_id=current_user.id,
            content_type="game",
            content_id=game_id,
        ))

    db.commit()

    data = {
        "session_id": session_id,
        "game_url": game.game_url or "",
        "game_type": game.game_type or "h5",
    }
    return ApiResponse(code=200, message="开始游戏", data=data)


@router.post("/play/end/{game_id}", response_model=ApiResponse)
def game_play_end(
    game_id: int,
    req: GamePlayEndRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """结束游戏"""
    # 查找最近的游玩记录
    record = db.query(EntGamePlayRecord).filter(
        EntGamePlayRecord.user_id == current_user.id,
        EntGamePlayRecord.game_id == game_id,
    ).order_by(desc(EntGamePlayRecord.created_at)).first()

    if record and record.session_id == req.session_id:
        record.end_at = datetime.now()
        record.duration_sec = req.duration_sec or 0
        db.commit()

    return ApiResponse(code=200, message="游戏结束")


@router.get("/rank", response_model=ApiResponse)
def game_rank(
    rank_type: str = Query("hot"),
    limit: int = Query(20, ge=1, le=50),
    db: Session = Depends(get_db),
):
    """游戏排行榜"""
    query = db.query(EntGame).filter(EntGame.status == 1)

    if rank_type == "hot":
        query = query.order_by(desc(EntGame.play_count))
    elif rank_type == "new":
        query = query.order_by(desc(EntGame.created_at))
    elif rank_type == "score":
        query = query.order_by(desc(EntGame.score))
    elif rank_type == "duration":
        # 按总游玩时长排序
        query = query.order_by(desc(EntGame.play_count))
    else:
        query = query.order_by(desc(EntGame.play_count))

    games = query.limit(limit).all()

    result = []
    for i, g in enumerate(games):
        result.append(RankItem(
            rank=i + 1,
            id=g.id,
            title=g.title,
            cover_url=g.cover_url or "",
            score=g.score or 0,
            extra=f"{g.play_count or 0}次游玩",
        ).model_dump())

    return ApiResponse(code=200, message="success", data=result)


@router.get("/my", response_model=ApiResponse)
def my_games(
    type: str = Query("recent"),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """我的游戏"""
    if type == "recent":
        # 最近游玩
        records = db.query(EntHistory).filter(
            EntHistory.user_id == current_user.id,
            EntHistory.content_type == "game",
        ).order_by(desc(EntHistory.last_at)).limit(20).all()

        game_ids = [r.content_id for r in records]
        if not game_ids:
            return ApiResponse(code=200, message="success", data=[])

        games = db.query(EntGame).filter(EntGame.id.in_(game_ids)).all()
        game_map = {g.id: g for g in games}
        result = []
        for rid in game_ids:
            if rid in game_map:
                result.append(_game_to_item(game_map[rid]).model_dump())
        return ApiResponse(code=200, message="success", data=result)

    elif type == "favorite":
        # 我的收藏
        favs = db.query(EntFavorite).filter(
            EntFavorite.user_id == current_user.id,
            EntFavorite.content_type == "game",
        ).order_by(desc(EntFavorite.created_at)).limit(20).all()

        game_ids = [f.content_id for f in favs]
        if not game_ids:
            return ApiResponse(code=200, message="success", data=[])

        games = db.query(EntGame).filter(EntGame.id.in_(game_ids)).all()
        game_map = {g.id: g for g in games}
        result = []
        for fid in game_ids:
            if fid in game_map:
                result.append(_game_to_item(game_map[fid]).model_dump())
        return ApiResponse(code=200, message="success", data=result)

    return ApiResponse(code=200, message="success", data=[])


def _game_to_item(game: EntGame) -> GameListItem:
    """转换为列表项"""
    return GameListItem(
        id=game.id,
        title=game.title,
        cover_url=game.cover_url or "",
        description=game.description or "",
        category_id=game.category_id or 0,
        game_type=game.game_type or "h5",
        game_url=game.game_url or "",
        difficulty=game.difficulty or "easy",
        is_free=game.is_free or 1,
        tags=game.tags or "",
        play_count=game.play_count or 0,
        score=game.score or 0,
    )
