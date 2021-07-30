variable "project" {
  type    = string
  default = "Forest watcher"
}

variable "project_prefix" {
  type    = string
  default = "fw"
}

variable "environment" {
  type = string
}

variable "public_url" {
  type = string
}

variable "gfw_data_api_key" {
  type = string
}