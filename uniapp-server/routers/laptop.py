"""笔记本电脑智能推荐路由"""
import json
from fastapi import APIRouter, Depends, Request
from sqlalchemy.orm import Session
from database import get_db
from models.laptop import LaptopModel, LaptopRecommendation
from models.log import OperationLog
from schemas.laptop import (
    RecommendRequest, RecommendResult, LaptopRecommendItem,
    LaptopScore, LaptopConfig
)
from schemas.user import ApiResponse
from services.auth import get_current_user
from models.user import User

router = APIRouter(prefix="/api/laptops", tags=["笔记本推荐"])

# 场景映射：前端key -> 数据库字段
SCENE_MAP = {
    "basic": "scene_basic",
    "multi": "scene_multi",
    "design": "scene_design",
    "video": "scene_video",
    "3d": "scene_3d",
    "ai": "scene_ai",
    "travel": "scene_travel",
    "entertainment": "scene_entertainment",
}

# 场景中文名
SCENE_NAMES = {
    "basic": "基础办公",
    "multi": "多任务办公",
    "design": "设计美工",
    "video": "视频剪辑",
    "3d": "三维建模",
    "ai": "AI办公",
    "travel": "商旅便携",
    "entertainment": "轻度娱乐",
}

# 预算区间映射
BUDGET_MAP = {
    "3000-4000": (3000, 4000),
    "4000-6000": (4000, 6000),
    "6000-8000": (6000, 8000),
    "8000-12000": (8000, 12000),
    "12000+": (12000, 99999),
}

# 偏好权重加分
PREFERENCE_BOOST = {
    "thin": {"is_thin": 15},  # 优先轻薄便携
    "ram": {"score_office": 10},  # 优先大内存
    "screen": {"score_graphics": 10},  # 优先高色域屏幕
    "battery": {"score_fluency": 10},  # 优先超长续航
    "brand": {"score_value": 5},  # 优先一线品牌(通用加分)
    "no_gaming": {"is_thin": 10},  # 拒绝游戏本(轻薄加分)
}

# 场景权重：不同场景对各维度的权重影响
SCENE_WEIGHTS = {
    "basic": {"office": 1.2, "fluency": 1.3, "portability": 1.1, "value": 1.2},
    "multi": {"office": 1.5, "fluency": 1.3, "value": 1.1},
    "design": {"office": 1.1, "graphics": 1.5, "fluency": 1.1},
    "video": {"office": 1.3, "graphics": 1.4, "fluency": 1.2},
    "3d": {"office": 1.4, "graphics": 1.5, "fluency": 1.1},
    "ai": {"office": 1.4, "graphics": 1.2, "fluency": 1.2},
    "travel": {"portability": 1.8, "fluency": 1.4, "office": 0.8},
    "entertainment": {"office": 1.0, "graphics": 1.1, "fluency": 1.1, "value": 1.2},
}


def calc_match_score(laptop: LaptopModel, scenes: list, preferences: list, budget_range: tuple) -> float:
    """计算机型匹配度分数"""
    score = 0.0
    max_score = 0.0

    # 1. 场景匹配度（40%权重）
    scene_score = 0.0
    scene_count = 0
    for scene in scenes:
        db_field = SCENE_MAP.get(scene)
        if db_field:
            scene_val = getattr(laptop, db_field, 0) or 0
            scene_score += scene_val
            scene_count += 1
    if scene_count > 0:
        scene_score = scene_score / scene_count
    score += scene_score * 0.4
    max_score += 100 * 0.4

    # 2. 综合评分（35%权重）
    total = laptop.score_total or 0
    # 根据场景加权
    weighted_total = total
    for scene in scenes:
        weights = SCENE_WEIGHTS.get(scene, {})
        if weights:
            weighted_total = (
                (laptop.score_office or 0) / 30 * weights.get("office", 1) * 30 +
                (laptop.score_graphics or 0) / 20 * weights.get("graphics", 1) * 20 +
                (laptop.score_fluency or 0) / 20 * weights.get("fluency", 1) * 20 +
                (laptop.score_portability or 0) / 15 * weights.get("portability", 1) * 15 +
                (laptop.score_value or 0) / 15 * weights.get("value", 1) * 15
            )
            break  # 取第一个场景的权重
    score += min(weighted_total, 100) * 0.35
    max_score += 100 * 0.35

    # 3. 偏好加分（15%权重）
    pref_score = 0.0
    pref_count = len(preferences)
    if pref_count > 0:
        for pref in preferences:
            boost = PREFERENCE_BOOST.get(pref, {})
            for field, bonus in boost.items():
                val = getattr(laptop, field, None)
                if val is not None:
                    if isinstance(val, int) and val == 1:
                        pref_score += bonus
                    elif isinstance(val, (int, float)) and val > 0:
                        pref_score += bonus * 0.5
        pref_score = min(pref_score, 100)
    score += pref_score * 0.15
    max_score += 100 * 0.15

    # 4. 价格匹配度（10%权重）
    price_mid = (budget_range[0] + budget_range[1]) / 2
    laptop_mid = ((laptop.price_min or 0) + (laptop.price_max or 0)) / 2
    if laptop_mid > 0:
        price_diff = abs(price_mid - laptop_mid) / price_mid
        price_score = max(0, 100 - price_diff * 100)
    else:
        price_score = 50
    score += price_score * 0.10
    max_score += 100 * 0.10

    # 计算百分比
    if max_score > 0:
        return round(score / max_score * 100, 1)
    return 0.0


