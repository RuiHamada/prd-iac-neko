FROM python:3.12

WORKDIR /app

# 環境変数の設定
ENV PYTHONPATH=/app
ENV PYTHONUNBUFFERED=1
ENV PORT=8080

# 依存関係のインストール
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# curlをヘルスチェック用にインストール
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# アプリケーションファイルのコピー
COPY . .

# 非rootユーザーの作成と設定
RUN useradd --create-home --shell /bin/bash app \
    && chown -R app:app /app
USER app

EXPOSE ${PORT}

# ヘルスチェック
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:${PORT}/ || exit 1

CMD ["sh", "-c", "gunicorn --bind 0.0.0.0:$PORT --workers 1 --threads 8 --timeout 0 --preload --log-level info main:app"]
