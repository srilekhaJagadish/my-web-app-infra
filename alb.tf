resource "aws_lb" "fomax_alb" {
  name               = "fomax-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = module.vpc.public_subnets
}

resource "aws_lb_target_group" "app_tg" {
  port     = 8080
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    path = "/actuator/health"
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.fomax_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}