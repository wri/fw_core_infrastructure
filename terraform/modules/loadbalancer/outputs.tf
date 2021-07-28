output "dns_name" {
  value = aws_lb.default.dns_name
}

output "arn" {
  value = aws_lb.default.arn
}

output "listener_arn"{
  value = var.acm_certificate_arn == null ? aws_lb_listener.http[0].arn : aws_lb_listener.https[0].arn
}

output "security_group_arn" {
  value = aws_security_group.lb.arn
}

output "security_group_id" {
  value = aws_security_group.lb.id
}