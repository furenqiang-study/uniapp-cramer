"""用户管理路由"""
from fastapi import APIRouter, Depends, HTTPException, Request, status
from sqlalchemy.orm import Session
from sqlalchemy import or_
from database import get_db
from models.user import User
from models.log import OperationLog
from schemas.user import UserInfo, ApiResponse, UserCreate, UserUpdateAdmin
from services.auth import hash_password, get_current_user

router = APIRouter(prefix="/api/users", tags=["用户管理"])


@router.get("", response_model=ApiResponse)
def get_user_list(
    keyword: str = "",
    role: str = "",
    status: int = -1,
    page: int = 1,
    page_size: int = 20,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """获取用户列表（分页、搜索、筛选）"""
    query = db.query(User)

    # 搜索过滤
    if keyword:
        query = query.filter(
            or_(
                User.username.like(f"%{keyword}%"),
                User.nickname.like(f"%{keyword}%"),
                User.phone.like(f"%{keyword}%"),
            )
        )
    if role:
        query = query.filter(User.role == role)
    if status >= 0:
        query = query.filter(User.status == status)

    # 总数
    total = query.count()

    # 分页
    items = query.order_by(User.id.desc()).offset((page - 1) * page_size).limit(page_size).all()

    return ApiResponse(
        code=200,
        message="success",
        data={
            "total": total,
            "page": page,
            "page_size": page_size,
            "list": [UserInfo.model_validate(u).model_dump() for u in items],
        },
    )


@router.get("/{user_id}", response_model=ApiResponse)
def get_user_detail(
    user_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """获取用户详情"""
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        return ApiResponse(code=404, message="用户不存在")
    return ApiResponse(code=200, message="success", data=UserInfo.model_validate(user).model_dump())


@router.post("", response_model=ApiResponse)
def create_user(
    data: UserCreate,
    request: Request,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """新增用户（仅admin）"""
    if current_user.role != "admin":
        return ApiResponse(code=403, message="无权限操作")

    existing = db.query(User).filter(User.username == data.username).first()
    if existing:
        return ApiResponse(code=400, message="用户名已存在")

    user = User(
        username=data.username,
        password=hash_password(data.password),
        nickname=data.nickname or data.username,
        phone=data.phone or "",
        role=data.role or "user",
        status=1,
    )
    db.add(user)
    db.commit()
    db.refresh(user)

    # 记录日志
    client_ip = request.client.host if request.client else ""
    log = OperationLog(
        user_id=current_user.id,
        username=current_user.username,
        action="create",
        module="user",
        detail=f"管理员创建用户 {user.username}",
        ip=client_ip,
    )
    db.add(log)
    db.commit()

    return ApiResponse(code=200, message="创建成功", data=UserInfo.model_validate(user).model_dump())


@router.put("/{user_id}", response_model=ApiResponse)
def update_user(
    user_id: int,
    data: UserUpdateAdmin,
    request: Request,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """编辑用户信息"""
    if current_user.role != "admin" and current_user.id != user_id:
        return ApiResponse(code=403, message="无权限操作")

    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        return ApiResponse(code=404, message="用户不存在")

    if data.nickname is not None:
        user.nickname = data.nickname
    if data.phone is not None:
        user.phone = data.phone
    if data.avatar is not None:
        user.avatar = data.avatar
    # 仅admin可修改角色
    if data.role is not None and current_user.role == "admin":
        user.role = data.role
    # 如果提供了新密码
    if data.password:
        user.password = hash_password(data.password)

    db.commit()
    db.refresh(user)

    # 记录日志
    client_ip = request.client.host if request.client else ""
    log = OperationLog(
        user_id=current_user.id,
        username=current_user.username,
        action="update",
        module="user",
        detail=f"编辑用户 {user.username}(ID:{user.id})",
        ip=client_ip,
    )
    db.add(log)
    db.commit()

    return ApiResponse(code=200, message="更新成功", data=UserInfo.model_validate(user).model_dump())


@router.put("/{user_id}/status", response_model=ApiResponse)
def toggle_user_status(
    user_id: int,
    request: Request,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """切换用户状态（启用/禁用）"""
    if current_user.role != "admin":
        return ApiResponse(code=403, message="无权限操作")

    if current_user.id == user_id:
        return ApiResponse(code=400, message="不能禁用自己")

    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        return ApiResponse(code=404, message="用户不存在")

    user.status = 0 if user.status == 1 else 1
    db.commit()

    status_text = "启用" if user.status == 1 else "禁用"
    client_ip = request.client.host if request.client else ""
    log = OperationLog(
        user_id=current_user.id,
        username=current_user.username,
        action="toggle_status",
        module="user",
        detail=f"{status_text}用户 {user.username}(ID:{user.id})",
        ip=client_ip,
    )
    db.add(log)
    db.commit()

    return ApiResponse(code=200, message=f"已{status_text}", data={"status": user.status})


@router.delete("/{user_id}", response_model=ApiResponse)
def delete_user(
    user_id: int,
    request: Request,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """删除用户（仅admin，不可删除自己）"""
    if current_user.role != "admin":
        return ApiResponse(code=403, message="无权限操作")

    if current_user.id == user_id:
        return ApiResponse(code=400, message="不能删除自己")

    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        return ApiResponse(code=404, message="用户不存在")

    username = user.username
    db.delete(user)
    db.commit()

    # 记录日志
    client_ip = request.client.host if request.client else ""
    log = OperationLog(
        user_id=current_user.id,
        username=current_user.username,
        action="delete",
        module="user",
        detail=f"删除用户 {username}(ID:{user_id})",
        ip=client_ip,
    )
    db.add(log)
    db.commit()

    return ApiResponse(code=200, message="删除成功")