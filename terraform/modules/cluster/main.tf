resource "aws_ecs_cluster" "default" {
  name = "${var.project_prefix}-cluster"
  tags = var.tags
}