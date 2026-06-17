"""新闻现在模块 - 代理 NewsNow API"""
import json
import urllib.request
from datetime import datetime
from fastapi import APIRouter, Query

router = APIRouter(prefix="/api/news", tags=["新闻现在"])

NEWSNOW_BASE = "https://newsnow.busiyi.world"


def _fetch_json(url: str, timeout: int = 10):
    """通用 JSON 请求"""
    req = urllib.request.Request(url)
    req.add_header("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36")
    req.add_header("Accept", "application/json")
    resp = urllib.request.urlopen(req, timeout=timeout)
    return json.loads(resp.read().decode("utf-8"))


@router.get("/list")
def get_news_list(
    category: str = Query("hottest", description="分类: hottest/latest/custom"),
):
    """获取新闻列表（聚合接口，兼容前端不同 tab）"""
    # 映射前端 tab 到 NewsNow 可用的端点
    endpoint_map = {
        "hottest": "/api/news/hottest",
        "latest": "/api/news/latest",
    }
    endpoint = endpoint_map.get(category, "/api/news/hottest")
    try:
        data = _fetch_json(f"{NEWSNOW_BASE}{endpoint}")
        # 确保返回列表
        items = data if isinstance(data, list) else data.get("items", data.get("data", []))
        # 标准化字段
        result = []
        for item in items:
            result.append({
                "id": item.get("id", ""),
                "title": item.get("title", ""),
                "url": item.get("url", ""),
                "mobileUrl": item.get("mobileUrl", item.get("url", "")),
                "description": item.get("description", ""),
                "source": item.get("extra", {}).get("info", {}).get("name", item.get("source", "")),
                "icon": item.get("extra", {}).get("info", {}).get("icon", ""),
                "timestamp": item.get("extra", {}).get("info", {}).get("time", item.get("timestamp", "")),
                "engagement": item.get("extra", {}).get("info", {}).get("engagement", ""),
            })
        return {"code": 200, "data": result, "total": len(result)}
    except Exception as e:
        return {"code": 500, "data": [], "message": str(e)}


@router.get("/sources")
def get_news_sources():
    """获取所有可用的新闻源"""
    try:
        data = _fetch_json(f"{NEWSNOW_BASE}/api/sources")
        return {"code": 200, "data": data}
    except Exception as e:
        return {"code": 500, "data": [], "message": str(e)}


@router.get("/categories")
def get_news_categories():
    """获取新闻分类列表（前端 tab 用）"""
    categories = [
        {"key": "hottest", "label": "最热", "icon": "🔥"},
        {"key": "latest", "label": "最新", "icon": "⚡"},
    ]
    return {"code": 200, "data": categories}