"""数据库初始化脚本 - 创建表结构并插入初始数据"""
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from database import engine, Base, SessionLocal
from models.user import User
from models.menu import Menu
from models.log import OperationLog
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

        print("\n数据库初始化完成！")

    finally:
        db.close()


if __name__ == "__main__":
    init_database()