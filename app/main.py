from fastapi import FastAPI, HTTPException
from fastapi.responses import RedirectResponse
from pydantic import BaseModel
import string, random, redis, os

app = FastAPI()

# Conecta a Redis — el host "redis" lo resuelve Docker Compose via networking
r = redis.Redis(
    host=os.getenv("REDIS_HOST", "redis"),
    port=6379,
    decode_responses=True
)

class URLRequest(BaseModel):
    url: str

def generate_code(length: int = 6) -> str:
    chars = string.ascii_letters + string.digits
    return ''.join(random.choices(chars, k=length))

@app.post("/shorten")
def shorten_url(request: URLRequest):
    code = generate_code()
    r.set(code, request.url)  # Guarda en Redis en vez de memoria
    return {"short_url": f"http://localhost/{code}"}

@app.get("/{code}")
def redirect_url(code: str):
    url = r.get(code)  # Lee de Redis
    if not url:
        raise HTTPException(status_code=404, detail="URL no encontrada")
    return RedirectResponse(url=url, status_code=307)
