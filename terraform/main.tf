terraform {
  backend "s3" {
    region = "us-east-1"
    key = "wri__fw_core_infrastructure.tfstate"
    encrypt = true
  }
}

module "cluster" {
  source = "./modules/cluster"
  project_prefix = var.project_prefix
  tags = local.tags
}

module "loadbalancer" {
  source = "./modules/loadbalancer"
  project_prefix = var.project_prefix
  subnet_ids = data.terraform_remote_state.core.outputs.public_subnet_ids
  tags = local.tags
  vpc_id = data.terraform_remote_state.core.outputs.vpc_id
}

module "documentdb" {
  source = "./modules/document_db"
  log_retention_period = var.log_retention_period
  private_subnet_ids = data.terraform_remote_state.core.outputs.private_subnet_ids
  project = var.project_prefix
  backup_retention_period = var.backup_retention_period
  instance_class = var.db_instance_class
  cluster_size = var.db_instance_count
  master_username = "wri"  # superuser, create app specific users at project level
  tags = local.tags
  vpc_id = data.terraform_remote_state.core.outputs.vpc_id
  vpc_cidr_block = data.terraform_remote_state.core.outputs.cidr_block
  engine_version = "3.6.0"
  enabled_cloudwatch_logs_exports = var.db_logs_exports
  cluster_parameters = [
    {
      apply_method = "pending-reboot"
      name = "tls"
      value = "disabled"
    }]
}
