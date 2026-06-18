"""
天气预报 API
数据来源：腾讯天气 (i.news.qq.com)
"""

import time
from typing import Any, Dict, List, Optional

import httpx
from fastapi import APIRouter, Query

router = APIRouter(prefix="/api/weather")

# ============================================================
# 全局缓存
# ============================================================
_cache: Dict[str, Any] = {}
_CACHE_TTL = 1800  # 30 分钟

# 热门城市列表（含省份，腾讯天气接口需要）
HOT_CITIES = [
    {"code": "beijing", "name": "北京", "province": "北京"},
    {"code": "shanghai", "name": "上海", "province": "上海"},
    {"code": "guangzhou", "name": "广州", "province": "广东"},
    {"code": "shenzhen", "name": "深圳", "province": "广东"},
    {"code": "chengdu", "name": "成都", "province": "四川"},
    {"code": "hangzhou", "name": "杭州", "province": "浙江"},
    {"code": "wuhan", "name": "武汉", "province": "湖北"},
    {"code": "nanjing", "name": "南京", "province": "江苏"},
    {"code": "chongqing", "name": "重庆", "province": "重庆"},
    {"code": "xian", "name": "西安", "province": "陕西"},
    {"code": "changsha", "name": "长沙", "province": "湖南"},
    {"code": "tianjin", "name": "天津", "province": "天津"},
    {"code": "suzhou", "name": "苏州", "province": "江苏"},
    {"code": "zhengzhou", "name": "郑州", "province": "河南"},
    {"code": "dongguan", "name": "东莞", "province": "广东"},
    {"code": "qingdao", "name": "青岛", "province": "山东"},
    {"code": "kunming", "name": "昆明", "province": "云南"},
    {"code": "dalian", "name": "大连", "province": "辽宁"},
    {"code": "xiamen", "name": "厦门", "province": "福建"},
    {"code": "hefei", "name": "合肥", "province": "安徽"},
    {"code": "fuzhou", "name": "福州", "province": "福建"},
    {"code": "jinan", "name": "济南", "province": "山东"},
    {"code": "wenzhou", "name": "温州", "province": "浙江"},
    {"code": "harbin", "name": "哈尔滨", "province": "黑龙江"},
    {"code": "nanning", "name": "南宁", "province": "广西"},
    {"code": "guiyang", "name": "贵阳", "province": "贵州"},
    {"code": "urumqi", "name": "乌鲁木齐", "province": "新疆"},
    {"code": "lhasa", "name": "拉萨", "province": "西藏"},
    {"code": "sanya", "name": "三亚", "province": "海南"},
    {"code": "haikou", "name": "海口", "province": "海南"},
]

# 城市名 → 省份映射
_CITY_PROVINCE_MAP: Dict[str, str] = {c["name"]: c["province"] for c in HOT_CITIES}


def _get_cache_key(city: str) -> str:
    return f"weather_{city}"


def _get_from_cache(key: str) -> Optional[Any]:
    if key in _cache:
        entry = _cache[key]
        if time.time() - entry["ts"] < _CACHE_TTL:
            return entry["data"]
    return None


def _set_cache(key: str, data: Any):
    _cache[key] = {"data": data, "ts": time.time()}


def _map_weather_desc_to_icon(desc: str) -> str:
    """将天气描述文字映射为 emoji 图标"""
    if not desc:
        return "🌤️"
    desc = desc.lower()
    if "晴" in desc:
        return "☀️"
    elif "多云" in desc and "晴" not in desc:
        return "⛅"
    elif "阴" in desc:
        return "☁️"
    elif "雾" in desc or "霾" in desc:
        return "🌫️"
    elif "雷" in desc and "雨" in desc:
        return "⛈️"
    elif "雪" in desc and "雨" in desc:
        return "🌨️"
    elif "暴雪" in desc or "大雪" in desc:
        return "❄️"
    elif "雪" in desc:
        return "🌨️"
    elif "暴雨" in desc or "大雨" in desc:
        return "🌧️"
    elif "中雨" in desc:
        return "🌧️"
    elif "小雨" in desc or "阵雨" in desc or "毛毛雨" in desc:
        return "🌦️"
    elif "雨" in desc:
        return "🌧️"
    else:
        return "🌤️"


