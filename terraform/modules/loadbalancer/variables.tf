variable "project_prefix" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "tags" {
  type = map(string)
}

variable "acm_certificate_arn" {
  type = string
  default = null
}

variable "vpc_id" {
  type = string
}

variable "listener_port" {
  type = number
  default = 80
}