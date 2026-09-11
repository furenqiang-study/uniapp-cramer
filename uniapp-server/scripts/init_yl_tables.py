import sys
sys.path.insert(0, r"D:\work\MyVueProject\2026\xiaomi-uniapp\uniapp-server")
from sqlalchemy import text
from database import engine, Base
from models.user import User  # noqa
from models.menu import Menu  # noqa
from models.log import OperationLog  # noqa
from models import coolcap  # noqa

try:
    Base.metadata.create_all(bind=engine)
    print("create_all OK")
    with engine.connect() as conn:
        rows = conn.execute(text("SHOW TABLES LIKE 'YL_%'")).fetchall()
        print("YL tables:", [r[0] for r in rows])
except Exception as e:
    print("DB_ERROR", type(e).__name__, e)
    sys.exit(1)
