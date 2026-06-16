"""笔记本机型相关数据模型"""
from sqlalchemy import Column, Integer, String, Float, Text, DateTime
from sqlalchemy.sql import func
from database import Base


class LaptopModel(Base):
    """笔记本机型表"""
    __tablename__ = "laptop_models"

    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(200), nullable=False, comment="机型名称")
    brand = Column(String(50), nullable=False, comment="品牌")
    price_min = Column(Integer, default=0, comment="最低价(元)")
    price_max = Column(Integer, default=0, comment="最高价(元)")
    price_tag = Column(String(50), default="", comment="价格标签 如3000-4000")
    year = Column(String(10), default="2026", comment="年款")
    is_new = Column(Integer, default=1, comment="是否2026新款 1是0否")

    # 处理器
    cpu = Column(String(100), nullable=False, comment="CPU型号")
    cpu_level = Column(String(20), default="mainstream", comment="CPU定位 entry/mainstream/high/flagship")
    cpu_desc = Column(String(300), default="", comment="CPU通俗解释")

    # 内存
    ram = Column(String(50), nullable=False, comment="内存 如16GB/32GB")
    ram_type = Column(String(20), default="LPDDR5", comment="内存类型")
    ram_freq = Column(String(20), default="", comment="内存频率")
    ram_expandable = Column(Integer, default=0, comment="是否可扩展 1是0否")
    ram_desc = Column(String(300), default="", comment="内存通俗解释")

    # 硬盘
    storage = Column(String(50), nullable=False, comment="硬盘 如512GB SSD")
    storage_type = Column(String(30), default="NVMe SSD", comment="硬盘协议")
    storage_desc = Column(String(300), default="", comment="硬盘通俗解释")

    # 显卡
    gpu = Column(String(100), nullable=False, comment="显卡型号")
    gpu_type = Column(String(20), default="integrated", comment="显卡类型 integrated/discrete")
    gpu_desc = Column(String(300), default="", comment="显卡通俗解释")

    # 屏幕
    screen_size = Column(String(20), default="", comment="屏幕尺寸")
    screen_resolution = Column(String(30), default="", comment="分辨率")
    screen_refresh = Column(String(20), default="", comment="刷新率")
    screen_color_gamut = Column(String(30), default="", comment="色域")
    screen_brightness = Column(String(20), default="", comment="亮度")
    screen_desc = Column(String(300), default="", comment="屏幕通俗解释")

    # 机身
    weight = Column(String(20), default="", comment="重量")
    thickness = Column(String(20), default="", comment="厚度")
    material = Column(String(50), default="", comment="材质")
    portability_desc = Column(String(300), default="", comment="便携通俗解释")

    # 续航
    battery = Column(String(30), default="", comment="电池容量")
    battery_life = Column(String(30), default="", comment="办公续航时长")
    fast_charge = Column(String(30), default="", comment="快充能力")
    battery_desc = Column(String(300), default="", comment="续航通俗解释")

    # 接口
    ports = Column(String(500), default="", comment="接口列表")
    ports_desc = Column(String(300), default="", comment="接口通俗解释")

    # 特色功能
    features = Column(String(500), default="", comment="特色功能")

    # 评分(满分100)
    score_office = Column(Float, default=0, comment="办公性能分(30)")
    score_graphics = Column(Float, default=0, comment="图形设计分(20)")
    score_fluency = Column(Float, default=0, comment="流畅续航分(20)")
    score_portability = Column(Float, default=0, comment="便携质感分(15)")
    score_value = Column(Float, default=0, comment="性价比分(15)")
    score_total = Column(Float, default=0, comment="综合总分")

    # 场景标签
    scene_tags = Column(String(300), default="", comment="适用场景标签 JSON数组")
    scene_basic = Column(Integer, default=0, comment="基础办公匹配度0-100")
    scene_multi = Column(Integer, default=0, comment="多任务办公匹配度")
    scene_design = Column(Integer, default=0, comment="设计美工匹配度")
    scene_video = Column(Integer, default=0, comment="视频剪辑匹配度")
    scene_3d = Column(Integer, default=0, comment="三维建模匹配度")
    scene_ai = Column(Integer, default=0, comment="AI办公匹配度")
    scene_travel = Column(Integer, default=0, comment="商旅便携匹配度")
    scene_entertainment = Column(Integer, default=0, comment="轻度娱乐匹配度")

    # 优缺点和建议
    pros = Column(Text, default="", comment="优点")
    cons = Column(Text, default="", comment="缺点")
    buy_guide = Column(Text, default="", comment="购买建议/避坑提示")
    suitable_for = Column(String(300), default="", comment="适合人群")
    not_suitable_for = Column(String(300), default="", comment="不适合人群")

    # 购买链接
    buy_url = Column(String(500), default="", comment="京东购买链接")

    # 轻薄属性
    is_thin = Column(Integer, default=0, comment="是否轻薄本 1是0否")
    weight_kg = Column(Float, default=0, comment="重量(kg) 用于筛选")

    created_at = Column(DateTime, server_default=func.now(), comment="创建时间")
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now(), comment="更新时间")


class LaptopRecommendation(Base):
    """用户推荐记录表"""
    __tablename__ = "laptop_recommendations"

    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(Integer, nullable=False, comment="用户ID")
    budget = Column(String(50), default="", comment="预算区间")
    scenes = Column(String(300), default="", comment="选择的场景 JSON数组")
    preferences = Column(String(300), default="", comment="偏好选项 JSON数组")
    extra_demand = Column(String(500), default="", comment="额外需求")
    result_ids = Column(String(200), default="", comment="推荐机型ID列表 逗号分隔")
    result_detail = Column(Text, default="", comment="推荐结果详情JSON")
    created_at = Column(DateTime, server_default=func.now(), comment="创建时间")