def build_match_reason(laptop: LaptopModel, scenes: list, preferences: list, budget_range: tuple) -> str:
    """生成精准适配说明"""
    reasons = []

    # 预算匹配
    laptop_mid = ((laptop.price_min or 0) + (laptop.price_max or 0)) / 2
    budget_mid = (budget_range[0] + budget_range[1]) / 2
    if laptop_mid <= budget_mid:
        reasons.append(f"售价在您的{budget_range[0]}-{budget_range[1]}元预算内，性价比出色")
    else:
        reasons.append(f"售价略高于预算中位，但配置在同价位段极具竞争力")

    # 场景匹配
    scene_list = [SCENE_NAMES.get(s, s) for s in scenes]
    scene_str = "、".join(scene_list[:3])
    best_scene = ""
    best_score = 0
    for scene in scenes:
        db_field = SCENE_MAP.get(scene)
        if db_field:
            val = getattr(laptop, db_field, 0) or 0
            if val > best_score:
                best_score = val
                best_scene = SCENE_NAMES.get(scene, scene)
    if best_scene:
        reasons.append(f"针对「{scene_str}」场景，{best_scene}匹配度高达{best_score}%")

    # 偏好匹配
    pref_reasons = []
    if "thin" in preferences and laptop.is_thin:
        pref_reasons.append("轻薄便携")
    if "battery" in preferences and laptop.battery_life:
        pref_reasons.append(f"续航持久({laptop.battery_life})")
    if "screen" in preferences and laptop.screen_color_gamut and "100%" in str(laptop.screen_color_gamut):
        pref_reasons.append("高色域屏幕")
    if pref_reasons:
        reasons.append(f"满足您对{'、'.join(pref_reasons)}的偏好")

    return "；".join(reasons) if reasons else "综合配置均衡，适合您的使用需求"


@router.get("/options", response_model=ApiResponse)
def get_options(current_user: User = Depends(get_current_user)):
    """获取推荐问卷选项"""
    data = {
        "budgets": [
            {"value": "3000-4000", "label": "3000-4000元", "desc": "入门学生/基础办公性价比档"},
            {"value": "4000-6000", "label": "4000-6000元", "desc": "主流职场全能办公档"},
            {"value": "6000-8000", "label": "6000-8000元", "desc": "中度设计/多任务/AI办公档"},
            {"value": "8000-12000", "label": "8000-12000元", "desc": "高端商务/剪辑建模/全能旗舰档"},
            {"value": "12000+", "label": "12000元以上", "desc": "专业创作/移动工作站旗舰档"},
        ],
        "scenes": [
            {"value": "basic", "label": "基础办公", "desc": "Word/Excel/PPT、网页多开、网课"},
            {"value": "multi", "label": "多任务办公", "desc": "大量文档、浏览器20+标签、多软件常驻"},
            {"value": "design", "label": "设计美工", "desc": "PS/AI/CDR、修图、海报设计"},
            {"value": "video", "label": "视频剪辑", "desc": "PR/AE、短视频剪辑、4K素材处理"},
            {"value": "3d", "label": "三维建模/渲染", "desc": "SU/3DMAX/CAD、GIS地图处理"},
            {"value": "ai", "label": "AI办公", "desc": "AI绘图、AI文案、本地AI模型运行"},
            {"value": "travel", "label": "商旅便携", "desc": "经常外出、通勤携带、无固定电源"},
            {"value": "entertainment", "label": "轻度娱乐", "desc": "追剧、网页游戏、LOL等轻度游戏"},
        ],
        "preferences": [
            {"value": "thin", "label": "优先轻薄便携"},
            {"value": "ram", "label": "优先大内存多开不卡"},
            {"value": "screen", "label": "优先高色域高清屏幕"},
            {"value": "battery", "label": "优先超长续航"},
            {"value": "brand", "label": "优先一线品牌售后"},
            {"value": "no_gaming", "label": "拒绝游戏本"},
        ],
    }
    return ApiResponse(code=200, message="success", data=data)


