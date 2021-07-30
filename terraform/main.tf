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
  source      = "git::https://github.com/wri/gfw-terraform-modules.git//terraform/modules/storage?ref=v0.5.0"
  bucket_name = "gfw-fw-data${local.bucket_suffix}"
  project     = var.project_prefix
  tags        = merge({ Job = "Forest Watcher Data" }, local.tags)
}


module "api_key_secret" {
  source        = "git::https://github.com/wri/gfw-terraform-modules.git//terraform/modules/secrets?ref=v0.5.0"
  project       = var.project_prefix
  name          = "${var.project_prefix}-gfw_data_api_key"
  secret_string = var.gfw_data_api_key
}

module "user_sdavidge_3sc" {
  source       = "./modules/user"
  email        = "sam@3sidedcube.com"
  full_name    = "Sam Davidge"
  organization = "3SidedCube"
  tags         = local.tags
  user_name    = "sdavidge_3sc"
}

module "user_tyeadon_3sc" {
  source       = "./modules/user"
  email        = "tom.yeadon@3sidedcube.com"
  full_name    = "Tom Yeadon"
  organization = "3SidedCube"
  tags         = local.tags
  user_name    = "tyeadon_3sc"
}

module "user_bsherred_3sc" {
  source       = "./modules/user"
  email        = "ben.sherred@3sidedcube.com"
  full_name    = "Ben Sherred"
  organization = "3SidedCube"
  tags         = local.tags
  user_name    = "bsherred_3sc"
}

module "user_jsantos_3sc" {
  source       = "./modules/user"
  email        = "javier@3sidedcube.com"
  full_name    = "Javier Santos"
  organization = "3SidedCube"
  tags         = local.tags
  user_name    = "jsantos_3sc"
}

module "user_wkelsey_3sc" {
  source       = "./modules/user"
  email        = "will.kelsey@3sidedcube.com"
  full_name    = "Will Kelsey"
  organization = "3SidedCube"
  tags         = local.tags
  user_name    = "wkelsey_3sc"
}

module "s3c_developers" {
  source = "./modules/group"
  project_prefix = var.project_prefix
  name   = "s3c_developers"
  policy_arns = ["arn:aws:iam::aws:policy/ReadOnlyAccess",
    module.data_bucket.write_policy_arns[0],
  data.terraform_remote_state.core.outputs.document_db_secrets_policy_arn]
  users = [module.user_bsherred_3sc.name,
    module.user_jsantos_3sc.name,
    module.user_sdavidge_3sc.name,
    module.user_tyeadon_3sc.name,
  module.user_wkelsey_3sc.name]
  path = "/users/"
}