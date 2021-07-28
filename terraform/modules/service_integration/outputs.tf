output "lb_target_group_arn" {
  value = aws_lb_target_group.default.arn
}

output "lb_target_group_port" {
  value = aws_lb_target_group.default.port
}