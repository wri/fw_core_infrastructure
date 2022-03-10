#
# ALB Resources
#

resource "aws_lb" "apigw" {
  name                             = trimsuffix(replace(substr("${var.project_prefix}-apigw-elb", 0, 32), "_", "-"), "-")
  enable_cross_zone_load_balancing = true

  subnets = data.terraform_remote_state.core.outputs.public_subnet_ids
  security_groups = [aws_security_group.lb.id]

  tags = local.tags
}


resource "aws_lb_target_group" "apigw_http" {
  name = trimsuffix(replace(substr("${var.project_prefix}-apigw-tg", 0, 32), "_", "-"), "-")
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.core.outputs.vpc_id
  target_type = "instance"
  tags = local.tags

  health_check {
    enabled = true
    path = "/status"
    matcher = "200,202"
  }
}

resource "aws_lb_target_group_attachment" "apigw_http" {
  target_group_arn = aws_lb_target_group.apigw_http.arn
  target_id = split("/",data.terraform_remote_state.core.outputs.api_gw_instance_arn)[1]
  port = 80
}

# use this resource as listener if no SSL certificate was provided (HTTP only)
# will listen on specified listener port (default 80)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.apigw.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.apigw_http.id
  }
}


# # If SSL certificate available forward HTTP requests to HTTPS
# # Listener port will be ignored
# resource "aws_lb_listener" "http_https" {
#   load_balancer_arn = aws_lb.apigw.arn
#   port              = 80
#   protocol          = "HTTP"

#   default_action {
#     type = "redirect"

#     redirect {
#       port        = "443"
#       protocol    = "HTTPS"
#       status_code = "HTTP_301"
#     }
#   }
# }


# # If SSL certificate present, use this resource as listener
# # listener port will be ignored
# resource "aws_lb_listener" "https" {
#   load_balancer_arn = aws_lb.apigw.arn
#   port              = 443
#   protocol          = "HTTPS"
#   certificate_arn   = data.terraform_remote_state.core.outputs.acm_certificate
#   default_action {
#     type = "fixed-response"
#     fixed_response {
#       content_type = "application/json"
#       message_body = jsonencode({
#         data : {},
#         status : "success"
#       })
#       status_code = 200
#     }
#   }
# }


###

# ALB Security group
# This is the group you need to edit if you want to restrict access to your application
resource "aws_security_group" "lb" {

  name        = "${var.project_prefix}-apigw-alb"
  description = "Controls access to the ALB for APIGW"
  vpc_id      = data.terraform_remote_state.core.outputs.vpc_id

  # When using SSL certificate open port 80 for ingress, otherwise user specific port
  ingress {
    protocol  = "tcp"
    from_port = 80
    to_port   = 80
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

  egress {
    protocol = "tcp"
    from_port = 80
    to_port = 80
    cidr_blocks = [
      data.terraform_remote_state.core.outputs.cidr_block
    ]
  }
  egress {
    protocol = "tcp"
    from_port = 443
    to_port = 443
    cidr_blocks = [
      data.terraform_remote_state.core.outputs.cidr_block
    ]
  }

  tags = merge(
    {
      Name = "${var.project_prefix}-apigw-alb"
    },
    local.tags
  )
}
