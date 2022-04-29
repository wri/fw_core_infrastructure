# -------------------
# ApiGW ALB Resources
# -------------------

# ALB Security group
# This is the group you need to edit if you want to restrict access to your application
resource "aws_security_group" "lb" {

  name        = "${var.project_prefix}-apigw-alb"
  description = "Controls access to the ALB for APIGW"
  vpc_id      = data.terraform_remote_state.core.outputs.vpc_id

  # When using SSL certificate open port 443 for ingress, otherwise user specific port
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

# Load balancer, listener and target groups
resource "aws_lb" "apigw" {
  name                             = trimsuffix(replace(substr("${var.project_prefix}-apigw-elb", 0, 32), "_", "-"), "-")
  enable_cross_zone_load_balancing = true

  subnets = data.terraform_remote_state.core.outputs.public_subnet_ids
  security_groups = [aws_security_group.lb.id]

  tags = local.tags
}


resource "aws_lb_target_group" "apigw_http" {
  name_prefix = trimsuffix(replace(substr("${var.project_prefix}-apigw-tg", 0, 6), "_", "-"), "-")
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.core.outputs.vpc_id
  target_type = "instance"
  tags = local.tags

  health_check { 
    enabled = true
    path = "/status"    // This endpoint is specific for Kong, amend this if using a different API Gateway
    matcher = "200,202"
  }
}

resource "aws_lb_target_group_attachment" "apigw_http" {
  target_group_arn = aws_lb_target_group.apigw_http.arn
  target_id = split("/",aws_instance.apigw.arn)[1] // Get ID from instance ARN
  port = 80

  # Use this `depends_on` block if no SSL certificate was provided (for HTTP only)
  # depends_on = [
  #   aws_lb_listener.http
  # ]

  depends_on = [
    aws_lb_listener.http_https
  ]
}
# use this resource as listener if no SSL certificate was provided (HTTP only)
# will listen on specified listener port (default 80)
# resource "aws_lb_listener" "http" {
#   load_balancer_arn = aws_lb.apigw.arn
#   port              = 80
#   protocol          = "HTTP"

#   default_action {
#     type = "forward"
#     target_group_arn = aws_lb_target_group.apigw_http.id
#   }
# }


# # If SSL certificate available forward HTTP requests to HTTPS
# Listener port will be ignored
resource "aws_lb_listener" "http_https" {
  load_balancer_arn = aws_lb.apigw.arn
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


# # If SSL certificate present, use this resource as listener
# # listener port will be ignored
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.apigw.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = data.terraform_remote_state.core.outputs.acm_certificate
  default_action {
    type = "forward"
    target_group_arn = "${aws_lb_target_group.apigw_http.id}"
  }
}

# ------------------
# ApiGW EC2 instance
# ------------------

data "aws_ami" "apigw_ami" {
  most_recent = true
  owners = [
  "amazon"]

  filter {
    name = "name"
    values = [
    "amzn2-ami-hvm*"]
  }
}

resource "aws_security_group" "apigw" {
  vpc_id = data.terraform_remote_state.core.outputs.vpc_id
  name   = "${var.project_prefix}-apigw"
  tags = merge(
    {
      Name = "${var.project_prefix}-apigw"
    },
    local.tags
  )
}

resource "aws_security_group_rule" "apigw_http_ingress" {
  type        = "ingress"
  from_port   = "80"
  to_port     = "80"
  protocol    = "tcp"
  cidr_blocks = [data.terraform_remote_state.core.outputs.cidr_block]

  security_group_id = aws_security_group.apigw.id
}
resource "aws_security_group_rule" "apigw_https_ingress" {
  type        = "ingress"
  from_port   = "443"
  to_port     = "443"
  protocol    = "tcp"
  cidr_blocks = [data.terraform_remote_state.core.outputs.cidr_block]

  security_group_id = aws_security_group.apigw.id
}

# User data script to bootstrap authorized ssh keys
data "template_file" "apigw_setup" {
  template = file("${path.module}/user_data/bastion_setup.sh.tpl")
  vars = {
    user                = "ec2-user"
    authorized_ssh_keys = <<EOT
%{for row in formatlist("echo \"%v\" >> /home/ec2-user/.ssh/authorized_keys", values(data.terraform_remote_state.core.outputs.key_pairs)[*].public_key)~}
${row}
%{endfor~}
EOT
  }
}

resource "aws_instance" "apigw" {
  ami                         = data.aws_ami.apigw_ami.id
  ebs_optimized               = true
  instance_type               = "t3.large"
  monitoring                  = true
  subnet_id                   = data.terraform_remote_state.core.outputs.public_subnet_ids[0]
  vpc_security_group_ids      = [data.terraform_remote_state.core.outputs.default_security_group_id, aws_security_group.apigw.id]
  associate_public_ip_address = true
  user_data                   = data.template_file.apigw_setup.rendered

  lifecycle {
    ignore_changes = [ami]
  }

  tags = merge(
    {
      Name = "${var.project}-ApiGW"
    },
    local.tags
  )
}

# resource "aws_eip" "apigw" {
#   vpc = true
# }

# resource "aws_eip_association" "apigw_eip_assoc" {
#   instance_id   = aws_instance.apigw.id
#   allocation_id = aws_eip.apigw.id
# }

# -------------
# ApiGW Outputs
# -------------

output "api_gw_hostname" {
    value = aws_instance.apigw.public_dns
}
output "api_gw_public_ip" {
    value = aws_instance.apigw.public_ip
}
output "api_gw_instance_arn" {
    value = aws_instance.apigw.arn
}