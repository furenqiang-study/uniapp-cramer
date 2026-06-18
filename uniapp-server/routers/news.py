"""
新闻现在 - 热点新闻聚合 API
数据来源：优先从 newsnow.busiyi.world 获取，失败时回退到本地 news.json
"""

import json
import os
import time
from pathlib import Path
from typing import Any, Dict, List, Optional

import httpx
from fastapi import APIRouter, Query

router = APIRouter(prefix="/api/news")

# ============================================================
# 全局缓存
# ============================================================
_cache: Dict[str, Any] = {"data": None, "ts": 0}
_CACHE_TTL = 300  # 5 分钟

NEWSNOW_API = "https://newsnow.busiyi.world/api/s/entire"
NEWSNOW_SOURCES = [
    "36kr-renqi", "baidu", "bilibili-hot-search", "chongbuluo-hot", "cls-hot",
    "coolapk", "douban", "douyin", "freebuf", "github-trending-today",
    "hackernews", "hupu", "ifeng", "iqiyi-hot-ranklist", "juejin",
    "nowcoder", "producthunt", "qqvideo-tv-hotsearch", "sspai", "steam",
    "tencent-hot", "thepaper", "tieba", "toutiao", "wallstreetcn-hot",
    "weibo", "xueqiu-hotstock", "zhihu",
]

# 本地备份数据路径（相对于项目根目录）
_LOCAL_JSON_PATH = Path(__file__).resolve().parent.parent.parent / "design" / "新闻现在模块" / "news.json"

# newsnow API id → 前端 sourceKey 映射
SOURCE_ID_MAP = {
    "zhihu": "zhihu",
    "weibo": "weibo",
    "baidu": "baidu",
    "douyin": "douyin",
    "bilibili-hot-search": "bilibili",
    "toutiao": "toutiao",
    "36kr-renqi": "36kr",
    "cls-hot": "cls",
    "coolapk": "coolapk",
    "chongbuluo-hot": "chongbuluo",
}

# 每个 sourceKey 的展示配置
NEWS_SOURCES = {
    "zhihu": {
        "name": "知乎",
        "icon": "/icons/zhihu.png",
        "color": "#0066FF",
        "bgColor": "#E8F0FE",
        "label": "热榜",
    },
    "weibo": {
        "name": "微博",
        "icon": "/icons/weibo.png",
        "color": "#FF4500",
        "bgColor": "#FFF0E8",
        "label": "实时热搜",
    },
    "baidu": {
        "name": "百度",
        "icon": "/icons/baidu.png",
        "color": "#2932E1",
        "bgColor": "#E8EAFF",
        "label": "热搜",
    },
    "douyin": {
        "name": "抖音",
        "icon": "/icons/douyin.png",
        "color": "#000000",
        "bgColor": "#F0F0F0",
        "label": "热搜",
    },
    "bilibili": {
        "name": "哔哩哔哩",
        "icon": "/icons/bilibili.png",
        "color": "#00A1D6",
        "bgColor": "#E8F6FA",
        "label": "热门",
    },
    "toutiao": {
        "name": "今日头条",
        "icon": "/icons/toutiao.png",
        "color": "#FF0000",
        "bgColor": "#FFE8E8",
        "label": "热榜",
    },
}


def _fetch_newsnow_data() -> Dict[str, List[dict]]:
    """
    从 newsnow.busiyi.world 获取全部数据，返回 {sourceKey: [items]} 的字典。
    带全局缓存。
    """
    now = time.time()
    if _cache["data"] is not None and now - _cache["ts"] < _CACHE_TTL:
        return _cache["data"]

    raw_list = None
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36",
        "Accept": "application/json, text/plain, */*",
        "Accept-Language": "zh-CN,zh;q=0.9,en;q=0.8",
        "Referer": "https://newsnow.busiyi.world/",
        "Origin": "https://newsnow.busiyi.world",
    }
    # 优先尝试在线 API（POST 请求，带 sources 列表）
    try:
        headers["Content-Type"] = "application/json"
        resp = httpx.post(
            NEWSNOW_API,
            timeout=15,
            headers=headers,
            follow_redirects=True,
            json={"sources": NEWSNOW_SOURCES},
        )
        resp.raise_for_status()
        raw_list = resp.json()
    except Exception:
        # 在线 API 失败，回退到本地 JSON 文件
        raw_list = None

    # 回退：读取本地 news.json
    if raw_list is None:
        if _LOCAL_JSON_PATH.exists():
            with open(_LOCAL_JSON_PATH, "r", encoding="utf-8") as f:
                raw_list = json.load(f)
        else:
            return {}

    result: Dict[str, List[dict]] = {}
    for entry in raw_list:
        raw_id = entry.get("id", "")
        source_key = SOURCE_ID_MAP.get(raw_id, raw_id)
        items = entry.get("items", [])
        parsed = []
        for idx, item in enumerate(items, 1):
            extra = item.get("extra") or {}
            parsed.append({
                "id": f"{source_key}_{idx}",
                "rank": idx,
                "title": item.get("title", ""),
                "url": item.get("url", ""),
                "hotValue": extra.get("info", ""),
                "description": extra.get("hover", ""),
            })
        result[source_key] = parsed

    _cache["data"] = result
    _cache["ts"] = now
    return result


