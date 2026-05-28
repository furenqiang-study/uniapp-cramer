"""FastAPI 应用入口"""
import sys
import os

# 将当前目录加入 Python 路径
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from config import settings
from database import engine, Base
from routers import auth, menu, home, profile, log

# 创建数据库表
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="小米 uni-app 后台管理系统 API",
    description="基于 FastAPI + SQLAlchemy 的小程序后台接口",
    version="1.0.0",
)

# CORS 跨域配置
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 注册路由
app.include_router(auth.router)
app.include_router(menu.router)
app.include_router(home.router)
app.include_router(profile.router)
app.include_router(log.router)


@app.get("/", tags=["健康检查"])
def root():
    return {"message": "uni-app server is running", "version": "1.0.0"}


@app.get("/api/health", tags=["健康检查"])
def health():
    return {"status": "ok"}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host=settings.HOST, port=settings.PORT, reload=True)