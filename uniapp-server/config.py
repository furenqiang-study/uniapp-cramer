"""应用配置"""
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    # 数据库配置
    DB_HOST: str = "120.48.35.53"
    DB_PORT: int = 3306
    DB_USER: str = "root"
    DB_PASSWORD: str = "123321Frq"
    DB_NAME: str = "study_uniapp"

    @property
    def DATABASE_URL(self) -> str:
        return f"mysql+pymysql://{self.DB_USER}:{self.DB_PASSWORD}@{self.DB_HOST}:{self.DB_PORT}/{self.DB_NAME}?charset=utf8mb4&use_unicode=1"

    # JWT配置
    SECRET_KEY: str = "xiaomi-uniapp-secret-key-2026"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 1440  # 24小时

    # 服务配置
    HOST: str = "0.0.0.0"
    PORT: int = 8000

    class Config:
        env_file = ".env"


settings = Settings()