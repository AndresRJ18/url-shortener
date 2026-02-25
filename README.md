# URL Shortener

Acortador de URLs desplegado en AWS ECS Fargate con CI/CD automatizado.

## Tech Stack

- **FastAPI** — API REST
- **Redis** — almacenamiento key-value
- **Nginx** — reverse proxy
- **Docker + Docker Compose** — contenedorización
- **Terraform** — infraestructura como código
- **GitHub Actions** — CI/CD pipeline
- **AWS ECR** — registro de imágenes
- **AWS ECS Fargate** — despliegue serverless

## Arquitectura
```
Internet → Nginx :80 → FastAPI :8000 → Redis :6379
```

## Uso
```bash
# Acortar URL
curl -X POST http://<host>/shorten \
  -H "Content-Type: application/json" \
  -d '{"url": "https://ejemplo.com"}'

# Redirect
curl -L http://<host>/<código>
```

## Desarrollo local
```bash
docker compose up --build
```

## Deploy

El pipeline de GitHub Actions buildea y pushea la imagen a ECR en cada push a `main`. La infra se provisiona con Terraform:
```bash
cd terraform
terraform init
terraform apply
```
