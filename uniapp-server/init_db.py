"""数据库初始化脚本 - 创建表结构并插入初始数据"""
import sys
import os
import json

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from database import engine, Base, SessionLocal
from models.user import User
from models.menu import Menu
from models.log import OperationLog
from models.laptop import LaptopModel, LaptopRecommendation
from services.auth import hash_password


def init_database():
    """初始化数据库"""
    print("正在创建数据库表...")
    Base.metadata.create_all(bind=engine)
    print("数据库表创建完成！")

    db = SessionLocal()
    try:
        # 检查是否已有管理员账号
        admin = db.query(User).filter(User.username == "admin").first()
        if not admin:
            print("正在创建默认管理员账号...")
            admin = User(
                username="admin",
                password=hash_password("123456"),
                nickname="管理员",
                phone="13800000000",
                role="admin",
                status=1,
            )
            db.add(admin)
            db.commit()
            print("默认管理员创建成功: admin / 123456")
        else:
            print("管理员账号已存在，跳过创建")

        # 检查是否已有菜单数据
        menu_count = db.query(Menu).count()
        if menu_count == 0:
            print("正在插入初始菜单数据...")
            menus = [
                Menu(name="首页", icon="home", path="pages/home/home", parent_id=0, sort_order=1),
                Menu(name="系统管理", icon="settings", path="", parent_id=0, sort_order=2),
                Menu(name="菜单管理", icon="menu", path="pages/menu/menu", parent_id=2, sort_order=1),
                Menu(name="用户管理", icon="person", path="", parent_id=2, sort_order=2),
                Menu(name="日志管理", icon="document", path="", parent_id=2, sort_order=3),
                Menu(name="工具", icon="tools", path="", parent_id=0, sort_order=3),
                Menu(name="相机拍照", icon="camera", path="pages/camera/camera", parent_id=6, sort_order=1),
                Menu(name="我的", icon="profile", path="pages/profile/profile", parent_id=0, sort_order=4),
            ]
            db.add_all(menus)
            db.commit()
            print(f"成功插入 {len(menus)} 条菜单数据")
        else:
            print(f"菜单数据已存在（{menu_count}条），跳过插入")

        # 检查是否已有笔记本机型数据
        laptop_count = db.query(LaptopModel).count()
        if laptop_count == 0:
            print("正在插入笔记本机型数据...")
            laptops = get_seed_laptops()
            db.add_all(laptops)
            db.commit()
            print(f"成功插入 {len(laptops)} 条笔记本机型数据")
        else:
            print(f"笔记本机型数据已存在（{laptop_count}条），跳过插入")

        print("\n数据库初始化完成！")

    finally:
        db.close()


