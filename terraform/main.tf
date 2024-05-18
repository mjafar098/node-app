provider "aws" {
  region = var.aws_region
}

resource "aws_ecs_cluster" "cluster" {
  name = var.ecs_cluster_name
}

resource "aws_iam_role" "ecs_task_execution" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Peincipal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam:aws::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "app" {
  family = var.app_name
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "256"
  memory = "512"
  execution_role_arn = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name = var.app_name
      image = "${aws_ecr_repository.app.repository_url}:latest"
      portMappings = [
        {
          containerPort = 3000
          hostPort = 3000
        }
      ]
    }
  ])
}

resource "aws_ecr_repository" "app" {
  name = var.app_name
}

resource "aws_ecs_service" "app" {
  name = var.app_name
  cluster = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count = var.desired_count
  launch_type = "FARGATE"

  network_configuration {
    subents = aws_subnet.subnet.*.id
    security_groups = [aws_security_group.app.id]
  }
}

resource "aws_security_group" "app" {
  name = "app-sg"
  description = "Allow inbound traffics to  the app"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port = 3000
    to_port = 3000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0]
    }

    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0]
      }
    }

    resource "aws_vpc" "main"{
      cidr_block = "10.0.0.0/16"
    }

    resource "aws_subnet_" "subnet" {
      count = 2
      vpc_id = aws_vpc.main.id
      cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
      availability_zone = element(["$(var,aws_region}a","${var.aws_region}b"], count.index)
    }
