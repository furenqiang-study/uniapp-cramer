"""新闻现在模块 - 直接爬取各大新闻平台热点"""
import json
import re
import ssl
import urllib.request
from datetime import datetime
from fastapi import APIRouter, Query

router = APIRouter(prefix="/api/news", tags=["新闻现在"])

HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,application/json,*/*;q=0.8",
    "Accept-Language": "zh-CN,zh;q=0.9,en;q=0.8",
}

# 忽略 SSL 证书验证（某些国内站点证书问题）
_ssl_ctx = ssl.create_default_context()
_ssl_ctx.check_hostname = False
_ssl_ctx.verify_mode = ssl.CERT_NONE


def _fetch_url(url: str, timeout: int = 10, accept_json: bool = True):
    """通用请求，带重试和SSL容错"""
    req = urllib.request.Request(url)
    for k, v in HEADERS.items():
        req.add_header(k, v)
    if accept_json:
        req.add_header("Accept", "application/json, text/plain, */*")
        req.add_header("X-Requested-With", "XMLHttpRequest")
    resp = urllib.request.urlopen(req, timeout=timeout, context=_ssl_ctx)
    raw = resp.read()
    # 检查 Content-Type，如果是 HTML 说明被反爬了
    content_type = resp.headers.get("Content-Type", "")
    if "text/html" in content_type and accept_json:
        raise ValueError(f"Expected JSON but got HTML from {url}")
    # 尝试多种编码
    for encoding in ["utf-8", "gbk", "gb2312"]:
        try:
            return raw.decode(encoding)
        except (UnicodeDecodeError, LookupError):
            continue
    return raw.decode("utf-8", errors="replace")


def _fetch_zhihu_hot():
    """知乎热榜 - 使用第三方聚合API"""
    try:
        # 优先尝试第三方聚合接口
        try:
            url = "https://api.vvhan.com/api/hotlist/zhihu"
            text = _fetch_url(url, accept_json=True)
            data = json.loads(text)
            if data.get("success"):
                items = data.get("data", [])
                result = []
                for i, item in enumerate(items[:20]):
                    title = item.get("title", "")
                    hot = item.get("hot", "")
                    url_link = item.get("url", item.get("mobilUrl", ""))
                    if not title:
                        continue
                    result.append({
                        "id": f"zhihu_{i}",
                        "title": title,
                        "url": url_link if url_link else f"https://www.zhihu.com",
                        "description": "",
                        "hotValue": str(hot) if hot else "",
                        "image": "",
                    })
                if result:
                    return result
        except Exception as e:
            print(f"知乎聚合API失败，尝试官方接口: {e}")

        # 回退: 官方接口
        url = "https://www.zhihu.com/api/v3/feed/topstory/hot-lists/total?limit=20"
        text = _fetch_url(url, accept_json=True)
        data = json.loads(text)
        items = data.get("data", [])
        result = []
        for i, item in enumerate(items):
            target = item.get("target", {})
            title = target.get("titleArea", {}).get("text", "")
            excerpt = target.get("excerptArea", {}).get("text", "")
            link = target.get("link", {}).get("url", "")
            metrics = target.get("metricsArea", {}).get("text", "")
            image = target.get("imageArea", {}).get("url", "")
            if not title:
                continue
            result.append({
                "id": f"zhihu_{i}",
                "title": title,
                "url": link if link.startswith("http") else f"https://www.zhihu.com{link}",
                "description": excerpt,
                "hotValue": metrics,
                "image": image,
            })
        return result
    except Exception as e:
        print(f"知乎热榜获取失败: {e}")
        return []


def _fetch_weibo_hot():
    """微博热搜 - 多源兜底"""
    try:
        # 优先尝试第三方聚合接口
        try:
            url = "https://api.vvhan.com/api/hotlist/wbHot"
            text = _fetch_url(url, accept_json=True)
            data = json.loads(text)
            if data.get("success"):
                items = data.get("data", [])
                result = []
                for i, item in enumerate(items[:20]):
                    title = item.get("title", "")
                    hot = item.get("hot", "")
                    url_link = item.get("url", item.get("mobilUrl", ""))
                    if not title:
                        continue
                    result.append({
                        "id": f"weibo_{i}",
                        "title": title,
                        "url": url_link if url_link else f"https://weibo.com",
                        "description": "",
                        "hotValue": str(hot) if hot else "",
                        "image": "",
                    })
                if result:
                    return result
        except Exception as e:
            print(f"微博聚合API失败，尝试官方接口: {e}")

        # 回退: 官方接口
        url = "https://weibo.com/ajax/side/hotSearch"
        text = _fetch_url(url, accept_json=True)
        data = json.loads(text)
        realtime = data.get("data", {}).get("realtime", [])
        result = []
        for i, item in enumerate(realtime[:20]):
            word = item.get("word", "")
            num = item.get("num", 0)
            word_scheme = item.get("word_scheme", word)
            label_name = item.get("label_name", "")
            icon_desc = item.get("icon_desc", "")
            result.append({
                "id": f"weibo_{i}",
                "title": word,
                "url": f"https://s.weibo.com/weibo?q=%23{word_scheme}%23",
                "description": f"{icon_desc} {label_name}".strip() if icon_desc or label_name else "",
                "hotValue": f"{num}" if num else "",
                "image": "",
                "tag": label_name,
                "icon": icon_desc,
            })
        return result
    except Exception as e:
        print(f"微博热搜获取失败: {e}")
        return []


