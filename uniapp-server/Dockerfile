FROM python:3.11-slim

WORKDIR /app

# 安装依赖
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple

# 复制项目文件
COPY . .

# 暴露端口
EXPOSE 8022

# 启动命令
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8022"]