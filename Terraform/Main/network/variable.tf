variable "default_tags" {
  default = {}
  type    = map(any)

}


# Name prefix
variable "prefix" {
  type = string
}




variable "region" {
  type = string
}

variable "vpc" {
  type = map(string)
}

variable "public_cidr" {
  type = map(string)
}