def _fetch_douyin_hot():
    """抖音热搜 - 多源兜底"""
    try:
        # 优先尝试第三方聚合接口
        try:
            url = "https://api.vvhan.com/api/hotlist/douyinHot"
            text = _fetch_url(url, accept_json=True)
            data = json.loads(text)
            if data.get("success"):
                items = data.get("data", [])
                result = []
                for i, item in enumerate(items[:20]):
                    title = item.get("title", "")
                    hot = item.get("hot", "")
                    url_link = item.get("url", item.get("mobilUrl", ""))
                    if not title:
                        continue
                    result.append({
                        "id": f"douyin_{i}",
                        "title": title,
                        "url": url_link if url_link else f"https://www.douyin.com",
                        "description": "",
                        "hotValue": str(hot) if hot else "",
                        "image": "",
                    })
                if result:
                    return result
        except Exception as e:
            print(f"抖音聚合API失败，尝试官方接口: {e}")

        # 回退: 官方接口
        url = "https://www.douyin.com/aweme/v1/web/hot/search/list/"
        text = _fetch_url(url, accept_json=True)
        data = json.loads(text)
        word_list = data.get("data", {}).get("word_list", [])
        result = []
        for i, item in enumerate(word_list[:20]):
            word = item.get("word", "")
            hot_value = item.get("hot_value", 0)
            result.append({
                "id": f"douyin_{i}",
                "title": word,
                "url": f"https://www.douyin.com/search/{word}",
                "description": "",
                "hotValue": f"{hot_value}" if hot_value else "",
                "image": "",
            })
        return result
    except Exception as e:
        print(f"抖音热搜获取失败: {e}")
        return []


def _fetch_baidu_hot():
    """百度热搜"""
    try:
        url = "https://top.baidu.com/board?tab=realtime"
        text = _fetch_url(url, accept_json=False)
        # 解析 JSON 数据
        pattern = r'<!--s-data:(.*?)-->'
        match = re.search(pattern, text, re.DOTALL)
        if match:
            json_str = match.group(1)
            data = json.loads(json_str)
            cards = data.get("data", {}).get("cards", [])
            result = []
            if cards:
                content = cards[0].get("content", [])
                for i, item in enumerate(content[:20]):
                    word = item.get("word", "")
                    desc = item.get("desc", "")
                    hot_score = item.get("hotScore", "")
                    url_link = item.get("url", "")
                    img = item.get("img", "")
                    result.append({
                        "id": f"baidu_{i}",
                        "title": word,
                        "url": url_link if url_link else f"https://www.baidu.com/s?wd={word}",
                        "description": desc,
                        "hotValue": str(hot_score) if hot_score else "",
                        "image": img,
                    })
            return result
        return []
    except Exception as e:
        print(f"百度热搜获取失败: {e}")
        return []


def _fetch_bilibili_hot():
    """B站热门"""
    try:
        url = "https://api.bilibili.com/x/web-interface/popular?ps=20&pn=1"
        text = _fetch_url(url, accept_json=True)
        data = json.loads(text)
        video_list = data.get("data", {}).get("list", [])
        result = []
        for i, item in enumerate(video_list[:20]):
            title = item.get("title", "")
            bvid = item.get("bvid", "")
            stat = item.get("stat", {})
            view = stat.get("view", 0)
            like = stat.get("like", 0)
            pic = item.get("pic", "")
            desc = item.get("desc", "")
            owner = item.get("owner", {}).get("name", "")
            result.append({
                "id": f"bilibili_{i}",
                "title": title,
                "url": f"https://www.bilibili.com/video/{bvid}" if bvid else "",
                "description": f"UP主: {owner} | {desc[:50]}" if desc else f"UP主: {owner}",
                "hotValue": f"{view}播放" if view else "",
                "image": pic if pic.startswith("http") else f"https:{pic}",
            })
        return result
    except Exception as e:
        print(f"B站热门获取失败: {e}")
        return []


def _fetch_toutiao_hot():
    """今日头条热榜"""
    try:
        url = "https://www.toutiao.com/hot-event/hot-board/?origin=toutiao_pc"
        text = _fetch_url(url, accept_json=True)
        data = json.loads(text)
        items = data.get("data", [])
        result = []
        for i, item in enumerate(items[:20]):
            title = item.get("Title", "")
            hot_value = item.get("HotValue", 0)
            url_link = item.get("Url", "")
            image = item.get("Image", {}).get("url", "") if isinstance(item.get("Image"), dict) else ""
            result.append({
                "id": f"toutiao_{i}",
                "title": title,
                "url": url_link if url_link else f"https://so.toutiao.com/search?keyword={title}",
                "description": "",
                "hotValue": str(hot_value) if hot_value else "",
                "image": image,
            })
        return result
    except Exception as e:
        print(f"头条热榜获取失败: {e}")
        return []


