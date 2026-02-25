FROM python:3.12-slim

WORKDIR /app

# Deps primero — aprovecha cache de layers
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app/ .

# No correr como root
RUN useradd -r appuser
USER appuser

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
