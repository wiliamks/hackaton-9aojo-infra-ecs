resource "aws_alb" "application_load_balancer" {
  name               = "hackaton-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = aws_subnet.public.*.id
  security_groups    = [aws_security_group.alb_security_group.id]

  tags = {
    Name        = "hackaton-alb"
    Environment = "backend"
  }
}

# SG
resource "aws_security_group" "alb_security_group" {
  vpc_id = aws_vpc.vpc-hackaton.id

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name        = "hackaton-alb-sg"
    Environment = "backend"
  }
}

# TG
resource "aws_lb_target_group" "target_group" {
  name        = "hackaton-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.vpc-hackaton.id

#  health_check {
#    healthy_threshold   = "3"
#    interval            = "300"
#    protocol            = "HTTP"
#    matcher             = "200"
#    timeout             = "3"
#    path                = "/v1/status"
#    unhealthy_threshold = "2"
#  }

  tags = {
    Name        = "hackaton-lb-tg"
    Environment = "backend"
  }
}

# Listeners
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_alb.application_load_balancer.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.id
  }
}

