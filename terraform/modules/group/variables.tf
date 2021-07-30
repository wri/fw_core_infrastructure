variable "name" {
  type = string
}
variable "path" {
  type = string
  default = "/"
}

variable "users" {
  type = list(string)
}

variable "policy_arns" {
  type = string
}