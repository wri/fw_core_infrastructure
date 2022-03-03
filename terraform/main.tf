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

module "user_sdavidge_3sc" {
  source       = "./modules/user"
  email        = "sam@3sidedcube.com"
  full_name    = "Sam Davidge"
  organization = "3SidedCube"
  tags         = local.tags
  user_name    = "sdavidge_3sc"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDrcI4YJtnQo5IhUeGFrqzVf4utuSV8qqpgxbh3iFz1LkFZ84rZ5S+taDqhxc7Oq7g5Au/7Z6Eal5kuSxSG212tHGQ/4Ebsjqa9qN6SPLQ+PCUUDH7t9tTKduKeaesS4PY5F/6RF2KA3dQVtvowxvQ1iGIngR7AfU8JVvHoN7YEG02UeCfMxkoAdXho7lQFHPvug+/I6K2RtG2StSYGpxFNc8FcDEc7897nCv8tG9hV+lsUlPRTRlPpuaut/kDzeHqLeEw4S/lMD7s0nWGAZ31GE0b2kpdwbBeyhbZDXr2FX6ZJA4ERoUVh5xn14Lx2CDJoit3hCSDkuX2XlpQsapVD8I8MIhI9pgLWdhxfOnxOKU96pH76O1Zza0FswNGig3smvxxbDjYNSyAYIywxyRyBepHmlA/R7iyMazzE9MIU5PYPnOXXHqkovDl8GbWgaFAtD1q9trMRk5/xIu25OzpS2fyuQOa0GyakGPjrLzdRLsMBx1JXNlQ7RxaFWrbYgLEldCZWT364YnTL6bEWi0Eaoiifv3kuKZXigClWsSxSxtH3axqf/RRg0AO6Uhbi3tGznCV6uSYI9HoFquiQE6ucPlS48yEEM6z78gmRLi1ob0bzeqUfOT4YcE2/VmGP3lAPvTET4Y51muhNw5GTboGitL4S8B3cB+dbBz/FzzTWtQ== samdavidge@Sams-MacBook-Pro.local"
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

module "user_bsherred_3sc" {
  source       = "./modules/user"
  email        = "ben.sherred@3sidedcube.com"
  full_name    = "Ben Sherred"
  organization = "3SidedCube"
  tags         = local.tags
  user_name    = "bsherred_3sc"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDEZ2a1o2OQCvScQipFvnQ7OrCxWRx7QwGa76BB6YJ9aex13AANeMXQQ3hLWdKvTA03N47x6CwbwBcFs532Oc0EFjYrFYmt3/ZrUW87OKC0LJz+i9Ap7HfMtJWAKL5HyFWTqL1ohsXrXftdotq54rfJK2xJ+hRsFVKXxd8FFVhPNAN5nV7oVf+7Q9/WnPwXcHJvPQCys6oiDCySk0a9P76sW1vSFghAIokgMsFYK9PE5gLP4wT3G13A+Z+VOZTLzUJHoYRnFK/QPI2P5fAf7vstVYwIdDhw9NwZF2j9bTabQsqJrxVUrqCX2A2xEzLgfbVQm4JG5LWxneLTkzX1vzHr"
}

module "user_jsantos_3sc" {
  source       = "./modules/user"
  email        = "javier@3sidedcube.com"
  full_name    = "Javier Santos"
  organization = "3SidedCube"
  tags         = local.tags
  user_name    = "jsantos_3sc"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDefcdUnLcTtIQBL/J4+AyX7Em8NclP9UU9AyG/NSu1Di19HRnN0/IiuYKDvgyeyNtUOW7n/im2xf4RX7RfcrjeGTudrlHZX5sZF5R+PEQoktGTl11Mhkmqj/z//gHymDDk4wVyRJ8J1YHyxbwyhx6Y3m2hdDZOeS/VKejPSSaDk6DPCeB7smHE5W1gXr4EgCEKyC6u2b8neZEi0fn7Mx/pLTsIklQwud+wfJRhq9SilM8BVH5a/mUaE6joDoxcMdjKzb0iHGFzmnseJNJPPZbny917WG3OGlCn1Tpv0rv2x0QhSll5DDSAdJBx4O/N0ka/WhfpjRDg3Syj+AOONDZV9EwsykPc+29KHwVyathONxjbt6gm0E9zhBin0687mdhoAo24FSxc7mWZXtzS7Y64tYKB1yH7iLFBkRZdsX+sMTrL40cZbuIZtDRvrJsEtIWCkiOTN3hWpROIhFEfmbeVRbzB0wAI5ee1UfR3XKMykGcMzhTremLCRRTFpXo4Ty2x309Cv59W6dIlizHO2RLwQlZawFT8U0FLtuelvriiSrHAXEb/8FVqPpc8STt0Wn6Zqnljqdja+sQ6CmTNU6wI0hOXeqwd0VXx5o+pnhQovj2prJrzbi75q9eRJP2Trw4cwR8ZjklBDdqo+Y/CT+B099czn4fD8mGP512dpX5K4Q== javier@3sidedcube.com"
}

module "user_wkelsey_3sc" {
  source       = "./modules/user"
  email        = "will.kelsey@3sidedcube.com"
  full_name    = "Will Kelsey"
  organization = "3SidedCube"
  tags         = local.tags
  user_name    = "wkelsey_3sc"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDehBSncifV972we9WVA8LRmdtICNAEYwQHelFD/8G3nW7DV840vWacRxagm7bCRN5bALm6XwUtNJ53UahHvPpaNvqMZxidwAnIUOWQK2/3gpbvHpy2Czss9sICrTK3Rju4U6moRHYtn1Req/rDhi3ULSJnENXXwfGP+oC8XrBBe2541FrP9ReKlWQfCkNNxmsuoPpOt/etnhp1X68TY0pdi3eusFUCDneJuJd6E1TPnorvDXhzDnf+IixZdi3AbeR0yvYO7mUpR0qnl1XQQ/FVNgHm31DNh754kFUVC2vXkt7erVNQcZmftY2/fJMshngC2uORLq31WbmG5pMK3bCvLidQ8PxaK/tl+iJ+/5W70G1xe82ExaCU1evj9nr1/NlxCFRIhFAYouBcj/ZDQ/ZZAwZWRr8xVKx+lkQpoT22CDDYqCE4cfD+Z4kBHvWNsr0M3okLdlykl5BjYP3eedvuHZljSxMqXZNZKSDdO3A8HisCmuR2aMPSmzYalEEVAUM= will@wills-MBP.home"
}

module "s3c_developers" {
  source = "./modules/group"
  project_prefix = var.project_prefix
  name   = "s3c_developers"
  policy_arns = ["arn:aws:iam::aws:policy/ReadOnlyAccess",
    module.data_bucket.write_policy_arns[0],
  data.terraform_remote_state.core.outputs.document_db_secrets_policy_arn]
  users = [module.user_bsherred_3sc.name,
    module.user_jsantos_3sc.name,
    module.user_sdavidge_3sc.name,
    module.user_tyeadon_3sc.name,
  module.user_wkelsey_3sc.name]
  path = "/users/"
}