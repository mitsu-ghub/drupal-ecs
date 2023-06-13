resource "aws_lb" "drupal_load_balancer" {
  name               = "drupal-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.drupal_sg.id]
  subnets            = module.vpc.public_subnets  # Replace with your desired subnets

  tags = {
    Name = "drupal-load-balancer"
  }
}

resource "aws_lb_target_group" "drupal_target_group" {
  name        = "drupal-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"
  health_check {
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "drupal_listener" {
  load_balancer_arn = aws_lb.drupal_load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.drupal_target_group.arn
    type             = "forward"
  }
}

resource "aws_lb_listener_rule" "drupal_listener_rule" {
  listener_arn = aws_lb_listener.drupal_listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.drupal_target_group.arn
  }

  condition {
    path_pattern {
      values = ["/"]
    }
  }
}

