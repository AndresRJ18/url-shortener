provider "aws" {
  region = "us-east-1"
}

# Repo donde se guardan las imágenes Docker
resource "aws_ecr_repository" "url_shortener" {
  name                 = "url-shortener"
  image_tag_mutability = "MUTABLE"

  # Limpia imágenes viejas sin tag
  image_scanning_configuration {
    scan_on_push = true
  }
}

output "ecr_repo_url" {
  value = aws_ecr_repository.url_shortener.repository_url
}
