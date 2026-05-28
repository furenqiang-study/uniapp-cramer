"""日志相关数据模型"""
from datetime import datetime
from typing import Optional
from pydantic import BaseModel


class LogCreate(BaseModel):
    """创建日志"""
    user_id: Optional[int] = None
    username: Optional[str] = ""
    action: str
    module: Optional[str] = ""
    detail: Optional[str] = ""
    ip: Optional[str] = ""


class LogInfo(BaseModel):
    """日志信息响应"""
    id: int
    user_id: Optional[int] = None
    username: str
    action: str
    module: str
    detail: str
    ip: str
    created_at: Optional[datetime] = None

    class Config:
        from_attributes = True


class LogQuery(BaseModel):
    """日志查询参数"""
    page: int = 1
    page_size: int = 10
    action: Optional[str] = None
    module: Optional[str] = None
    username: Optional[str] = None