@router.post("/recommend", response_model=ApiResponse)
def recommend(
    req: RecommendRequest,
    request: Request,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """智能推荐笔记本"""
    import traceback
    try:
        return _do_recommend(req, request, db, current_user)
    except Exception as e:
        traceback.print_exc()
        return ApiResponse(code=500, message=f"推荐失败: {str(e)}")


def _do_recommend(req, request, db, current_user):
    """实际推荐逻辑"""
    # 解析预算区间
    budget_range = BUDGET_MAP.get(req.budget, (4000, 6000))

    # 查询预算范围内的机型（扩大范围以包含接近的机型）
    lower = budget_range[0] - 500
    upper = budget_range[1] + 500
    candidates = db.query(LaptopModel).filter(
        LaptopModel.price_min >= lower,
        LaptopModel.price_max <= upper,
    ).all()

    if not candidates:
        # 如果没有候选，放宽条件
        candidates = db.query(LaptopModel).all()

    if not candidates:
        return ApiResponse(code=404, message="暂无推荐机型，请稍后再试")

    # 计算每台机型的匹配度
    scored = []
    for laptop in candidates:
        match_score = calc_match_score(laptop, req.scenes, req.preferences, budget_range)
        scored.append((laptop, match_score))

    # 按匹配度降序排序
    scored.sort(key=lambda x: x[1], reverse=True)

    # 取Top 3
    top3 = scored[:3]

    # 构建推荐结果
    rank_labels = ["首选推荐", "备选性价比", "备选均衡款"]
    laptops = []
    for i, (laptop, match_score) in enumerate(top3):
        scene_tags = []
        if laptop.scene_tags:
            try:
                scene_tags = json.loads(laptop.scene_tags)
            except:
                scene_tags = [laptop.scene_tags]

        score = LaptopScore(
            office=laptop.score_office or 0,
            graphics=laptop.score_graphics or 0,
            fluency=laptop.score_fluency or 0,
            portability=laptop.score_portability or 0,
            value=laptop.score_value or 0,
            total=laptop.score_total or 0,
        )

        config = LaptopConfig(
            cpu=laptop.cpu or "",
            cpu_desc=laptop.cpu_desc or "",
            ram=laptop.ram or "",
            ram_type=laptop.ram_type or "",
            ram_desc=laptop.ram_desc or "",
            storage=laptop.storage or "",
            storage_desc=laptop.storage_desc or "",
            gpu=laptop.gpu or "",
            gpu_desc=laptop.gpu_desc or "",
            screen_size=laptop.screen_size or "",
            screen_resolution=laptop.screen_resolution or "",
            screen_refresh=laptop.screen_refresh or "",
            screen_color_gamut=laptop.screen_color_gamut or "",
            screen_desc=laptop.screen_desc or "",
            weight=laptop.weight or "",
            thickness=laptop.thickness or "",
            material=laptop.material or "",
            portability_desc=laptop.portability_desc or "",
            battery=laptop.battery or "",
            battery_life=laptop.battery_life or "",
            fast_charge=laptop.fast_charge or "",
            battery_desc=laptop.battery_desc or "",
            ports=laptop.ports or "",
            ports_desc=laptop.ports_desc or "",
            features=laptop.features or "",
        )

        match_reason = build_match_reason(laptop, req.scenes, req.preferences, budget_range)

        item = LaptopRecommendItem(
            id=laptop.id,
            name=laptop.name,
            brand=laptop.brand,
            price_tag=laptop.price_tag or f"{laptop.price_min}-{laptop.price_max}元",
            year=laptop.year or "2026",
            is_new=laptop.is_new or 0,
            scene_tags=scene_tags,
            match_score=match_score,
            rank_label=rank_labels[i] if i < len(rank_labels) else "备选",
            score=score,
            config=config,
            pros=laptop.pros or "",
            cons=laptop.cons or "",
            buy_guide=laptop.buy_guide or "",
            suitable_for=laptop.suitable_for or "",
            not_suitable_for=laptop.not_suitable_for or "",
            match_reason=match_reason,
            buy_url=laptop.buy_url or "",
        )
        laptops.append(item)

    result = RecommendResult(
        budget=req.budget,
        scenes=req.scenes,
        preferences=req.preferences,
        laptops=laptops,
    )

    # 保存推荐记录
    rec = LaptopRecommendation(
        user_id=current_user.id,
        budget=req.budget,
        scenes=json.dumps(req.scenes, ensure_ascii=False),
        preferences=json.dumps(req.preferences, ensure_ascii=False),
        extra_demand=req.extra_demand,
        result_ids=",".join([str(lp.id) for lp, _ in top3]),
        result_detail=json.dumps([lp.name for lp, _ in top3], ensure_ascii=False),
    )
    db.add(rec)

    # 记录操作日志
    client_ip = request.client.host if request.client else ""
    log = OperationLog(
        user_id=current_user.id,
        username=current_user.username,
        action="recommend",
        module="laptop",
        detail=f"笔记本推荐: 预算{req.budget}, 场景{','.join(req.scenes)}",
        ip=client_ip,
    )
    db.add(log)
    db.commit()

    return ApiResponse(code=200, message="推荐成功", data=result.model_dump())


@router.get("/history", response_model=ApiResponse)
def get_history(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """获取推荐历史记录"""
    records = db.query(LaptopRecommendation).filter(
        LaptopRecommendation.user_id == current_user.id
    ).order_by(LaptopRecommendation.created_at.desc()).limit(10).all()

    data = []
    for rec in records:
        scenes = []
        try:
            scenes = json.loads(rec.scenes) if rec.scenes else []
        except:
            pass
        data.append({
            "id": rec.id,
            "budget": rec.budget,
            "scenes": scenes,
            "result_detail": rec.result_detail or "",
            "created_at": str(rec.created_at) if rec.created_at else "",
        })

    return ApiResponse(code=200, message="success", data=data)