def _fetch_weather_from_tencent(city: str, province: str) -> Optional[Dict[str, Any]]:
    """从腾讯天气获取天气数据"""
    cache_key = _get_cache_key(city)
    cached = _get_from_cache(cache_key)
    if cached is not None:
        return cached

    headers = {
        "accept": "application/json, text/javascript, */*; q=0.01",
        "accept-language": "zh-CN,zh;q=0.9,en;q=0.8",
        "origin": "https://tianqi.qq.com",
        "referer": "https://tianqi.qq.com/",
        "sec-ch-ua": '"Microsoft Edge";v="149", "Chromium";v="149", "Not)A;Brand";v="24"',
        "sec-ch-ua-mobile": "?0",
        "sec-ch-ua-platform": '"Windows"',
        "sec-fetch-dest": "empty",
        "sec-fetch-mode": "cors",
        "sec-fetch-site": "same-site",
        "user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0",
    }

    try:
        url = "https://i.news.qq.com/weather/common"
        params = {
            "source": "pc",
            "weather_type": "observe|forecast_1h|forecast_24h|index|alarm|limit|tips|rise",
            "province": province,
            "city": city,
        }
        resp = httpx.get(url, params=params, headers=headers, timeout=15)
        resp.raise_for_status()
        data = resp.json()
        result = _parse_tencent_data(data, city, province)
        if result:
            _set_cache(cache_key, result)
            return result
        return None
    except Exception as e:
        print(f"[Weather] 腾讯天气请求失败 ({province}/{city}): {e}")
        return None


