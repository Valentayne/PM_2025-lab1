FROM python:3.13-alpine AS builder

WORKDIR /app

COPY backend/requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt
COPY backend/ .  

FROM python:3.13-alpine

WORKDIR /app

COPY --from=builder /usr/local/lib/python3.13 /usr/local/lib/python3.13

COPY backend/ .  

EXPOSE 5000

CMD ["python", "app.py"]
