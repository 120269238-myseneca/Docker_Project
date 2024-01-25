# The thing that reiqrued to run these project are  
# Network - Include - VPC , PUBLIC SUBNET
# WebSite -  Using ECR for images repositiory, EC2 - UserData to run docker

provider "aws" {
  region = "us-east-1a"  # Example region
}
#VPC 
data "aws_vpc" "mainVPC" {
  default = true
}

data "aws_availability_zones" "available" {
  state = "available"
}

#Subnet (Only one public subnet)
resource "aws_subnet" "publicSubnet" {
  vpc_id            = aws_vpc.mainVPC.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
}


# 
data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# EC2 Instance
resource "aws_instance" "web" {
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.publicSubnet.id
  security_groups             = [aws_security_group.allow_web.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.web_key.key_name
  user_data = <<-EOF
                #!/bin/bash
                # Update the package manager
                sudo yum update -y

                # Install Docker
                sudo yum install docker -y
                sudo service docker start
  tags = {
    Name = "MyWebServer"
  }
}

#computeSG
resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow web inbound traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [data.aws_subnet.publicSubnet.cidr_block]
  }

  ingress {
    description = "Custom ports for containers"
    from_port   = 8081
    to_port     = 8083
    protocol    = "tcp"
    cidr_blocks = [data.aws_subnet.publicSubnet.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# SSH Key Pair
resource "aws_key_pair" "web_key" {
  key_name   = local.name_prefix
  public_key = file("${local.name_prefix}.pub")
}