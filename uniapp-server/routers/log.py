"""操作日志路由"""
from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from sqlalchemy import desc
from database import get_db
from models.log import OperationLog
from models.user import User
from schemas.log import LogInfo
from schemas.user import ApiResponse
from services.auth import get_current_user

router = APIRouter(prefix="/api/logs", tags=["日志"])


@router.get("", response_model=ApiResponse)
def get_logs(
    page: int = Query(1, ge=1, description="页码"),
    page_size: int = Query(10, ge=1, le=100, description="每页条数"),
    action: str = Query(None, description="操作类型筛选"),
    module: str = Query(None, description="模块筛选"),
    username: str = Query(None, description="用户名筛选"),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """获取操作日志列表"""
    query = db.query(OperationLog)

    if action:
        query = query.filter(OperationLog.action == action)
    if module:
        query = query.filter(OperationLog.module == module)
    if username:
        query = query.filter(OperationLog.username.like(f"%{username}%"))

    total = query.count()
    logs = query.order_by(desc(OperationLog.created_at)).offset((page - 1) * page_size).limit(page_size).all()

    log_list = [LogInfo.model_validate(log).model_dump() for log in logs]

    return ApiResponse(
        code=200,
        message="success",
        data={
            "total": total,
            "page": page,
            "pageSize": page_size,
            "list": log_list,
        },
    )


@router.get("/{log_id}", response_model=ApiResponse)
def get_log_detail(
    log_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """获取日志详情"""
    log = db.query(OperationLog).filter(OperationLog.id == log_id).first()
    if not log:
        return ApiResponse(code=404, message="日志不存在")
    return ApiResponse(code=200, message="success", data=LogInfo.model_validate(log).model_dump())