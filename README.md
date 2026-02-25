# 🔗 URL Shortener

Acortador de URLs full-stack desplegado en AWS ECS Fargate con CI/CD automatizado.

## Demo

![Demo](demo.gif)

## Tech Stack

- **FastAPI** (Python) — API REST
- **Redis** — almacenamiento key-value con persistencia
- **Nginx** — reverse proxy
- **Docker + Docker Compose** — contenedorización multi-servicio
- **Terraform** — infraestructura como código (IaC)
- **GitHub Actions** — CI/CD pipeline
- **AWS ECR** — registro privado de imágenes Docker
- **AWS ECS Fargate** — despliegue serverless

## Arquitectura

### Local (Docker Compose)
```
Cliente → Nginx :80 → FastAPI :8000 → Redis :6379
```

### Producción (AWS)
```
Cliente → ECS Fargate :8000 → FastAPI
              │
              └── Imagen desde ECR (CI/CD automático)
```

## Endpoints

| Método | Ruta | Descripción |
|--------|------|-------------|
| POST | `/shorten` | Acorta una URL |
| GET | `/{code}` | Redirige a la URL original |
| GET | `/health` | Health check del servicio |
| GET | `/docs` | Documentación Swagger |
| GET | `/` | Frontend web |

## Desarrollo local
```bash
docker compose up --build
# Abrir http://localhost
```

## Deploy a AWS
```bash
cd terraform
terraform init
terraform apply

# Destruir para no pagar
terraform destroy
```

## CI/CD

Cada push a `main` ejecuta automáticamente:
1. Build de la imagen Docker
2. Push a AWS ECR con tag `latest` + SHA del commit

## Estructura
```
url-shortener/
├── app/
│   ├── main.py              # API FastAPI
│   └── static/
│       └── index.html       # Frontend
├── nginx/
│   └── nginx.conf           # Reverse proxy
├── terraform/
│   └── main.tf              # Infra AWS
├── .github/workflows/
│   └── deploy.yml           # CI/CD pipeline
├── Dockerfile
├── docker-compose.yml
└── requirements.txt
```
