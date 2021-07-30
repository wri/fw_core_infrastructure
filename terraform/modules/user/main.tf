
resource "aws_iam_user" "default" {
  name = var.user_name
  path = var.path
  force_destroy = var.force_destroy
  tags = merge({
    Name = var.full_name
    Email = var.email
    Organization = var.organization
  }, var.tags)
}

resource "aws_iam_access_key" "default" {
  user = aws_iam_user.default.name
}