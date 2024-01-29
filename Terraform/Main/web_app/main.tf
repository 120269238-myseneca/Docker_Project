# The thing that reiqrued to run these project are  
# Network - Include - VPC , PUBLIC SUBNET
# WebSite -  Using ECR for images repositiory, EC2 - UserData to run docker






data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "docker-assignment-sudeep-s3"
    key    = "network/terraform.tfstate"
    region = "us-east-1"
  }
}
locals {
  default_tags = merge(
    var.default_tags,
    # Add any additional default tags here
  )
  name_prefix = "${var.prefix}"
}

module "web_app" {
  source               = "../../module/web_app"
  default_tags        = var.default_tags
  prefix              = var.prefix
  instance_type       = var.instance_type
  region              = var.region
  key_name            = aws_key_pair.web_key.key_name
  subnet_id           = data.terraform_remote_state.network.outputs.public_subnet_id
  sg_id               = [aws_security_group.ec2SG.id]
  user_data           = file("${path.module}/install_httpd.sh")
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


resource "aws_ecr_repository" "application" {
  name = "app-image-${local.name_prefix}"
  tags = merge(
    var.default_tags, {
      Name = "${local.name_prefix}-docker-app-image"
    }
  )
}


resource "aws_ecr_repository" "database" {
  name = "database-image-${local.name_prefix}"
  tags = merge(
    var.default_tags, {
      Name = "${local.name_prefix}-docker-database-image"
    }
  )
}





resource "aws_alb_target_group" "app_target_group" {
  name     = "tg-app"
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  port     = 80  # The ALB's listener port, not the container's port

  health_check {
    path                = "/"
    port                = "traffic-port"  # Use the port specified in the target registration
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }
}

resource "aws_lb_target_group_attachment" "app1_attachment" {
  target_group_arn = aws_alb_target_group.app_target_group.arn
  target_id        = aws_instance.your_instance.id
  port             = 8081
}

resource "aws_lb_target_group_attachment" "app2_attachment" {
  target_group_arn = aws_alb_target_group.app_target_group.arn
  target_id        = aws_instance.your_instance.id
  port             = 8082
}

resource "aws_lb_target_group_attachment" "app3_attachment" {
  target_group_arn = aws_alb_target_group.app_target_group.arn
  target_id        = aws_instance.your_instance.id
  port             = 8083
}


resource "aws_alb_listener" "webservers_listener" {
  load_balancer_arn = aws_alb.webservers_load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.app_target_group.arn
  }
}