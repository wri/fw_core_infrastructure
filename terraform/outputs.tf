output "lb_dns_name" {
  value = module.loadbalancer.dns_name
}

output "lb_arn" {
  value = module.loadbalancer.arn
}

output "lb_listener_arn"{
  value = module.loadbalancer.listener_arn
}


output "lb_security_group_id" {
  value = module.loadbalancer.security_group_id
}

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

output "document_db_security_group_id" {
  value = module.documentdb.security_group_id
}

output "document_db_secrets_arn" {
  value = module.documentdb.secrets_documentdb_arn
}

output "document_db_secrets_policy_arn" {
  value = module.documentdb.secrets_documentdb_policy_arn
}