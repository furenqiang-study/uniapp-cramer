"""黄金预测路由"""
import json
import math
import random
import re
import time
from datetime import datetime, timedelta
from typing import List, Optional
from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from database import get_db
from models.gold import GoldPrice, GoldPrediction
from models.user import User
from schemas.gold import (
    GoldPriceInfo, GoldPredictRequest, GoldPredictionInfo,
    GoldPredictResult, GoldPredictParams, GoldRealtimeInfo
)
from schemas.user import ApiResponse
from services.auth import get_current_user

router = APIRouter(prefix="/api/gold", tags=["黄金预测"])

_realtime_cache: dict = {}
_REALTIME_CACHE_TTL = 30


def _fetch_realtime_gold() -> dict:
    """从汇率表抓取实时金价数据"""
    now = time.time()
    if _realtime_cache and now - _realtime_cache.get("_ts", 0) < _REALTIME_CACHE_TTL:
        return _realtime_cache

    try:
        import httpx
        url = f"https://www.huilvbiao.com/api/gold_indexApi?t={int(now * 1000)}"
        headers = {
            "User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15",
            "Referer": "https://www.huilvbiao.com/gold",
            "X-Requested-With": "XMLHttpRequest",
            "Accept": "*/*",
        }
        resp = httpx.get(url, headers=headers, timeout=10)
        text = resp.text

        def _parse_var(name: str) -> list:
            m = re.search(rf'var\s+{name}\s*=\s*"([^"]*)"', text)
            if not m:
                return []
            return m.group(1).split(",")

        def _safe_float(val, default=0.0):
            try:
                return float(val) if val else default
            except (ValueError, TypeError):
                return default

        def _safe_int(val, default=0):
            try:
                return int(val) if val and val.isdigit() else default
            except (ValueError, TypeError):
                return default

        autd = _parse_var("hq_str_gds_AUTD")
        gc = _parse_var("hq_str_hf_GC")
        xau = _parse_var("hq_str_hf_XAU")

        result = {"_ts": now}

        if len(autd) >= 14:
            result["shanghai"] = {
                "price": _safe_float(autd[0]),
                "yesterday_close": _safe_float(autd[2]),
                "open": _safe_float(autd[3]),
                "high": _safe_float(autd[4]),
                "low": _safe_float(autd[5]),
                "time": autd[6] if len(autd) > 6 else "",
                "prev_settle": _safe_float(autd[7]),
                "volume": _safe_int(autd[9]),
                "change": _safe_float(autd[10]),
                "change_pct": _safe_float(autd[11]),
                "date": autd[12] if len(autd) > 12 else "",
                "name": autd[13] if len(autd) > 13 else "黄金延期",
            }

        if len(gc) >= 14:
            result["newyork"] = {
                "price": _safe_float(gc[0]),
                "open": _safe_float(gc[3]),
                "high": _safe_float(gc[4]),
                "low": _safe_float(gc[5]),
                "time": gc[6] if len(gc) > 6 else "",
                "prev_settle": _safe_float(gc[7]),
                "date": gc[12] if len(gc) > 12 else "",
                "name": gc[13] if len(gc) > 13 else "纽约黄金",
            }

        if len(xau) >= 14:
            result["london"] = {
                "price": _safe_float(xau[0]),
                "prev_close": _safe_float(xau[1]),
                "open": _safe_float(xau[3]),
                "high": _safe_float(xau[4]),
                "low": _safe_float(xau[5]),
                "time": xau[6] if len(xau) > 6 else "",
                "date": xau[12] if len(xau) > 12 else "",
                "name": xau[13] if len(xau) > 13 else "伦敦金",
            }

        _realtime_cache.clear()
        _realtime_cache.update(result)
        return result
    except Exception:
        return _realtime_cache or {}


