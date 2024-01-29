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

variable "instance_type" {
  default ="t3.small"
  type = string
}