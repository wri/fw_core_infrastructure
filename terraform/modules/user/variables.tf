variable "user_name" {
  type = string
}
variable "path" {
  type    = string
  default = "/"
}
variable "full_name" {
  type = string
}
variable "email" {
  type = string
}
variable "organization" {
  type = string
}
variable "tags" {
  type = map(string)
}

variable "force_destroy" {
  default = true
  type    = bool
}

variable "key_encoding" {
  type = string
  default = "SSH"
}
variable "public_key" {
  type = string
}