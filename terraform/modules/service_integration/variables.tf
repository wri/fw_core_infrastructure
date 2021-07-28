variable "environment" {
  type = string
}

variable "project_prefix" {
  type = string
}

variable "service_path" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "port" {
  type = number
}

variable "load_balancer_arn" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "api_gateway_id" {
  type = string
}

variable "api_gateway_root_resource_id" {
  type = string
}

variable "vpc_link_id" {
  type = string
}

variable "load_balancer_dns" {
  type = string
}
