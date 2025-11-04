FROM python:3.13-alpine AS builder

WORKDIR /app

COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir gunicorn

COPY . .

FROM python:3.13-alpine

WORKDIR /app

COPY --from=builder /usr/local /usr/local

COPY . .

CMD sh -c "python3 -c 'from app import init_db; init_db()' && gunicorn -w 4 -b 0.0.0.0:${PORT} wsgi:app"