def _predict_ma(prices: List[float], days: int) -> List[float]:
    """移动平均预测"""
    if not prices:
        return []
    window = min(5, len(prices))
    result = []
    current = prices[-1]
    for i in range(days):
        start_idx = max(0, len(prices) - window)
        avg = sum(prices[start_idx:]) / len(prices[start_idx:])
        noise = random.gauss(0, current * 0.003)
        current = avg + noise
        result.append(round(current, 2))
        prices = prices[1:] + [current]
    return result


def _predict_ema(prices: List[float], days: int, alpha: float = 0.3) -> List[float]:
    """指数平滑预测"""
    if not prices:
        return []
    ema = prices[0]
    for p in prices[1:]:
        ema = alpha * p + (1 - alpha) * ema
    result = []
    current = ema
    for i in range(days):
        noise = random.gauss(0, current * 0.002)
        current = current + noise
        result.append(round(current, 2))
    return result


def _predict_lr(prices: List[float], days: int) -> List[float]:
    """线性回归预测"""
    n = len(prices)
    if n < 2:
        return [prices[-1]] * days if prices else []
    x = list(range(n))
    x_mean = sum(x) / n
    y_mean = sum(prices) / n
    numerator = sum((x[i] - x_mean) * (prices[i] - y_mean) for i in range(n))
    denominator = sum((x[i] - x_mean) ** 2 for i in range(n))
    if denominator == 0:
        return [prices[-1]] * days
    slope = numerator / denominator
    intercept = y_mean - slope * x_mean
    result = []
    for i in range(days):
        pred = slope * (n + i) + intercept
        noise = random.gauss(0, abs(slope) * 0.5 + prices[-1] * 0.002)
        result.append(round(pred + noise, 2))
    return result


def _predict_ensemble(prices: List[float], days: int) -> List[float]:
    """集成模型预测（加权平均）"""
    ma = _predict_ma(prices[:], days)
    ema = _predict_ema(prices[:], days)
    lr = _predict_lr(prices[:], days)
    result = []
    for i in range(days):
        val = ma[i] * 0.3 + ema[i] * 0.3 + lr[i] * 0.4
        result.append(round(val, 2))
    return result


PREDICT_FUNCS = {
    "ma": _predict_ma,
    "ema": _predict_ema,
    "lr": _predict_lr,
    "ensemble": _predict_ensemble,
}

MODEL_NAMES = {
    "ma": "移动平均",
    "ema": "指数平滑",
    "lr": "线性回归",
    "ensemble": "集成模型",
}


def _calc_confidence(prices: List[float], algorithm: str) -> float:
    """计算置信度"""
    if len(prices) < 5:
        return 40.0
    recent = prices[-5:]
    volatility = max(recent) - min(recent)
    avg_price = sum(recent) / len(recent)
    vol_pct = volatility / avg_price if avg_price > 0 else 1
    base_conf = max(30, min(90, 85 - vol_pct * 200))
    model_bonus = {"ensemble": 5, "lr": 3, "ema": 2, "ma": 0}
    base_conf += model_bonus.get(algorithm, 0)
    data_bonus = min(10, len(prices) * 0.5)
    return round(min(95, base_conf + data_bonus), 1)


def _fetch_kline_data() -> list:
    """从汇率表抓取AUTD K线历史数据"""
    try:
        import httpx
        url = "https://www.huilvbiao.com/api/gold_autd_kline"
        headers = {
            "User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15",
            "Referer": "https://www.huilvbiao.com/gold/autd",
            "X-Requested-With": "XMLHttpRequest",
            "Accept": "application/json, text/javascript, */*; q=0.01",
        }
        resp = httpx.get(url, headers=headers, timeout=15)
        data = resp.json()
        if isinstance(data, list) and len(data) > 0:
            return data
        return []
    except Exception:
        return []


