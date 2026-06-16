"""菜单相关数据模型"""
from datetime import datetime
from typing import Optional, List
from pydantic import BaseModel


class MenuCreate(BaseModel):
    """创建菜单请求"""
    name: str
    icon: Optional[str] = ""
    path: Optional[str] = ""
    parent_id: Optional[int] = 0
    sort_order: Optional[int] = 0
    status: Optional[int] = 1


class MenuUpdate(BaseModel):
    """更新菜单请求"""
    name: Optional[str] = None
    icon: Optional[str] = None
    path: Optional[str] = None
    parent_id: Optional[int] = None
    sort_order: Optional[int] = None
    status: Optional[int] = None


class MenuInfo(BaseModel):
    """菜单信息响应"""
    id: int
    name: str
    icon: str
    path: str
    parent_id: int
    sort_order: int
    status: int
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
    children: Optional[List["MenuInfo"]] = None

    class Config:
        from_attributes = True