variable "project_prefix" {
  type        = string
  description = "A project namespace for the infrastructure."
}

variable "environment" {
  type        = string
  description = "An environment namespace for the infrastructure."
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC for ECS resources."
}

variable "vpc_private_subnet_ids" {
  type        = list(any)
  description = "A list of VPC public subnet IDs."
}

//variable "service_integrations" {
//  type = list(any)
//
//}

variable "tags" {
  default     = {}
  type        = map(string)
  description = "A mapping of keys and values to apply as tags to all resources that support them."
}