def _ensure_real_data(db: Session):
    """确保数据库有真实金价数据，优先从API拉取"""
    count = db.query(GoldPrice).count()
    if count > 0:
        return

    kline = _fetch_kline_data()
    if kline:
        existing_dates = set(
            r.date for r in db.query(GoldPrice.date).all()
        )
        records = []
        for item in kline:
            day = item.get("day", "")
            if not day:
                continue
            date_str = day.replace("/", "-")
            if date_str in existing_dates:
                continue
            close = float(item.get("close", 0) or 0)
            open_p = float(item.get("open", 0) or 0)
            high = float(item.get("high", 0) or 0)
            low = float(item.get("low", 0) or 0)
            change = float(item.get("change", 0) or 0)
            volume = int(item.get("volume", 0) or 0)
            prev_close = close - change
            change_pct = round(change / prev_close * 100, 2) if prev_close != 0 else 0
            price_usd = round(close * 31.1035 / 7.25, 2) if close > 0 else 0
            records.append(GoldPrice(
                date=date_str,
                price_cny=round(close, 2),
                price_usd=price_usd,
                change_pct=change_pct,
                open=round(open_p, 2),
                high=round(high, 2),
                low=round(low, 2),
                close=round(close, 2),
                volume=volume,
            ))
        if records:
            db.add_all(records)
            db.commit()
        return


@router.get("/realtime", response_model=ApiResponse)
def get_realtime_price():
    """获取实时金价（来自汇率表）"""
    data = _fetch_realtime_gold()
    if not data or "shanghai" not in data:
        return ApiResponse(code=503, message="实时金价数据获取失败，请稍后重试")
    return ApiResponse(code=200, message="success", data=data)


