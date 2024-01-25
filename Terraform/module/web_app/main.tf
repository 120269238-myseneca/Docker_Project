provider "aws" {
  region = var.region
}

data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}


locals {
  default_tags = var.default_tags
  name_prefix = "${local.name_prefix}"
}



# Instance
resource "aws_instance" "computeInstance" {
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = var.subnet_id
  security_groups             = var.sg_id
  associate_public_ip_address = true
  user_data                   = var.user_data
  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.default_tags,
    {
      Name = "${local.name_prefix}-web-app"
    }
  )
}