def get_seed_laptops():
    """预置2026年主流笔记本机型数据"""
    laptops = []

    # ======== 3000-4000 入门档 ========
    laptops.append(LaptopModel(
        name="联想IdeaPad 15 2026款",
        brand="联想",
        buy_url="https://re.jd.com/search?keyword=联想IdeaPad+15+2026&re_dcp=302c306c306c306c306c306c",
        price_min=3299, price_max=3999, price_tag="3000-4000", year="2026", is_new=1,
        cpu="AMD Ryzen 5 7530U", cpu_level="entry",
        cpu_desc="6核12线程，日常办公、网课、文档处理绰绰有余，功耗低续航长",
        ram="16GB", ram_type="DDR4", ram_freq="3200MHz", ram_expandable=1,
        ram_desc="16G内存日常办公完全够用，支持扩展到32G，后期不担心不够用",
        storage="512GB SSD", storage_type="NVMe",
        storage_desc="512G固态硬盘，开机8秒，Office秒开，存文档照片够用",
        gpu="AMD Radeon集成显卡", gpu_type="integrated",
        gpu_desc="集成显卡，办公看视频没问题，不适合玩大型游戏和专业设计",
        screen_size="15.6英寸", screen_resolution="1920x1080", screen_refresh="60Hz",
        screen_color_gamut="45%NTSC", screen_brightness="250nit",
        screen_desc="15.6寸大屏，1080P分辨率看文档清晰，色域一般，不适合设计修图",
        weight="1.65kg", thickness="17.9mm", material="工程塑料",
        portability_desc="1.65kg在15寸本里算轻的，日常通勤可以接受",
        battery="42Wh", battery_life="约6-8小时", fast_charge="支持快充，1小时充至60%",
        battery_desc="42Wh电池办公能用大半天，中度使用需要带充电器",
        ports="USB-C x1, USB-A x2, HDMI x1, 耳机孔, SD卡槽",
        ports_desc="接口齐全，USB-C/HDMI/USB-A都有，接投影U盘很方便",
        features="指纹解锁, 数字小键盘",
        score_office=20, score_graphics=8, score_fluency=18, score_portability=10, score_value=14,
        score_total=70,
        scene_tags=json.dumps(["基础办公", "学生网课"], ensure_ascii=False),
        scene_basic=85, scene_multi=55, scene_design=30, scene_video=20, scene_3d=15,
        scene_ai=20, scene_travel=60, scene_entertainment=50,
        pros="价格实惠，大屏办公舒适，接口齐全，支持内存扩展",
        cons="色域低不适合设计，性能仅够基础办公，塑料机身质感一般",
        buy_guide="注意选R5版本别选R3，内存一定选16G别选8G，这是2026年办公基本线",
        suitable_for="预算有限的学生、基础办公、网课学习",
        not_suitable_for="设计师、视频剪辑、游戏玩家",
        is_thin=0, weight_kg=1.65,
    ))

    laptops.append(LaptopModel(
        name="荣耀MagicBook X16 2026款",
        brand="荣耀",
        price_min=3499, price_max=3999, price_tag="3000-4000", year="2026", is_new=1,
        cpu="Intel Core i5-13420H", cpu_level="entry",
        cpu_desc="4核8线程标压处理器，办公性能比低压U强一档，多开软件更流畅",
        ram="16GB", ram_type="LPDDR4X", ram_freq="4266MHz", ram_expandable=0,
        ram_desc="16G高频内存，办公多开不卡，但不可扩展，买的时候一步到位",
        storage="512GB SSD", storage_type="NVMe",
        storage_desc="512G固态，读写速度快，开机和软件启动都很迅速",
        gpu="Intel UHD集成显卡", gpu_type="integrated",
        gpu_desc="Intel集成显卡，办公看视频流畅，不适合游戏和专业图形处理",
        screen_size="16英寸", screen_resolution="1920x1200", screen_refresh="60Hz",
        screen_color_gamut="100%sRGB", screen_brightness="300nit",
        screen_desc="16寸大屏+100%sRGB高色域，这个价位难得！看文档修图都舒服",
        weight="1.62kg", thickness="17.9mm", material="铝合金",
        portability_desc="1.62kg铝合金机身，质感比同价位塑料本好很多",
        battery="60Wh", battery_life="约8-10小时", fast_charge="65W快充",
        battery_desc="60Wh大电池，办公一整天不插电，65W快充回血很快",
        ports="USB-C x1, USB-A x2, HDMI x1, 耳机孔",
        ports_desc="常用接口都有，USB-C支持充电和数据传输",
        features="指纹电源二合一, 多屏协同, 护眼模式",
        score_office=22, score_graphics=12, score_fluency=20, score_portability=11, score_value=14,
        score_total=79,
        scene_tags=json.dumps(["基础办公", "学生网课"], ensure_ascii=False),
        scene_basic=90, scene_multi=60, scene_design=50, scene_video=25, scene_3d=15,
        scene_ai=25, scene_travel=65, scene_entertainment=55,
        pros="高色域屏幕在这个价位很难得，铝合金机身质感好，续航长",
        cons="内存不可扩展，集成显卡性能有限",
        buy_guide="这个价位性价比之王，尤其高色域屏幕，办公修图都行",
        suitable_for="预算有限但对屏幕有要求的用户，基础办公学生",
        not_suitable_for="视频剪辑、游戏玩家",
        is_thin=0, weight_kg=1.62,
    ))

    # ======== 4000-6000 主流档 ========
    laptops.append(LaptopModel(
        name="联想小新Pro 16 2026款",
        brand="联想",
        price_min=4999, price_max=5999, price_tag="4000-6000", year="2026", is_new=1,
        cpu="AMD Ryzen 7 8845H", cpu_level="mainstream",
        cpu_desc="8核16线程标压处理器，性能强劲，多任务办公、轻度设计都能胜任",
        ram="32GB", ram_type="LPDDR5X", ram_freq="7500MHz", ram_expandable=0,
        ram_desc="32G超大内存，开几十个标签页+微信钉钉+WPS同时运行完全不卡",
        storage="1TB SSD", storage_type="NVMe PCIe4.0",
        storage_desc="1TB大容量固态，存大量文件不用焦虑空间不够",
        gpu="AMD Radeon 780M集成显卡", gpu_type="integrated",
        gpu_desc="目前最强核显，性能接近入门独显，PS修图和轻度剪辑可以搞定",
        screen_size="16英寸", screen_resolution="2560x1600", screen_refresh="120Hz",
        screen_color_gamut="100%sRGB", screen_brightness="400nit",
        screen_desc="2.5K高清屏+120Hz高刷，色彩准确画面细腻，办公修图都很爽",
        weight="1.95kg", thickness="17.5mm", material="铝合金",
        portability_desc="1.95kg在16寸性能本里算轻的，日常通勤OK",
        battery="75Wh", battery_life="约10-12小时", fast_charge="100W快充",
        battery_desc="75Wh超大电池，重度办公也能撑一整天，100W快充半小时充一半",
        ports="USB-C x2, USB-A x2, HDMI 2.0 x1, SD卡槽, 耳机孔",
        ports_desc="接口丰富，双USB-C+双USB-A+HDMI+SD卡槽，外接设备不用转接器",
        features="IR人脸识别, 1080P摄像头, 杜比音效, 护眼模式",
        score_office=27, score_graphics=16, score_fluency=20, score_portability=11, score_value=14,
        score_total=88,
        scene_tags=json.dumps(["多任务办公", "设计美工", "基础办公"], ensure_ascii=False),
        scene_basic=95, scene_multi=90, scene_design=75, scene_video=50, scene_3d=35,
        scene_ai=55, scene_travel=55, scene_entertainment=70,
        pros="32G大内存+1TB硬盘一步到位，2.5K高刷屏素质优秀，续航超长",
        cons="1.95kg略重，没有独显做不了重度设计和剪辑",
        buy_guide="这个价位最全能的选择，办公设计都能搞定，R7+32G+1TB配置很良心",
        suitable_for="多任务办公用户、轻度设计师、追求全面的职场人",
        not_suitable_for="重度视频剪辑、3D建模、大型游戏玩家",
        is_thin=0, weight_kg=1.95,
    ))

    laptops.append(LaptopModel(
        name="华为MateBook 14 2026款",
        brand="华为",
        price_min=5299, price_max=5999, price_tag="4000-6000", year="2026", is_new=1,
        cpu="Intel Core Ultra 5 125H", cpu_level="mainstream",
        cpu_desc="Intel新一代AI处理器，4性能核+8能效核，AI办公和日常任务都很强",
        ram="16GB", ram_type="LPDDR5X", ram_freq="7467MHz", ram_expandable=0,
        ram_desc="16G高频内存，办公流畅，但重度多任务建议选32G版本",
        storage="512GB SSD", storage_type="NVMe PCIe4.0",
        storage_desc="512G固态够日常办公用，文件多建议搭配云盘或移动硬盘",
        gpu="Intel Arc集成显卡", gpu_type="integrated",
        gpu_desc="Intel Arc核显，支持AI加速，PS修图和1080P视频剪辑可以应对",
        screen_size="14.2英寸", screen_resolution="2880x1800", screen_refresh="120Hz",
        screen_color_gamut="100%sRGB/P3广色域", screen_brightness="450nit",
        screen_desc="2.8K OLED级色彩，P3广色域，设计师看了都说好，护眼认证",
        weight="1.31kg", thickness="14.5mm", material="铝合金一体成型",
        portability_desc="仅1.31kg，比两瓶矿泉水还轻，通勤出差无压力",
        battery="60Wh", battery_life="约8-10小时", fast_charge="65W超级快充",
        battery_desc="60Wh电池+低功耗处理器，办公一整天没问题，手机充电器也能充",
        ports="USB-C x2, USB-A x1, HDMI x1, 耳机孔",
        ports_desc="USB-C支持充电和数据，HDMI直连投影，日常够用",
        features="AI慧眼(智能追踪), 超级终端(华为多设备协同), 指纹电源键, 护眼模式",
        score_office=25, score_graphics=15, score_fluency=19, score_portability=14, score_value=12,
        score_total=85,
        scene_tags=json.dumps(["商旅便携", "多任务办公", "基础办公"], ensure_ascii=False),
        scene_basic=90, scene_multi=80, scene_design=70, scene_video=40, scene_3d=25,
        scene_ai=65, scene_travel=95, scene_entertainment=60,
        pros="极轻机身+顶级屏幕+华为生态协同，商旅办公首选",
        cons="接口偏少，内存不可扩展，重度任务性能不足",
        buy_guide="华为用户首选，多屏协同生态无敌，屏幕素质同价位顶级",
        suitable_for="经常出差的商务人士、华为生态用户、注重屏幕的办公用户",
        not_suitable_for="重度剪辑建模、游戏玩家、预算敏感用户",
        is_thin=1, weight_kg=1.31,
    ))

    laptops.append(LaptopModel(
        name="华硕无畏Pro15 2026款",
        brand="华硕",
        price_min=4999, price_max=5699, price_tag="4000-6000", year="2026", is_new=1,
        cpu="AMD Ryzen 7 8845H", cpu_level="mainstream",
        cpu_desc="8核16线程高性能处理器，多任务办公、PS修图、轻度剪辑都流畅",
        ram="16GB", ram_type="LPDDR5X", ram_freq="6400MHz", ram_expandable=0,
        ram_desc="16G高频内存，办公多开流畅",
        storage="512GB SSD", storage_type="NVMe PCIe4.0",
        storage_desc="512G固态，读写快，日常办公够用",
        gpu="AMD Radeon 780M集成显卡", gpu_type="integrated",
        gpu_desc="旗舰级核显，PS/AI设计软件可以跑，轻度PR剪辑也OK",
        screen_size="15.6英寸", screen_resolution="2880x1620", screen_refresh="120Hz",
        screen_color_gamut="100%DCI-P3", screen_brightness="600nit",
        screen_desc="2.8K OLED屏幕，600nit超高亮度，P3广色域，色彩惊艳，设计师利器",
        weight="1.7kg", thickness="17.9mm", material="铝合金",
        portability_desc="1.7kg在15寸本里算轻的，日常通勤没问题",
        battery="70Wh", battery_life="约8-10小时", fast_charge="90W快充",
        battery_desc="70Wh大电池，办公续航一整天",
        ports="USB-C x2, USB-A x1, HDMI 2.0 x1, MicroSD, 耳机孔",
        ports_desc="双USB-C+USB-A+HDMI，日常接口齐全",
        features="OLED屏幕, AI降噪, 杜比全景声, 指纹解锁",
        score_office=26, score_graphics=17, score_fluency=19, score_portability=12, score_value=13,
        score_total=87,
        scene_tags=json.dumps(["设计美工", "多任务办公", "轻度娱乐"], ensure_ascii=False),
        scene_basic=88, scene_multi=85, scene_design=88, scene_video=55, scene_3d=35,
        scene_ai=50, scene_travel=60, scene_entertainment=65,
        pros="OLED屏幕色彩顶级，性能强劲，性价比高",
        cons="OLED有烧屏风险需注意，没有独显做不了重度设计",
        buy_guide="设计师预算有限首选，OLED屏幕素质碾压同价位，注意避免长时间显示静态画面",
        suitable_for="设计师、对屏幕要求高的办公用户",
        not_suitable_for="重度视频剪辑、3D建模",
        is_thin=0, weight_kg=1.7,
    ))

    # ======== 6000-8000 中高端档 ========
    laptops.append(LaptopModel(
        name="联想小新Pro 16 2026 独显版",
        brand="联想",
        price_min=6499, price_max=7499, price_tag="6000-8000", year="2026", is_new=1,
        cpu="AMD Ryzen 7 8845H", cpu_level="high",
        cpu_desc="8核16线程标压高性能处理器，重度多任务、设计剪辑都能胜任",
        ram="32GB", ram_type="LPDDR5X", ram_freq="7500MHz", ram_expandable=0,
        ram_desc="32G超大内存，同时开PS+PR+浏览器几十个标签都稳如泰山",
        storage="1TB SSD", storage_type="NVMe PCIe4.0",
        storage_desc="1TB大容量高速固态，存4K素材也够用",
        gpu="NVIDIA RTX 4060 8GB", gpu_type="discrete",
        gpu_desc="独立显卡！PS/AI设计无压力，PR剪辑4K视频流畅，还能玩大部分游戏",
        screen_size="16英寸", screen_resolution="2560x1600", screen_refresh="120Hz",
        screen_color_gamut="100%sRGB", screen_brightness="400nit",
        screen_desc="2.5K高刷屏，色彩准确，设计修图和日常办公都很舒适",
        weight="2.0kg", thickness="17.9mm", material="铝合金",
        portability_desc="2.0kg有独显算轻的，通勤可以接受",
        battery="75Wh", battery_life="约7-9小时", fast_charge="100W快充",
        battery_desc="75Wh大电池，日常办公大半天，用独显的话续航会缩短",
        ports="USB-C x2, USB-A x2, HDMI 2.1 x1, SD卡槽, 耳机孔, 网口",
        ports_desc="接口最全的笔记本之一，网口/HDMI/SD卡槽全有，不用转接器",
        features="RTX4060独显, AI加速, 1080P摄像头, 杜比音效, 数字小键盘",
        score_office=29, score_graphics=19, score_fluency=19, score_portability=10, score_value=13,
        score_total=90,
        scene_tags=json.dumps(["视频剪辑", "设计美工", "多任务办公"], ensure_ascii=False),
        scene_basic=90, scene_multi=92, scene_design=90, scene_video=85, scene_3d=70,
        scene_ai=75, scene_travel=45, scene_entertainment=85,
        pros="独显+32G大内存，设计剪辑全能选手，接口齐全",
        cons="2.0kg偏重，续航不如核显版",
        buy_guide="需要独显做设计剪辑的最佳选择，比游戏本轻便比轻薄本性能强",
        suitable_for="设计师、视频剪辑师、需要独显的办公用户",
        not_suitable_for="追求极致轻薄的用户",
        is_thin=0, weight_kg=2.0,
    ))

    laptops.append(LaptopModel(
        name="华为MateBook X Pro 2026款",
        brand="华为",
        price_min=7999, price_max=8999, price_tag="6000-8000", year="2026", is_new=1,
        cpu="Intel Core Ultra 7 155H", cpu_level="high",
        cpu_desc="Intel旗舰AI处理器，6性能核+8能效核+NPU，AI办公和专业任务都强",
        ram="32GB", ram_type="LPDDR5X", ram_freq="7467MHz", ram_expandable=0,
        ram_desc="32G超高频内存，重度多任务毫无压力",
        storage="1TB SSD", storage_type="NVMe PCIe4.0",
        storage_desc="1TB大容量固态，存什么都够",
        gpu="Intel Arc集成显卡", gpu_type="integrated",
        gpu_desc="Intel Arc核显+NPU AI加速，轻度设计和AI应用可以胜任",
        screen_size="14.2英寸", screen_resolution="3120x2080", screen_refresh="120Hz",
        screen_color_gamut="100%DCI-P3", screen_brightness="600nit",
        screen_desc="3.1K顶级屏幕，P3广色域600nit，色彩精准度DeltaE<1，设计师最爱",
        weight="0.98kg", thickness="13.5mm", material="镁铝合金一体成型",
        portability_desc="不到1kg！极致轻薄，单手轻松拿起，出差神器",
        battery="72Wh", battery_life="约10-12小时", fast_charge="90W超级快充",
        battery_desc="72Wh大电池塞进1kg机身，续航一整天，90W快充回血超快",
        ports="Thunderbolt 4 x2, USB-C x1, 耳机孔",
        ports_desc="3个USB-C(含2个雷电4)，需要转接器接传统USB设备",
        features="AI慧眼, 超级终端, 压感触控板, 指纹解锁, 六扬声器",
        score_office=27, score_graphics=14, score_fluency=20, score_portability=15, score_value=11,
        score_total=87,
        scene_tags=json.dumps(["商旅便携", "多任务办公", "AI办公"], ensure_ascii=False),
        scene_basic=92, scene_multi=88, scene_design=72, scene_video=45, scene_3d=30,
        scene_ai=80, scene_travel=98, scene_entertainment=60,
        pros="不到1kg极致轻薄，3.1K顶级屏幕，AI处理器，华为生态",
        cons="接口少需要转接器，没有独显，价格较高",
        buy_guide="追求极致轻薄+顶级屏幕的不二之选，华为生态加分",
        suitable_for="高端商务人士、华为生态用户、追求极致便携的用户",
        not_suitable_for="重度设计剪辑、游戏玩家、预算敏感用户",
        is_thin=1, weight_kg=0.98,
    ))

    laptops.append(LaptopModel(
        name="荣耀MagicBook Art 14 2026款",
        brand="荣耀",
        price_min=6299, price_max=7299, price_tag="6000-8000", year="2026", is_new=1,
        cpu="Intel Core Ultra 5 125H", cpu_level="mainstream",
        cpu_desc="Intel AI处理器，4性能核+8能效核，AI办公和日常任务表现优秀",
        ram="32GB", ram_type="LPDDR5X", ram_freq="7467MHz", ram_expandable=0,
        ram_desc="32G大内存，多任务办公丝滑流畅",
        storage="1TB SSD", storage_type="NVMe PCIe4.0",
        storage_desc="1TB大容量，办公文件随便存",
        gpu="Intel Arc集成显卡", gpu_type="integrated",
        gpu_desc="Intel Arc核显，办公设计轻度使用OK",
        screen_size="14.6英寸", screen_resolution="3120x2080", screen_refresh="120Hz",
        screen_color_gamut="100%DCI-P3", screen_brightness="700nit",
        screen_desc="3.1K OLED屏幕，700nit峰值亮度，P3广色域，户外也能看清",
        weight="1.07kg", thickness="12.9mm", material="镁铝合金",
        portability_desc="1.07kg超轻薄，12.9mm超薄，随身携带无负担",
        battery="75Wh", battery_life="约10-12小时", fast_charge="100W快充",
        battery_desc="75Wh超大电池，续航一整天，100W快充半小时充50%",
        ports="Thunderbolt 4 x1, USB-C x2, USB-A x1, HDMI x1, 耳机孔",
        ports_desc="比华为多一个USB-A和HDMI，不用转接器更方便",
        features="AI字幕, 隔空手势, 指纹解锁, 六扬声器, 护眼认证",
        score_office=26, score_graphics=14, score_fluency=20, score_portability=15, score_value=13,
        score_total=88,
        scene_tags=json.dumps(["商旅便携", "多任务办公", "AI办公"], ensure_ascii=False),
        scene_basic=92, scene_multi=85, scene_design=72, scene_video=42, scene_3d=28,
        scene_ai=78, scene_travel=96, scene_entertainment=60,
        pros="1kg级轻薄+3.1K OLED+32G+1TB，接口比华为丰富，性价比高",
        cons="没有独显，荣耀生态不如华为丰富",
        buy_guide="比华为MateBook X Pro便宜2000+但配置几乎一样，性价比更高",
        suitable_for="注重性价比的轻薄本用户、商务出差人士",
        not_suitable_for="重度设计剪辑、游戏玩家",
        is_thin=1, weight_kg=1.07,
    ))

    # ======== 8000-12000 高端档 ========
    laptops.append(LaptopModel(
        name="ThinkPad X1 Carbon 2026款",
        brand="ThinkPad",
        price_min=9999, price_max=11999, price_tag="8000-12000", year="2026", is_new=1,
        cpu="Intel Core Ultra 7 155H", cpu_level="high",
        cpu_desc="Intel旗舰AI处理器，6性能核+8能效核+NPU，专业办公和AI任务游刃有余",
        ram="32GB", ram_type="LPDDR5X", ram_freq="7467MHz", ram_expandable=0,
        ram_desc="32G超高频内存，同时运行虚拟机、Docker、大型项目都不卡",
        storage="1TB SSD", storage_type="NVMe PCIe4.0",
        storage_desc="1TB高速固态，企业级数据读写",
        gpu="Intel Arc集成显卡", gpu_type="integrated",
        gpu_desc="Intel Arc核显+NPU，办公和AI应用足够",
        screen_size="14英寸", screen_resolution="2880x1800", screen_refresh="120Hz",
        screen_color_gamut="100%DCI-P3", screen_brightness="500nit",
        screen_desc="2.8K OLED屏幕，500nit亮度，P3广色域，色彩精准，商务演示效果出色",
        weight="1.08kg", thickness="14.9mm", material="碳纤维+镁铝合金",
        portability_desc="1.08kg碳纤维机身，坚固耐用又轻便，商务出差首选",
        battery="57Wh", battery_life="约8-10小时", fast_charge="65W快充",
        battery_desc="57Wh电池配合低功耗处理器，办公一整天",
        ports="Thunderbolt 4 x2, USB-A x2, HDMI 2.0 x1, 耳机孔",
        ports_desc="双雷电4+双USB-A+HDMI，商务接口齐全",
        features="经典小红点, ThinkPad键盘, IR+虹膜人脸识别, MIL-STD-810H军标认证, vPro企业管理",
        score_office=28, score_graphics=13, score_fluency=20, score_portability=14, score_value=10,
        score_total=85,
        scene_tags=json.dumps(["商旅便携", "多任务办公", "AI办公"], ensure_ascii=False),
        scene_basic=92, scene_multi=90, scene_design=68, scene_video=42, scene_3d=30,
        scene_ai=78, scene_travel=95, scene_entertainment=55,
        pros="ThinkPad经典品质，碳纤维超轻，键盘手感顶级，军标认证耐用",
        cons="价格较高，没有独显，性价比一般",
        buy_guide="企业采购首选，品质和稳定性无敌，注意选2.8K OLED屏幕版本",
        suitable_for="企业高管、商务精英、ThinkPad老用户",
        not_suitable_for="设计师、游戏玩家、追求性价比的用户",
        is_thin=1, weight_kg=1.08,
    ))

    laptops.append(LaptopModel(
        name="MacBook Air M4 2026款",
        brand="Apple",
        price_min=8999, price_max=10999, price_tag="8000-12000", year="2026", is_new=1,
        cpu="Apple M4芯片", cpu_level="high",
        cpu_desc="苹果自研M4芯片，10核CPU+10核GPU+16核NPU，能效比极高",
        ram="16GB", ram_type="统一内存", ram_freq="", ram_expandable=0,
        ram_desc="16G统一内存，macOS优化好，实际体验相当于Windows 32G",
        storage="512GB SSD", storage_type="NVMe",
        storage_desc="512G固态，苹果SSD读写速度行业顶级",
        gpu="M4集成10核GPU", gpu_type="integrated",
        gpu_desc="M4 GPU性能强劲，Final Cut剪辑4K无压力，AI运算飞快",
        screen_size="15.3英寸", screen_resolution="2880x1864", screen_refresh="120Hz",
        screen_color_gamut="P3广色域", screen_brightness="600nit",
        screen_desc="Liquid Retina显示屏，P3广色域600nit，色彩精准度行业顶级",
        weight="1.51kg", thickness="11.5mm", material="100%再生铝金属",
        portability_desc="1.51kg+11.5mm，15寸大屏做到这个重量厚度，工艺顶级",
        battery="66.5Wh", battery_life="约15-18小时", fast_charge="70W快充",
        battery_desc="M4能效比逆天，办公续航可达18小时，两天不充电都行",
        ports="Thunderbolt 4/USB-C x2, MagSafe充电口, 耳机孔",
        ports_desc="只有2个USB-C，需要转接器接传统设备，MagSafe磁吸充电很方便",
        features="Touch ID, 空间音频, Apple Intelligence AI, macOS生态, 无风扇静音设计",
        score_office=28, score_graphics=17, score_fluency=20, score_portability=14, score_value=11,
        score_total=90,
        scene_tags=json.dumps(["商旅便携", "视频剪辑", "AI办公", "多任务办公"], ensure_ascii=False),
        scene_basic=95, scene_multi=92, scene_design=80, scene_video=82, scene_3d=55,
        scene_ai=90, scene_travel=90, scene_entertainment=70,
        pros="续航逆天18小时，M4芯片性能强，无风扇静音，macOS生态优秀",
        cons="接口少需要转接器，软件生态不如Windows丰富，价格高",
        buy_guide="苹果生态用户必选，续航和静音是最大卖点，注意512G存储可能不够用",
        suitable_for="苹果生态用户、创意工作者、追求续航和静音的商务人士",
        not_suitable_for="Windows必须用户、游戏玩家、预算有限的用户",
        is_thin=1, weight_kg=1.51,
    ))

    laptops.append(LaptopModel(
        name="华硕灵耀14 2026 旗舰版",
        brand="华硕",
        price_min=8499, price_max=9999, price_tag="8000-12000", year="2026", is_new=1,
        cpu="Intel Core Ultra 9 185H", cpu_level="flagship",
        cpu_desc="Intel最强AI处理器，6性能核+8能效核+2超低功耗核+NPU，性能怪兽",
        ram="32GB", ram_type="LPDDR5X", ram_freq="7467MHz", ram_expandable=0,
        ram_desc="32G超高频内存，专业工作流毫无压力",
        storage="1TB SSD", storage_type="NVMe PCIe4.0",
        storage_desc="1TB高速固态，大型项目文件随便存",
        gpu="Intel Arc集成显卡", gpu_type="integrated",
        gpu_desc="Intel Arc核显+NPU，AI创作和轻度设计可以胜任",
        screen_size="14英寸", screen_resolution="2880x1800", screen_refresh="120Hz",
        screen_color_gamut="100%DCI-P3", screen_brightness="600nit",
        screen_desc="2.8K OLED华硕好屏，600nit P3广色域，DeltaE<1专业级色准",
        weight="1.29kg", thickness="13.9mm", material="铝合金CNC工艺",
        portability_desc="1.29kg轻薄机身，CNC工艺质感出众",
        battery="75Wh", battery_life="约10-12小时", fast_charge="90W快充",
        battery_desc="75Wh大电池，旗舰处理器也能续航一整天",
        ports="Thunderbolt 4 x2, USB-A x1, HDMI 2.1 x1, MicroSD, 耳机孔",
        ports_desc="双雷电4+USB-A+HDMI+SD卡槽，接口丰富不用转接",
        features="AI降噪, OLED屏幕, 1080P摄像头, 哈曼卡顿音效, 指纹解锁",
        score_office=29, score_graphics=16, score_fluency=20, score_portability=13, score_value=11,
        score_total=89,
        scene_tags=json.dumps(["AI办公", "设计美工", "多任务办公", "商旅便携"], ensure_ascii=False),
        scene_basic=92, scene_multi=92, scene_design=82, scene_video=55, scene_3d=40,
        scene_ai=92, scene_travel=80, scene_entertainment=65,
        pros="旗舰处理器+OLED屏幕+轻薄机身，AI性能顶级",
        cons="没有独显，价格偏高",
        buy_guide="AI办公需求强烈用户的最佳选择，Ultra 9处理器NPU性能最强",
        suitable_for="AI办公用户、创意工作者、追求极致性能的轻薄本用户",
        not_suitable_for="重度游戏、预算有限用户",
        is_thin=1, weight_kg=1.29,
    ))

    # ======== 12000+ 旗舰档 ========
    laptops.append(LaptopModel(
        name="MacBook Pro 16 M4 Pro 2026款",
        brand="Apple",
        price_min=18999, price_max=24999, price_tag="12000+", year="2026", is_new=1,
        cpu="Apple M4 Pro芯片", cpu_level="flagship",
        cpu_desc="苹果M4 Pro芯片，12核CPU+18核GPU+16核NPU，专业创作性能怪兽",
        ram="36GB", ram_type="统一内存", ram_freq="", ram_expandable=0,
        ram_desc="36G统一内存，处理8K视频、大型3D项目、AI模型训练都绑绑的",
        storage="512GB SSD", storage_type="NVMe",
        storage_desc="512G起步，建议选1TB版本，苹果SSD读写速度行业最快",
        gpu="M4 Pro集成18核GPU", gpu_type="discrete",
        gpu_desc="18核GPU性能媲美RTX4070，Final Cut/达芬奇剪辑8K无压力",
        screen_size="16.2英寸", screen_resolution="3456x2234", screen_refresh="120Hz",
        screen_color_gamut="P3广色域", screen_brightness="1600nit HDR",
        screen_desc="Liquid Retina XDR显示屏，1600nit HDR峰值亮度，专业影视创作标配",
        weight="2.14kg", thickness="16.8mm", material="100%再生铝金属",
        portability_desc="2.14kg在16寸专业本里算正常，移动办公可以接受",
        battery="100Wh", battery_life="约15-18小时", fast_charge="140W快充",
        battery_desc="100Wh超大电池+M4 Pro高能效，续航18小时，专业工作也能撑一整天",
        ports="Thunderbolt 5 x3, HDMI 2.1 x1, SD卡槽, MagSafe, 耳机孔",
        ports_desc="3个雷电5+HDMI+SD卡槽，专业接口齐全，外接显示器不用转接",
        features="Liquid Retina XDR, ProMotion 120Hz, Apple Intelligence, 空间音频, 六扬声器",
        score_office=30, score_graphics=20, score_fluency=20, score_portability=9, score_value=10,
        score_total=89,
        scene_tags=json.dumps(["视频剪辑", "三维建模", "AI办公", "设计美工"], ensure_ascii=False),
        scene_basic=95, scene_multi=95, scene_design=92, scene_video=95, scene_3d=85,
        scene_ai=95, scene_travel=50, scene_entertainment=80,
        pros="专业创作性能无敌，续航超长，屏幕顶级，macOS生态优秀",
        cons="价格昂贵，重量偏大，游戏生态差",
        buy_guide="专业视频剪辑/音乐制作/AI开发的终极选择，建议选1TB版本",
        suitable_for="专业视频剪辑师、音乐制作人、AI开发者、高端创意工作者",
        not_suitable_for="普通办公用户(杀鸡用牛刀)、游戏玩家、预算有限用户",
        is_thin=0, weight_kg=2.14,
    ))

    laptops.append(LaptopModel(
        name="ThinkPad X1 Extreme 2026款",
        brand="ThinkPad",
        price_min=12999, price_max=15999, price_tag="12000+", year="2026", is_new=1,
        cpu="Intel Core Ultra 9 185H", cpu_level="flagship",
        cpu_desc="Intel旗舰处理器，6P+8E+2LPE核心+NPU，专业工作站级别性能",
        ram="32GB", ram_type="DDR5", ram_freq="5600MHz", ram_expandable=1,
        ram_desc="32G DDR5可扩展到64G，专业工作流灵活升级",
        storage="1TB SSD", storage_type="NVMe PCIe4.0",
        storage_desc="1TB企业级固态，双M.2插槽可扩展",
        gpu="NVIDIA RTX 4070 8GB", gpu_type="discrete",
        gpu_desc="RTX 4070专业独显，3D建模渲染、4K视频剪辑、AI训练都能胜任",
        screen_size="16英寸", screen_resolution="3840x2400", screen_refresh="120Hz",
        screen_color_gamut="100%DCI-P3", screen_brightness="600nit",
        screen_desc="4K+ OLED屏幕，600nit P3广色域，专业色准DeltaE<1",
        weight="1.88kg", thickness="17.9mm", material="碳纤维+镁铝合金",
        portability_desc="1.88kg塞进RTX4070，碳纤维机身兼顾轻便和坚固",
        battery="90Wh", battery_life="约8-10小时", fast_charge="130W快充",
        battery_desc="90Wh大电池，日常办公一整天，用独显重度工作建议插电",
        ports="Thunderbolt 4 x2, USB-A x2, HDMI 2.1 x1, SD卡槽, 网口, 耳机孔",
        ports_desc="最全接口：双雷电4+双USB-A+HDMI+网口+SD卡槽，外接设备随便接",
        features="RTX4070独显, 双M.2扩展, 网口, MIL-STD-810H军标, vPro企业管理, IR人脸识别",
        score_office=30, score_graphics=20, score_fluency=19, score_portability=10, score_value=9,
        score_total=88,
        scene_tags=json.dumps(["三维建模", "视频剪辑", "设计美工", "AI办公"], ensure_ascii=False),
        scene_basic=88, scene_multi=95, scene_design=92, scene_video=90, scene_3d=92,
        scene_ai=88, scene_travel=55, scene_entertainment=85,
        pros="4K OLED+RTX4070+可扩展，专业移动工作站，接口最全",
        cons="价格昂贵，重量偏大，续航一般",
        buy_guide="需要Windows专业工作站的终极选择，3D建模/AI训练首选",
        suitable_for="3D建模师、工程师、AI开发者、需要Windows专业软件的用户",
        not_suitable_for="普通办公用户、预算有限用户、追求轻薄的用户",
        is_thin=0, weight_kg=1.88,
    ))

    laptops.append(LaptopModel(
        name="华为MateBook X Pro 2026 微绒典藏版",
        brand="华为",
        price_min=12999, price_max=14999, price_tag="12000+", year="2026", is_new=1,
        cpu="Intel Core Ultra 9 185H", cpu_level="flagship",
        cpu_desc="Intel最强AI处理器，旗舰级性能+NPU AI加速",
        ram="32GB", ram_type="LPDDR5X", ram_freq="7467MHz", ram_expandable=0,
        ram_desc="32G超高频内存，旗舰级多任务处理能力",
        storage="2TB SSD", storage_type="NVMe PCIe4.0",
        storage_desc="2TB超大容量，存什么都够用",
        gpu="Intel Arc集成显卡", gpu_type="integrated",
        gpu_desc="Intel Arc核显+NPU，AI办公和轻度创作可以胜任",
        screen_size="14.2英寸", screen_resolution="3120x2080", screen_refresh="120Hz",
        screen_color_gamut="100%DCI-P3", screen_brightness="600nit",
        screen_desc="3.1K顶级OLED屏幕，P3广色域600nit，DeltaE<1专业色准",
        weight="0.98kg", thickness="13.5mm", material="微绒金属+镁铝合金",
        portability_desc="0.98kg极致轻薄，微绒工艺手感温润，尊贵质感",
        battery="72Wh", battery_life="约10-12小时", fast_charge="90W超级快充",
        battery_desc="72Wh大电池，旗舰处理器也能续航一整天",
        ports="Thunderbolt 4 x2, USB-C x1, 耳机孔",
        ports_desc="3个USB-C含2个雷电4，需要转接器",
        features="微绒工艺, AI慧眼, 超级终端, 六扬声器, 压感触控板, 指纹解锁",
        score_office=28, score_graphics=14, score_fluency=20, score_portability=15, score_value=8,
        score_total=85,
        scene_tags=json.dumps(["商旅便携", "AI办公", "多任务办公"], ensure_ascii=False),
        scene_basic=92, scene_multi=90, scene_design=72, scene_video=45, scene_3d=30,
        scene_ai=85, scene_travel=98, scene_entertainment=60,
        pros="0.98kg极致轻薄+微绒工艺尊贵质感+2TB超大存储+AI处理器",
        cons="没有独显，接口少，价格昂贵",
        buy_guide="华为旗舰商务本，追求极致轻薄+尊贵质感的用户首选",
        suitable_for="高端商务人士、华为生态深度用户、追求极致品质的用户",
        not_suitable_for="设计师(无独显)、游戏玩家、追求性价比的用户",
        is_thin=1, weight_kg=0.98,
    ))

    return laptops


if __name__ == "__main__":
    init_database()