def _enrich_items(items: List[dict], source_key: str) -> List[dict]:
    """给每条新闻附加来源信息"""
    src = NEWS_SOURCES.get(source_key, {})
    for item in items:
        item["sourceKey"] = source_key
        item["sourceName"] = src.get("name", source_key)
        item["sourceIcon"] = src.get("icon", "")
        item["sourceColor"] = src.get("color", "#333")
        item["sourceBgColor"] = src.get("bgColor", "#f5f5f5")
        item["sourceLabel"] = src.get("label", "热门")
    return items


# ============================================================
# 接口
# ============================================================

@router.get("/sources")
def get_news_sources():
    """获取所有可用的新闻源"""
    try:
        data = _fetch_newsnow_data()
        return {
            "code": 200,
            "data": [
                {
                    "key": k,
                    "name": v["name"],
                    "icon": v["icon"],
                    "color": v["color"],
                    "bgColor": v["bgColor"],
                    "label": v["label"],
                }
                for k, v in NEWS_SOURCES.items()
                if k in data
            ],
        }
    except Exception as e:
        return {"code": 500, "data": [], "message": str(e)}


@router.get("/list")
def get_news_list(
    category: str = Query("hottest", description="分类: hottest/latest"),
    sources: str = Query("", description="指定新闻源，逗号分隔，如 zhihu,weibo"),
):
    """获取新闻列表（聚合多个平台热点）"""
    try:
        data = _fetch_newsnow_data()

        if sources:
            source_keys = [s.strip() for s in sources.split(",") if s.strip() in data]
        else:
            source_keys = list(data.keys())

        all_news: List[dict] = []
        for key in source_keys:
            items = data.get(key, [])
            all_news.extend(_enrich_items([dict(i) for i in items], key))

        return {
            "code": 200,
            "data": all_news,
            "total": len(all_news),
            "sources": [
                {
                    "key": k,
                    "name": NEWS_SOURCES.get(k, {}).get("name", k),
                    "icon": NEWS_SOURCES.get(k, {}).get("icon", ""),
                    "color": NEWS_SOURCES.get(k, {}).get("color", "#333"),
                    "bgColor": NEWS_SOURCES.get(k, {}).get("bgColor", "#f5f5f5"),
                    "label": NEWS_SOURCES.get(k, {}).get("label", "热门"),
                    "count": len(data.get(k, [])),
                }
                for k in source_keys
            ],
        }
    except Exception as e:
        return {"code": 500, "data": [], "message": str(e)}


@router.get("/source/{source_key}")
def get_news_by_source(source_key: str):
    """获取指定新闻源的热点"""
    try:
        data = _fetch_newsnow_data()
        if source_key not in data:
            return {"code": 404, "data": [], "message": f"未知的新闻源: {source_key}"}

        items = _enrich_items([dict(i) for i in data[source_key]], source_key)
        src = NEWS_SOURCES.get(source_key, {})
        return {
            "code": 200,
            "data": items,
            "source": {
                "key": source_key,
                "name": src.get("name", source_key),
                "icon": src.get("icon", ""),
                "color": src.get("color", "#333"),
                "bgColor": src.get("bgColor", "#f5f5f5"),
                "label": src.get("label", "热门"),
            },
        }
    except Exception as e:
        return {"code": 500, "data": [], "message": str(e)}


@router.get("/categories")
def get_news_categories():
    """获取新闻分类列表"""
    return {
        "code": 200,
        "data": [
            {"key": "hottest", "label": "热门", "icon": "🔥"},
            {"key": "latest", "label": "最新", "icon": "⚡"},
        ],
    }