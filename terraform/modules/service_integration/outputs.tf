output "lb_target_group_arn" {
  value = aws_lb_target_group.default.arn
}

output "lb_target_group_port" {
  value = aws_lb_target_group.default.port
}

output "root_resource" {
  value = aws_api_gateway_resource.service_root.id
}

output "proxy_resource" {
  value = aws_api_gateway_resource.proxy.id
}