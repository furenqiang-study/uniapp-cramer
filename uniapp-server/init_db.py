"""数据库初始化：创建 CoolCap 相关表并写入默认管理员"""
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from database import engine, Base, SessionLocal
from models.user import User  # noqa: F401
from models.log import OperationLog  # noqa: F401
from models import coolcap  # noqa: F401
from services.auth import hash_password


def init_database():
    print("创建表结构...")
    Base.metadata.create_all(bind=engine)

    db = SessionLocal()
    try:
        admin = db.query(User).filter(User.username == "admin").first()
        if not admin:
            admin = User(
                username="admin",
                password=hash_password("admin123"),
                nickname="管理员",
                role="admin",
                status=1,
            )
            db.add(admin)
            db.commit()
            print("已创建默认管理员 admin / admin123")
        else:
            print("管理员已存在")

        # 确保内置方案存在
        from routers.coolcap import _ensure_builtin_protocols
        _ensure_builtin_protocols(db)
        print("初始化完成")
    finally:
        db.close()


if __name__ == "__main__":
    init_database()
