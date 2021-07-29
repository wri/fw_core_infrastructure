#
# ALB Resources
#

resource "aws_lb" "default" {
  name                             = trimsuffix(replace(substr("${var.project_prefix}-elb", 0, 32), "_", "-"), "-")
  enable_cross_zone_load_balancing = true

  subnets = var.subnet_ids
  security_groups = [
  aws_security_group.lb.id]

  tags = var.tags
}


# use this resource as listener if no SSL certificate was provided (HTTP only)
# will listen on specified listener port (default 80)
resource "aws_lb_listener" "http" {
  count             = var.acm_certificate_arn == null ? 1 : 0
  load_balancer_arn = aws_lb.default.arn
  port              = var.listener_port
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "application/json"
      message_body = jsonencode({
        data : {},
        status : "success"
      })
      status_code = 200
    }
  }
}


# If SSL certificate available forward HTTP requests to HTTPS
# Listener port will be ignored
resource "aws_lb_listener" "http_https" {
  count             = var.acm_certificate_arn == null ? 0 : 1
  load_balancer_arn = aws_lb.default.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}


# If SSL certificate present, use this resource as listener
# listener port will be ignored
resource "aws_lb_listener" "https" {
  count             = var.acm_certificate_arn == null ? 0 : 1
  load_balancer_arn = aws_lb.default.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.acm_certificate_arn
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "application/json"
      message_body = jsonencode({
        data : {},
        status : "success"
      })
      status_code = 200
    }
  }
}


###

# ALB Security group
# This is the group you need to edit if you want to restrict access to your application
resource "aws_security_group" "lb" {

  name        = "${var.project_prefix}-ecs-alb"
  description = "Controls access to the ALB"
  vpc_id      = var.vpc_id

  # When using SSL certificate open port 80 for ingress, otherwise user specific port
  ingress {
    protocol  = "tcp"
    from_port = var.acm_certificate_arn == null ? 80 : var.listener_port
    to_port   = var.acm_certificate_arn == null ? 80 : var.listener_port
    cidr_blocks = [
    "0.0.0.0/0"]
  }

  ingress {
    protocol  = "tcp"
    from_port = 443
    to_port   = 443
    cidr_blocks = [
    "0.0.0.0/0"]
  }

  tags = merge(
    {
      Name = "${var.project_prefix}-ecs-alb"
    },
    var.tags
  )
}

