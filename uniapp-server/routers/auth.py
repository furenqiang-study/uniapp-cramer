"""认证路由"""
from fastapi import APIRouter, Depends, HTTPException, Request, status
from sqlalchemy.orm import Session
from database import get_db
from models.user import User
from schemas.user import UserLogin, UserRegister, UserInfo, Token, ApiResponse
from services.auth import hash_password, verify_password, create_access_token, get_current_user
from models.log import OperationLog

router = APIRouter(prefix="/api/auth", tags=["认证"])


@router.post("/login", response_model=ApiResponse)
def login(data: UserLogin, request: Request, db: Session = Depends(get_db)):
    """用户登录"""
    user = db.query(User).filter(User.username == data.username).first()
    if not user:
        return ApiResponse(code=400, message="用户名或密码错误")
    if not verify_password(data.password, user.password):
        return ApiResponse(code=400, message="用户名或密码错误")
    if user.status == 0:
        return ApiResponse(code=403, message="用户已被禁用")

    # 创建Token
    access_token = create_access_token(data={"sub": str(user.id)})

    # 记录登录日志
    client_ip = request.client.host if request.client else ""
    log = OperationLog(
        user_id=user.id,
        username=user.username,
        action="login",
        module="auth",
        detail=f"用户 {user.username} 登录成功",
        ip=client_ip,
    )
    db.add(log)
    db.commit()

    user_info = UserInfo.model_validate(user)
    return ApiResponse(
        code=200,
        message="登录成功",
        data={
            "access_token": access_token,
            "token_type": "bearer",
            "user": user_info.model_dump(),
        },
    )


@router.post("/register", response_model=ApiResponse)
def register(data: UserRegister, db: Session = Depends(get_db)):
    """用户注册"""
    existing = db.query(User).filter(User.username == data.username).first()
    if existing:
        return ApiResponse(code=400, message="用户名已存在")

    user = User(
        username=data.username,
        password=hash_password(data.password),
        nickname=data.nickname or data.username,
    )
    db.add(user)
    db.commit()
    db.refresh(user)

    return ApiResponse(code=200, message="注册成功", data=UserInfo.model_validate(user).model_dump())


@router.get("/current", response_model=ApiResponse)
def get_current(current_user: User = Depends(get_current_user)):
    """获取当前用户信息"""
    user_info = UserInfo.model_validate(current_user)
    return ApiResponse(code=200, message="success", data=user_info.model_dump())


@router.post("/logout", response_model=ApiResponse)
def logout(request: Request, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    """用户登出"""
    client_ip = request.client.host if request.client else ""
    log = OperationLog(
        user_id=current_user.id,
        username=current_user.username,
        action="logout",
        module="auth",
        detail=f"用户 {current_user.username} 登出",
        ip=client_ip,
    )
    db.add(log)
    db.commit()
    return ApiResponse(code=200, message="登出成功")