@router.get("/prices", response_model=ApiResponse)
def get_prices(
    days: int = Query(30, description="获取最近N天数据"),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """获取历史价格列表"""
    _ensure_real_data(db)
    records = db.query(GoldPrice).order_by(
        GoldPrice.date.desc()
    ).limit(days).all()
    records = list(reversed(records))
    data = [GoldPriceInfo.model_validate(r).model_dump() for r in records]
    return ApiResponse(code=200, message="success", data=data)


@router.get("/latest", response_model=ApiResponse)
def get_latest_price(
    db: Session = Depends(get_db),
):
    """获取最新金价（优先实时数据）"""
    rt = _fetch_realtime_gold()
    if rt and "shanghai" in rt:
        sh = rt["shanghai"]
        data = {
            "id": 0,
            "date": sh.get("date", ""),
            "price_cny": sh.get("price", 0),
            "price_usd": rt.get("newyork", {}).get("price", 0),
            "change_pct": sh.get("change_pct", 0),
            "open": sh.get("open", 0),
            "high": sh.get("high", 0),
            "low": sh.get("low", 0),
            "close": sh.get("price", 0),
            "volume": sh.get("volume", 0),
            "created_at": None,
            "is_realtime": True,
            "update_time": sh.get("time", ""),
            "source": "上海黄金交易所",
        }
        return ApiResponse(code=200, message="success", data=data)

    _ensure_real_data(db)
    latest = db.query(GoldPrice).order_by(GoldPrice.date.desc()).first()
    if not latest:
        return ApiResponse(code=404, message="暂无价格数据")
    data = GoldPriceInfo.model_validate(latest).model_dump()
    data["is_realtime"] = False
    return ApiResponse(code=200, message="success", data=data)


@router.get("/predict", response_model=ApiResponse)
def predict_gold(
    days: int = Query(7, description="预测天数"),
    algorithm: str = Query("ensemble", description="预测模型"),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """执行黄金价格预测"""
    _ensure_real_data(db)

    if days < 1 or days > 30:
        return ApiResponse(code=400, message="预测天数需在1-30之间")
    if algorithm not in PREDICT_FUNCS:
        return ApiResponse(code=400, message=f"不支持的模型类型: {algorithm}")

    records = db.query(GoldPrice).order_by(GoldPrice.date.asc()).all()
    if len(records) < 5:
        return ApiResponse(code=400, message="历史数据不足，至少需要5条")

    prices = [r.price_cny for r in records]
    latest = records[-1]

    rt = _fetch_realtime_gold()
    if rt and "shanghai" in rt:
        current_price = rt["shanghai"].get("price", latest.price_cny)
        current_date = rt["shanghai"].get("date", latest.date)
        if current_price > 0:
            prices.append(current_price)
    else:
        current_price = latest.price_cny
        current_date = latest.date

    predict_func = PREDICT_FUNCS[algorithm]
    predicted_prices = predict_func(prices[:], days)
    confidence = _calc_confidence(prices, algorithm)

    predictions = []
    for i, pred_price in enumerate(predicted_prices):
        target_date = (datetime.strptime(current_date, "%Y-%m-%d") + timedelta(days=i + 1)).strftime("%Y-%m-%d")
        change = round((pred_price - current_price) / current_price * 100, 2) if current_price > 0 else 0
        if change > 0.5:
            trend = "up"
        elif change < -0.5:
            trend = "down"
        else:
            trend = "stable"
        predictions.append(GoldPredictionInfo(
            predict_date=target_date,
            predict_price=pred_price,
            algorithm=algorithm,
            confidence=round(confidence - i * 0.5, 1),
            trend=trend,
            change_pct=change,
        ))

    up_count = sum(1 for p in predictions if p.trend == "up")
    down_count = sum(1 for p in predictions if p.trend == "down")
    if up_count > down_count:
        trend_summary = "up"
    elif down_count > up_count:
        trend_summary = "down"
    else:
        trend_summary = "stable"

    result = GoldPredictResult(
        current_price=current_price,
        current_date=current_date,
        algorithm=algorithm,
        predictions=predictions,
        confidence_avg=confidence,
        trend_summary=trend_summary,
    )

    pred_record = GoldPrediction(
        user_id=current_user.id,
        predict_date=predictions[-1].predict_date if predictions else current_date,
        predict_price=predictions[-1].predict_price if predictions else current_price,
        algorithm=algorithm,
        params=json.dumps({"days": days, "algorithm": algorithm}, ensure_ascii=False),
        confidence=confidence,
        trend=trend_summary,
        change_pct=predictions[-1].change_pct if predictions else 0,
    )
    db.add(pred_record)
    db.commit()

    return ApiResponse(code=200, message="预测成功", data=result.model_dump())


@router.get("/predictions", response_model=ApiResponse)
def get_predictions(
    limit: int = Query(20, description="获取条数"),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """获取历史预测记录"""
    records = db.query(GoldPrediction).filter(
        GoldPrediction.user_id == current_user.id
    ).order_by(GoldPrediction.created_at.desc()).limit(limit).all()

    data = []
    for r in records:
        item = GoldPredictionInfo(
            id=r.id,
            predict_date=r.predict_date,
            predict_price=r.predict_price,
            algorithm=r.algorithm,
            confidence=r.confidence,
            trend=r.trend,
            change_pct=r.change_pct,
            created_at=r.created_at,
        )
        data.append(item.model_dump())

    return ApiResponse(code=200, message="success", data=data)


@router.get("/params", response_model=ApiResponse)
def get_predict_params():
    """获取预测参数选项"""
    data = GoldPredictParams(
        days_options=[
            {"value": 7, "label": "7天预测", "desc": "短期趋势预测"},
            {"value": 14, "label": "14天预测", "desc": "中期趋势预测"},
            {"value": 30, "label": "30天预测", "desc": "长期趋势预测"},
        ],
        algorithm_options=[
            {"value": "ma", "label": "移动平均", "desc": "基于近期均价预测，适合震荡行情"},
            {"value": "ema", "label": "指数平滑", "desc": "加权近期数据，反应更灵敏"},
            {"value": "lr", "label": "线性回归", "desc": "基于趋势线预测，适合单边行情"},
            {"value": "ensemble", "label": "集成模型", "desc": "综合多种模型，预测更稳健"},
        ],
    )
    return ApiResponse(code=200, message="success", data=data.model_dump())

