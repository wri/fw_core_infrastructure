locals {
  ssh_cidr_blocks = ["54.173.196.8/32", "216.70.220.184/32", "86.143.108.56/32", "92.234.149.30/32", "212.35.238.28/32", "90.206.63.59/32"]
  description = ["3SC Office VPN", "Office", "Dockerised", "Dockerised2", "Owen", "Edward"]
}

data "aws_ami" "amazon_linux_ami" {
  most_recent = true
  owners = [
  "amazon"]

  filter {
    name = "name"
    values = [
    "amzn2-ami-hvm*"]
  }
}

# Need to create new private keys outside of TF and AWS
# Note: Adding new keys will destroy the Bastion host and recreate it with new user data
resource "aws_key_pair" "all" {
  for_each = {
    jterry_gfw     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCOGcXvYQel176C7gXPPsz8/tOotAJ8yfj4I2e1Uw0KMLgMao/9Yl9DZg9obBO7nG1DiDW9YUt2hpQkB2PpzP5N9yMriL4WXEhLroCWKj/vljRIDZjS3ZG+pPLs2Li9eFLDc0WGb9D+dxVG7Emwg8O/mTVbaAdklC4D1cwKQx7V7kU19K4jTTCA7aqagtI7X6FNh0fJGfVz0aQ01ECZmUNCkVZy+LYhk2wxSDuXV9DIha0akPXZCWqOtICPln+tquM9befLevCcuDpwVOkh1wrAP7EkRQtL8x8lIadenQpHgXoeoNGGp7x10Dywlw2u6Hm4b0mGITu4P1JTf0O2mmDd jterry_gfw",
    gcrosby_gfw    = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDlNQHV5VApZuneWtc9m9d7WEUqmfoLWm0John5vRwoPC0GYIU56BH90Yeiw5HkXJsiqnO+WXubFqWylhCRyfckNiTC7sKbpydZHVH4VmvNzOV4z8BXPob1qsnL2d+5eO8U7Sf21jpBQ4HEXgBk4GZ4eRuktM4eYRGsgTRW/FLFUex6c76Nb5va0FakDKXNKiojIoTIjLN0sxKAQtxuJAt4X4Jg6rtd5pS/4l9pH/VPncKcag1tDvx5ytN/4+lb9IZg/8OyG5JZDWaCsvhauJxn+LGP3GtHiEmiu3IMvTwthVWBj1rmFaX/KoOSlQazHlzEREHQ51mb+6MXSwoz+WrqcgkvFLtky0syMRqwjBgCU2IoKS/Cn2+qh7pI0L7ctPb7WjKmQw7vTfQDW3IDPPU2/H2WlJRChrLMWYzFt6oBWKDr4D7YwH89LYsA67rR9xZHY6TgmVexjiXPjnawAqHKEryESqSuNLDWQmNwrGJaWzmf04T3N+5puDIyuhq5MIlbP63mxSXOUEsFIsCKZPkuh/oR105cbSW3U2fZIajuNICXU/YETChn9K7CaR53uqWM7A6vU2VipNb8NJ4v0IP1djECR3/HwrCY+04Fvt/ZOzbvME6cXxfPZLCDRF9Styz4NiTKPQz/6g3Gbl6CF86vdG8uVKmLRUbSBUbEJX02Sw== george@3sidedcube.com"
    owen_gfw       = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCd3YO71r9bA5ziwi0upz1ESlDUKqgLeWRdROJ5hRNb7fkMx68UnHqPxj/S/+OXWMjlW1kSnSqXZcaWbqSkQ7neI6obMjaQ7lGxCy1NPPDzwv/BID4S2U3hMIMKoAlhK6P0rvSPkn4wpPl4g8Dlmj9y0nX2GBK3zcoeTroDA9EUtZspjTX/+3lcJS/Yln+ZVHtTQVT83HbFXWyui53TyRG2m1ieEcCCUFYxeSKFdQvSTqTD+AioXdU7Z/Akie4DR/J1o1rO3WlBvpYqSAnWOcj+l1VtJYE7xMr/O+L6CkfhuIoU/LlbagdEJsq03WAYUfETUCCTcwKn2ALHQ4bQ/TeCYuEfnZ2KpUZOY+goNpptXozKx1+SDjJjpXbZ4mZcawEmPYQQS/dcgQi40X038c/X7nxtnQNWJUbbwIhiZ+mdfiRy7CS6J1u7LRm5T17Vg+V5IlKW98tDmbx9TFzUXeODgDoqII9KoF79+E/WvHNuQNqIAC/DMIFoGaOMS1R30dM= user@users-MacBook-Pro.local"
    tyeadon_3sc  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDEZ2a1o2OQCvScQipFvnQ7OrCxWRx7QwGa76BB6YJ9aex13AANeMXQQ3hLWdKvTA03N47x6CwbwBcFs532Oc0EFjYrFYmt3/ZrUW87OKC0LJz+i9Ap7HfMtJWAKL5HyFWTqL1ohsXrXftdotq54rfJK2xJ+hRsFVKXxd8FFVhPNAN5nV7oVf+7Q9/WnPwXcHJvPQCys6oiDCySk0a9P76sW1vSFghAIokgMsFYK9PE5gLP4wT3G13A+Z+VOZTLzUJHoYRnFK/QPI2P5fAf7vstVYwIdDhw9NwZF2j9bTabQsqJrxVUrqCX2A2xEzLgfbVQm4JG5LWxneLTkzX1vzHr"
    gcrosby_3sc  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDAIRH+V6hqIpFfPrw+7SkeROHr30Meci99Nc7fmeIxdlxR+yJPlogLFauj3D/4MMSvx+p4QjULd0TKO9Pc7b92vX1diqSNq3dom79ccZlntA+ITaS1DzmMcIcX3/szBUCmEeBYDw+v7Z7A77PvUQqxlLfx0I34JQEyF59XxVIwisz0tACaY1iLvdCAEypMTRWm1hDQPPRYJUHQ3VyOJ4XMUTo6iP4dwv3W1gKhq6Kpc00Ha1FBtpLSRtJhLqxq0kT9T2dYpvF3xf/r569PVolES/IBkgM/Vobbb3THrmH0TXKZNydaI1gLZC3y38nSmVJ/B2SH7AYwgBTkfO6jYez1 2021-08-04"
    oevans_3sc  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDdy9oatA/nDCdGpBusaK/XiqSWrWSMtVkBQAfIEznZf1vCUsbOrgLQTYJWbuPaHj0IBzZlEeFATLEY04GIYa++t1du1JAIJqd2bhNYrEGYPimkzF11k93UygIuYnDdgJfApwyibdvUj63xtgP/INzUJan2NdgGZ/pg7ZJAbPMZgtE+QO8qFZkHIsnnAyJl+ZyV5SrMjK+5Qxv05TuR+bb1sGg05IW2uqAHdRMZEREfRdDoo1jVU7oIsHbNJQdSvA6kC0NBfIn0M1nb/br6t+Gr7oACzpOs/JKSOinIi0l1pJZ1dDoQTS5ACppUh5MXjgsmGCxYk7pN7x0vTj+bxQBFLbJZklK/dTAPVO8MKIFDHgfnh4LyoEPnOcpkUcmZ3Dxl1PulEYmtQRkOdQPI5jkF2SOT/iJ42UIgMZ1m08ZOT4wf+oKncW9Rb/4uo+PHRddrdBcyS/dZHkLDogvYNpMXpeJyniRHcEsXszv5HPPf88Ka93pj0N1btz0bwgpG8Yc= owen@3s-MacBook-Pro.local"
    gcrosby_3sc  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDlNQHV5VApZuneWtc9m9d7WEUqmfoLWm0John5vRwoPC0GYIU56BH90Yeiw5HkXJsiqnO+WXubFqWylhCRyfckNiTC7sKbpydZHVH4VmvNzOV4z8BXPob1qsnL2d+5eO8U7Sf21jpBQ4HEXgBk4GZ4eRuktM4eYRGsgTRW/FLFUex6c76Nb5va0FakDKXNKiojIoTIjLN0sxKAQtxuJAt4X4Jg6rtd5pS/4l9pH/VPncKcag1tDvx5ytN/4+lb9IZg/8OyG5JZDWaCsvhauJxn+LGP3GtHiEmiu3IMvTwthVWBj1rmFaX/KoOSlQazHlzEREHQ51mb+6MXSwoz+WrqcgkvFLtky0syMRqwjBgCU2IoKS/Cn2+qh7pI0L7ctPb7WjKmQw7vTfQDW3IDPPU2/H2WlJRChrLMWYzFt6oBWKDr4D7YwH89LYsA67rR9xZHY6TgmVexjiXPjnawAqHKEryESqSuNLDWQmNwrGJaWzmf04T3N+5puDIyuhq5MIlbP63mxSXOUEsFIsCKZPkuh/oR105cbSW3U2fZIajuNICXU/YETChn9K7CaR53uqWM7A6vU2VipNb8NJ4v0IP1djECR3/HwrCY+04Fvt/ZOzbvME6cXxfPZLCDRF9Styz4NiTKPQz/6g3Gbl6CF86vdG8uVKmLRUbSBUbEJX02Sw=="
    lpopov_3sc = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDI3Vd+ksZNDpkxKLdwgHD5FZ8ngUk7Xvj9cV9nlGQ90ti77d+QtqRjGYpCmechizl5BEaaT9xi1DH8W7h3Isu85CnuAQqwb5lZMKDGsEzQTzxZ7h3AuMFkMNrN3d7PupwFifLVXmQF5R7E9I0EIGTrtnrINrzWMuU4VxVu3N0z3VDdkAvOAPDARaggr9K5zvmxB8NQ0iXCafNFk5bsddour/yxmWXxT7M3+qDB3CcHVzFqtMKVPyAs9HSuEfNBpenSTyNCMw78Bn7uvTzZdVlLIfmvz4H17pwKnoQTf3TEzTmpKg8A3XaqbHVrFODr7zl11tVxykA5nsy+FdeRu2z8quUji/qK0tStAd/1F6a19bLZ1rvlZp5uGbQnMuqNqiuEJs0F90VqcaEZ1wZe7d6EFPr++Yby2hUEo/eh3X8aSg50uog5S4f3pnbzB6RTB1dwLZWMo/tTx0UW/SavrbTcQlCOm31uKfJWkOgVW/lVikPq0O7k903OMIPPMSkCJ3U= 2022-04-14"
    ipopov_3sc = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDI3Vd+ksZNDpkxKLdwgHD5FZ8ngUk7Xvj9cV9nlGQ90ti77d+QtqRjGYpCmechizl5BEaaT9xi1DH8W7h3Isu85CnuAQqwb5lZMKDGsEzQTzxZ7h3AuMFkMNrN3d7PupwFifLVXmQF5R7E9I0EIGTrtnrINrzWMuU4VxVu3N0z3VDdkAvOAPDARaggr9K5zvmxB8NQ0iXCafNFk5bsddour/yxmWXxT7M3+qDB3CcHVzFqtMKVPyAs9HSuEfNBpenSTyNCMw78Bn7uvTzZdVlLIfmvz4H17pwKnoQTf3TEzTmpKg8A3XaqbHVrFODr7zl11tVxykA5nsy+FdeRu2z8quUji/qK0tStAd/1F6a19bLZ1rvlZp5uGbQnMuqNqiuEJs0F90VqcaEZ1wZe7d6EFPr++Yby2hUEo/eh3X8aSg50uog5S4f3pnbzB6RTB1dwLZWMo/tTx0UW/SavrbTcQlCOm31uKfJWkOgVW/lVikPq0O7k903OMIPPMSkCJ3U= iuripopov@Iuris-MacBook-Pro.local"
    emartin_3sc = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC2CK+B7W21KNwYK9OYNgBME0ski/Iv92uyljXdIq8q6UjczaiuOx9k2uFTBKzRfcnUkd3/Csr7utw/grSZEAJz/nRq0r1LzW+CBv7FMuhAzQ0iO/dSLwgD0Jygb3y52o/P/raPobADFzpS1tOeX+RtOIEHT2Ki7m7FIdOAmHJ7iOSmpGpe/XSkrA3pjewVX2S/FKmTqgrRFsSxYbH0UlrX3AvetZOMCYsK5r0eWc+Pcifq2qEPc6uRasoLwlVj4f51llT36ILGvvQZJX/8JiBzhAo8Yg8Qz0S62tGCHpgLEOdTJu6ZyKA6xiq6YWwOxSEPq99L0pur0ahbLvmIJp0PPvhz9yMpdQCUu+wh0xy4fLtFm+112/uGl7THKiGWc/oM8VPNdF8ZtjU2FWA3oP1ZKm7uAKXw/pXiG50wYjaqh8joGoDn5d41vMfHCWC0ZsTyNYRDNIm2mKQBUQNdEiBYWOx2HVgWWbQbff2JMLS4qy5lnwBhL0GZArB6eSJsLiU= edward@3sidedcube.com"
    gcrosby2_3sc = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDAIRH+V6hqIpFfPrw+7SkeROHr30Meci99Nc7fmeIxdlxR+yJPlogLFauj3D/4MMSvx+p4QjULd0TKO9Pc7b92vX1diqSNq3dom79ccZlntA+ITaS1DzmMcIcX3/szBUCmEeBYDw+v7Z7A77PvUQqxlLfx0I34JQEyF59XxVIwisz0tACaY1iLvdCAEypMTRWm1hDQPPRYJUHQ3VyOJ4XMUTo6iP4dwv3W1gKhq6Kpc00Ha1FBtpLSRtJhLqxq0kT9T2dYpvF3xf/r569PVolES/IBkgM/Vobbb3THrmH0TXKZNydaI1gLZC3y38nSmVJ/B2SH7AYwgBTkfO6jYez1 2021-08-04"
  }
  key_name   = each.key
  public_key = each.value
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.amazon_linux_ami.id
  availability_zone           = "us-east-1a"
  ebs_optimized               = true
  instance_type               = "t3.nano"
  monitoring                  = true
  subnet_id                   = data.terraform_remote_state.core.outputs.public_subnet_ids[0]
  vpc_security_group_ids      = [
    data.terraform_remote_state.core.outputs.default_security_group_id,
    data.terraform_remote_state.core.outputs.webserver_security_group_id,
    data.terraform_remote_state.core.outputs.document_db_security_group_id,
    data.terraform_remote_state.core.outputs.postgresql_security_group_id,
    data.terraform_remote_state.core.outputs.redis_security_group_id
  ]
  associate_public_ip_address = true
  user_data                   = data.template_file.bastion_setup.rendered

  lifecycle {
    ignore_changes = [ami]
  }

  tags = merge(
    {
      Name = "fw-Bastion"
    }
  )
}

# User data script to bootstrap authorized ssh keys
data "template_file" "bastion_setup" {
  template = file("${path.root}/templates/bastion_setup.sh.tpl")
  vars = {
    user                = "ec2-user"
    authorized_ssh_keys = <<EOT
%{for row in formatlist("echo \"%v\" >> /home/ec2-user/.ssh/authorized_keys", values(aws_key_pair.all)[*].public_key)~}
${row}
%{endfor~}
EOT
  }
}

resource "aws_eip" "bastion" {
  vpc = true
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.bastion.id
  allocation_id = aws_eip.bastion.id
}

# Add SSH ingress for IPs
resource "aws_security_group_rule" "ingress_ssh" {
  count             = length(local.ssh_cidr_blocks)
  type              = "ingress"
  from_port         = "22"
  to_port           = "22"
  protocol          = "tcp"
  cidr_blocks       = [local.ssh_cidr_blocks[count.index]]
  description       = local.description[count.index]
  security_group_id = data.terraform_remote_state.core.outputs.default_security_group_id
}