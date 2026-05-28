"""首页路由"""
from datetime import datetime, date
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy import func
from database import get_db
from models.user import User
from models.menu import Menu
from models.log import OperationLog
from schemas.user import ApiResponse
from services.auth import get_current_user

router = APIRouter(prefix="/api/home", tags=["首页"])


@router.get("/stats", response_model=ApiResponse)
def get_home_stats(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """获取首页统计数据"""
    user_count = db.query(func.count(User.id)).scalar() or 0
    menu_count = db.query(func.count(Menu.id)).scalar() or 0
    log_count = db.query(func.count(OperationLog.id)).scalar() or 0

    # 今日操作数
    today = datetime.combine(date.today(), datetime.min.time())
    today_log_count = (
        db.query(func.count(OperationLog.id))
        .filter(OperationLog.created_at >= today)
        .scalar()
        or 0
    )

    # 最近登录记录
    recent_logins = (
        db.query(OperationLog)
        .filter(OperationLog.action == "login")
        .order_by(OperationLog.created_at.desc())
        .limit(5)
        .all()
    )
    recent_login_list = [
        {
            "id": log.id,
            "username": log.username,
            "detail": log.detail,
            "created_at": log.created_at.strftime("%Y-%m-%d %H:%M:%S") if log.created_at else "",
        }
        for log in recent_logins
    ]

    return ApiResponse(
        code=200,
        message="success",
        data={
            "userCount": user_count,
            "menuCount": menu_count,
            "logCount": log_count,
            "todayLogCount": today_log_count,
            "recentLogins": recent_login_list,
        },
    )