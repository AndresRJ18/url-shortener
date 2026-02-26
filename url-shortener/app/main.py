from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import RedirectResponse, HTMLResponse
from pydantic import BaseModel
import string, random, os, pathlib

app = FastAPI()

static_dir = pathlib.Path(__file__).parent / "static"

try:
    import redis
    r = redis.Redis(
        host=os.getenv("REDIS_HOST", "redis"),
        port=6379,
        decode_responses=True,
        socket_connect_timeout=2
    )
    r.ping()
    store_type = "redis"
except:
    r = None
    store_type = "memory"

url_store = {}

class URLRequest(BaseModel):
    url: str

def generate_code(length: int = 6) -> str:
    chars = string.ascii_letters + string.digits
    return ''.join(random.choices(chars, k=length))

@app.get("/", response_class=HTMLResponse)
def home():
    return (static_dir / "index.html").read_text()

@app.get("/health")
def health():
    return {"status": "ok", "store": store_type}

@app.post("/shorten")
def shorten_url(request: URLRequest, req: Request):
    code = generate_code()
    if r:
        r.set(code, request.url)
    else:
        url_store[code] = request.url
    base_url = f"{req.url.scheme}://{req.headers.get('host', 'localhost')}"
    return {"short_url": f"{base_url}/{code}"}

@app.get("/{code}")
def redirect_url(code: str):
    url = r.get(code) if r else url_store.get(code)
    if not url:
        raise HTTPException(status_code=404, detail="URL no encontrada")
    return RedirectResponse(url=url, status_code=307)
