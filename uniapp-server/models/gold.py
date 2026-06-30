"""黄金预测数据模型"""
from datetime import datetime
from sqlalchemy import Column, Integer, String, Float, DateTime, Text
from database import Base


class GoldPrice(Base):
    __tablename__ = "gold_prices"

    id = Column(Integer, primary_key=True, autoincrement=True, comment="主键")
    date = Column(String(20), nullable=False, unique=True, index=True, comment="日期 YYYY-MM-DD")
    price_cny = Column(Float, nullable=False, default=0, comment="人民币金价(元/克)")
    price_usd = Column(Float, default=0, comment="美元金价(美元/盎司)")
    change_pct = Column(Float, default=0, comment="涨跌幅(%)")
    open = Column(Float, default=0, comment="开盘价(元/克)")
    high = Column(Float, default=0, comment="最高价(元/克)")
    low = Column(Float, default=0, comment="最低价(元/克)")
    close = Column(Float, default=0, comment="收盘价(元/克)")
    volume = Column(Integer, default=0, comment="成交量")
    created_at = Column(DateTime, default=datetime.now, comment="创建时间")


class GoldPrediction(Base):
    __tablename__ = "gold_predictions"

    id = Column(Integer, primary_key=True, autoincrement=True, comment="主键")
    user_id = Column(Integer, nullable=False, index=True, comment="用户ID")
    predict_date = Column(String(20), nullable=False, comment="预测目标日期")
    predict_price = Column(Float, nullable=False, default=0, comment="预测价格(元/克)")
    algorithm = Column(String(20), nullable=False, default="ensemble", comment="预测模型: ma/ema/lr/ensemble")
    params = Column(Text, comment="预测参数JSON")
    confidence = Column(Float, default=0, comment="置信度(0-100)")
    trend = Column(String(10), default="up", comment="趋势: up/down/stable")
    change_pct = Column(Float, default=0, comment="预测涨跌幅(%)")
    created_at = Column(DateTime, default=datetime.now, comment="创建时间")
