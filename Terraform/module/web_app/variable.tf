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

variable "instance_type" {
  type = string
}


variable "key_name" {
  type = string
}


variable "subnet_id" {
  type = string
}



variable "sg_id" {
  type    = list(string)
  default = []
}


variable "user_data" {
  type = string
}