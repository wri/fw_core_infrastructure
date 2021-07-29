terraform {
  backend "s3" {
    region  = "us-east-1"
    key     = "wri__fw_core_infrastructure.tfstate"
    encrypt = true
  }
}

module "cluster" {
  source         = "./modules/cluster"
  project_prefix = var.project_prefix
  tags           = local.tags
}

module "loadbalancer" {
  source              = "./modules/loadbalancer"
  project_prefix      = var.project_prefix
  subnet_ids          = data.terraform_remote_state.core.outputs.public_subnet_ids
  tags                = local.tags
  vpc_id              = data.terraform_remote_state.core.outputs.vpc_id
  acm_certificate_arn = data.terraform_remote_state.core.outputs.acm_certificate
}
