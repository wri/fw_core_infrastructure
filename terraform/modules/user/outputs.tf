output "name" {
  value = aws_iam_user.default.name
}

output "public_key" {
  value = aws_iam_user_ssh_key.default.public_key
}