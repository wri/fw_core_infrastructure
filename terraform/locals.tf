
# some local
locals {
  bucket_suffix   = var.environment == "production" ? "" : "-${var.environment}"
  tf_state_bucket = "gfw-terraform${local.bucket_suffix}"
  tags            = data.terraform_remote_state.core.outputs.tags
  fargate_tags = merge(
    {
      Job = "Data-API Service",
  }, local.tags)
  name_suffix = terraform.workspace == "default" ? "" : "-${terraform.workspace}"
  project     = "fw"
}

