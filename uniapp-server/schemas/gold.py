"""黄金预测相关数据模型"""
from datetime import datetime
from typing import Optional, List
from pydantic import BaseModel


class GoldPriceInfo(BaseModel):
    """黄金价格信息"""
    id: int
    date: str
    price_cny: float
    price_usd: Optional[float] = 0
    change_pct: Optional[float] = 0
    open: Optional[float] = 0
    high: Optional[float] = 0
    low: Optional[float] = 0
    close: Optional[float] = 0
    volume: Optional[int] = 0
    created_at: Optional[datetime] = None
    is_realtime: Optional[bool] = False
    update_time: Optional[str] = ""
    source: Optional[str] = ""

    class Config:
        from_attributes = True


class GoldRealtimeInfo(BaseModel):
    """实时金价信息"""
    shanghai: Optional[dict] = None
    newyork: Optional[dict] = None
    london: Optional[dict] = None


class GoldPredictRequest(BaseModel):
    """预测请求"""
    days: int = 7
    algorithm: str = "ensemble"


class GoldPredictionInfo(BaseModel):
    """预测结果信息"""
    id: Optional[int] = None
    predict_date: str
    predict_price: float
    algorithm: str = "ensemble"
    confidence: float = 0
    trend: str = "stable"
    change_pct: float = 0
    created_at: Optional[datetime] = None

    class Config:
        from_attributes = True


class GoldPredictResult(BaseModel):
    """完整预测结果"""
    current_price: float
    current_date: str
    algorithm: str
    predictions: List[GoldPredictionInfo]
    confidence_avg: float = 0
    trend_summary: str = "stable"


class GoldPredictParams(BaseModel):
    """预测参数选项"""
    days_options: List[dict] = []
    algorithm_options: List[dict] = []
