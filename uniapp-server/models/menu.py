"""菜单模型"""
from datetime import datetime
from sqlalchemy import Column, Integer, String, DateTime, SmallInteger
from database import Base


class Menu(Base):
    __tablename__ = "menus"

    id = Column(Integer, primary_key=True, autoincrement=True, comment="菜单ID")
    name = Column(String(50), nullable=False, comment="菜单名称")
    icon = Column(String(100), default="", comment="图标")
    path = Column(String(100), default="", comment="页面路径")
    parent_id = Column(Integer, default=0, comment="父菜单ID(0为顶级)")
    sort_order = Column(Integer, default=0, comment="排序")
    status = Column(SmallInteger, default=1, comment="状态(0禁用/1启用)")
    created_at = Column(DateTime, default=datetime.now, comment="创建时间")
    updated_at = Column(DateTime, default=datetime.now, onupdate=datetime.now, comment="更新时间")