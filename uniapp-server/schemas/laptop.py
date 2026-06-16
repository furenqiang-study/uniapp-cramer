"""笔记本相关数据结构"""
from pydantic import BaseModel
from typing import Optional, List


class RecommendRequest(BaseModel):
    """推荐请求"""
    budget: str  # 预算区间
    scenes: List[str]  # 选择的场景列表
    preferences: List[str] = []  # 偏好选项
    extra_demand: str = ""  # 额外需求


class LaptopScore(BaseModel):
    """五维评分"""
    office: float = 0      # 办公性能分(30)
    graphics: float = 0    # 图形设计分(20)
    fluency: float = 0     # 流畅续航分(20)
    portability: float = 0 # 便携质感分(15)
    value: float = 0       # 性价比分(15)
    total: float = 0       # 综合总分


class LaptopConfig(BaseModel):
    """机型配置详情"""
    cpu: str = ""
    cpu_desc: str = ""
    ram: str = ""
    ram_type: str = ""
    ram_desc: str = ""
    storage: str = ""
    storage_desc: str = ""
    gpu: str = ""
    gpu_desc: str = ""
    screen_size: str = ""
    screen_resolution: str = ""
    screen_refresh: str = ""
    screen_color_gamut: str = ""
    screen_desc: str = ""
    weight: str = ""
    thickness: str = ""
    material: str = ""
    portability_desc: str = ""
    battery: str = ""
    battery_life: str = ""
    fast_charge: str = ""
    battery_desc: str = ""
    ports: str = ""
    ports_desc: str = ""
    features: str = ""


class LaptopRecommendItem(BaseModel):
    """单台推荐机型"""
    id: int
    name: str
    brand: str
    price_tag: str = ""
    year: str = ""
    is_new: int = 1
    scene_tags: List[str] = []
    match_score: float = 0  # 匹配度百分比
    rank_label: str = ""  # 首选推荐/备选性价比/备选均衡
    score: LaptopScore
    config: LaptopConfig
    pros: str = ""
    cons: str = ""
    buy_guide: str = ""
    suitable_for: str = ""
    not_suitable_for: str = ""
    match_reason: str = ""  # 精准适配说明
    buy_url: str = ""  # 京东购买链接


class RecommendResult(BaseModel):
    """推荐结果"""
    budget: str
    scenes: List[str]
    preferences: List[str]
    laptops: List[LaptopRecommendItem]