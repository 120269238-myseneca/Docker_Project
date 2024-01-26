# The thing that reiqrued to run these project are  
# Network - Include - VPC , PUBLIC SUBNET
# WebSite -  Using ECR for images repositiory, EC2 - UserData to run docker






data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "${local.name_prefix}-Sudeep"
    key    = "network/terraform.tfstate"
    region = "us-east-1"
  }
}

module "web_app" {
  source               = "../../modules/web_app"
  default_tags        = var.default_tags
  prefix              = var.prefix
  instance_type       = var.instance_type
  region              = var.region
  key_name            = aws_key_pair.web_key.key_name
  subnet_id           = data.terraform_remote_state.network.outputs.public_subnet_id
  sg_id               = aws_security_group.ec2SG.id
  user_data           = file("${path.module}/user_data.sh")
}


resource "aws_key_pair" "web_key" {
  key_name   = local.name_prefix
  public_key = file("${local.name_prefix}.pub")
}



#SG
resource "aws_security_group" "ec2SG" {
  name        = "${local.name_prefix}-compute-Security-Group"
  description = "Allow all inbound HTTP traffic"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 8082
    to_port     = 8082
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 8083
    to_port     = 8083
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = merge(
    local.default_tags, {
      Name = "${local.name_prefix}-Compute-Security-Group"
    }
  )
}