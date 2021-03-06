
resource "aws_iam_group" "default" {
  name = var.name
  path = var.path
}

resource "aws_iam_group_membership" "default" {
  name = "${var.project_prefix}-${aws_iam_group.default.name}-membership"
  users = var.users
  group = aws_iam_group.default.name
}



resource "aws_iam_group_policy_attachment" "default" {
  count      = length(var.policy_arns)
  group      = aws_iam_group.default.name
  policy_arn = var.policy_arns[count.index]
}