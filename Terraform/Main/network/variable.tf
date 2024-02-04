variable "default_tags" {
  type    = map(string)
  default = {}
}

variable "prefix" {
  default = "docker-Sudeep"
  type    = string
}




variable "region" {
  default = "us-east-1"
  type    = string
}

variable "vpc" {
  default = "10.10.0.0/16"
  type = string
}




variable "public_cidr" {
  default = ["10.10.0.0/24","10.10.1.0/24"]
  type = list(string)
}