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
  iam_instance_profile = "LabInstanceProfile"
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
# ALB
resource "aws_lb" "my_alb" {
  name               = "${local.name_prefix}-my-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = data.terraform_remote_state.network.outputs.public_subnet_id

  tags = local.default_tags
}

# ALB Security Group
resource "aws_security_group" "alb_sg" {
  name        = "${local.name_prefix}-alb-sg"
  description = "ALB Security Group"
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
  
  tags = local.default_tags
}




# Target Groups
resource "aws_lb_target_group" "tg_blue" {
  name     = "${local.name_prefix}-tg-blue"
  port     = 8081
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.network.outputs.vpc_id

  health_check {
    path               = "/"
    protocol           = "HTTP"
    matcher            = "200"
  }

  tags = local.default_tags
}



resource "aws_lb_target_group" "tg_lime" {
  name     = "${local.name_prefix}-tg-lime"
  port     = 8082
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.network.outputs.vpc_id

  health_check {
    path               = "/"
    protocol           = "HTTP"
    matcher            = "200"
  }

  tags = local.default_tags
}



resource "aws_lb_target_group" "tg_pink" {
  name     = "${local.name_prefix}-tg-pink"
  port     = 8083
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.network.outputs.vpc_id

  health_check {
    path               = "/"
    protocol           = "HTTP"
    matcher            = "200"
  }

  tags = local.default_tags
}

resource "aws_lb_target_group_attachment" "attach_instance_to_tg_blue" {
  count            = length(module.web_app.instance_ids)
  target_group_arn = aws_lb_target_group.tg_blue.arn
  target_id        = element(module.web_app.instance_ids, count.index)
  port             = 8081
}
resource "aws_lb_target_group_attachment" "attach_instance_to_tg_lime" {
  count            = length(module.web_app.instance_ids)
  target_group_arn = aws_lb_target_group.tg_lime.arn
  target_id        = element(module.web_app.instance_ids, count.index)
  port             = 8082
}

resource "aws_lb_target_group_attachment" "attach_instance_to_tg_pink" {
  count            = length(module.web_app.instance_ids)
  target_group_arn = aws_lb_target_group.tg_pink.arn
  target_id        = element(module.web_app.instance_ids, count.index)
  port             = 8083
}


resource "aws_lb_listener" "app_listener_80" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_blue.arn 
  }
}

resource "aws_lb_listener_rule" "blue_path" {
  listener_arn = aws_lb_listener.app_listener_80.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_blue.arn
  }

  condition {
    path_pattern {
      values = ["/blue*"]
    }
  }
}




resource "aws_lb_listener" "app_listener_8081" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = 8081
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_blue.arn 
  }
}



resource "aws_lb_listener" "app_listener_8082" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = 8082
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_lime.arn 
  }
}



resource "aws_lb_listener" "app_listener_8083" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = 8083
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_pink.arn 
  }
}

