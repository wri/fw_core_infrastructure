output "lb_dns_name" {
  value = module.loadbalancer.dns_name
}

output "lb_arn" {
  value = module.loadbalancer.arn
}

output "lb_listener_arn" {
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


output "ecs_cluster_name" {
  value = module.cluster.cluster_name
}

output "public_url" {
  value = var.public_url
}

output "data_bucket" {
  value = module.data_bucket.bucket_id
}

output "data_bucket_write_policy_arn" {
  value = module.data_bucket.write_policy_arns[0]
}

output "data_bucket_read_policy_arn" {
  value = module.data_bucket.read_policy_arn
}

output "tags" {
  value = local.tags
}