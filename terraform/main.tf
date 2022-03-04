terraform {
  backend "s3" {
    region  = "us-east-1"
    key     = "wri__fw_core_infrastructure.tfstate"
    encrypt = true
  }
}

module "cluster" {
  source         = "./modules/cluster"
  project_prefix = var.project_prefix
  tags           = local.tags
}

module "loadbalancer" {
  source              = "./modules/loadbalancer"
  project_prefix      = var.project_prefix
  subnet_ids          = data.terraform_remote_state.core.outputs.public_subnet_ids
  tags                = local.tags
  vpc_id              = data.terraform_remote_state.core.outputs.vpc_id
  acm_certificate_arn = data.terraform_remote_state.core.outputs.acm_certificate
}

# Forward all other traffic to other address
resource "aws_lb_listener_rule" "forward" {
  listener_arn = module.loadbalancer.listener_arn
  priority     = 100
  action {
    type = "redirect"

    redirect {
      host        = var.production_applications_fqdn
      status_code = "HTTP_301"
    }
  }
  condition {
    path_pattern {
      values = ["/v1/*"]
    }
  }
}


module "data_bucket" {
  source      = "git::https://github.com/wri/gfw-terraform-modules.git//terraform/modules/storage?ref=v0.5.0"
  bucket_name = "gfw-fw-data${local.bucket_suffix}"
  project     = var.project_prefix
  tags        = merge({ Job = "Forest Watcher Data" }, local.tags)
}


module "api_key_secret" {
  source        = "git::https://github.com/wri/gfw-terraform-modules.git//terraform/modules/secrets?ref=v0.5.0"
  project       = var.project_prefix
  name          = "${var.project_prefix}-gfw_data_api_key"
  secret_string = var.gfw_data_api_key
}

module "user_tyeadon_3sc" {
  source       = "./modules/user"
  email        = "tom.yeadon@3sidedcube.com"
  full_name    = "Tom Yeadon"
  organization = "3SidedCube"
  tags         = local.tags
  user_name    = "tyeadon_3sc"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDwij4YT+AA2GgIohM1L8yRP3KgvWFZJwHH9Dwbl7r0C4hClZTKlJoaTT/GN+FOpk83MpM+SybcJMfJTBtw3/8K/WzRd3ry+yHOn23FW3AXR/pAOuBg0CPsvd8i1K8eOmdqFBDuJi/fIqpykoKf/b79vxfWRb5N8dkDaolSRfMQibuuw74G5CNSmC+24rHZBiM5CYua6Mck2vnZFsYgraZ0iuDIFc9mj73AdOfcXie7u8kRU8axRuCDBprLGwUtAJ5q2dN97IVXTeHCoIrMNoaWhj2TnXfku49woDm0flmPWMTEv8Io7MIiPiu2wDCkjAoyrjG6nmaV58SxilxpVFCFMJWMVez964NfGxa+dxRC1mR/Z9suiA7njnpUlcsUiJgr3+WJZ6TJQXvw7tMAUZdSd7w44f43rFSeTXEovhAGUQoFof1ctodLCXLganZ1xhXAAQZ3NAIuXEzxV5L10w83A7SlDfmN+hEyzXBMNM0Txh6PAfyatl7s5MWSnEdJ3Wk="
}

module "user_gcrosby_3sc" {
  source       = "./modules/user"
  email        = "george.crosby@3sidedcube.com"
  full_name    = "George Crosby"
  organization = "3SidedCube"
  tags         = local.tags
  user_name    = "gcrosby_3sc"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDlNQHV5VApZuneWtc9m9d7WEUqmfoLWm0John5vRwoPC0GYIU56BH90Yeiw5HkXJsiqnO+WXubFqWylhCRyfckNiTC7sKbpydZHVH4VmvNzOV4z8BXPob1qsnL2d+5eO8U7Sf21jpBQ4HEXgBk4GZ4eRuktM4eYRGsgTRW/FLFUex6c76Nb5va0FakDKXNKiojIoTIjLN0sxKAQtxuJAt4X4Jg6rtd5pS/4l9pH/VPncKcag1tDvx5ytN/4+lb9IZg/8OyG5JZDWaCsvhauJxn+LGP3GtHiEmiu3IMvTwthVWBj1rmFaX/KoOSlQazHlzEREHQ51mb+6MXSwoz+WrqcgkvFLtky0syMRqwjBgCU2IoKS/Cn2+qh7pI0L7ctPb7WjKmQw7vTfQDW3IDPPU2/H2WlJRChrLMWYzFt6oBWKDr4D7YwH89LYsA67rR9xZHY6TgmVexjiXPjnawAqHKEryESqSuNLDWQmNwrGJaWzmf04T3N+5puDIyuhq5MIlbP63mxSXOUEsFIsCKZPkuh/oR105cbSW3U2fZIajuNICXU/YETChn9K7CaR53uqWM7A6vU2VipNb8NJ4v0IP1djECR3/HwrCY+04Fvt/ZOzbvME6cXxfPZLCDRF9Styz4NiTKPQz/6g3Gbl6CF86vdG8uVKmLRUbSBUbEJX02Sw=="
}

module "user_oevans_3sc" {
  source       = "./modules/user"
  email        = "owen.evans@3sidedcube.com"
  full_name    = "Owen Evans"
  organization = "3SidedCube"
  tags         = local.tags
  user_name    = "oevans_3sc"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCd3YO71r9bA5ziwi0upz1ESlDUKqgLeWRdROJ5hRNb7fkMx68UnHqPxj/S/+OXWMjlW1kSnSqXZcaWbqSkQ7neI6obMjaQ7lGxCy1NPPDzwv/BID4S2U3hMIMKoAlhK6P0rvSPkn4wpPl4g8Dlmj9y0nX2GBK3zcoeTroDA9EUtZspjTX/+3lcJS/Yln+ZVHtTQVT83HbFXWyui53TyRG2m1ieEcCCUFYxeSKFdQvSTqTD+AioXdU7Z/Akie4DR/J1o1rO3WlBvpYqSAnWOcj+l1VtJYE7xMr/O+L6CkfhuIoU/LlbagdEJsq03WAYUfETUCCTcwKn2ALHQ4bQ/TeCYuEfnZ2KpUZOY+goNpptXozKx1+SDjJjpXbZ4mZcawEmPYQQS/dcgQi40X038c/X7nxtnQNWJUbbwIhiZ+mdfiRy7CS6J1u7LRm5T17Vg+V5IlKW98tDmbx9TFzUXeODgDoqII9KoF79+E/WvHNuQNqIAC/DMIFoGaOMS1R30dM="
}

module "s3c_developers" {
  source = "./modules/group"
  project_prefix = var.project_prefix
  name   = "s3c_developers"
  policy_arns = ["arn:aws:iam::aws:policy/ReadOnlyAccess",
    module.data_bucket.write_policy_arns[0],
  data.terraform_remote_state.core.outputs.document_db_secrets_policy_arn]
  users = [
    module.user_tyeadon_3sc.name,
    module.user_gcrosby_3sc.name,
    module.user_oevans_3sc.name,
  ]
  path = "/users/"
}