def _parse_tencent_data(data: Dict[str, Any], city: str, province: str) -> Optional[Dict[str, Any]]:
    """解析腾讯天气 JSON 数据为统一格式"""
    try:
        # 腾讯天气 API 返回格式：有时有 data 包装层，有时直接返回数据
        data_section = data.get("data") or data
        if not data_section:
            return None

        # --- 当前天气 (observe) ---
        observe = data_section.get("observe") or {}
        current_weather = {
            "city": city,
            "tempC": str(observe.get("degree", "--")),
            "feelsLikeC": str(observe.get("degree", "--")),
            "humidity": str(observe.get("humidity", "--")),
            "windSpeedKmph": "--",
            "windDir16Point": observe.get("wind_direction_name", ""),
            "windPower": observe.get("wind_power", ""),
            "visibility": str(observe.get("visibility", "--") if observe.get("visibility") else "--"),
            "pressure": str(observe.get("pressure", "--")),
            "uvIndex": "--",
            "weatherDesc": observe.get("weather", ""),
            "icon": _map_weather_desc_to_icon(observe.get("weather", "")),
            "observationTime": observe.get("update_time", ""),
            "aqi": str(observe.get("aqi", "")),
            "aqiDesc": observe.get("aqi_name", ""),
        }

        # --- 空气质量 (air) ---
        air = data_section.get("air") or {}
        if air:
            current_weather["aqi"] = str(air.get("aqi", current_weather["aqi"]))
            current_weather["aqiDesc"] = air.get("aqi_name", current_weather["aqiDesc"])

        # --- 日出日落 (rise) ---
        rise_list = data_section.get("rise") or []
        if rise_list and isinstance(rise_list, list) and len(rise_list) > 0:
            today_rise = rise_list[0]
            current_weather["sunrise"] = today_rise.get("sunrise", "")
            current_weather["sunset"] = today_rise.get("sunset", "")

        # --- 未来预报 (forecast_24h) ---
        # 腾讯天气 API 返回的是一个列表，每个元素包含 time, day_weather, night_weather, min_degree, max_degree 等字段
        forecast_24h = data_section.get("forecast_24h") or []
        forecast_list = []
        if isinstance(forecast_24h, list):
            for day in forecast_24h:
                if not isinstance(day, dict):
                    continue
                forecast_list.append({
                    "date": day.get("time", ""),
                    "maxTempC": str(day.get("max_degree", "--")),
                    "minTempC": str(day.get("min_degree", "--")),
                    "avgTempC": str((int(day.get("max_degree", 0)) + int(day.get("min_degree", 0))) // 2) if day.get("max_degree") and day.get("min_degree") else "--",
                    "weatherDesc": day.get("day_weather", ""),
                    "weatherNightDesc": day.get("night_weather", ""),
                    "dayIcon": _map_weather_desc_to_icon(day.get("day_weather", "")),
                    "nightIcon": _map_weather_desc_to_icon(day.get("night_weather", "")),
                    "icon": _map_weather_desc_to_icon(day.get("day_weather", "")),
                    "windDir": day.get("day_wind_direction", ""),
                    "windPower": day.get("day_wind_power", ""),
                })
        elif isinstance(forecast_24h, dict):
            for date_key in sorted(forecast_24h.keys()):
                day = forecast_24h[date_key]
                if not isinstance(day, dict):
                    continue
                forecast_list.append({
                    "date": date_key,
                    "maxTempC": str(day.get("max_degree", "--")),
                    "minTempC": str(day.get("min_degree", "--")),
                    "avgTempC": str((int(day.get("max_degree", 0)) + int(day.get("min_degree", 0))) // 2) if day.get("max_degree") and day.get("min_degree") else "--",
                    "weatherDesc": day.get("weather", ""),
                    "weatherNightDesc": day.get("weather_night", ""),
                    "dayIcon": _map_weather_desc_to_icon(day.get("weather", "")),
                    "nightIcon": _map_weather_desc_to_icon(day.get("weather_night", "")),
                    "icon": _map_weather_desc_to_icon(day.get("weather", "")),
                    "windDir": day.get("wind_direction", ""),
                    "windPower": day.get("wind_power", ""),
                })

        # --- 逐小时预报 (forecast_1h) ---
        forecast_1h = data_section.get("forecast_1h") or []
        hourly_list = []
        if isinstance(forecast_1h, list):
            for h in forecast_1h:
                if not isinstance(h, dict):
                    continue
                update_time = h.get("update_time", "")
                # update_time 格式: "20260618180000" → 提取 HH:MM
                hour_str = ""
                if len(update_time) >= 10:
                    hour_str = f"{update_time[8:10]}:{update_time[10:12]}" if len(update_time) >= 12 else update_time[8:10]
                hourly_list.append({
                    "time": hour_str,
                    "tempC": str(h.get("degree", "--")),
                    "weatherDesc": h.get("weather", ""),
                    "icon": _map_weather_desc_to_icon(h.get("weather", "")),
                    "windDir": h.get("wind_direction", ""),
                    "windPower": h.get("wind_power", ""),
                    "weatherUrl": h.get("weather_url", ""),
                })

        # --- 生活指数 (index) ---
        index_data = data_section.get("index") or {}
        life_index = {}
        if isinstance(index_data, dict):
            index_keys = [
                "ultraviolet", "clothes", "umbrella", "carwash",
                "sports", "cold", "comfort", "airconditioner",
                "sunscreen", "traffic",
            ]
            for key in index_keys:
                item = index_data.get(key)
                if item and isinstance(item, dict):
                    life_index[key] = {
                        "name": item.get("name", ""),
                        "info": item.get("info", ""),
                        "detail": item.get("detail", ""),
                        "url": item.get("url", ""),
                    }

        # --- 限行 (limit) ---
        limit_data = data_section.get("limit") or {}
        limit_info = None
        if limit_data and isinstance(limit_data, dict):
            limit_info = {
                "tailNumber": limit_data.get("tail_number", ""),
                "time": limit_data.get("time", ""),
            }

        return {
            "current": current_weather,
            "forecast": forecast_list,
            "hourly": hourly_list,
            "lifeIndex": life_index,
            "limit": limit_info,
            "updateTime": time.strftime("%Y-%m-%d %H:%M:%S"),
        }
    except Exception as e:
        print(f"[Weather] 解析腾讯天气数据失败: {e}")
        return None


def _generate_fallback_weather(city: str) -> Dict[str, Any]:
    """生成备用天气数据（当所有 API 都失败时）"""
    import random
    now = time.localtime()
    month = now.tm_mon

    if month in [12, 1, 2]:
        base_temp = random.randint(-5, 8)
    elif month in [3, 4, 5]:
        base_temp = random.randint(10, 25)
    elif month in [6, 7, 8]:
        base_temp = random.randint(25, 38)
    else:
        base_temp = random.randint(12, 28)

    weather_types = [
        {"desc": "晴", "icon": "☀️"},
        {"desc": "多云", "icon": "⛅"},
        {"desc": "阴", "icon": "☁️"},
        {"desc": "小雨", "icon": "🌦️"},
    ]
    wt = random.choice(weather_types)
    humidity = random.randint(30, 85)
    wind_speed = random.randint(5, 25)
    wind_dirs = ["北风", "东北风", "东风", "东南风", "南风", "西南风", "西风", "西北风"]
    wind_dir = random.choice(wind_dirs)

    forecast = []
    for i in range(3):
        day_time = time.localtime(time.time() + i * 86400)
        day_wt = random.choice(weather_types)
        day_max = base_temp + random.randint(2, 8)
        day_min = base_temp - random.randint(2, 6)
        forecast.append({
            "date": f"{day_time.tm_mon:02d}-{day_time.tm_mday:02d}",
            "maxTempC": str(day_max),
            "minTempC": str(day_min),
            "avgTempC": str((day_max + day_min) // 2),
            "weatherDesc": day_wt["desc"],
            "icon": day_wt["icon"],
        })

    return {
        "current": {
            "city": city,
            "tempC": str(base_temp),
            "feelsLikeC": str(base_temp + random.randint(-3, 3)),
            "humidity": str(humidity),
            "windSpeedKmph": str(wind_speed),
            "windDir16Point": wind_dir,
            "visibility": str(random.randint(5, 25)),
            "pressure": str(random.randint(1000, 1025)),
            "uvIndex": str(random.randint(1, 8)),
            "weatherDesc": wt["desc"],
            "icon": wt["icon"],
            "observationTime": time.strftime("%H:%M"),
        },
        "forecast": forecast,
        "updateTime": time.strftime("%Y-%m-%d %H:%M:%S"),
        "isFallback": True,
    }


# ============================================================
# 接口
# ============================================================

@router.get("/tencent-raw")
async def tencent_raw_proxy(
    province: str = Query("", description="省份"),
    city: str = Query("北京", description="城市名称"),
    weather_type: str = Query(
        "observe|forecast_1h|forecast_24h|index|alarm|limit|tips|rise",
        description="天气类型"
    ),
):
    """代理腾讯天气 API 原始数据（前端解析用，避免生产环境跨域）"""
    if not province:
        province = _CITY_PROVINCE_MAP.get(city, city)

    headers = {
        "accept": "application/json, text/javascript, */*; q=0.01",
        "accept-language": "zh-CN,zh;q=0.9,en;q=0.8",
        "origin": "https://tianqi.qq.com",
        "referer": "https://tianqi.qq.com/",
        "user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36",
    }
    params = {
        "source": "pc",
        "weather_type": weather_type,
        "province": province,
        "city": city,
    }
    try:
        async with httpx.AsyncClient(timeout=15) as client:
            resp = await client.get(
                "https://i.news.qq.com/weather/common",
                params=params,
                headers=headers,
            )
            resp.raise_for_status()
            return {"code": 200, "message": "success", "data": resp.json()}
    except Exception as e:
        return {"code": 500, "message": str(e), "data": None}


@router.get("")
async def get_weather(city: str = Query("北京", description="城市名称（中文）")):
    """获取指定城市的天气预报"""
    try:
        # 获取省份信息
        province = _CITY_PROVINCE_MAP.get(city, city)

        # 优先从腾讯天气获取
        weather_data = _fetch_weather_from_tencent(city, province)
        if weather_data:
            return {"code": 200, "data": weather_data}

        # 所有 API 都失败，返回模拟数据
        fallback = _generate_fallback_weather(city)
        return {"code": 200, "data": fallback}

    except Exception as e:
        fallback = _generate_fallback_weather(city)
        fallback["message"] = f"数据获取异常，显示模拟数据: {str(e)}"
        return {"code": 200, "data": fallback}


@router.get("/cities")
async def get_cities():
    """获取热门城市列表（供前端切换选择）"""
    return {"code": 200, "data": HOT_CITIES}