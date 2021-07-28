// Load Balancer Target group and Listener


resource "aws_lb_target_group" "default" {
  name        = "${var.project_prefix}-target-group-${var.service_path}"
  port        = var.port
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    enabled  = true
    protocol = "TCP"
  }

  tags = var.tags

}


resource "aws_lb_listener" "default" {
  load_balancer_arn = var.load_balancer_arn
  port              = var.port
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.default.arn
  }
}


// API Gateway resources


resource "aws_api_gateway_resource" "service_root" {
  rest_api_id = var.api_gateway_id
  parent_id   = var.api_gateway_root_resource_id
  path_part   = var.service_path
}


resource "aws_api_gateway_method" "service_root" {
  rest_api_id   =  var.api_gateway_id
  resource_id   = aws_api_gateway_resource.service_root.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "nlb_root" {
  rest_api_id = var.api_gateway_id
  resource_id = aws_api_gateway_method.service_root.resource_id
  http_method = aws_api_gateway_method.service_root.http_method

  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  connection_type         = "VPC_LINK"
  connection_id           = var.vpc_link_id
  uri                     = "http://${var.load_balancer_dns}"
}


resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = var.api_gateway_id
  parent_id   = aws_api_gateway_resource.service_root.id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = var.api_gateway_id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "nlb" {
  rest_api_id = var.api_gateway_id
  resource_id = aws_api_gateway_method.proxy.resource_id
  http_method = aws_api_gateway_method.proxy.http_method

  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  connection_type         = "VPC_LINK"
  connection_id           = "${var.vpc_link_id}"
  uri                     = "http://${var.load_balancer_dns}"
}
