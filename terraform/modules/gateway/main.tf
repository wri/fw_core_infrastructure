#
# API Gateway resources
#
resource "aws_api_gateway_vpc_link" "default" {
  name        = "link${var.environment}${var.project_prefix}"
  target_arns = [aws_lb.default.arn]
}

resource "aws_api_gateway_rest_api" "default" {
  name = "api${var.environment}${var.project_prefix}"
  description = "API Gateway for the Forest Watcher"

  endpoint_configuration {
    types = [
    "REGIONAL"]
  }
}


resource "aws_api_gateway_deployment" "default" {

  rest_api_id = aws_api_gateway_rest_api.default.id
  stage_name  = "${var.project_prefix}-api_gateway_deployment"

   triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.default.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "default" {
  deployment_id = aws_api_gateway_deployment.default.id
  rest_api_id   = aws_api_gateway_rest_api.default.id
  stage_name    = "${var.project_prefix}-api_gateway_stage"
}

#
# NLB Resources
#
resource "aws_lb" "default" {
  name                             = "nlb${var.environment}${var.project_prefix}"
  internal                         = true
  load_balancer_type               = "network"
  enable_cross_zone_load_balancing = true

  subnets = var.vpc_private_subnet_ids

  tags = var.tags
}