# 新闻源配置
NEWS_SOURCES = {
    "zhihu": {
        "name": "知乎",
        "icon": "/icons/zhihu.png",
        "color": "#0066FF",
        "bgColor": "#E8F0FE",
        "fetch": _fetch_zhihu_hot,
        "label": "热榜",
    },
    "weibo": {
        "name": "微博",
        "icon": "/icons/weibo.png",
        "color": "#FF4500",
        "bgColor": "#FFF0E8",
        "fetch": _fetch_weibo_hot,
        "label": "实时热搜",
    },
    "baidu": {
        "name": "百度",
        "icon": "/icons/baidu.png",
        "color": "#2932E1",
        "bgColor": "#E8EAFF",
        "fetch": _fetch_baidu_hot,
        "label": "热搜",
    },
    "douyin": {
        "name": "抖音",
        "icon": "/icons/douyin.png",
        "color": "#000000",
        "bgColor": "#F0F0F0",
        "fetch": _fetch_douyin_hot,
        "label": "热搜",
    },
    "bilibili": {
        "name": "哔哩哔哩",
        "icon": "/icons/bilibili.png",
        "color": "#00A1D6",
        "bgColor": "#E8F6FA",
        "fetch": _fetch_bilibili_hot,
        "label": "热门",
    },
    "toutiao": {
        "name": "今日头条",
        "icon": "/icons/toutiao.png",
        "color": "#FF0000",
        "bgColor": "#FFE8E8",
        "fetch": _fetch_toutiao_hot,
        "label": "热榜",
    },
}


@router.get("/list")
def get_news_list(
    category: str = Query("hottest", description="分类: hottest/latest"),
    sources: str = Query("", description="指定新闻源，逗号分隔，如 zhihu,weibo"),
):
    """获取新闻列表（聚合多个平台热点）"""
    try:
        # 确定要获取的源
        if sources:
            source_keys = [s.strip() for s in sources.split(",") if s.strip() in NEWS_SOURCES]
        else:
            source_keys = list(NEWS_SOURCES.keys())

        all_news = []
        for key in source_keys:
            source_info = NEWS_SOURCES[key]
            try:
                items = source_info["fetch"]()
                for item in items:
                    item["sourceKey"] = key
                    item["sourceName"] = source_info["name"]
                    item["sourceIcon"] = source_info["icon"]
                    item["sourceColor"] = source_info["color"]
                    item["sourceBgColor"] = source_info["bgColor"]
                    item["sourceLabel"] = source_info["label"]
                all_news.extend(items)
            except Exception as e:
                print(f"获取 {source_info['name']} 失败: {e}")
                continue

        return {
            "code": 200,
            "data": all_news,
            "total": len(all_news),
            "sources": [
                {
                    "key": k,
                    "name": v["name"],
                    "icon": v["icon"],
                    "color": v["color"],
                    "bgColor": v["bgColor"],
                    "label": v["label"],
                    "count": sum(1 for n in all_news if n.get("sourceKey") == k),
                }
                for k, v in NEWS_SOURCES.items()
                if k in source_keys
            ],
        }
    except Exception as e:
        return {"code": 500, "data": [], "message": str(e)}


@router.get("/source/{source_key}")
def get_news_by_source(
    source_key: str,
):
    """获取指定新闻源的热点"""
    if source_key not in NEWS_SOURCES:
        return {"code": 404, "data": [], "message": f"未知的新闻源: {source_key}"}

    source_info = NEWS_SOURCES[source_key]
    try:
        items = source_info["fetch"]()
        for item in items:
            item["sourceKey"] = source_key
            item["sourceName"] = source_info["name"]
            item["sourceIcon"] = source_info["icon"]
            item["sourceColor"] = source_info["color"]
            item["sourceBgColor"] = source_info["bgColor"]
            item["sourceLabel"] = source_info["label"]

        return {
            "code": 200,
            "data": items,
            "source": {
                "key": source_key,
                "name": source_info["name"],
                "icon": source_info["icon"],
                "color": source_info["color"],
                "bgColor": source_info["bgColor"],
                "label": source_info["label"],
            },
        }
    except Exception as e:
        return {"code": 500, "data": [], "message": str(e)}


@router.get("/sources")
def get_news_sources():
    """获取所有可用的新闻源"""
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
        ],
    }


@router.get("/categories")
def get_news_categories():
    """获取新闻分类列表（前端 tab 用）"""
    categories = [
        {"key": "hottest", "label": "热门", "icon": "🔥"},
        {"key": "latest", "label": "最新", "icon": "⚡"},
    ]
    return {"code": 200, "data": categories}