"""用户模型"""
from datetime import datetime
from sqlalchemy import Column, Integer, String, DateTime, SmallInteger
from database import Base


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, autoincrement=True, comment="用户ID")
    username = Column(String(50), unique=True, nullable=False, index=True, comment="用户名")
    password = Column(String(255), nullable=False, comment="密码(bcrypt加密)")
    nickname = Column(String(50), default="", comment="昵称")
    avatar = Column(String(255), default="", comment="头像URL")
    phone = Column(String(20), default="", comment="手机号")
    role = Column(String(20), default="user", comment="角色(admin/user)")
    status = Column(SmallInteger, default=1, comment="状态(0禁用/1启用)")
    created_at = Column(DateTime, default=datetime.now, comment="创建时间")
    updated_at = Column(DateTime, default=datetime.now, onupdate=datetime.now, comment="更新时间")