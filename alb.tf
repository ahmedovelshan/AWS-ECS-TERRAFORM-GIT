
resource "aws_lb_target_group" "web-inctances" {
  name     = "web-inctances"
  port     = 80
  protocol = "HTTP"
  health_check {
    enabled = true
    interval = 30
    path = "/index.html"
    port = 80
    protocol = "HTTP"
    timeout = 15
    unhealthy_threshold = 3
  }
  vpc_id   = aws_vpc.devops-vpc.id
}
resource "aws_lb" "alb-web" {
  name               = "alb-for-web"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.www-to-alb.id]
  subnets            = [for subnet in aws_subnet.public-subnet : subnet.id]

  depends_on = [ aws_lb_target_group.web-inctances ]
}


resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.alb-web.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web-inctances.arn
  }
}
