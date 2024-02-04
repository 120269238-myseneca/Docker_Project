variable "default_tags" {
  default = {}
  type    = map(any)

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
