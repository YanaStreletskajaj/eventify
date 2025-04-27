FROM python:3.13-alpine


WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 3000
WORKDIR /app/src

CMD ["sh", "-c", "alembic upgrade head && python main.py"]