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


module "data_bucket" {
  source         = "git::https://github.com/wri/gfw-terraform-modules.git//terraform/modules/storage?ref=v0.5.0"
  bucket_name    = "gfw-fw-data${local.bucket_suffix}"
  project        = var.project_prefix
  tags           = merge({ Job = "Forest Watcher Data" }, local.tags)
}


module "api_key_secret" {
  source        = "git::https://github.com/wri/gfw-terraform-modules.git//terraform/modules/secrets?ref=v0.5.0"
  project       = var.project_prefix
  name          = "${var.project_prefix}-gfw_data_api_key"
  secret_string = var.gfw_data_api_key
}