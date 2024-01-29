variable "default_tags" {
  type    = map(string)
  default = {
    "Owner" = "Sudeep"
    "App"   = "Web"
  }
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
  default = "10.10.0.0/24"
  type = string
}