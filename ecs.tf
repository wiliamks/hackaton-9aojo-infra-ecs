# ECR
resource "aws_ecr_repository" "ecr" {
  name = "hackaton-ecr"
  tags = {
    Name        = "hackaton"
    Environment = "backend"
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "ecs-cluster" {
  name = "backend-cluster"
  tags = {
    Name        = "hackaton-ecs"
    Environment = "backend"
  }
}

# Task Definition
resource "aws_ecs_task_definition" "ecs-task" {
  family = "hackaton-backend-task"

  container_definitions = <<DEFINITION
  [
    {
            "name": "hackaton-app",
            "image": "420455272363.dkr.ecr.us-east-1.amazonaws.com/hackaton-ecr:VideoTraining",
            "cpu": 1024,
            "memory": 2048,
            "environment": [{"name": "DB_HOSTNAME", "value": "video-training-db.cpj14ox1uuzw.us-east-1.rds.amazonaws.com"} ,{"name": "DB_PORT", "value": "3066"}, {"name": "DB_NAME", "value":"videoTraining"},{"name": "DB_USERNAME", "value": "admin" }, {"name": "DB_PASSWORD", "value": "hackathon1234"}],
            "portMappings": [
                {
                    "containerPort": 8080,
                    "hostPort": 8080,
                    "protocol": "tcp"
                }
            ],
            "essential": true,
            "mountPoints": [],
            "volumesFrom": [],
            "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-create-group": "true",
                    "awslogs-group": "hackaton",
                    "awslogs-region": "us-east-1",
                    "awslogs-stream-prefix": "ecs"
                }
            }
        }
  ]
  DEFINITION

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = "2048"
  cpu                      = "1024"
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn            = aws_iam_role.ecsTaskExecutionRole.arn
#  environment = [{"DB_HOSTNAME": "video-training-db.cpj14ox1uuzw.us-east-1.rds.amazonaws.com", "DB_PORT": "3066", "DB_NAME": "videoTraining"}]

  tags = {
    Name        = "hackaton-ecs-td"
    Environment = "backend"
  }
}

data "aws_ecs_task_definition" "main" {
  task_definition = aws_ecs_task_definition.ecs-task.family
}

# ECS Service
resource "aws_ecs_service" "ecs-service" {
  name                 = "hackaton-ecs-service"
  cluster              = aws_ecs_cluster.ecs-cluster.id
  task_definition      = "${aws_ecs_task_definition.ecs-task.family}:${max(aws_ecs_task_definition.ecs-task.revision, data.aws_ecs_task_definition.main.revision)}"
  launch_type          = "FARGATE"
  scheduling_strategy  = "REPLICA"
  desired_count        = 1
  force_new_deployment = true

  network_configuration {
    subnets          = aws_subnet.private.*.id
    assign_public_ip = false
    security_groups = [
      aws_security_group.service_security_group.id,
      aws_security_group.alb_security_group.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = "hackaton-app"
    container_port   = 8080
  }

  depends_on = [aws_lb_listener.listener]
}

# SG
resource "aws_security_group" "service_security_group" {
  vpc_id = aws_vpc.vpc-hackaton.id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.alb_security_group.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "hackaton-service-sg"
    Environment = "backend"
  }
}
