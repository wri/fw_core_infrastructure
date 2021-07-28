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
  depends_on = var.api_gateway_integratons

  rest_api_id = aws_api_gateway_rest_api.default.id
  stage_name  = "default"
}

data "aws_subnet" "private_subnet" {
  count = length(var.vpc_private_subnet_ids)
  id    = var.vpc_private_subnet_ids[count.index]
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
