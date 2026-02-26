provider "aws" {
  region = "us-east-1"
}

# ==================== ECR ====================
resource "aws_ecr_repository" "url_shortener" {
  name                 = "url-shortener"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}

# ==================== VPC ====================
resource "aws_default_vpc" "default" {}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [aws_default_vpc.default.id]
  }
}

# ==================== SECURITY GROUP ====================
resource "aws_security_group" "ecs_sg" {
  name        = "url-shortener-ecs-sg"
  description = "Allow HTTP traffic"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ==================== ECS ====================
resource "aws_ecs_cluster" "url_shortener" {
  name = "url-shortener-cluster"
}

resource "aws_iam_role" "ecs_execution_role" {
  name = "url-shortener-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "url_shortener" {
  family                   = "url-shortener"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([{
    name      = "url-shortener"
    image     = "${aws_ecr_repository.url_shortener.repository_url}:latest"
    essential = true
    portMappings = [{
      containerPort = 8000
      protocol      = "tcp"
    }]
  }])
}

resource "aws_ecs_service" "url_shortener" {
  name            = "url-shortener-service"
  cluster         = aws_ecs_cluster.url_shortener.id
  task_definition = aws_ecs_task_definition.url_shortener.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true  # Acceso directo por IP pública
  }
}

# ==================== OUTPUTS ====================
output "ecr_repo_url" {
  value = aws_ecr_repository.url_shortener.repository_url
}

output "nota" {
  value = "La IP pública la encuentras en la consola de ECS > Cluster > Task > Public IP"
}
