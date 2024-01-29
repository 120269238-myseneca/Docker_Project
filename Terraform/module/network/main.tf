provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  default_tags = merge(
    var.default_tags,
  )
  name_prefix = "${var.prefix}"
}

resource "aws_vpc" "main_cidr" {
  cidr_block = var.vpc
  tags = merge(
    local.default_tags,
    {
      Name = "${local.name_prefix}-vpc"
    }
  )
}


resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_cidr.id
  cidr_block              = var.public_cidr
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]
  tags = merge(
    local.default_tags, {
      Name = "${local.name_prefix}-public-subnet"
    }
  )
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_cidr.id
  tags = merge(
    local.default_tags, {
      "Name" = "${local.name_prefix}-igw"
    }
  )

}

resource "aws_route_table" "public_routetable" {
  vpc_id = aws_vpc.main_cidr.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge(
    local.default_tags, {
      Name = "${local.name_prefix}-public-route_table"
    }
  )
}

resource "aws_route_table_association" "public__subnet_routetable_assoication" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_routetable.id
}