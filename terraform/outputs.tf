output "vpc_private_subnet_ids" {
  value = data.terraform_remote_state.core.outputs.private_subnet_ids
}

output "vpc_id" {
  value = data.terraform_remote_state.core.outputs.vpc_id
}

output "vpc_cidr_block" {
  value = data.terraform_remote_state.core.outputs.cidr_block
}

output "ecs_cluster_id" {
  value = module.cluster.cluster_id
}

output "lb_arn" {
  value = module.gateway.load_balancer_arn
}

output "fw_forms_lb_target_group_arn" {
  value = module.fw_forms_integration.lb_target_group_arn
}
output "fw_forms_lb_target_group_port" {
  value = module.fw_forms_integration.lb_target_group_port
}

output "document_db_endpoint" {
  value = module.documentdb.endpoint
}

output "document_db_reader_endpoint" {
  value = module.documentdb.reader_endpoint
}

output "document_db_port" {
  value = module.documentdb.port
}

output "document_db_cluster_name" {
  value = module.documentdb.cluster_name
}


output "document_db_security_group_arn" {
  value = module.documentdb.security_group_arn
}

output "document_db_secrets_arn" {
  value = module.documentdb.secrets_documentdb_arn
}

output "document_db_secrets_policy_arn" {
  value = module.documentdb.secrets_documentdb_policy_arn
}