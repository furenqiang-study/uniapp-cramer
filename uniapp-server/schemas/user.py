"""用户相关数据模型"""
from datetime import datetime
from typing import Optional
from pydantic import BaseModel


class UserLogin(BaseModel):
    """登录请求"""
    username: str
    password: str


class UserRegister(BaseModel):
    """注册请求"""
    username: str
    password: str
    nickname: Optional[str] = ""


class UserInfo(BaseModel):
    """用户信息响应"""
    id: int
    username: str
    nickname: str
    avatar: str
    phone: str
    role: str
    status: int
    created_at: Optional[datetime] = None

    class Config:
        from_attributes = True


class UserUpdate(BaseModel):
    """更新用户信息"""
    nickname: Optional[str] = None
    avatar: Optional[str] = None
    phone: Optional[str] = None


class UserCreate(BaseModel):
    """管理员创建用户"""
    username: str
    password: str
    nickname: Optional[str] = ""
    phone: Optional[str] = ""
    role: Optional[str] = "user"


class UserUpdateAdmin(BaseModel):
    """管理员编辑用户"""
    nickname: Optional[str] = None
    avatar: Optional[str] = None
    phone: Optional[str] = None
    role: Optional[str] = None
    password: Optional[str] = None


class Token(BaseModel):
    """Token响应"""
    access_token: str
    token_type: str = "bearer"
    user: UserInfo


class ApiResponse(BaseModel):
    """通用API响应"""
    code: int = 200
    message: str = "success"
    data: Optional[object] = None