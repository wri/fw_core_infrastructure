terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3, < 4"
    }
    local = {
      source = "hashicorp/local"
    }
    template = {
      source = "hashicorp/template"
    }
  }
  required_version = ">= 1.0.3"
}
