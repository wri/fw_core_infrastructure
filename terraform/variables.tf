variable "project" {
  type = string
  default = "Forest watcher"
}

variable "project_prefix" {
  type = string
  default = "fw"
}

variable "log_retention_period" {
  type = number
}

variable "backup_retention_period" {
  type = number
}

variable "environment" {
  type = string
}

variable "db_instance_class" {
  type = string
}

variable "db_instance_count" {
  type = number
}

variable "db_logs_exports" {
  type  = list(string)
  default = ["audit", "profiler"]
}

variable "public_url" {
  type = string
}