output "api_endpoint" {
  value       = "${aws_api_gateway_deployment.default.invoke_url}"
  description = "API Gateway endpoint responsible for proxying requests to the ECS service."
}

output "api_gateway_id" {
  value = aws_api_gateway_rest_api.default.id
}

output "api_gateway_root_resource_id" {
  value = aws_api_gateway_rest_api.default.root_resource_id
}

output "load_balancer_arn" {
  value = aws_lb.default.arn
}

output "load_balancer_dns" {
  value = aws_lb.default.dns_name
}

output "vpc_link_id" {
  value = aws_api_gateway_vpc_link.default.id
}