"""用户信息路由"""
from fastapi import APIRouter, Depends, Request
from sqlalchemy.orm import Session
from database import get_db
from models.user import User
from models.log import OperationLog
from schemas.user import UserInfo, UserUpdate, ApiResponse
from services.auth import get_current_user

router = APIRouter(prefix="/api/users", tags=["用户"])


@router.get("/profile", response_model=ApiResponse)
def get_profile(current_user: User = Depends(get_current_user)):
    """获取用户个人信息"""
    user_info = UserInfo.model_validate(current_user)
    return ApiResponse(code=200, message="success", data=user_info.model_dump())


@router.put("/profile", response_model=ApiResponse)
def update_profile(
    data: UserUpdate,
    request: Request,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """更新用户个人信息"""
    update_data = data.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        if value is not None:
            setattr(current_user, key, value)
    db.commit()
    db.refresh(current_user)

    # 记录日志
    client_ip = request.client.host if request.client else ""
    log = OperationLog(
        user_id=current_user.id,
        username=current_user.username,
        action="update",
        module="user",
        detail=f"更新个人信息",
        ip=client_ip,
    )
    db.add(log)
    db.commit()

    user_info = UserInfo.model_validate(current_user)
    return ApiResponse(code=200, message="更新成功", data=user_info.model_dump())