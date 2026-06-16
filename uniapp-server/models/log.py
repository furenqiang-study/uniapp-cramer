"""操作日志模型"""
from datetime import datetime
from sqlalchemy import Column, Integer, String, DateTime, Text
from database import Base


class OperationLog(Base):
    __tablename__ = "operation_logs"

    id = Column(Integer, primary_key=True, autoincrement=True, comment="日志ID")
    user_id = Column(Integer, default=None, comment="操作用户ID")
    username = Column(String(50), default="", comment="操作用户名")
    action = Column(String(50), nullable=False, comment="操作类型(login/create/update/delete)")
    module = Column(String(50), default="", comment="模块名(menu/user等)")
    detail = Column(Text, default="", comment="操作详情")
    ip = Column(String(50), default="", comment="操作IP")
    created_at = Column(DateTime, default=datetime.now, comment="创建时间")